## Hey Emacs, this is -*- coding: utf-8 -*-
<%
  project_name = utils.kebab_case(config["project_name"])
%>\
<%text>#!/bin/bash

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

echo
CMD=(cmake)
CMD+=(--build)
CMD+=(.)
</%text>CMD+=(--target "${project_name}.test")<%text>
CMD+=("--config=Release")
echo + "${CMD[@]}" && "${CMD[@]}"

echo
CMD=(source deactivate_conanbuild.sh)
echo + "${CMD[@]}" && "${CMD[@]}"
</%text>