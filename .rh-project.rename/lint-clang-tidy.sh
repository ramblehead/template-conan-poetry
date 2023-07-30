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

# Set the directory to search
SRC="${PRJ_ROOT_PATH}/src"

error_total_count=0
warning_total_count=0

SRC_TYPES=(-name '*.cpp' -o -name '*.hpp' -o -name '*.c' -o -name '*.h')

while IFS= read -r -d '' FILE; do
  CMD=("'clang-tidy-${CLANG_VERSION}'")
  CMD+=("'${FILE}'")

  output=$(script -qefc "${CMD[*]} 2>&1" /dev/null | tee /dev/tty) ||:
  warning_count=$(echo "${output}" | grep -ci "warning\:") ||:
  error_count=$(echo "${output}" | grep -ci "error\:") ||:

  echo
  echo "For ${FILE}:"
  echo "  File total number of clang-tidy errors: ${error_count}"
  echo "  File total number of clang-tidy warnings: ${warning_count}"

  ((error_total_count += error_count)) ||:
  ((warning_total_count += warning_count)) ||:
done < <(find "${SRC}" -type f \( "${SRC_TYPES[@]}" \) -print0)

echo
echo "Project total number of clang-tidy errors: ${error_total_count}"
echo "Project total number of clang-tidy warnings: ${warning_total_count}"
