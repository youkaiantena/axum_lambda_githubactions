FROM rust:1.64-buster as build

RUN apt update -y && apt install python3-pip -y && pip3 install cargo-zigbuild==0.14.0

RUN rustup update && rustup target add aarch64-unknown-linux-musl

WORKDIR /app
ENV CARGO_TARGET_DIR=/tmp/target
ENV PKG_CONFIG_ALLOW_CROSS=1
COPY Cargo.toml Cargo.toml
COPY Cargo.lock Cargo.lock
RUN mkdir -p src/

RUN echo "fn main() {println!(\"if you see this, the build broke\")}" >src/main.rs
RUN echo "//lib" > src/lib.rs
RUN cargo zigbuild --release --target aarch64-unknown-linux-musl
RUN rm -f /tmp/target/release/deps/app*

COPY src src
RUN touch src/lib.rs && cargo zigbuild --release --target aarch64-unknown-linux-musl

FROM public.ecr.aws/lambda/provided:al2
COPY --from=build /tmp/target/aarch64-unknown-linux-musl/release/container ${LAMBDA_RUNTIME_DIR}/bootstrap
CMD [ "lambda-handler" ]
