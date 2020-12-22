cmake_minimum_required(VERSION 3.14)
project(foo VERSION 1.0.0)

find_package(catkin 2.0 REQUIRED)

add_library(foo src/libfoo.cpp)
set_target_properties(foo PROPERTIES SOVERSION 0)
target_include_directories(foo PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:${CATKIN_GLOBAL_INCLUDE_DESTINATION}>)
install(DIRECTORY include/${PROJECT_NAME} DESTINATION ${CATKIN_GLOBAL_INCLUDE_DESTINATION})

catkin_package(TARGETS foo)
