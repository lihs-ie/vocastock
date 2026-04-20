use std::io::Write;

const FIREBASE_DEPENDENCIES_PATH: &str = "/dependencies/firebase";

pub struct HttpResponse {
    pub status: &'static str,
    pub body: String,
}

pub fn request_path(request_line: &str) -> &str {
    request_line.split_whitespace().nth(1).unwrap_or("/")
}

pub fn response_for_path(path: &str, readiness_path: &str) -> HttpResponse {
    let sample_route = crate::route_document("{ status }");

    match path {
        path if path == readiness_path => HttpResponse {
            status: "200 OK",
            body: format!("{} ready", crate::SERVICE_NAME),
        },
        FIREBASE_DEPENDENCIES_PATH => firebase_dependency_response(),
        "/" => HttpResponse {
            status: "200 OK",
            body: format!(
                "{} routes mutation to {} and query/subscription to {}",
                crate::SERVICE_NAME,
                crate::COMMAND_UPSTREAM,
                sample_route.upstream_service
            ),
        },
        _ => HttpResponse {
            status: "404 Not Found",
            body: "not found".to_owned(),
        },
    }
}

pub fn write_response(stream: &mut impl Write, response: &HttpResponse) -> std::io::Result<()> {
    write!(
        stream,
        "HTTP/1.1 {}\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length: {}\r\nConnection: close\r\n\r\n{}",
        response.status,
        response.body.len(),
        response.body
    )
}

fn firebase_dependency_response() -> HttpResponse {
    let body = shared_runtime::firebase_dependency_report();
    let status = if shared_runtime::firebase_dependencies_healthy() {
        "200 OK"
    } else {
        "503 Service Unavailable"
    };

    HttpResponse { status, body }
}
