# Source: https://hub.docker.com/_/python
FROM dhi.io/debian-base:trixie-debian13-dev@sha256:0f418f411e5735a418e475f86703b24f1d78c0a386e0a4d9872e8d617ff7a860

LABEL maintainer="florian.stosse@gmail.com"
LABEL lastupdate="2026-04-03"
LABEL author="Florian Stosse"
LABEL description="CppCheck v2.20.1, built using Docker Hardened Debian image"
LABEL license="MIT license"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  cmake \
  git \
  ca-certificates \
  libpcre2-dev \
  libpcre2-8-0 \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src

# Cf. https://github.com/danmar/cppcheck/releases
RUN git clone --branch 2.20.1 https://github.com/danmar/cppcheck.git --depth 1 

WORKDIR /usr/src/cppcheck

RUN git fetch --depth 1 origin pull/8382/head && git checkout FETCH_HEAD # Temporary checkout the PCRE2 support PR 8382 until the PR is merged

RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DHAVE_RULES=ON -DUSE_PCRE2=ON -DDISABLE_PCRE1=ON && \
    cmake --build build && \
    cmake --install build --prefix=/usr/local

USER nonroot

# Test run
RUN cppcheck -h

ENTRYPOINT [ "cppcheck" ]
