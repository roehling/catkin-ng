cmake_minimum_required(VERSION 3.10)
project(pkgconfig_test)

find_package(hazel REQUIRED)
hazel_import(PkgConfig::PNG libpng>=1.6 REQUIRED)
hazel_import(PkgConfig::JPEG libjpeg)

add_library(test INTERFACE)
target_link_libraries(test INTERFACE PkgConfig::PNG)

hazel_package(TARGETS test)
