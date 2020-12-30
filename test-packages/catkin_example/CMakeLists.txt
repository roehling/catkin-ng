cmake_minimum_required(VERSION 3.0.2)
project(catkin_example)
find_package(catkin REQUIRED COMPONENTS roscpp)
include_directories(${catkin_INCLUDE_DIRS} include)

catkin_package(INCLUDE_DIRS include LIBRARIES catkin_example CATKIN_DEPENDS roscpp)

add_library(catkin_example src/example.cpp)
target_link_libraries(catkin_example ${catkin_LIBRARIES})
install(TARGETS catkin_example LIBRARY DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION})
install(DIRECTORY include/catkin_example DESTINATION ${CATKIN_GLOBAL_INCLUDE_DESTINATION})
