## Hey Emacs, this is -*- coding: utf-8 -*-
<%
  project_name = config["project_name"]
%>\
# Hey Emacs, this is -*- coding: utf-8 -*-

cmake_minimum_required(VERSION 3.15)
project("${project_name}" LANGUAGES C CXX)

find_package(range-v3 REQUIRED)
find_package(Boost COMPONENTS unit_test_framework REQUIRED)

message("== Building with CMake version: <%text>${CMAKE_VERSION}</%text>")

add_executable(<%text>${PROJECT_NAME}</%text> src/main.cpp)

add_executable(<%text>${PROJECT_NAME}.perf</%text> src/main.perf.cpp)
target_link_libraries(<%text>${PROJECT_NAME}.perf</%text> range-v3::range-v3)

add_executable(<%text>${PROJECT_NAME}.test</%text> src/main.test.cpp)
target_link_libraries(<%text>${PROJECT_NAME}.test</%text> \
PRIVATE Boost::unit_test_framework)
