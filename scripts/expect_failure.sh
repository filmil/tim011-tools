#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
#
# Runs a command that must fail, and fails if it succeeds.
#
# Usage: expect_failure.sh <command> [args...]
if "$@"; then
  echo "FAIL: expected '$*' to fail, and it passed" >&2
  exit 1
fi
echo "PASS: '$1' failed, as expected"
