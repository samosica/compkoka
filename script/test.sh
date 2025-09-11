#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly SCRIPT_DIR

readonly ROOT_DIR=$SCRIPT_DIR/..

TEMP_DIR=$(mktemp -d)
readonly TEMP_DIR
# shellcheck disable=SC2064
trap "rm -r $TEMP_DIR" 0

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

    koka_compiler=${koka_compiler:-koka}
    koka_options=${koka_options-}
}

run_test(){
    cd "$TEMP_DIR"
    "$koka_compiler" --no-debug -i"$ROOT_DIR/src" -o all.exe -v0 "$ROOT_DIR/test/all.kk"
    chmod +x all.exe
    ./all.exe
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
