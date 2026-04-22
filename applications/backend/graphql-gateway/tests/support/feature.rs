use std::collections::BTreeMap;
use std::env;
use std::fs;
use std::io::{BufRead, BufReader, Read, Write};
use std::net::{TcpListener, TcpStream};
use std::path::{Path, PathBuf};
use std::process::{Command, Output};
use std::sync::{mpsc, Mutex, MutexGuard, OnceLock};
use std::thread::{self, sleep, JoinHandle};
use std::time::{Duration, Instant, SystemTime, UNIX_EPOCH};

use serde_json::Value;

const GRAPHQL_GATEWAY_SERVICE: &str = "graphql-gateway";
const COMMAND_API_SERVICE: &str = "command-api";
const QUERY_API_SERVICE: &str = "query-api";
const EMULATOR_CONTAINER_NAME: &str = "vocastock-firebase-emulators";
const DEFAULT_GRAPHQL_GATEWAY_PORT: u16 = 18180;
const DEFAULT_COMMAND_API_PORT: u16 = 18181;
const DEFAULT_QUERY_API_PORT: u16 = 18182;
const DEFAULT_FIRESTORE_PORT: u16 = 18080;
const DEFAULT_STORAGE_PORT: u16 = 19199;
const DEFAULT_AUTH_PORT: u16 = 19099;
const DEFAULT_PUBSUB_PORT: u16 = 18085;
const DEFAULT_EMULATOR_API_KEY: &str = "demo-emulator-api-key";
const DEMO_EMAIL: &str = "demo@vocastock.test";
const DEMO_PASSWORD: &str = "demo1234";
const FREE_EMAIL: &str = "free@vocastock.test";
const FREE_PASSWORD: &str = "free1234";
const DEFAULT_READINESS_PATH: &str = "/readyz";
const DEFAULT_READY_BUDGET_SECONDS: u64 = 120;
const DEFAULT_EMULATOR_READY_BUDGET_SECONDS: &str = "300";
const FEATURE_REUSE_ENV: &str = "VOCAS_FEATURE_REUSE_RUNNING";
const FEATURE_SKIP_BUILD_ENV: &str = "VOCAS_FEATURE_SKIP_BUILD";

struct ApplicationPorts {
    gateway: u16,
    command: u16,
    query: u16,
    firestore: u16,
    storage: u16,
    auth: u16,
    pubsub: u16,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct FeatureRuntimeOptions {
    pub command_upstream_base_url: Option<String>,
    pub query_upstream_base_url: Option<String>,
}

pub struct FeatureRuntime {
    _lock: MutexGuard<'static, ()>,
    repo_root: PathBuf,
    compose_file: PathBuf,
    env_file: PathBuf,
    readiness_path: String,
    gateway_port: u16,
    firestore_port: u16,
    storage_port: u16,
    auth_port: u16,
    started_emulators: bool,
    started_services: bool,
}

pub struct HttpResponse {
    pub status: u16,
    pub body: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct CapturedRequest {
    pub method: String,
    pub path: String,
    pub headers: BTreeMap<String, String>,
    pub body: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct StubResponse {
    pub status: u16,
    pub content_type: String,
    pub body: String,
}

pub struct StubServer {
    base_url: String,
    captured_request: mpsc::Receiver<CapturedRequest>,
    handle: Option<JoinHandle<()>>,
}

impl FeatureRuntime {
    pub fn start() -> Self {
        Self::start_with_options(FeatureRuntimeOptions::default())
    }

    pub fn start_with_options(options: FeatureRuntimeOptions) -> Self {
        let lock = feature_test_lock()
            .lock()
            .unwrap_or_else(|poisoned| poisoned.into_inner());
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
        let pubsub_port = port_from_env(&firebase_env, "FIREBASE_PUBSUB_PORT", DEFAULT_PUBSUB_PORT);

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
            pubsub: pubsub_port,
        };

        let env_file =
            write_application_smoke_env_file(&repo_root, &app_env_file, &ports, &options);

        let mut runtime = Self {
            _lock: lock,
            repo_root,
            compose_file,
            env_file,
            readiness_path,
            gateway_port,
            firestore_port,
            storage_port,
            auth_port,
            started_emulators: false,
            started_services: false,
        };

        if !runtime.should_reuse_running_emulators() {
            runtime.start_emulators();
        }
        runtime.seed_emulators();

        runtime.remove_stale_application_containers();
        runtime.start_services();
        runtime.wait_for_gateway_ready(readiness_budget);
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

    /// Signs the seeded demo user in through the Firebase Auth emulator
    /// and returns a `Bearer <id_token>` string ready for HTTP request
    /// headers.
    pub fn demo_bearer(&self) -> String {
        self.obtain_bearer(DEMO_EMAIL, DEMO_PASSWORD)
    }

    pub fn free_bearer(&self) -> String {
        self.obtain_bearer(FREE_EMAIL, FREE_PASSWORD)
    }

    fn obtain_bearer(&self, email: &str, password: &str) -> String {
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
        let payload: Value = serde_json::from_str(&response)
            .unwrap_or_else(|error| panic!("failed to parse sign-in response: {error}"));
        let token = payload
            .get("idToken")
            .and_then(|value| value.as_str())
            .unwrap_or_else(|| panic!("sign-in response missing idToken: {response}"));
        format!("Bearer {token}")
    }

    pub fn get(&self, path: &str) -> HttpResponse {
        self.request("GET", path, None, None, None)
    }

    pub fn post_json(
        &self,
        path: &str,
        authorization: Option<&str>,
        correlation: Option<&str>,
        payload: &Value,
    ) -> HttpResponse {
        let body = payload.to_string();
        self.request(
            "POST",
            path,
            authorization,
            correlation,
            Some(body.as_str()),
        )
    }

    fn request(
        &self,
        method: &str,
        path: &str,
        authorization: Option<&str>,
        correlation: Option<&str>,
        body: Option<&str>,
    ) -> HttpResponse {
        let mut headers = BTreeMap::new();
        if let Some(authorization) = authorization {
            headers.insert("authorization".to_owned(), authorization.to_owned());
        }
        if let Some(correlation) = correlation {
            headers.insert("x-request-correlation".to_owned(), correlation.to_owned());
        }

        http_request("127.0.0.1", self.gateway_port, method, path, &headers, body)
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

    fn remove_stale_application_containers(&self) {
        let args = compose_args(
            &self.env_file,
            &self.compose_file,
            &[
                "rm",
                "-sf",
                GRAPHQL_GATEWAY_SERVICE,
                COMMAND_API_SERVICE,
                QUERY_API_SERVICE,
            ],
        );
        let output = try_run_command(&self.repo_root, "docker", &args)
            .unwrap_or_else(|error| panic!("failed to execute docker: {error}"));
        if output.status.success() {
            return;
        }

        let stderr = String::from_utf8_lossy(&output.stderr);
        if stderr.contains("removal of container") && stderr.contains("already in progress") {
            return;
        }

        let stdout = String::from_utf8_lossy(&output.stdout);
        panic!(
            "command failed: docker {}\nstdout:\n{}\nstderr:\n{}",
            args.join(" "),
            stdout,
            stderr
        );
    }

    fn start_services(&mut self) {
        let mut args = compose_args(&self.env_file, &self.compose_file, &["up", "-d"]);
        if !env_flag(FEATURE_SKIP_BUILD_ENV) {
            args.push("--build".to_owned());
        }
        args.push(GRAPHQL_GATEWAY_SERVICE.to_owned());
        args.push(COMMAND_API_SERVICE.to_owned());
        args.push(QUERY_API_SERVICE.to_owned());

        run_command(&self.repo_root, "docker", &args);
        self.started_services = true;
    }

    fn wait_for_gateway_ready(&self, budget: Duration) {
        let deadline = Instant::now() + budget;

        loop {
            if let Ok(response) =
                std::panic::catch_unwind(|| self.get(self.readiness_path.as_str()))
            {
                if response.status == 200 {
                    return;
                }
            }

            if Instant::now() >= deadline {
                panic!("graphql-gateway readiness did not become healthy in time");
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
        if self.started_services {
            let _ = try_run_command(
                &self.repo_root,
                "docker",
                &compose_args(
                    &self.env_file,
                    &self.compose_file,
                    &["down", "--remove-orphans"],
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

impl StubResponse {
    pub fn json(status: u16, body: Value) -> Self {
        Self {
            status,
            content_type: "application/json".to_owned(),
            body: body.to_string(),
        }
    }
}

impl StubServer {
    pub fn start(response: StubResponse) -> Self {
        // Containers reach the host through host-gateway on Linux runners, so loopback-only
        // listeners are not visible from docker compose services during feature tests.
        let listener = TcpListener::bind(("0.0.0.0", 0)).expect("stub listener should bind");
        let port = listener
            .local_addr()
            .expect("listener address should resolve")
            .port();
        let (sender, receiver) = mpsc::channel();

        let handle = thread::spawn(move || {
            let (mut stream, _) = listener.accept().expect("stub request should arrive");
            let captured_request = read_incoming_request(&mut stream);
            sender
                .send(captured_request)
                .expect("captured request should send");
            write!(
                stream,
                "HTTP/1.1 {} {}\r\nContent-Type: {}\r\nContent-Length: {}\r\nConnection: close\r\n\r\n{}",
                response.status,
                status_reason(response.status),
                response.content_type,
                response.body.len(),
                response.body
            )
            .expect("stub response should write");
            stream.flush().expect("stub response should flush");
        });

        Self {
            base_url: format!("http://host.docker.internal:{port}"),
            captured_request: receiver,
            handle: Some(handle),
        }
    }

    pub fn base_url(&self) -> String {
        self.base_url.clone()
    }

    pub fn capture(mut self) -> CapturedRequest {
        let captured_request = self
            .captured_request
            .recv_timeout(Duration::from_secs(10))
            .expect("stub request should be captured");
        if let Some(handle) = self.handle.take() {
            handle.join().expect("stub thread should finish");
        }
        captured_request
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
        "expected {label} to omit {needle}, actual body: {haystack}"
    );
}

pub fn unused_host_base_url() -> String {
    let listener = TcpListener::bind(("0.0.0.0", 0)).expect("ephemeral port should bind");
    let port = listener
        .local_addr()
        .expect("listener address should resolve")
        .port();
    drop(listener);
    format!("http://host.docker.internal:{port}")
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
    options: &FeatureRuntimeOptions,
) -> PathBuf {
    let logs_dir = repo_root.join(".artifacts/ci/logs");
    fs::create_dir_all(&logs_dir)
        .unwrap_or_else(|error| panic!("failed to create {}: {error}", logs_dir.display()));

    let unique_suffix = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("system clock before unix epoch")
        .as_nanos();
    let env_file = logs_dir.join(format!(
        "graphql-gateway-feature-{unique_suffix}-{}.env",
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
COMPOSE_PROJECT_NAME=vocastock-graphql-gateway-feature-{}-{}
GRAPHQL_GATEWAY_PORT={}
COMMAND_API_PORT={}
QUERY_API_PORT={}
VOCAS_COMMAND_UPSTREAM_BASE_URL={}
VOCAS_QUERY_UPSTREAM_BASE_URL={}
FIRESTORE_EMULATOR_HOST=host.docker.internal:{}
STORAGE_EMULATOR_HOST=host.docker.internal:{}
FIREBASE_AUTH_EMULATOR_HOST=host.docker.internal:{}
PUBSUB_EMULATOR_HOST=host.docker.internal:{}
VOCAS_PRODUCTION_ADAPTERS=true
",
        unique_suffix,
        std::process::id(),
        ports.gateway,
        ports.command,
        ports.query,
        options
            .command_upstream_base_url
            .as_deref()
            .unwrap_or(&format!("http://command-api:{}", ports.command)),
        options
            .query_upstream_base_url
            .as_deref()
            .unwrap_or(&format!("http://query-api:{}", ports.query)),
        ports.firestore,
        ports.storage,
        ports.auth,
        ports.pubsub,
    ));

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
    headers: &BTreeMap<String, String>,
    body: Option<&str>,
) -> HttpResponse {
    let mut stream = TcpStream::connect((host, port))
        .unwrap_or_else(|error| panic!("failed to connect to {host}:{port}: {error}"));
    stream
        .set_read_timeout(Some(Duration::from_secs(5)))
        .expect("read timeout should be configurable");
    stream
        .set_write_timeout(Some(Duration::from_secs(5)))
        .expect("write timeout should be configurable");

    let mut request = format!("{method} {path} HTTP/1.1\r\nHost: {host}:{port}\r\n");
    for (header_name, header_value) in headers {
        request.push_str(&format!("{header_name}: {header_value}\r\n"));
    }
    if let Some(body) = body {
        request.push_str("Content-Type: application/json\r\n");
        request.push_str(&format!("Content-Length: {}\r\n", body.len()));
    }
    request.push_str("Connection: close\r\n\r\n");
    if let Some(body) = body {
        request.push_str(body);
    }

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
    let (head, body) = raw_response
        .split_once("\r\n\r\n")
        .unwrap_or((raw_response.as_str(), ""));
    let mut lines = head.lines();
    let status = lines
        .next()
        .and_then(|status_line| status_line.split_whitespace().nth(1))
        .and_then(|status| status.parse::<u16>().ok())
        .unwrap_or(500);

    let mut headers = BTreeMap::new();
    for line in lines {
        if let Some((name, value)) = line.split_once(':') {
            headers.insert(name.trim().to_ascii_lowercase(), value.trim().to_owned());
        }
    }

    HttpResponse {
        status,
        body: body.to_owned(),
    }
}

fn read_incoming_request(stream: &mut TcpStream) -> CapturedRequest {
    let mut reader = BufReader::new(stream);
    let mut request_line = String::new();
    let mut headers = BTreeMap::new();
    reader
        .read_line(&mut request_line)
        .expect("request line should read");

    loop {
        let mut header_line = String::new();
        let bytes_read = reader
            .read_line(&mut header_line)
            .expect("header line should read");
        if bytes_read == 0 || header_line == "\r\n" {
            break;
        }

        if let Some((name, value)) = header_line.split_once(':') {
            headers.insert(name.trim().to_ascii_lowercase(), value.trim().to_owned());
        }
    }

    let content_length = headers
        .get("content-length")
        .and_then(|value| value.parse::<usize>().ok())
        .unwrap_or(0);
    let mut body_bytes = vec![0; content_length];
    if content_length > 0 {
        reader
            .read_exact(&mut body_bytes)
            .expect("body should read exactly");
    }

    CapturedRequest {
        method: request_line
            .split_whitespace()
            .next()
            .unwrap_or("GET")
            .to_owned(),
        path: request_line
            .split_whitespace()
            .nth(1)
            .unwrap_or("/")
            .to_owned(),
        headers,
        body: String::from_utf8_lossy(&body_bytes).into_owned(),
    }
}

fn status_reason(status: u16) -> &'static str {
    match status {
        200 => "OK",
        202 => "Accepted",
        400 => "Bad Request",
        401 => "Unauthorized",
        403 => "Forbidden",
        409 => "Conflict",
        502 => "Bad Gateway",
        503 => "Service Unavailable",
        _ => "OK",
    }
}
