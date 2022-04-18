# Source: https://hub.docker.com/_/alpine/
FROM alpine:3.15.4

LABEL maintainer "florian.stosse@safrangroup.com"
LABEL lastupdate "2022-04-18"
LABEL author "Florian Stosse"
LABEL description "CppCheck v2.7.5, built using Alpine image v3.15.4"
LABEL license "MIT license"

RUN \
  apk add --no-cache -t .required_apks git make g++ pcre-dev && \
  mkdir -p /usr/src /src

WORKDIR /usr/src

# Cf. https://github.com/danmar/cppcheck/releases
RUN git clone --branch 2.7.5 https://github.com/danmar/cppcheck.git --depth 1

WORKDIR /usr/src/cppcheck

RUN \
  make install FILESDIR=/cfg HAVE_RULES=yes CXXFLAGS="-O2 -DNDEBUG --static" && \
  strip /usr/bin/cppcheck && \
  apk del .required_apks && \
  rm -rf /usr/src/cppcheck
  
RUN addgroup -g 999 appuser && \
    mkdir -p /home/appuser && \
    adduser -h /home/appuser -u 999 -G appuser appuser && \
    chown -R appuser:appuser /home/appuser
USER appuser
