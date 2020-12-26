cmake_minimum_required(VERSION 3.14)
project(pkgconfig-test)

find_package(hazel REQUIRED)
hazel_import_pkgconfig(pkg-config::png libpng>=1.6 REQUIRED)
hazel_import_pkgconfig(pkg-config::jpeg libjpeg)

add_library(test INTERFACE)
target_link_libraries(test INTERFACE pkg-config::png)

hazel_package(TARGETS test)
