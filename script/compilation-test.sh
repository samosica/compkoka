#!/usr/bin/env bash
set -euo pipefail

CURDIR=$(cd "$(dirname "$0")" && pwd)
readonly CURDIR

KOKA_COMPILE_OPTIONS=${KOKA_COMPILE_OPTIONS-}

usage(){
    cat <<EOF
Usage: $0
Compilation test

Options:
    -h, --help          help

Environment variables:
    KOKA_COMPILE_OPTIONS    specify compile options (default: none)
EOF
}

read_args(){
    while [ $# -ge 1 ]; do
        case "$1" in
            -h | --help) usage; exit 0;;
            *) usage; exit 1;;
        esac
    done
}

read_args "$@"
cd "$CURDIR/../src"
# shellcheck disable=SC2086
koka --library --no-debug -v0 $KOKA_COMPILE_OPTIONS ck/*.kk toc.kk
rm -r .koka
