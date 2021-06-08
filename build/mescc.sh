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
- name: "source-file"
  type: string
  help: "The name of the source file to compile"
- name: "source-path"
  type: string
- name: "include-files"
  type: stringlist
  help: "the list of pairs of full paths and short names of files"
- name: "out-file"
  type: string
  help: "the name of the output file"
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
readonly _mescc_srcdir="${_script_dir}/mescc_compiler.runfiles/mescc"
readonly _emulator="$(rlocation tim011_tools/CPMEmulator/cpm)"

cp --dereference -R ${_mescc_srcdir}/* ${_tmpdir}
cp "${_emulator}" "${_tmpdir}/cpm"
mv ${_tmpdir}/small_c_17/* ${_tmpdir}
cp "${gotopt2_source_path}" "${_tmpdir}"/"${gotopt2_source_file}"

for f in ${gotopt2_include_files__list[@]}; do
  bf="${f##*/}"
  cp ${f} "${_tmpdir}/${bf}"
done

fname="$(basename ${gotopt2_source_file})"
basename="${fname%.*}"

(
  cd "${_tmpdir}"

  # xvfb-run needs to be installed since X is not accessible from the sandbox.
  xvfb-run -a -e /dev/stdout ./cpm cc ${gotopt2_source_file}
  xvfb-run -a -e /dev/stdout ./cpm zsm ${basename}
  xvfb-run -a -e /dev/stdout ./cpm hextocom ${basename}
)

# end...
cp "${_tmpdir}/${basename}.com" ${gotopt2_out_file}
