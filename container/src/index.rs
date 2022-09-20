use crate::controllers::health_controller::{ping};
use axum::{routing::get, Router};

pub async fn app() -> Router {
    let health_router: Router = Router::new()
        .route("/ping", get(ping));

    Router::new().nest("/health", health_router)
}
