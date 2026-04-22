use std::env;
use std::io::BufReader;
use std::net::{TcpListener, TcpStream};

const DEFAULT_HOST: &str = "0.0.0.0";
const DEFAULT_PORT: u16 = 18182;
const DEFAULT_READINESS_PATH: &str = "/readyz";

fn main() {
    let host = env::var("VOCAS_SERVICE_HOST").unwrap_or_else(|_| DEFAULT_HOST.to_owned());
    let port = env::var("VOCAS_SERVICE_PORT")
        .ok()
        .and_then(|value| value.parse::<u16>().ok())
        .unwrap_or(DEFAULT_PORT);
    let readiness_path =
        env::var("VOCAS_READINESS_PATH").unwrap_or_else(|_| DEFAULT_READINESS_PATH.to_owned());

    let listener = TcpListener::bind((host.as_str(), port)).unwrap_or_else(|error| {
        panic!(
            "{} failed to bind on {}:{}: {}",
            query_api::SERVICE_NAME,
            host,
            port,
            error
        )
    });

    println!(
        "{} listening on {}:{} with readiness {}",
        query_api::SERVICE_NAME,
        host,
        port,
        readiness_path
    );

    let verifier = query_api::StubTokenVerifier;
    let catalog_source: Box<dyn query_api::CatalogProjectionSource> =
        match query_api::FirestoreCatalogProjectionSource::from_env() {
            Some(firestore) => {
                println!(
                    "{} reading catalog from Firestore emulator (FIRESTORE_EMULATOR_HOST set)",
                    query_api::SERVICE_NAME,
                );
                Box::new(firestore)
            }
            None => {
                println!(
                    "{} reading catalog from the in-memory fixture (set FIRESTORE_EMULATOR_HOST to switch)",
                    query_api::SERVICE_NAME,
                );
                Box::new(query_api::InMemoryCatalogProjectionSource::default())
            }
        };

    let vocabulary_expression_detail_source: Option<
        Box<dyn query_api::VocabularyExpressionDetailSource>,
    > = query_api::FirestoreVocabularyExpressionDetailSource::from_env()
        .map(|source| Box::new(source) as Box<_>);
    let explanation_detail_source: Option<Box<dyn query_api::ExplanationDetailSource>> =
        query_api::FirestoreExplanationDetailSource::from_env()
            .map(|source| Box::new(source) as Box<_>);
    let image_detail_source: Option<Box<dyn query_api::ImageDetailSource>> =
        query_api::FirestoreImageDetailSource::from_env().map(|source| Box::new(source) as Box<_>);
    let subscription_status_source: Option<Box<dyn query_api::SubscriptionStatusSource>> =
        query_api::FirestoreSubscriptionStatusSource::from_env()
            .map(|source| Box::new(source) as Box<_>);

    if vocabulary_expression_detail_source.is_some() {
        println!(
            "{} detail readers wired to Firestore emulator",
            query_api::SERVICE_NAME,
        );
    } else {
        println!(
            "{} detail readers unavailable (set VOCAS_PRODUCTION_ADAPTERS=true + FIRESTORE_EMULATOR_HOST to enable)",
            query_api::SERVICE_NAME,
        );
    }

    for stream in listener.incoming() {
        match stream {
            Ok(stream) => {
                let ctx = query_api::RouteContext {
                    readiness_path: readiness_path.as_str(),
                    verifier: &verifier,
                    catalog_source: catalog_source.as_ref(),
                    vocabulary_expression_detail_source: vocabulary_expression_detail_source
                        .as_deref(),
                    explanation_detail_source: explanation_detail_source.as_deref(),
                    image_detail_source: image_detail_source.as_deref(),
                    subscription_status_source: subscription_status_source.as_deref(),
                };
                if let Err(error) = handle_connection(stream, &ctx) {
                    eprintln!(
                        "{} request handling error: {}",
                        query_api::SERVICE_NAME,
                        error
                    );
                }
            }
            Err(error) => {
                eprintln!("{} accept error: {}", query_api::SERVICE_NAME, error);
            }
        }
    }
}

fn handle_connection(
    mut stream: TcpStream,
    ctx: &query_api::RouteContext<'_>,
) -> std::io::Result<()> {
    let request = {
        let mut reader = BufReader::new(&mut stream);
        query_api::read_request(&mut reader)?
    };
    let response = query_api::route_request(&request, ctx);

    query_api::write_response(&mut stream, &response)
}
