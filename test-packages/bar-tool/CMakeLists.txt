cmake_minimum_required(VERSION 3.14)
project(bar-tool VERSION 1.0.0)

find_package(hazel REQUIRED)
find_package(bar REQUIRED)

add_executable(bar-tool src/bar-tool.cpp)
target_link_libraries(bar-tool PRIVATE bar::bar)

hazel_package(TARGETS bar-tool)
