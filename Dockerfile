# Source: https://hub.docker.com/_/python
FROM python:3.13.0-alpine3.20

LABEL maintainer "florian.stosse@gmail.com"
LABEL lastupdate "2024-10-27"
LABEL author "Florian Stosse"
LABEL description "CppCheck v2.16.0, built using Alpine image v3.20 with Python 3.12.6"
LABEL license "MIT license"

RUN \
  apk add --no-cache -t .required_apks git make g++ pcre-dev && \
  mkdir -p /usr/src /src

WORKDIR /usr/src

# Cf. https://github.com/danmar/cppcheck/releases
RUN git clone --branch 2.16.0 https://github.com/danmar/cppcheck.git --depth 1

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
