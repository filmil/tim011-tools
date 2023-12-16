#! /bin/bash

set -x
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
- name: "img-file"
  type: string
  help: "The disk image to start"
- name: "rom-directory"
  type: string
  help: "The rom directory to use"
- name: "program-name"
  type: string
  help: "The program to run"
  default: "r"
- name: "keep"
  type: bool
  default: true
- name: "tmp-dir"
  type: string
  help: "The temporary directory to use - one will be generated if not given"
  default: ""
- name: "slowdown"
  type: bool
  default: true
  help: "Whether to slow the machine down to 100% once it boots"
- name: "debug"
  type: string
  default: ""
  help: "Additional flags to add to the command line."
- name: "sleep"
  type: int
  default: 5 
  help: "How long to sleep for the system to boot."
- name: "kill-at-end"
  type: bool
  help: "Whether to kill the emulator at the end"
EOF
)
if [[ "$?" == "11" ]]; then
  # When --help option is used, gotopt2 exits with code 11.
  exit 1
fi

# Evaluate the output of the call to gotopt2, shell vars assignment is here.
eval "${GOTOPT2_OUTPUT}"

# ---
_tmpdir="${gotopt2_tmp_dir}"
if [[ "${_tmpdir}" == "" ]]; then
  _tmpdir="$(mktemp -d || mktemp -d -t bazel-tmp)"
fi

if [[ "${gotopt2_keep}" != "true" ]]; then
  trap "rm -fr ${_tmpdir}" EXIT
fi

CONTAINER_NAME="${CONTAINER_NAME:-filipfilmar/mame-docker:latest}"

cp -R --dereference "${gotopt2_rom_directory}" "${_tmpdir}"
cp --dereference "${gotopt2_img_file}" "${_tmpdir}"

INTERACTIVE=""
if sh -c ": >/dev/tty" >/dev/null 2>/dev/null; then
	# Only add these if running on actual terminal.
	INTERACTIVE="--interactive --tty"
fi

cp ${gotopt2_img_file} ${_tmpdir}

(
  docker run \
    ${INTERACTIVE} \
    -u $(id -u):$(id -g) \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -v "${_tmpdir}:/work:rw" \
    -e DISPLAY="${DISPLAY}" \
    -e HOME="/work" \
    -e PROGRAM="${gotopt2_program_name}"  \
    -e IMAGE="$(basename ${gotopt2_img_file})"  \
    -e SLOWDOWN="${gotopt2_slowdown}"  \
    -e DEBUG="${gotopt2_debug}"  \
    -e KILL_AT_END="${gotopt2_kill_at_end}" \
    --net=host \
    "${CONTAINER_NAME}" \
    /bin/bash -c "/run.sh"
)

