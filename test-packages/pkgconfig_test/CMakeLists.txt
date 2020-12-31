cmake_minimum_required(VERSION 3.14)
project(pkgconfig_test)

find_package(hazel REQUIRED)
hazel_import(pkgconfig::png libpng>=1.6 REQUIRED)
hazel_import(pkgconfig::jpeg libjpeg)

add_library(test INTERFACE)
target_link_libraries(test INTERFACE pkgconfig::png)

hazel_package(TARGETS test)
