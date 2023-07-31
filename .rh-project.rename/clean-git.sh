#!/bin/bash

set -eu
set -o pipefail

SDPATH="$(dirname "${BASH_SOURCE[0]}")"
if [[ ! -d "${SDPATH}" ]]; then SDPATH="${PWD}"; fi
SDPATH="$(cd "${SDPATH}" && pwd)"
readonly SDPATH

# shellcheck disable=1090
source "${SDPATH}/conf.sh"

cd "${PRJ_ROOT_PATH}" && echo + cd "${PWD}"

CMD=(git reset --hard)
echo + "${CMD[@]}" && "${CMD[@]}"

CMD=(git submodule foreach --recursive git reset --hard)
echo + "${CMD[@]}" && "${CMD[@]}"

CMD=(git clean -xfd)
echo + "${CMD[@]}" && "${CMD[@]}"

CMD=(git submodule foreach --recursive git clean -xfd)
echo + "${CMD[@]}" && "${CMD[@]}"
