# Source: https://hub.docker.com/_/python
FROM python:3.11.0b5-alpine3.16

LABEL maintainer "florian.stosse@safrangroup.com"
LABEL lastupdate "2022-07-25"
LABEL author "Florian Stosse"
LABEL description "CppCheck v2.8.2, built using Alpine image v3.16"
LABEL license "MIT license"

RUN \
  apk add --no-cache -t .required_apks git make g++ pcre-dev && \
  mkdir -p /usr/src /src

WORKDIR /usr/src

# Cf. https://github.com/danmar/cppcheck/releases
RUN git clone --branch 2.8.2 https://github.com/danmar/cppcheck.git --depth 1

WORKDIR /usr/src/cppcheck

RUN \
  make -j$(getconf _NPROCESSORS_ONLN) MATCHCOMPILER=yes HAVE_RULES=yes CXXFLAGS="-O2 -DNDEBUG --static -Wall -Wno-sign-compare -Wno-unused-function" && \ 
  make install FILESDIR=/cfg && \
  strip /usr/bin/cppcheck && \
  apk del .required_apks && \
  rm -rf /usr/src/cppcheck
  
RUN addgroup -g 666 appuser && \
    mkdir -p /home/appuser && \
    adduser -D -h /home/appuser -u 666 -G appuser appuser && \
    chown -R appuser:appuser /home/appuser
USER appuser
