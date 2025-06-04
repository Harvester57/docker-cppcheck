# Source: https://hub.docker.com/_/python
FROM python:3.13.4-alpine3.21@sha256:5422fa20201241110c0a2a970a99740a5cb4095164b8c8f901a83dc4164d32fa

LABEL maintainer="florian.stosse@gmail.com"
LABEL lastupdate="2025-04-27"
LABEL author="Florian Stosse"
LABEL description="CppCheck v2.17.1, built using Alpine image v3.21 with Python 3.13.3"
LABEL license="MIT license"

RUN apk update && \
    apk upgrade --available

RUN \
  apk add --no-cache -t .required_apks git make g++ pcre-dev ca-certificates && \
  mkdir -p /usr/src /src

WORKDIR /usr/src

# Cf. https://github.com/danmar/cppcheck/releases
RUN git clone --branch 2.17.1 https://github.com/danmar/cppcheck.git --depth 1

WORKDIR /usr/src/cppcheck

RUN \
  make -j$(getconf _NPROCESSORS_ONLN) MATCHCOMPILER=yes FILESDIR=/usr/share/cppcheck HAVE_RULES=yes CXXFLAGS="-O2 -DNDEBUG -Wall -Wno-sign-compare -Wno-unused-function" && \ 
  make install FILESDIR=/cfg && \
  strip /usr/bin/cppcheck && \
  apk del .required_apks && \
  rm -rf /usr/src/cppcheck
  
RUN addgroup -g 666 appuser && \
    mkdir -p /home/appuser && \
    adduser -D -h /home/appuser -u 666 -G appuser appuser && \
    chown -R appuser:appuser /home/appuser
USER appuser
