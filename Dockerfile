# syntax=docker/dockerfile:1
FROM ubuntu:noble@sha256:786a8b558f7be160c6c8c4a54f9a57274f3b4fb1491cf65146521ae77ff1dc54
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
