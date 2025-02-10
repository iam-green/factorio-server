FROM ubuntu:20.04
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
  SPACE_AGE_ENABLE=false
RUN mkdir -p /factorio
WORKDIR /factorio
RUN apt-get update -y
RUN apt-get install -y libc6-dev curl sudo
COPY server .
RUN chmod +x server
EXPOSE 34197/udp
CMD ./server -v $VERSION -m $MAP_NAME \
  -d $SERVER_DIRECTORY -ld $LIBRARY_DIRECTORY \
  $( [ "$SPACE_AGE_ENABLE" = "true" ] && echo "-sa" || echo "" ) \
  $( [ "$FORCE_REPLACE" = "true" ] && echo "-f" || echo "" )