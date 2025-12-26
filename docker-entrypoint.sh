#!/usr/bin/env sh
set -e

exec firebase emulators:start \
  --project "${PROJECT_ID}" \
  ${EMULATOR_FLAGS}