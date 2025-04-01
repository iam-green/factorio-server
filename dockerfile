FROM ubuntu:latest
LABEL maintainer="iam-green <yundohyun050121@gmail.com>"
LABEL org.opencontainers.image.source https://github.com/iam-green/factorio-server
ARG DEBIAN_FRONTEND=noninteractive
ENV UID=1000 \
  GID=1000 \
  TZ=Asia/Seoul \
  SERVER_DIRECTORY=/factorio/data \
  LIBRARY_DIRECTORY=/factorio/lib \
  FORCE_REPLACE=false \
  VERSION=stable \ 
  MAP_NAME=factorio \
  ELEVATED_RAILS_ENABLE=false \
  QUALITY_ENABLE=false \
  SPACE_AGE_ENABLE=false \
  PORT=34197 \
  WHITELIST_ENABLE=false
RUN mkdir -p /factorio
WORKDIR /factorio
RUN apt-get update -y
RUN apt-get install -y libc6-dev curl sudo xz-utils
COPY server .
RUN chmod +x server
EXPOSE 34197/udp
VOLUME ["/factorio/data", "/factorio/lib"]
CMD ./server -v $VERSION -m $MAP_NAME -p $PORT \
  -d $SERVER_DIRECTORY -ld $LIBRARY_DIRECTORY \
  $( [ "$ELEVATED_RAILS_ENABLE" = "true" ] && echo "-er" || echo "" ) \
  $( [ "$QUALITY_ENABLE" = "true" ] && echo "-q" || echo "" ) \
  $( [ "$SPACE_AGE_ENABLE" = "true" ] && echo "-sa" || echo "" ) \
  $( [ "$FORCE_REPLACE" = "true" ] && echo "-f" || echo "" ) \
  $( [ "$WHITELIST_ENABLE" = "true" ] && echo "-w" || echo "" )
