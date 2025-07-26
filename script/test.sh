#!/usr/bin/env bash
# TODO: コンパイラのバージョンとオプションを指定できるようにする
set -euo pipefail

CURDIR=$(cd "$(dirname "$0")" && pwd)
readonly CURDIR

usage(){
    cat <<EOF
Usage: $0
Test library

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
cd "$CURDIR/../test"
koka --no-debug -i../src -o all.exe -v0  all.kk
chmod +x all.exe
./all.exe
rm all.exe
