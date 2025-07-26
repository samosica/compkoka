#!/usr/bin/env bash
set -euo pipefail

CURDIR=$(cd "$(dirname "$0")" && pwd)
readonly CURDIR

echo-in-gh-actions(){
    if [ -n "${GITHUB_ACTION-}" ]; then
        echo "$@"
    fi
}

cd "$CURDIR"
echo-in-gh-actions '::group::Compilation test'
./compilation-test.sh
echo-in-gh-actions '::endgroup::'
echo-in-gh-actions '::group::Unit tests'
./test.sh
echo-in-gh-actions '::endgroup::'
