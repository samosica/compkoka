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
    koka_compiler           specify compiler path (default: koka)
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

KOKA_OPTION_SETS=('' '-O2')

cd "$CURDIR"
export koka_options
for koka_options in "${KOKA_OPTION_SETS[@]}"; do
    ./compilation-test.sh
done
for koka_options in "${KOKA_OPTION_SETS[@]}"; do
    ./test.sh
done
for koka_options in "${KOKA_OPTION_SETS[@]}"; do
    ./io-test.sh
done
