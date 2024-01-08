# build image
FROM rust:latest as builder

RUN apt update && apt install -y build-essential gcc-x86-64-linux-gnu clang llvm

WORKDIR /usr/src/app
COPY . .
# Will build and cache the binary and dependent crates in release mode
RUN --mount=type=cache,target=/usr/local/cargo,from=rust:latest,source=/usr/local/cargo \
    --mount=type=cache,target=target \
    RUSTFLAGS="--cfg tokio_unstable" cargo build --release && mv target/release/corrosion ./

# Runtime image
FROM debian:bookworm-slim

RUN apt update && apt install -y sqlite3 && rm -rf /var/lib/apt/lists/*

# Get compiled binaries from builder's cargo install directory
COPY --from=builder /usr/src/app/corrosion /usr/bin/corrosion

# Run the app
CMD ["corrosion", "agent"]
