#! /bin/bash

set -eo pipefail

readonly _script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# This magic was copied from runfiles by consulting:
#   https://stackoverflow.com/questions/53472993/how-do-i-make-a-bazel-sh-binary-target-depend-on-other-binary-targets

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---

_gotopt_binary="$(rlocation \
  gotopt2/cmd/gotopt2/linux_amd64_stripped/gotopt2)" || true
if [[ "${_gotopt_binary}" == "" ]]; then
  _gotopt_binary="$(rlocation \
    gotopt2/cmd/gotopt2/gotopt2_/gotopt2)"
fi

GOTOPT2_OUTPUT=$($_gotopt_binary "${@}" <<EOF
flags:
- name: "--com-file"
  type: string
  help: "The .COM file path to run."
EOF
)
if [[ "$?" == "11" ]]; then
  # When --help option is used, gotopt2 exits with code 11.
  exit 1
fi

# Evaluate the output of the call to gotopt2, shell vars assignment is here.
eval "${GOTOPT2_OUTPUT}"

# ---
readonly _tmpdir="$(mktemp -d || mktemp -d -t bazel-tmp)"
trap "rm -fr ${_tmpdir}" EXIT

readonly _emulator="$(rlocation tim011_tools/CPMEmulator/cpm)"

(
  echo "${_emulator}" ${gotopt2_com_file}
)

