use std::collections::BTreeMap;
use std::env;
use std::fs;
use std::io::{Read, Write};
use std::net::TcpStream;
use std::path::{Path, PathBuf};
use std::process::{Command, Output};
use std::sync::{Mutex, MutexGuard, OnceLock};
use std::thread::sleep;
use std::time::{Duration, Instant, SystemTime, UNIX_EPOCH};

const QUERY_API_SERVICE: &str = "query-api";
const EMULATOR_CONTAINER_NAME: &str = "vocastock-firebase-emulators";
const DEFAULT_GRAPHQL_GATEWAY_PORT: u16 = 18180;
const DEFAULT_COMMAND_API_PORT: u16 = 18181;
const DEFAULT_QUERY_API_PORT: u16 = 18182;
const DEFAULT_FIRESTORE_PORT: u16 = 18080;
const DEFAULT_STORAGE_PORT: u16 = 19199;
const DEFAULT_AUTH_PORT: u16 = 19099;
const DEFAULT_READINESS_PATH: &str = "/readyz";
const DEFAULT_READY_BUDGET_SECONDS: u64 = 120;
const DEFAULT_EMULATOR_READY_BUDGET_SECONDS: &str = "300";
const FEATURE_REUSE_ENV: &str = "VOCAS_FEATURE_REUSE_RUNNING";
const FEATURE_SKIP_BUILD_ENV: &str = "VOCAS_FEATURE_SKIP_BUILD";
const DEFAULT_EMULATOR_API_KEY: &str = "demo-emulator-api-key";
const DEMO_EMAIL: &str = "demo@vocastock.test";
const DEMO_PASSWORD: &str = "demo1234";
const FREE_EMAIL: &str = "free@vocastock.test";
const FREE_PASSWORD: &str = "free1234";

struct ApplicationPorts {
    gateway: u16,
    command: u16,
    query: u16,
    firestore: u16,
    storage: u16,
    auth: u16,
}

pub struct FeatureRuntime {
    _lock: MutexGuard<'static, ()>,
    repo_root: PathBuf,
    compose_file: PathBuf,
    env_file: PathBuf,
    readiness_path: String,
    query_port: u16,
    firestore_port: u16,
    storage_port: u16,
    auth_port: u16,
    started_emulators: bool,
    started_query_api: bool,
}

#[derive(Clone, Copy, Debug, Default)]
pub struct FeatureRuntimeOptions {
    /// When true, the query-api container runs with
    /// `VOCAS_PRODUCTION_ADAPTERS=true`, switching all read sources to
    /// the Firestore-backed implementations. Detail feature tests need
    /// this; the legacy catalog feature test keeps it off.
    pub production_adapters: bool,
}

pub struct HttpResponse {
    pub status: u16,
    pub body: String,
}

impl FeatureRuntime {
    pub fn start_with_production_adapters() -> Self {
        Self::start_with_options(FeatureRuntimeOptions {
            production_adapters: true,
        })
    }

    fn start_with_options(options: FeatureRuntimeOptions) -> Self {
        let lock = feature_test_lock()
            .lock()
            .expect("feature test lock poisoned");
        let repo_root = repo_root();
        let compose_file = repo_root.join("docker/applications/compose.yaml");
        let readiness_budget = Duration::from_secs(DEFAULT_READY_BUDGET_SECONDS);

        let firebase_env = load_env_file(resolve_env_file(
            repo_root.join("docker/firebase/env/.env"),
            repo_root.join("docker/firebase/env/.env.example"),
        ));
        let firestore_port = port_from_env(
            &firebase_env,
            "FIREBASE_FIRESTORE_PORT",
            DEFAULT_FIRESTORE_PORT,
        );
        let storage_port =
            port_from_env(&firebase_env, "FIREBASE_STORAGE_PORT", DEFAULT_STORAGE_PORT);
        let auth_port = port_from_env(&firebase_env, "FIREBASE_AUTH_PORT", DEFAULT_AUTH_PORT);

        let app_env_file = ensure_application_env_file(&repo_root);
        let app_env = load_env_file(app_env_file.clone());
        let readiness_path = app_env
            .get("VOCAS_READINESS_PATH")
            .cloned()
            .unwrap_or_else(|| DEFAULT_READINESS_PATH.to_owned());

        let gateway_port = next_available_port(port_from_env(
            &app_env,
            "GRAPHQL_GATEWAY_PORT",
            DEFAULT_GRAPHQL_GATEWAY_PORT,
        ));
        let command_port = next_distinct_available_port(
            port_from_env(&app_env, "COMMAND_API_PORT", DEFAULT_COMMAND_API_PORT),
            &[gateway_port],
        );
        let query_port = next_distinct_available_port(
            port_from_env(&app_env, "QUERY_API_PORT", DEFAULT_QUERY_API_PORT),
            &[gateway_port, command_port],
        );

        let ports = ApplicationPorts {
            gateway: gateway_port,
            command: command_port,
            query: query_port,
            firestore: firestore_port,
            storage: storage_port,
            auth: auth_port,
        };

        let env_file = write_application_smoke_env_file(&repo_root, &app_env_file, &ports, options);

        let mut runtime = Self {
            _lock: lock,
            repo_root,
            compose_file,
            env_file,
            readiness_path,
            query_port,
            firestore_port,
            storage_port,
            auth_port,
            started_emulators: false,
            started_query_api: false,
        };

        if !runtime.should_reuse_running_emulators() {
            runtime.start_emulators();
        }
        runtime.seed_emulators();

        runtime.remove_stale_query_api_container();
        runtime.start_query_api();
        runtime.wait_for_query_api_ready(readiness_budget);
        runtime
    }

    pub fn firestore_port(&self) -> u16 {
        self.firestore_port
    }

    pub fn storage_port(&self) -> u16 {
        self.storage_port
    }

    pub fn auth_port(&self) -> u16 {
        self.auth_port
    }

    pub fn get(&self, path: &str, authorization: Option<&str>) -> HttpResponse {
        self.request("GET", path, authorization)
    }

    pub fn post(&self, path: &str, authorization: Option<&str>) -> HttpResponse {
        self.request("POST", path, authorization)
    }

    pub fn request(&self, method: &str, path: &str, authorization: Option<&str>) -> HttpResponse {
        http_request("127.0.0.1", self.query_port, method, path, authorization)
    }

    /// Signs the seeded user in against the Firebase Auth emulator's REST
    /// identity toolkit endpoint and returns the freshly minted ID token.
    /// The emulator ignores the API key but still expects the query
    /// parameter; a sentinel is used.
    pub fn obtain_id_token(&self, email: &str, password: &str) -> String {
        let path = format!(
            "/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={}",
            DEFAULT_EMULATOR_API_KEY
        );
        let body = format!(
            r#"{{"email":"{}","password":"{}","returnSecureToken":true}}"#,
            email, password
        );
        let host_port = format!("127.0.0.1:{}", self.auth_port);
        let response = shared_firestore::execute_post(&host_port, &path, &body)
            .unwrap_or_else(|error| panic!("failed to sign in {email}: {error:?}"));
        let payload: serde_json::Value = serde_json::from_str(&response)
            .unwrap_or_else(|error| panic!("failed to parse sign-in response: {error}"));
        payload
            .get("idToken")
            .and_then(|value| value.as_str())
            .map(|value| value.to_owned())
            .unwrap_or_else(|| panic!("sign-in response missing idToken: {response}"))
    }

    pub fn demo_bearer(&self) -> String {
        format!("Bearer {}", self.obtain_id_token(DEMO_EMAIL, DEMO_PASSWORD))
    }

    pub fn free_bearer(&self) -> String {
        format!("Bearer {}", self.obtain_id_token(FREE_EMAIL, FREE_PASSWORD))
    }

    fn should_reuse_running_emulators(&self) -> bool {
        env_flag(FEATURE_REUSE_ENV)
            || emulator_container_running(&self.repo_root)
            || self.firebase_ports_are_listening()
    }

    fn start_emulators(&mut self) {
        let ready_budget = env::var("VOCAS_EMULATOR_READY_BUDGET_SECONDS")
            .unwrap_or_else(|_| DEFAULT_EMULATOR_READY_BUDGET_SECONDS.to_owned());
        run_command(
            &self.repo_root,
            "bash",
            &[path_arg(
                self.repo_root.join("scripts/firebase/start_emulators.sh"),
            )],
        );
        run_command(
            &self.repo_root,
            "bash",
            &[
                path_arg(self.repo_root.join("scripts/firebase/smoke_local_stack.sh")),
                ready_budget,
            ],
        );
        self.started_emulators = true;
    }

    fn seed_emulators(&self) {
        run_command(
            &self.repo_root,
            "bash",
            &[path_arg(
                self.repo_root.join("scripts/firebase/seed_emulators.sh"),
            )],
        );
    }

    fn remove_stale_query_api_container(&self) {
        run_command(
            &self.repo_root,
            "docker",
            &compose_args(
                &self.env_file,
                &self.compose_file,
                &["rm", "-sf", QUERY_API_SERVICE],
            ),
        );
    }

    fn start_query_api(&mut self) {
        let mut args = compose_args(&self.env_file, &self.compose_file, &["up", "-d"]);
        if !env_flag(FEATURE_SKIP_BUILD_ENV) {
            args.push("--build".to_owned());
        }
        args.push(QUERY_API_SERVICE.to_owned());

        run_command(&self.repo_root, "docker", &args);
        self.started_query_api = true;
    }

    fn wait_for_query_api_ready(&self, budget: Duration) {
        let deadline = Instant::now() + budget;

        loop {
            if let Ok(response) = std::panic::catch_unwind(|| {
                http_request(
                    "127.0.0.1",
                    self.query_port,
                    "GET",
                    self.readiness_path.as_str(),
                    None,
                )
            }) {
                if response.status == 200 {
                    return;
                }
            }

            if Instant::now() >= deadline {
                panic!("query-api readiness did not become healthy in time");
            }

            sleep(Duration::from_secs(2));
        }
    }

    fn firebase_ports_are_listening(&self) -> bool {
        port_is_listening(self.firestore_port)
            && port_is_listening(self.storage_port)
            && port_is_listening(self.auth_port)
    }
}

impl Drop for FeatureRuntime {
    fn drop(&mut self) {
        if self.started_query_api {
            let _ = try_run_command(
                &self.repo_root,
                "docker",
                &compose_args(
                    &self.env_file,
                    &self.compose_file,
                    &["stop", QUERY_API_SERVICE],
                ),
            );
        }

        if self.started_emulators {
            let _ = try_run_command(
                &self.repo_root,
                "bash",
                &[path_arg(
                    self.repo_root.join("scripts/firebase/stop_emulators.sh"),
                )],
            );
        }

        let _ = fs::remove_file(&self.env_file);
    }
}

pub fn assert_contains(haystack: &str, needle: &str, label: &str) {
    assert!(
        haystack.contains(needle),
        "expected {label} to contain {needle}, actual body: {haystack}"
    );
}

pub fn assert_not_contains(haystack: &str, needle: &str, label: &str) {
    assert!(
        !haystack.contains(needle),
        "expected {label} to not contain {needle}, actual body: {haystack}"
    );
}

fn feature_test_lock() -> &'static Mutex<()> {
    static LOCK: OnceLock<Mutex<()>> = OnceLock::new();
    LOCK.get_or_init(|| Mutex::new(()))
}

fn repo_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../..")
        .canonicalize()
        .expect("repo root should resolve")
}

fn resolve_env_file(primary: PathBuf, fallback: PathBuf) -> PathBuf {
    if primary.exists() {
        primary
    } else {
        fallback
    }
}

fn ensure_application_env_file(repo_root: &Path) -> PathBuf {
    let env_file = repo_root.join("docker/applications/env/.env");
    if env_file.exists() {
        return env_file;
    }

    let template = repo_root.join("docker/applications/env/.env.example");
    fs::copy(&template, &env_file).unwrap_or_else(|error| {
        panic!(
            "failed to create application env file from {}: {error}",
            template.display()
        )
    });
    env_file
}

fn load_env_file(path: PathBuf) -> BTreeMap<String, String> {
    let contents = fs::read_to_string(&path)
        .unwrap_or_else(|error| panic!("failed to read env file {}: {error}", path.display()));

    contents
        .lines()
        .filter_map(|line| {
            let trimmed = line.trim();
            if trimmed.is_empty() || trimmed.starts_with('#') {
                return None;
            }

            let (key, value) = trimmed.split_once('=')?;
            Some((key.trim().to_owned(), value.trim().to_owned()))
        })
        .collect()
}

fn port_from_env(env_map: &BTreeMap<String, String>, key: &str, default: u16) -> u16 {
    env_map
        .get(key)
        .and_then(|value| value.parse::<u16>().ok())
        .unwrap_or(default)
}

fn next_available_port(start: u16) -> u16 {
    let mut port = start;
    loop {
        if port_is_available(port) {
            return port;
        }
        port = port.checked_add(1).expect("no available port found");
    }
}

fn next_distinct_available_port(start: u16, reserved: &[u16]) -> u16 {
    let mut port = start;
    loop {
        if !reserved.contains(&port) && port_is_available(port) {
            return port;
        }
        port = port
            .checked_add(1)
            .expect("no distinct available port found");
    }
}

fn port_is_available(port: u16) -> bool {
    !port_is_listening(port)
}

fn port_is_listening(port: u16) -> bool {
    Command::new("lsof")
        .args(["-nP", &format!("-iTCP:{port}"), "-sTCP:LISTEN"])
        .output()
        .map(|output| output.status.success())
        .unwrap_or(false)
}

fn write_application_smoke_env_file(
    repo_root: &Path,
    base_env_file: &Path,
    ports: &ApplicationPorts,
    options: FeatureRuntimeOptions,
) -> PathBuf {
    let logs_dir = repo_root.join(".artifacts/ci/logs");
    fs::create_dir_all(&logs_dir)
        .unwrap_or_else(|error| panic!("failed to create {}: {error}", logs_dir.display()));

    let unique_suffix = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("system clock before unix epoch")
        .as_nanos();
    let env_file = logs_dir.join(format!(
        "query-api-feature-{unique_suffix}-{}.env",
        std::process::id()
    ));

    let mut contents = fs::read_to_string(base_env_file).unwrap_or_else(|error| {
        panic!(
            "failed to read base env file {}: {error}",
            base_env_file.display()
        )
    });
    if !contents.ends_with('\n') {
        contents.push('\n');
    }
    contents.push_str(&format!(
        "\
GRAPHQL_GATEWAY_PORT={}
COMMAND_API_PORT={}
QUERY_API_PORT={}
VOCAS_COMMAND_UPSTREAM_BASE_URL=http://command-api:{}
VOCAS_QUERY_UPSTREAM_BASE_URL=http://query-api:{}
FIRESTORE_EMULATOR_HOST=host.docker.internal:{}
STORAGE_EMULATOR_HOST=host.docker.internal:{}
FIREBASE_AUTH_EMULATOR_HOST=host.docker.internal:{}
",
        ports.gateway,
        ports.command,
        ports.query,
        ports.command,
        ports.query,
        ports.firestore,
        ports.storage,
        ports.auth
    ));

    if options.production_adapters {
        contents.push_str("VOCAS_PRODUCTION_ADAPTERS=true\n");
    }

    fs::write(&env_file, contents)
        .unwrap_or_else(|error| panic!("failed to write {}: {error}", env_file.display()));
    env_file
}

fn emulator_container_running(repo_root: &Path) -> bool {
    let output = try_run_command(
        repo_root,
        "docker",
        &[
            "ps".to_owned(),
            "--format".to_owned(),
            "{{.Names}}".to_owned(),
        ],
    )
    .expect("docker ps should succeed");
    let stdout = String::from_utf8_lossy(&output.stdout);
    stdout
        .lines()
        .any(|line| line.trim() == EMULATOR_CONTAINER_NAME)
}

fn compose_args(env_file: &Path, compose_file: &Path, extra: &[&str]) -> Vec<String> {
    let mut args = vec![
        "compose".to_owned(),
        "--env-file".to_owned(),
        path_arg(env_file),
        "-f".to_owned(),
        path_arg(compose_file),
    ];
    args.extend(extra.iter().map(|arg| (*arg).to_owned()));
    args
}

fn path_arg(path: impl AsRef<Path>) -> String {
    path.as_ref().display().to_string()
}

fn run_command(repo_root: &Path, program: &str, args: &[String]) -> Output {
    let output = try_run_command(repo_root, program, args)
        .unwrap_or_else(|error| panic!("failed to execute {program}: {error}"));

    if output.status.success() {
        return output;
    }

    let stdout = String::from_utf8_lossy(&output.stdout);
    let stderr = String::from_utf8_lossy(&output.stderr);
    panic!(
        "command failed: {} {}\nstdout:\n{}\nstderr:\n{}",
        program,
        args.join(" "),
        stdout,
        stderr
    );
}

fn try_run_command(repo_root: &Path, program: &str, args: &[String]) -> std::io::Result<Output> {
    Command::new(program)
        .args(args)
        .current_dir(repo_root)
        .output()
}

fn env_flag(key: &str) -> bool {
    env::var(key)
        .map(|value| {
            matches!(
                value.trim().to_ascii_lowercase().as_str(),
                "1" | "true" | "yes" | "on"
            )
        })
        .unwrap_or(false)
}

fn http_request(
    host: &str,
    port: u16,
    method: &str,
    path: &str,
    authorization: Option<&str>,
) -> HttpResponse {
    let mut stream = TcpStream::connect((host, port))
        .unwrap_or_else(|error| panic!("failed to connect to {host}:{port}: {error}"));
    stream
        .set_read_timeout(Some(Duration::from_secs(5)))
        .expect("read timeout should be configurable");
    stream
        .set_write_timeout(Some(Duration::from_secs(5)))
        .expect("write timeout should be configurable");

    let mut request =
        format!("{method} {path} HTTP/1.1\r\nHost: {host}:{port}\r\nConnection: close\r\n");
    if let Some(value) = authorization {
        request.push_str(&format!("Authorization: {value}\r\n"));
    }
    request.push_str("\r\n");

    stream
        .write_all(request.as_bytes())
        .expect("request write should succeed");
    stream.flush().expect("request flush should succeed");

    let mut raw_response = String::new();
    stream
        .read_to_string(&mut raw_response)
        .expect("response read should succeed");
    parse_http_response(raw_response)
}

fn parse_http_response(raw_response: String) -> HttpResponse {
    let mut parts = raw_response.splitn(2, "\r\n\r\n");
    let headers = parts.next().unwrap_or_default();
    let body = parts.next().unwrap_or_default().to_owned();
    let status = headers
        .lines()
        .next()
        .and_then(|line| line.split_whitespace().nth(1))
        .and_then(|code| code.parse::<u16>().ok())
        .unwrap_or(0);

    HttpResponse { status, body }
}
