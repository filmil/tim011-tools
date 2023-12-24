#!/bin/bash

RUNNER="$(realpath ${CPM_BINARY})"
BINARY="${RUN_BINARY}"
DIR="$(dirname $BINARY)"

echo "RUNNER: ${RUNNER}"
echo "TEST  : ${RUN_BINARY}"
echo "DIR   : ${DIR}"
echo "PWD   : ${PWD}"
echo ----------

cd "${DIR}"
BASE="$(basename $BINARY)"
BASE_NOEXT="${BASE%%.*}"
"${RUNNER}" --exec "${BASE_NOEXT}"

if [[ ! -a "test_ok" ]]; then
  echo -e "\n\nnot ok: test_ok not found"
  exit 1
fi
