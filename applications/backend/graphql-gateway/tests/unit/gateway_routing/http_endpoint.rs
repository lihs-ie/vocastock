use graphql_gateway::http_endpoint::{
    request_path, response_for_path, write_response, HttpResponse,
};

#[test]
fn request_path_extracts_target_path() {
    assert_eq!(request_path("GET /readyz HTTP/1.1"), "/readyz");
}

#[test]
fn response_for_path_covers_ready_root_dependency_and_not_found() {
    let ready = response_for_path("/readyz", "/readyz");
    assert_eq!(ready.status, "200 OK");
    assert!(ready.body.contains("graphql-gateway ready"));

    let root = response_for_path("/", "/readyz");
    assert_eq!(root.status, "200 OK");
    assert!(root.body.contains("mutation to command-api"));

    let dependency = response_for_path("/dependencies/firebase", "/readyz");
    assert!(matches!(
        dependency.status,
        "200 OK" | "503 Service Unavailable"
    ));

    let missing = response_for_path("/unknown", "/readyz");
    assert_eq!(missing.status, "404 Not Found");
    assert_eq!(missing.body, "not found");
}

#[test]
fn write_response_renders_http_message() {
    let mut buffer = Vec::new();
    let response = HttpResponse {
        status: "200 OK",
        body: "gateway ready".to_owned(),
    };

    write_response(&mut buffer, &response).expect("response should write");

    let rendered = String::from_utf8(buffer).expect("response should be utf-8");
    assert!(rendered.contains("HTTP/1.1 200 OK"));
    assert!(rendered.contains("Content-Length: 13"));
    assert!(rendered.ends_with("gateway ready"));
}
