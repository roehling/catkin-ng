cmake_minimum_required(VERSION 3.10)
project(bar VERSION 1.0.0)

find_package(hazel REQUIRED)
find_package(foo REQUIRED)

add_library(bar src/libbar.cpp)
set_target_properties(bar PROPERTIES SOVERSION 0)
target_include_directories(bar PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:${HAZEL_GLOBAL_INCLUDE_DESTINATION}>)
target_link_libraries(bar PUBLIC foo::foo)
install(DIRECTORY include/${PROJECT_NAME} DESTINATION ${HAZEL_GLOBAL_INCLUDE_DESTINATION})

hazel_package(TARGETS bar)
