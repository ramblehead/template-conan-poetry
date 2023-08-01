#!/bin/bash

set -eu
set -o pipefail

SDPATH="$(dirname "${BASH_SOURCE[0]}")"
if [[ ! -d "${SDPATH}" ]]; then SDPATH="${PWD}"; fi
SDPATH="$(cd "${SDPATH}" && pwd)"
readonly SDPATH

# shellcheck disable=1090
source "${SDPATH}/conf.sh"

"${SDPATH}/build.sh"

echo
cd "${BLD_PATH}" && echo + cd "${PWD}"

echo
CMD=(source conanrun.sh)
echo + "${CMD[@]}" && "${CMD[@]}"

echo
CMD=("./${PROJECT_NAME}.test")
echo + "${CMD[@]}" && "${CMD[@]}"

echo
CMD=(source deactivate_conanrun.sh)
echo + "${CMD[@]}" && "${CMD[@]}"
