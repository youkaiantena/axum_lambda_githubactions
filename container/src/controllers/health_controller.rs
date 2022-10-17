use axum::{
    // extract::Json,
    http::StatusCode,
    response::IntoResponse,
};
use serde::Serialize;

// #[derive(Deserialize)]
// pub struct Ping {
//     content: String
// }

#[derive(Serialize)]
pub struct Pong {
    message: String
}

pub async fn ping() -> impl IntoResponse {
    (StatusCode::OK, axum::Json(Pong { message: String::from("pongpong") }))
}
