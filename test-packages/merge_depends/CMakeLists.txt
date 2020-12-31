cmake_minimum_required(VERSION 3.14)
project(merge_depends)

find_package(hazel REQUIRED)

hazel_package(DEPENDS "Boost 1.50 REQUIRED OPTIONAL_COMPONENTS system signals2" "Qt COMPONENTS Gui" "Boost 1.70 COMPONENTS system python")
