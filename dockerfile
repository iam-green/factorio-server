FROM ubuntu:latest

LABEL org.opencontainers.image.source="https://github.com/iam-green/factorio-server"

ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=Asia/Seoul \
  UID=1000 \
  GID=1000 \
  DATA_DIRECTORY=/app/data \
  LIBRARY_DIRECTORY=/app/lib \
  FACTORIO_DIRECTORY=/app/data/factorio \
  VERSION=stable \ 
  MAP_NAME=factorio \
  PORT=34197 \
  WHITELIST_ENABLE=false \
  QUALITY_ENABLE=false \
  SPACE_AGE_ENABLE=false

WORKDIR /app

# Install required packages
RUN apt-get update && \
  apt-get install -y --no-install-recommends libc6-dev curl xz-utils sudo && \
  rm -rf /var/lib/apt/lists/*

COPY start.sh .

RUN chmod +x start.sh

EXPOSE 34197/udp

VOLUME ["/app/data", "/app/lib"]

CMD ./start.sh -v $VERSION -m $MAP_NAME -p $PORT \
  -d ${DATA_DIRECTORY} -ld ${LIBRARY_DIRECTORY} \
  $( [ "${WHITELIST_ENABLE}" = "true" ] && echo "-w" || echo "" ) \
  $( [ "${ELEVATED_RAILS_ENABLE}" = "true" ] && echo "-er" || echo "" ) \
  $( [ "${QUALITY_ENABLE}" = "true" ] && echo "-q" || echo "" ) \
  $( [ "${SPACE_AGE_ENABLE}" = "true" ] && echo "-sa" || echo "" )
