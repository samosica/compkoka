# syntax=docker/dockerfile:1
FROM ubuntu:noble@sha256:66460d557b25769b102175144d538d88219c077c678a49af4afca6fbfc1b5252
ARG KOKA_VERSION
ENV KOKA_VERSION=${KOKA_VERSION:-latest}
# Without this line, we fail to run programs containing characters out of ASCII
ENV LANG=C.utf8

# npm for madoko and the others for Koka
RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && apt-get install -y npm curl build-essential gcc make tar curl cmake ninja-build pkg-config

RUN npm install -g madoko

RUN --mount=type=bind,source=.,target=/compkoka \
    /compkoka/script/install-koka.sh
