cmake_minimum_required(VERSION 3.14)
project(baz)

find_package(hazel REQUIRED)

hazel_import(catkin::catkin_example 0.2.3 REQUIRED)

add_library(baz src/libbaz.cpp)
target_include_directories(baz PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)
target_link_libraries(baz PUBLIC catkin::catkin_example)

hazel_package(TARGETS baz)
