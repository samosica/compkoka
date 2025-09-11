#!/usr/bin/env bash
set -euo pipefail

CURDIR=$(cd "$(dirname "$0")" && pwd)
readonly CURDIR

koka_compiler=${koka_compiler:-koka}
koka_options=${koka_options-}

usage(){
    cat <<EOF
Usage: $0
Compilation test

Options:
    -h, --help          help

Environment variables:
    koka_compiler           specify compiler path (default: koka)
    koka_options            specify compile options (default: none)
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

run_test(){
    cd "$CURDIR/../src"
    # shellcheck disable=SC2086
    "$koka_compiler" --library --no-debug -v0 ck/*.kk toc.kk
    rm -r .koka
}

read_args "$@"

if [ -n "${GITHUB_ACTION-}" ]; then
    echo "::group::Run compilation test (compile options: \"$koka_options\")"
    run_test
    echo '::endgroup::'
else
    echo "Run compilation test (compile options: \"$koka_options\")"
    run_test
fi
