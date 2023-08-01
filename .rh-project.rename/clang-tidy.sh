#!/bin/bash

set -eu
set -o pipefail

SDPATH="$(dirname "${BASH_SOURCE[0]}")"
if [[ ! -d "${SDPATH}" ]]; then SDPATH="${PWD}"; fi
SDPATH="$(cd -P "${SDPATH}" && pwd)"
readonly SDPATH

# shellcheck disable=1090
source "${SDPATH}/conf.sh"

cd "${PRJ_ROOT_PATH}" && echo + cd "${PWD}"

# Set the directory to search
SRC="${PRJ_ROOT_PATH}/src"

ERROR_TOTAL_COUNT=0
WARNING_TOTAL_COUNT=0

SRC_TYPES=(-name '*.cpp' -o -name '*.hpp' -o -name '*.c' -o -name '*.h')

while IFS= read -r -d '' FILE; do
  CMD=("clang-tidy-${CLANG_VERSION}")
  CMD+=("'${FILE}'")

  OUTPUT=$(script -qefc "${CMD[*]}" /dev/null < /dev/null | tee /dev/tty) ||:
  WARNING_COUNT=$(echo "${OUTPUT}" | grep -ci "warning\:") ||:
  ERROR_COUNT=$(echo "${OUTPUT}" | grep -ci "error\:") ||:

  echo
  echo "For ${FILE}:"
  echo "  File total number of clang-tidy errors: ${ERROR_COUNT}"
  echo "  File total number of clang-tidy warnings: ${WARNING_COUNT}"

  ((ERROR_TOTAL_COUNT += ERROR_COUNT)) ||:
  ((WARNING_TOTAL_COUNT += WARNING_COUNT)) ||:
done < <(find "${SRC}" -type f \( "${SRC_TYPES[@]}" \) -print0)

echo
echo "Project total number of clang-tidy errors: ${ERROR_TOTAL_COUNT}"
echo "Project total number of clang-tidy warnings: ${WARNING_TOTAL_COUNT}"
