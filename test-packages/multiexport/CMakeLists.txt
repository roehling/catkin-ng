cmake_minimum_required(VERSION 3.10)
project(multiexport)

find_package(hazel REQUIRED)
find_package(foo REQUIRED)
find_package(bar REQUIRED)

add_library(test1 INTERFACE)
target_link_libraries(test1 INTERFACE foo::foo)
hazel_export(TARGETS test1)

add_library(test2 INTERFACE)
target_link_libraries(test2 INTERFACE bar::bar)
hazel_export(TARGETS test2)

hazel_package()
