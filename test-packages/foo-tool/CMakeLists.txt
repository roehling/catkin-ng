cmake_minimum_required(VERSION 3.14)
project(foo-tool VERSION 1.0.0)

find_package(hazel REQUIRED)
find_package(foo REQUIRED)

add_executable(foo-tool src/foo-tool.cpp)
target_link_libraries(foo-tool PRIVATE foo::foo)

hazel_package()
