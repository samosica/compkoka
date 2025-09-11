#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly SCRIPT_DIR

ROOT_DIR=$SCRIPT_DIR/..

TEMP_DIR=$(mktemp -d)
readonly TEMP_DIR
# shellcheck disable=SC2064
trap "rm -r $TEMP_DIR" 0

KOKA_COMPILER=${KOKA_COMPILER:-koka}
KOKA_COMPILE_OPTIONS=${KOKA_COMPILE_OPTIONS-}

usage(){
    cat <<EOF
Usage: $0
Test library with IO

Options:
    -h, --help          help

Environment variables:
    KOKA_COMPILER           specify compiler path (default: koka)
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

green(){
    printf "\x1b[1;32m%s\x1b[0m\n" "$1"
}

red(){
    printf "\x1b[1;31m%s\x1b[0m\n" "$1"
}

run_test(){
    local prog=$1
    local prefix=${prog%.kk}
    local exe=${prefix}.exe
    local in=${prefix}-in
    local out=${prefix}-out

    echo -n "Testing $prog: "
    # shellcheck disable=SC2086
    if ! "$KOKA_COMPILER" --no-debug -i"$ROOT_DIR/src" -o "$exe" $KOKA_COMPILE_OPTIONS "$prog" >out 2>&1; then
        red "FAILED"
        cat out
        exit 1
    fi
    chmod +x "$exe"

    # Note: as of Koka v3.2.2, programs always exit with status code 0 so the following
    #       condition is always true. See <https://github.com/koka-lang/koka/issues/702>.
    if ! "$exe" <"$in" >out 2>err ; then
        red "FAILED"
        echo '[output]'
        cat out
        echo
        echo '[error]'
        cat err
        exit 1
    fi

    # shellcheck disable=SC2238
    # shellcheck disable=SC2094
    if ! diff out "$out" >diff 2>&1; then
        red "FAILED"
        cat diff
        exit 1
    fi

    green "SUCCEEDED"
}

run_tests(){
    cp -r "$ROOT_DIR"/test/io/* "$TEMP_DIR"
    cd "$TEMP_DIR"

    while IFS= read -r -d '' prog; do
        run_test "$prog"
    done < <(find . -type f -name '*.kk' -print0 | sort -z)
}

read_args "$@"

if [ -n "${GITHUB_ACTION-}" ]; then
    echo "::group::Run unit tests with IO (compile options: \"$KOKA_COMPILE_OPTIONS\")"
    run_tests
    echo '::endgroup::'
else
    echo "Run unit tests with IO (compile options: \"$KOKA_COMPILE_OPTIONS\")"
    run_tests
fi
