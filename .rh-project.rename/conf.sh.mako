## Hey Emacs, this is -*- coding: utf-8 -*-
<%
  project_name = utils.kebab_case(config["project_name"])
%>\
# shellcheck disable=2034

readonly PROJECT_NAME="${project_name}"

readonly COMPILER=clang
readonly COMPILER_VERSION=15
readonly CLANG_CHECK_VERSION=15
readonly CLANG_TIDY_VERSION=15

PRJ_ROOT_PATH="<%text>${SDPATH}</%text>/.."
PRJ_ROOT_PATH="$(cd "<%text>${PRJ_ROOT_PATH}</%text>" && pwd)"
readonly PRJ_ROOT_PATH

readonly BLD_DIR_NAME="build"
readonly BLD_PATH="<%text>${PRJ_ROOT_PATH}/${BLD_DIR_NAME}</%text>"
