FROM dhi.io/debian-base:trixie-debian13-dev@sha256:f5598e29999cb3f522d47e3885b63883d1f6e755a9957e4c880b35ed4561d65e

LABEL org.opencontainers.image.authors="Florian Stosse <florian.stosse@gmail.com>"
LABEL org.opencontainers.image.created="2026-04-03"
LABEL org.opencontainers.image.description="CppCheck v2.22.0, built using Docker Hardened Debian image"
LABEL org.opencontainers.image.licenses="MIT license"

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
  rm -rf /usr/src/cppcheck


USER nonroot

# Test run
RUN cppcheck -h

ENTRYPOINT [ "cppcheck" ]
