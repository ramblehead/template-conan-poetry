## Hey Emacs, this is -*- coding: utf-8 -*-
<%
  project_name = conf.project_name
%>\
# shellcheck disable=2034

readonly PROJECT_NAME="${project_name}"

readonly CLANG_VERSION=15

readonly BLD_DIR_NAME="build"
readonly BLD_PATH="<%text>${PRJ_ROOT_PATH}/${BLD_DIR_NAME}</%text>"