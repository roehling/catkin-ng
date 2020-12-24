cmake_minimum_required(VERSION 3.14)
project(foo)

find_package(hazel REQUIRED)

add_library(foo src/libfoo.cpp)
set_target_properties(foo PROPERTIES SOVERSION 0)
target_include_directories(foo PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:${HAZEL_GLOBAL_INCLUDE_DESTINATION}>)
install(DIRECTORY include/${PROJECT_NAME} DESTINATION ${HAZEL_GLOBAL_INCLUDE_DESTINATION})

hazel_package(TARGETS foo COMPATIBILITY SameMajorVersion)
