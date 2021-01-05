cmake_minimum_required(VERSION 3.14)
project(scripting VERSION 1.0.0)

find_package(hazel REQUIRED)

hazel_package(CMAKE_SCRIPTS
    cmake/regular.cmake
    cmake/configured.cmake
    cmake/preprocessed.cmake
    cmake/split.cmake
)
