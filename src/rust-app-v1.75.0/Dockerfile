FROM rust:1.75-slim as builder
WORKDIR /usr/src/app
COPY . .
RUN cargo build --release
FROM debian:bookworm-slim
COPY --from=builder /usr/src/app/target/release/rust-postgres-app /usr/local/bin/
EXPOSE 5300
CMD ["rust-postgres-app"]
