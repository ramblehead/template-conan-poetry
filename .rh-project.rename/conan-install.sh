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

CMD=(poetry run conan install)
CMD+=(.)
CMD+=("--output-folder=${BLD_PATH}")
# CMD+=('--build="*"')
CMD+=("--build=missing")
CMD+=("-pr:h=./utils/conan2/profiles/clang-${CLANG_VERSION}")
CMD+=("-pr:b=./utils/conan2/profiles/clang-${CLANG_VERSION}")

# shellcheck disable=2294
echo + "${CMD[@]}" && eval "${CMD[@]}"
