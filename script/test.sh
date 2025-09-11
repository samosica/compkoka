#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly SCRIPT_DIR

readonly ROOT_DIR=$SCRIPT_DIR/..

readonly TEST_DIR=$ROOT_DIR/test

TEMP_DIR=$(mktemp -d)
readonly TEMP_DIR
# shellcheck disable=SC2064
trap "rm -r $TEMP_DIR" 0

error(){
    printf "\x1b[1;31m[error]\x1b[0m %s\n" "$*" 1>&2
}

usage(){
    cat <<EOF
Usage: $0 [FILE]...
Run unit tests

Arguments:
    FILE                    specify test file to be executed (default: all)

Options:
    -h, --help              help

Environment variables:
    koka_compiler           specify compiler path (default: koka)
    koka_options            specify compile options (default: none)
EOF
}

read_args(){
    FILES=()

    while [ $# -ge 1 ]; do
        case "$1" in
            -h | --help) usage; exit 0;;
            -*) usage; exit 1;;
            *)
                if ! [ -e "$TEST_DIR/$1" ]; then
                    error "no such file: $1"; exit 1
                fi
                FILES+=("$1"); shift 1;;
        esac
    done

    if [ "${#FILES[@]}" -eq 0 ]; then
        FILES=(all.kk)
    fi
    readonly FILES

    koka_compiler=${koka_compiler:-koka}
    koka_options=${koka_options-}
}

run_test(){
    local prog=$1
    local exe=./${prog%.kk}.exe

    "$koka_compiler" --no-debug -i"$ROOT_DIR/src" -o "$exe" -v0 "$TEST_DIR/$prog"
    chmod +x "$exe"
    "$exe"
}

run_tests(){
    cd "$TEMP_DIR"

    local file
    for file in "${FILES[@]}"; do
        run_test "$file"
    done
}

read_args "$@"

if [ -n "${GITHUB_ACTION-}" ]; then
    echo "::group::Run unit tests (compile options: \"$koka_options\")"
    run_tests
    echo '::endgroup::'
else
    echo "Run unit tests (compile options: \"$koka_options\")"
    run_tests
fi
