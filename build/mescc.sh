#! /bin/bash

set -eo pipefail

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

readonly _script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

readonly _gotopt_binary="$(rlocation \
  gotopt2/cmd/gotopt2/linux_amd64_stripped/gotopt2)"

GOTOPT2_OUTPUT=$($_gotopt_binary "${@}" <<EOF
flags:
- name: "container"
  type: string
  help: "The name of the container to run"
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

readonly _mescc="$(rlocation mescc/cc.com)"
echo "mescc: ${_mescc}"
readonly _mescc_srcdir="${_script_dir}/mescc_compiler.runfiles/mescc"
readonly _emulator="$(rlocation tim011_tools/CPMEmulator/cpm)"

cp --dereference -R ${_mescc_srcdir}/* ${_tmpdir}
cp "${_emulator}" "${_tmpdir}/cpm"

echo "tmpdir: ${_tmpdir}"
cd "${_tmpdir}"
./cpm cc
