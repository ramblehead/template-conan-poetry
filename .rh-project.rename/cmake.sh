#!/bin/bash

set -eu
set -o pipefail

SDPATH="$(dirname "${BASH_SOURCE[0]}")"
if [[ ! -d "${SDPATH}" ]]; then SDPATH="${PWD}"; fi
SDPATH="$(cd "${SDPATH}" && pwd)"
readonly SDPATH

# shellcheck disable=1090
source "${SDPATH}/conf.sh"

cd "${BLD_PATH}" && echo + cd "${PWD}"

echo
CMD=(source conanbuild.sh)
echo + "${CMD[@]}" && "${CMD[@]}"

CMD=(cmake)
CMD+=(..)
CMD+=("-DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake")
CMD+=("-DCMAKE_EXPORT_COMPILE_COMMANDS=True")
# CMD+=("-DCMAKE_C_COMPILER=${CC}")
# CMD+=("-DCMAKE_CXX_COMPILER=${CXX}")
CMD+=("-DCMAKE_BUILD_TYPE=Release")
echo + "${CMD[@]}" && "${CMD[@]}"

echo
CMD=(source deactivate_conanbuild.sh)
echo + "${CMD[@]}" && "${CMD[@]}"
