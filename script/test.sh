#!/usr/bin/env bash
set -euo pipefail

CURDIR=$(cd "$(dirname "$0")" && pwd)
readonly CURDIR

koka_compiler=${koka_compiler:-koka}
koka_options=${koka_options-}

usage(){
    cat <<EOF
Usage: $0
Test library

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
    cd "$CURDIR/../test"
    # shellcheck disable=SC2086
    "$koka_compiler" --no-debug -i../src -o all.exe -v0 all.kk
    chmod +x all.exe
    ./all.exe
    rm all.exe
}

read_args "$@"

if [ -n "${GITHUB_ACTION-}" ]; then
    echo "::group::Run unit tests (compile options: \"$koka_options\")"
    run_test
    echo '::endgroup::'
else
    echo "Run unit tests (compile options: \"$koka_options\")"
    run_test
fi
