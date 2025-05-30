FROM ubuntu:latest

LABEL org.opencontainers.image.source="https://github.com/iam-green/factorio-server"

ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=Asia/Seoul \
  UID=1000 \
  GID=1000 \
  DATA_DIRECTORY=/app/data \
  LIBRARY_DIRECTORY=/app/lib \
  FACTORIO_DIRECTORY=/app/factorio \
  VERSION=stable \
  MAP_NAME=factorio \
  PORT=34197 \
  WHITELIST_ENABLE=false \
  QUALITY_ENABLE=false \
  ELEVATED_RAILS_ENABLE=false \
  SPACE_AGE_ENABLE=false

WORKDIR /app

# Install required packages
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    curl xz-utils sudo ca-certificates libc6 && \
  rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

COPY start.sh .
RUN chmod +x start.sh

EXPOSE 34197/udp

VOLUME ["/app/data", "/app/lib", "/app/factorio"]

ENTRYPOINT ["./entrypoint.sh"]
