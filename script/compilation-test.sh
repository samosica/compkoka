#!/usr/bin/env bash
set -euo pipefail
# TODO: コンパイラのバージョンとオプションを指定できるようにする

CURDIR=$(cd "$(dirname "$0")" && pwd)
readonly CURDIR

usage(){
    cat <<EOF
Usage: $0
Compilation test

Options:
    -h, --help          help
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
koka --library -v0 ck/*.kk toc.kk
rm -r .koka
