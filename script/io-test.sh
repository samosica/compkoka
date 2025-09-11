#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly SCRIPT_DIR

readonly ROOT_DIR=$SCRIPT_DIR/..

readonly TEST_DIR=$ROOT_DIR/test/io

TEMP_DIR=$(mktemp -d)
readonly TEMP_DIR
# shellcheck disable=SC2064
trap "rm -r $TEMP_DIR" 0

usage(){
    cat <<EOF
Usage: $0 [FILE]...
Run unit tests using IO

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
                FILES+=("./$1"); shift 1;;
        esac
    done

    if [ "${#FILES[@]}" -eq 0 ]; then
        pushd "$TEST_DIR" >/dev/null
        local file
        while IFS= read -r -d '' file; do
            FILES+=("$file")
        done < <(find . -type f -name '*.kk' -print0 | sort -z)
        popd >/dev/null
    fi
    readonly FILES

    koka_compiler=${koka_compiler:-koka}
    koka_options=${koka_options-}
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
    if ! "$koka_compiler" --no-debug -i"$ROOT_DIR/src" -o "$exe" "$TEST_DIR/$prog" >out 2>&1; then
        red "FAILED"
        cat out
        exit 1
    fi
    chmod +x "$exe"

    # Note: as of Koka v3.2.2, programs always exit with status code 0 so the following
    #       condition is always true. See <https://github.com/koka-lang/koka/issues/702>.
    if ! "$exe" <"$TEST_DIR/$in" >out 2>err ; then
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
    if ! diff out "$TEST_DIR/$out" >diff 2>&1; then
        red "FAILED"
        cat diff
        exit 1
    fi

    green "SUCCEEDED"
}

run_tests(){
    cd "$TEMP_DIR"

    for file in "${FILES[@]}"; do
        run_test "$file"
    done
}

read_args "$@"

if [ -n "${GITHUB_ACTION-}" ]; then
    echo "::group::Run unit tests with IO (compile options: \"$koka_options\")"
    run_tests
    echo '::endgroup::'
else
    echo "Run unit tests with IO (compile options: \"$koka_options\")"
    run_tests
fi
