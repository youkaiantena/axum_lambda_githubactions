FROM --platform=linux/amd64 rust:1.64.0-slim-bullseye as build

RUN apt-get -y update && apt-get -y install musl-tools libssl-dev pkg-config build-essential lld clang python3-pip && pip3 install cargo-zigbuild

RUN rustup update && rustup target add aarch64-unknown-linux-musl

WORKDIR /app
ENV CARGO_TARGET_DIR=/tmp/target
ENV PKG_CONFIG_ALLOW_CROSS=1
COPY .cargo .cargo
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
