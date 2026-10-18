#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
#
# Checks that CI builds with the Bazel version in .bazelversion.
#
# From September to October 2026 the weekly CI run failed every time: the
# repository had moved to Bzlmod and Bazel 9, but the workflow still
# installed Bazel 6.4.0, which ignores MODULE.bazel. So a workflow must
# install Bazel through Bazelisk, which reads .bazelversion, and must not
# name a Bazel version of its own.
#
# Usage: ci_bazel_version_test.sh <.bazelversion> <workflow.yml>...
set -o errexit -o nounset -o pipefail

version_file="$1"
shift

version="$(tr -d '[:space:]' < "${version_file}")"
if [[ -z "${version}" ]]; then
  echo "FAIL: ${version_file} is empty; it should name the Bazel version" >&2
  exit 1
fi
if [[ "$#" -eq 0 ]]; then
  echo "FAIL: no workflow files to check" >&2
  exit 1
fi

failed=0
for workflow in "$@"; do
  # An action that installs one fixed Bazel instead of Bazelisk.
  if grep -nE 'uses:[[:space:]]*abhinavsingh/setup-bazel' "${workflow}"; then
    echo "FAIL: ${workflow} installs a fixed Bazel; use bazel-contrib/setup-bazel, which runs Bazelisk" >&2
    failed=1
  fi
  # A Bazel version named in the workflow, which would override
  # .bazelversion: USE_BAZEL_VERSION anywhere outside a comment, or a
  # `version:` input inside a setup-bazel step. Other actions' `version:`
  # inputs are left alone.
  if grep -vE '^[[:space:]]*#' "${workflow}" | grep -nE 'USE_BAZEL_VERSION|bazelisk-version:' \
      || awk '/^[[:space:]]*- / { in_bazel = 0 }
              /uses:[[:space:]]*[^[:space:]]*setup-bazel/ { in_bazel = 1 }
              in_bazel && /^[[:space:]]*(version|bazel-version):/ { print NR ": " $0; found = 1 }
              END { exit !found }' "${workflow}"; then
    echo "FAIL: ${workflow} names a Bazel version; .bazelversion (${version}) must be the only one" >&2
    failed=1
  fi
  if grep -qE 'bazel (build|test|run)' "${workflow}" \
      && ! grep -qE 'uses:[[:space:]]*bazel-contrib/setup-bazel@' "${workflow}"; then
    echo "FAIL: ${workflow} runs Bazel without bazel-contrib/setup-bazel" >&2
    failed=1
  fi
done

if [ "${failed}" -ne 0 ]; then
  exit 1
fi
echo "PASS: $# workflow(s) use Bazelisk and Bazel ${version} from ${version_file}"
