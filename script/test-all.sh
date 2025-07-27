#!/usr/bin/env bash
set -euo pipefail

CURDIR=$(cd "$(dirname "$0")" && pwd)
readonly CURDIR

KOKA_COMPILE_OPTION_SETS=('' '-O2')

cd "$CURDIR"
export KOKA_COMPILE_OPTIONS
for KOKA_COMPILE_OPTIONS in "${KOKA_COMPILE_OPTION_SETS[@]}"; do
    ./compilation-test.sh
done
for KOKA_COMPILE_OPTIONS in "${KOKA_COMPILE_OPTION_SETS[@]}"; do
    ./test.sh
done
