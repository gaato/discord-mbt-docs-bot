#!/usr/bin/env bash
# The MoonBit gates: format, type checks, and tests on the native and js
# targets. The test job in deploy.yml runs them on the pinned toolchain before
# a deploy, and the canary (canary.yml) on the latest and nightly ones, both
# through this script so the two cannot drift.
set -euo pipefail
cd "$(dirname "$0")/.."

run() {
  echo "+ $*"
  "$@"
}

run moon fmt --check
run moon check --target native --deny-warn
run moon check --target js --deny-warn
run moon test --target native
run moon test --target js
