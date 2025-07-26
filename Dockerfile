# syntax=docker/dockerfile:1
FROM ubuntu:noble@sha256:a08e551cb33850e4740772b38217fc1796a66da2506d312abe51acda354ff061
ARG KOKAVER
ENV KOKAVER=${KOKAVER:-v2.4.2}
# Without this line, we fail to run programs containing characters out of ASCII
ENV LANG=C.utf8

RUN apt-get update \
    && apt-get install -y curl npm \
    && rm -rf /var/lib/apt/lists/*
RUN npm install -g madoko
RUN curl -sSL https://github.com/koka-lang/koka/releases/download/${KOKAVER}/install.sh -o /tmp/install.sh \
    && chmod +x /tmp/install.sh
RUN apt-get update \
    && /tmp/install.sh --minimal \
    && apt-get remove -y --purge --autoremove cmake ninja-build pkg-config \
    && rm -rf /var/lib/apt/lists/*
