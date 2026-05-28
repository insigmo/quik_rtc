FROM golang:trixie AS builder

WORKDIR /src
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64

RUN git clone --depth=1 https://github.com/openlibrecommunity/olcrtc . \
    && go mod download \
    && go build -o /out/olcrtc-server ./cmd/olcrtc

FROM debian:trixie-slim

ENV TZ=Etc/UTC DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /out/olcrtc-server /app/olcrtc-server

EXPOSE 8998
