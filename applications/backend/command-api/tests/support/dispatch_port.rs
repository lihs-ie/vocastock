//! Deterministic in-memory DispatchPort used by command-api unit tests.
//! Lives under `tests/support/` so the production binary never links
//! the synthetic dispatch fixture — the real adapter is
//! `PubSubDispatchPort`.

use std::sync::Mutex;

use command_api::{DispatchPlan, DispatchPort, DispatchRequest};

#[derive(Debug, Default)]
pub struct InMemoryDispatchPort {
    requests: Mutex<Vec<DispatchRequest>>,
}

impl InMemoryDispatchPort {
    pub fn dispatch(&self, request: DispatchRequest) -> DispatchPlan {
        self.requests
            .lock()
            .expect("dispatch port lock poisoned")
            .push(request.clone());

        if request.idempotency_key.contains("dispatch-fail") {
            DispatchPlan::failed()
        } else {
            DispatchPlan::accepted()
        }
    }

    pub fn recorded_requests(&self) -> Vec<DispatchRequest> {
        self.requests
            .lock()
            .expect("dispatch port lock poisoned")
            .clone()
    }
}

impl DispatchPort for InMemoryDispatchPort {
    fn dispatch(&self, request: DispatchRequest) -> DispatchPlan {
        Self::dispatch(self, request)
    }
}
