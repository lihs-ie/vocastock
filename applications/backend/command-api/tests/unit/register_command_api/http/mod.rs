use command_api::{RenderedResponse, Request};

#[test]
fn http_module_exports_request_and_response_types() {
    let request = Request {
        method: "GET".to_owned(),
        path: "/".to_owned(),
        headers: Default::default(),
        body: String::new(),
    };
    let response = RenderedResponse {
        status: "200 OK",
        content_type: "text/plain; charset=utf-8",
        body: "ok".to_owned(),
    };

    assert_eq!(request.path, "/");
    assert_eq!(response.status, "200 OK");
}
