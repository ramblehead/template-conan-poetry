#!/bin/bash

set -eu
set -o pipefail

SDPATH="$(dirname "${BASH_SOURCE[0]}")"
if [[ ! -d "${SDPATH}" ]]; then SDPATH="${PWD}"; fi
SDPATH="$(cd -P "${SDPATH}" && pwd)"
readonly SDPATH

PRJ_ROOT_PATH="${SDPATH}/.."
PRJ_ROOT_PATH="$(cd "${PRJ_ROOT_PATH}" && pwd)"
readonly PRJ_ROOT_PATH

# shellcheck disable=1090
source "${SDPATH}/conf.sh"

cd "${PRJ_ROOT_PATH}" && echo + cd "${PWD}"

CMD=("'clang-check-${CLANG_VERSION}'")
CMD+=(--analyze)
CMD+=("--extra-arg=-Xanalyzer")
CMD+=("--extra-arg=-analyzer-output=text")
CMD+=("--extra-arg=-Wno-unknown-warning-option")
CMD+=("--extra-arg=-Wno-unused-command-line-argument")
CMD+=("src/*")

OUTPUT=$(script -qefc "${CMD[*]} 2>&1" /dev/null | tee /dev/tty)

ERROR_COUNT=$(echo "${OUTPUT}" | grep -ci error) ||:
WARNING_COUNT=$(echo "${OUTPUT}" | grep -ci warning) ||:

echo
echo "Project total number of clang-check --analyze errors: ${ERROR_COUNT}"
echo "Project total number of clang-check --analyze warnings: ${WARNING_COUNT}"
