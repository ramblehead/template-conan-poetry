## Hey Emacs, this is -*- coding: utf-8 -*-
# Hey Emacs, this is -*- coding: utf-8 -*-

cmake_minimum_required(VERSION 3.15)
project(compressor LANGUAGES C CXX)

find_package(ZLIB REQUIRED)

message("== Building with CMake version: <%text>${CMAKE_VERSION}</%text>")

add_executable(<%text>${PROJECT_NAME}</%text> src/main.c)
target_link_libraries(<%text>${PROJECT_NAME}</%text> ZLIB::ZLIB)
