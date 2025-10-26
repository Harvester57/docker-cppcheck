# Source: https://hub.docker.com/_/python
FROM python:3.14.0-alpine@sha256:8373231e1e906ddfb457748bfc032c4c06ada8c759b7b62d9c73ec2a3c56e710

LABEL maintainer="florian.stosse@gmail.com"
LABEL lastupdate="2025-10-26"
LABEL author="Florian Stosse"
LABEL description="CppCheck v2.18.3, built using Alpine image with Python 3.13"
LABEL license="MIT license"

RUN apk update && \
    apk upgrade --available

RUN \
  apk add --no-cache -t .required_apks git make g++ pcre-dev ca-certificates && \
  mkdir -p /usr/src /src

WORKDIR /usr/src

# Cf. https://github.com/danmar/cppcheck/releases
RUN git clone --branch 2.18.3 https://github.com/danmar/cppcheck.git --depth 1

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
ENV PATH="/home/appuser/.local/bin:${PATH}"
USER appuser

# Test run
RUN cppcheck -h

ENTRYPOINT [ "cppcheck" ]
