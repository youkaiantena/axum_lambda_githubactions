FROM rust:1.64-bullseye as build

# RUN apt-get update && \
#     TZ=Asia/Tokyo apt-get install -y tzdata && \
#     apt-get install -y \
#     build-essential \
#     git \
#     clang \
#     lld \
#     cmake \
#     libxxhash-dev \
#     zlib1g-dev \
#     pkg-config && \
#     apt-get install -y libstdc++-10-dev

# RUN git clone https://github.com/rui314/mold.git && \
#     mkdir mold/build && \
#     cd mold/build && \
#     git checkout v1.5.1 && \
#     ../install-build-deps.sh && \
#     cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=c++ .. && \
#     cmake --build . -j $(nproc) && \
#     sudo cmake --install .
RUN apt-get -y update && apt-get -y install libssl-dev pkg-config build-essential gcc-aarch64-linux-gnu

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
RUN cargo build --release --target aarch64-unknown-linux-musl
RUN rm -f /tmp/target/release/deps/app*

COPY src src
RUN touch src/lib.rs && cargo build --release --target aarch64-unknown-linux-musl

FROM public.ecr.aws/lambda/provided:al2
COPY --from=build /tmp/target/aarch64-unknown-linux-musl/release/container ${LAMBDA_RUNTIME_DIR}/bootstrap
CMD [ "lambda-handler" ]
