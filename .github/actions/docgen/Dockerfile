# syntax=docker/dockerfile:1
FROM ubuntu:jammy-20231211.1@sha256:bbf3d1baa208b7649d1d0264ef7d522e1dc0deeeaaf6085bf8e4618867f03494
ARG KOKAVER
ENV KOKAVER ${KOKAVER:-v2.4.2}

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
