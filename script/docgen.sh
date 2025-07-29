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

get_koka_version(){
    # version: x.x.x
    koka --version | grep version | cut -d' ' -f2
}

if [ -z "${KOKA_VERSION-}" ]; then
    KOKA_VERSION="v$(get_koka_version)"
fi

compile(){
    local -r TMPDIR=$(mktemp -d)
    # shellcheck disable=SC2064
    trap "rm -r $TMPDIR" RETURN

    local -r SRCDIR="$CURDIR/../src"
    cd "$SRCDIR"
    koka --library --html --htmlcss koka.css --outputdir "$TMPDIR" ck/*.kk toc.kk

    cd "$TMPDIR"
    madoko --verbose --odir=. ./*.xmp.html

    # Embed library version and compiler version
    sed -i '\|</a></h1>|a\<p>compkoka ({{LIBRARY_VERSION}}). This is compiled by Koka {{KOKA_VERSION}}.</p>' toc.html
    sed -i 's/{{LIBRARY_VERSION}}/dev/' toc.html
    sed -i "s/{{KOKA_VERSION}}/${KOKA_VERSION}/" toc.html

    local -r DOCDIR="$CURDIR/../docs/dev"
    mkdir -p "$DOCDIR"
    # Remove outdated files
    # Note: rm "$DOCDIR"/**/*.html does not work when there are no matches.
    find "$DOCDIR" -type f -name '*.html' -delete
    find "$TMPDIR" -type f -name "*.html" -not \( -name "*.xmp.html" -o -name "std_*" \) -print0 \
    | sort -z \
    | xargs -0 -I {} -n1 cp {} "$DOCDIR"
}

compile
