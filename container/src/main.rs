use container::controllers::health_controller::{ping};
use axum::{routing::get, Router};
use std::net::SocketAddr;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let health_router = Router::new()
        .route("/ping", get(ping));

    let app = Router::new()
        .nest("/health", health_router);

    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));

    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();

    Ok(())
}
