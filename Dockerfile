FROM dhi.io/debian-base:trixie-debian13-dev@sha256:cc4e05ff415ee2d83918f2af45c737983209924ef7362c53f00cfcdaa1c94326

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
