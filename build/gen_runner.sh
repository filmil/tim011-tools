#!/bin/bash

env

RUNNER="$(realpath ${CPM_BINARY})"
BINARY="${RUN_BINARY}"
DIR="$(dirname $BINARY)"

echo "TEST: ${RUN_BINARY}"
cd "${DIR}"
BASE="$(basename $BINARY)"
BASE_NOEXT="${BASE%%.*}"
"${RUNNER}" --exec "${BASE_NOEXT}"

