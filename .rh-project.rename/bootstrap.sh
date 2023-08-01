#!/bin/bash

set -eu
set -o pipefail

SDPATH="$(dirname "${BASH_SOURCE[0]}")"
if [[ ! -d "${SDPATH}" ]]; then SDPATH="${PWD}"; fi
SDPATH="$(cd "${SDPATH}" && pwd)"
readonly SDPATH

# shellcheck disable=1090
source "${SDPATH}/conf.sh"

echo
cd "${PRJ_ROOT_PATH}" && echo + cd "${PWD}"

touch .rh-trusted

cd "${SDPATH}" && echo + cd "${PWD}"

echo
CMD=(./poetry-install.sh)
echo + "${CMD[@]}" && "${CMD[@]}"

echo
CMD=(./conan-install.sh)
echo + "${CMD[@]}" && "${CMD[@]}"

echo
CMD=(./cmake.sh)
echo + "${CMD[@]}" && "${CMD[@]}"

echo
CMD=(./build.sh)
echo + "${CMD[@]}" && "${CMD[@]}"

echo
CMD=(./run.sh)
echo + "${CMD[@]}" && "${CMD[@]}"
