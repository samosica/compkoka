#!/usr/bin/env bash
set -eu

CURDIR=$(cd "$(dirname "$0")" && pwd)
readonly CURDIR

usage(){
    cat <<EOF
Usage: $0
Generate documentation from source files

Options:
    -h                  help
EOF
}

while getopts h OPT; do
    case "$OPT" in
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

compile(){
    local -r TMPDIR=$(mktemp -d)
    # shellcheck disable=SC2064
    trap "rm -r $TMPDIR" RETURN

    local -r SRCDIR="$CURDIR/../src"
    cd "$SRCDIR"
    koka --library --html --htmlcss koka.css --outputdir "$TMPDIR" ck/*.kk toc.kk

    cd "$TMPDIR"
    madoko --verbose --odir=. ./*.xmp.html

    local -r DOCDIR="$CURDIR/../docs/dev"
    mkdir -p "$DOCDIR"
    find "$TMPDIR" -type f -name "*.html" -not \( -name "*.xmp.html" -o -name "std_*" \) -print0 \
    | sort -z \
    | xargs -0 -I {} -n1 cp {} "$DOCDIR"
}

compile
