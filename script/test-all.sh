#!/usr/bin/env bash
set -euo pipefail

CURDIR=$(cd "$(dirname "$0")" && pwd)
readonly CURDIR

cd "$CURDIR"
./compilation-test.sh
./test.sh
