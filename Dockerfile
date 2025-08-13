# Source: https://hub.docker.com/_/python
FROM python:3.13-alpine@sha256:97990f8cff85f0a25eef434f77f265d63d3767d15f59bfd19860de0b7f702ead

LABEL maintainer="florian.stosse@gmail.com"
LABEL lastupdate="2025-07-20"
LABEL author="Florian Stosse"
LABEL description="CppCheck v2.18.0, built using Alpine image with Python 3.13"
LABEL license="MIT license"

RUN apk update && \
    apk upgrade --available

RUN \
  apk add --no-cache -t .required_apks git make g++ pcre-dev ca-certificates && \
  mkdir -p /usr/src /src

WORKDIR /usr/src

# Cf. https://github.com/danmar/cppcheck/releases
RUN git clone --branch 2.18.0 https://github.com/danmar/cppcheck.git --depth 1

WORKDIR /usr/src/cppcheck

RUN \
  make -j$(getconf _NPROCESSORS_ONLN) MATCHCOMPILER=yes FILESDIR=/usr/share/cppcheck HAVE_RULES=yes CXXFLAGS="-O2 -DNDEBUG -Wall -Wno-sign-compare -Wno-unused-function" && \ 
  make install FILESDIR=/cfg && \
  strip /usr/bin/cppcheck && \
  apk del .required_apks && \
  apk add libstdc++ libgcc && \
  rm -rf /usr/src/cppcheck
  
RUN addgroup -g 666 appuser && \
    mkdir -p /home/appuser && \
    adduser -D -h /home/appuser -u 666 -G appuser appuser && \
    chown -R appuser:appuser /home/appuser
USER appuser

# Test run
RUN cppcheck -h
