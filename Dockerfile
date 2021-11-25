# Source: https://hub.docker.com/_/alpine/
FROM alpine:3.15.0 AS builder

LABEL maintainer "florian.stosse@safrangroup.com"
LABEL lastupdate "23-11-2021"
LABEL author "Florian Stosse"
LABEL description "CppCheck v2.6, built using Alpine image v3.14.3"
LABEL license "MIT license"

RUN \
  apk add --no-cache -t .required_apks git make g++ pcre-dev && \
  mkdir -p /usr/src /src

WORKDIR /usr/src

# Cf. https://github.com/danmar/cppcheck/releases
RUN	git clone --branch 2.6 https://github.com/danmar/cppcheck.git --depth 1

WORKDIR /usr/src/cppcheck

RUN \
  make install FILESDIR=/cfg HAVE_RULES=yes CXXFLAGS="-O3 -DNDEBUG --static" -j2 && \
  strip /usr/bin/cppcheck

FROM alpine:3.15.0

COPY --from=builder /usr/bin/cppcheck /usr/bin/cppcheck
ENTRYPOINT ["cppcheck"]
