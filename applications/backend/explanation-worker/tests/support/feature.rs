use std::collections::BTreeMap;
use std::env;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::{Command, Output};
use std::sync::{Mutex, MutexGuard, OnceLock};
use std::thread::sleep;
use std::time::{Duration, Instant, SystemTime, UNIX_EPOCH};

const EXPLANATION_WORKER_SERVICE: &str = "explanation-worker";
const EMULATOR_CONTAINER_NAME: &str = "vocastock-firebase-emulators";
const DEFAULT_FIRESTORE_PORT: u16 = 18080;
const DEFAULT_STORAGE_PORT: u16 = 19199;
const DEFAULT_AUTH_PORT: u16 = 19099;
const DEFAULT_READY_BUDGET_SECONDS: u64 = 30;
const DEFAULT_EMULATOR_READY_BUDGET_SECONDS: &str = "300";
const FEATURE_REUSE_ENV: &str = "VOCAS_FEATURE_REUSE_RUNNING";
const FEATURE_SKIP_BUILD_ENV: &str = "VOCAS_FEATURE_SKIP_BUILD";
static WORKER_IMAGE_BUILT: OnceLock<()> = OnceLock::new();

pub struct FeatureRuntime {
    _lock: MutexGuard<'static, ()>,
    repo_root: PathBuf,
    compose_file: PathBuf,
    env_file: PathBuf,
    started_emulators: bool,
    started_worker: bool,
}

#[derive(Debug)]
pub struct ValidationResult {
    fields: BTreeMap<String, String>,
}

impl ValidationResult {
    pub fn field(&self, key: &str) -> &str {
        self.fields
            .get(key)
            .map(|value| value.as_str())
            .unwrap_or_else(|| panic!("missing validation field: {key}"))
    }
}

impl FeatureRuntime {
    pub fn start() -> Self {
        let lock = feature_test_lock()
            .lock()
            .unwrap_or_else(|poisoned| poisoned.into_inner());
        let repo_root = repo_root();
        let compose_file = repo_root.join("docker/applications/compose.yaml");

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
        let env_file = write_feature_env_file(
            &repo_root,
            &app_env_file,
            firestore_port,
            storage_port,
            auth_port,
        );

        let mut runtime = Self {
            _lock: lock,
            repo_root,
            compose_file,
            env_file,
            started_emulators: false,
            started_worker: false,
        };

        if !runtime.should_reuse_running_emulators() {
            runtime.start_emulators();
        }

        runtime.build_worker_image();
        runtime.remove_stale_worker_container();
        runtime
    }

    pub fn start_stable_worker(&mut self) {
        let mut args = compose_args(
            &self.env_file,
            &self.compose_file,
            &["up", "-d"],
        );
        if !env_flag(FEATURE_SKIP_BUILD_ENV) {
            args.push("--build".to_owned());
        }
        args.push(EXPLANATION_WORKER_SERVICE.to_owned());

        run_command(&self.repo_root, "docker", &args);
        self.started_worker = true;
    }

    pub fn wait_for_stable_worker(&self) {
        let deadline = Instant::now() + Duration::from_secs(DEFAULT_READY_BUDGET_SECONDS);
        loop {
            if self
                .worker_logs()
                .lines()
                .any(|line| line.contains("entered stable-run mode"))
            {
                return;
            }

            if Instant::now() >= deadline {
                panic!("explanation-worker did not enter stable-run mode in time");
            }

            sleep(Duration::from_secs(1));
        }
    }

    pub fn worker_logs(&self) -> String {
        let output = run_command(
            &self.repo_root,
            "docker",
            &compose_args(
                &self.env_file,
                &self.compose_file,
                &["logs", "--no-color", EXPLANATION_WORKER_SERVICE],
            ),
        );
        String::from_utf8_lossy(&output.stdout).into_owned()
    }

    pub fn run_validation(&self, scenario: &str) -> ValidationResult {
        let output = run_command(
            &self.repo_root,
            "docker",
            &[
                compose_args(
                    &self.env_file,
                    &self.compose_file,
                    &[
                        "run",
                        "--rm",
                        "--no-deps",
                        "-e",
                        "VOCAS_WORKER_RUN_MODE=validate",
                        "-e",
                        &format!("VOCAS_EXPLANATION_WORKFLOW_SCENARIO={scenario}"),
                        EXPLANATION_WORKER_SERVICE,
                    ],
                ),
            ]
            .concat(),
        );
        let stdout = String::from_utf8_lossy(&output.stdout);
        parse_validation_result(stdout.as_ref())
    }

    fn should_reuse_running_emulators(&self) -> bool {
        env_flag(FEATURE_REUSE_ENV) || emulator_container_running(&self.repo_root)
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

    fn remove_stale_worker_container(&self) {
        let _ = try_run_command(
            &self.repo_root,
            "docker",
            &compose_args(
                &self.env_file,
                &self.compose_file,
                &["rm", "-sf", EXPLANATION_WORKER_SERVICE],
            ),
        );
    }

    fn build_worker_image(&self) {
        if env_flag(FEATURE_SKIP_BUILD_ENV) {
            return;
        }
        if worker_image_built() {
            return;
        }

        run_command(
            &self.repo_root,
            "docker",
            &compose_args(
                &self.env_file,
                &self.compose_file,
                &["build", EXPLANATION_WORKER_SERVICE],
            ),
        );
        mark_worker_image_built();
    }
}

impl Drop for FeatureRuntime {
    fn drop(&mut self) {
        if self.started_worker {
            let _ = try_run_command(
                &self.repo_root,
                "docker",
                &compose_args(
                    &self.env_file,
                    &self.compose_file,
                    &["down"],
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

pub fn assert_field(result: &ValidationResult, key: &str, expected: &str) {
    assert_eq!(expected, result.field(key), "unexpected value for {key}");
}

fn feature_test_lock() -> &'static Mutex<()> {
    static LOCK: OnceLock<Mutex<()>> = OnceLock::new();
    LOCK.get_or_init(|| Mutex::new(()))
}

fn worker_image_built() -> bool {
    WORKER_IMAGE_BUILT.get().is_some()
}

fn mark_worker_image_built() {
    let _ = WORKER_IMAGE_BUILT.set(());
}

fn repo_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../../..")
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

fn write_feature_env_file(
    repo_root: &Path,
    base_env_file: &Path,
    firestore_port: u16,
    storage_port: u16,
    auth_port: u16,
) -> PathBuf {
    let logs_dir = repo_root.join(".artifacts/ci/logs");
    fs::create_dir_all(&logs_dir)
        .unwrap_or_else(|error| panic!("failed to create {}: {error}", logs_dir.display()));

    let unique_suffix = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("system clock before unix epoch")
        .as_nanos();
    let env_file = logs_dir.join(format!(
        "explanation-worker-feature-{unique_suffix}-{}.env",
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
VOCAS_WORKER_STABLE_RUN_SECONDS=1
VOCAS_WORKER_POLL_INTERVAL_SECONDS=1
FIRESTORE_EMULATOR_HOST=host.docker.internal:{firestore_port}
STORAGE_EMULATOR_HOST=host.docker.internal:{storage_port}
FIREBASE_AUTH_EMULATOR_HOST=host.docker.internal:{auth_port}
"
    ));

    fs::write(&env_file, contents)
        .unwrap_or_else(|error| panic!("failed to write {}: {error}", env_file.display()));
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

fn parse_validation_result(stdout: &str) -> ValidationResult {
    let line = stdout
        .lines()
        .find(|line| line.starts_with("VOCAS_EXPLANATION_RESULT "))
        .unwrap_or_else(|| panic!("missing validation result in output:\n{stdout}"));

    let mut fields = BTreeMap::new();
    for token in line.split_whitespace().skip(1) {
        let (key, value) = token
            .split_once('=')
            .unwrap_or_else(|| panic!("unexpected validation token: {token}"));
        fields.insert(key.to_owned(), value.to_owned());
    }

    ValidationResult { fields }
}
