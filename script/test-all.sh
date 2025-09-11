#!/usr/bin/env bash
set -euo pipefail

CURDIR=$(cd "$(dirname "$0")" && pwd)
readonly CURDIR

usage(){
    cat <<EOF
Usage: $0
Perform all tests

Options:
    -h, --help          help

Environment variables:
    KOKA_COMPILER           specify compiler path (default: koka)
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

KOKA_COMPILE_OPTION_SETS=('' '-O2')

cd "$CURDIR"
export KOKA_COMPILE_OPTIONS
for KOKA_COMPILE_OPTIONS in "${KOKA_COMPILE_OPTION_SETS[@]}"; do
    ./compilation-test.sh
done
for KOKA_COMPILE_OPTIONS in "${KOKA_COMPILE_OPTION_SETS[@]}"; do
    ./test.sh
done
for KOKA_COMPILE_OPTIONS in "${KOKA_COMPILE_OPTION_SETS[@]}"; do
    ./io-test.sh
done
