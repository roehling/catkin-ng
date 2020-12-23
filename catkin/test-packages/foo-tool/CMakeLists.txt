cmake_minimum_required(VERSION 3.14)
project(foo-tool VERSION 1.0.0)

find_package(catkin 2.0 REQUIRED)
find_package(foo 1.0 REQUIRED)

add_executable(foo-tool src/foo-tool.cpp)
target_link_libraries(foo-tool PRIVATE foo::foo)

catkin_package()
