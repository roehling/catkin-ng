cmake_minimum_required(VERSION 3.14)
project(scripting VERSION 1.0.0)

find_package(catkin 2.0 REQUIRED)

catkin_package(SCRIPTS cmake/regular cmake/configured cmake/preprocessed cmake/split)
