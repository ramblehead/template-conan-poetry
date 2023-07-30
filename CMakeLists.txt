# Hey Emacs, this is -*- coding: utf-8 -*-

cmake_minimum_required(VERSION 3.15)
project(compressor LANGUAGES C CXX)

find_package(ZLIB REQUIRED)

message("== Building with CMake version: ${CMAKE_VERSION}")

add_executable(${PROJECT_NAME} src/main.c)
target_link_libraries(${PROJECT_NAME} ZLIB::ZLIB)
