# Source: https://hub.docker.com/_/python
FROM dhi.io/debian-base:trixie-debian13-dev@sha256:f18a569e4ed47f382ef551fac547bddcaa050f74565dfe35ba73958810fb8525

LABEL maintainer="florian.stosse@gmail.com"
LABEL lastupdate="2026-04-03"
LABEL author="Florian Stosse"
LABEL description="CppCheck v2.22.0, built using Docker Hardened Debian image"
LABEL license="MIT license"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  cmake \
  git \
  ca-certificates \
  libpcre2-dev \
  libpcre2-8-0 \
  python3 \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src

# Cf. https://github.com/danmar/cppcheck/releases
RUN git clone --branch 2.22.0 https://github.com/danmar/cppcheck.git --depth 1 

WORKDIR /usr/src/cppcheck

RUN \
  make -j$(getconf _NPROCESSORS_ONLN) MATCHCOMPILER=yes FILESDIR=/usr/share/cppcheck HAVE_RULES=yes CXXFLAGS="-O2 -DNDEBUG -Wall -Wno-sign-compare -Wno-unused-function" && \ 
  make install FILESDIR=/cfg && \
  strip /usr/bin/cppcheck && \
  apk del .required_apks && \
  apk add libstdc++ libgcc && \
  rm -rf /usr/src/cppcheck
  

USER nonroot

# Test run
RUN cppcheck -h

ENTRYPOINT [ "cppcheck" ]
