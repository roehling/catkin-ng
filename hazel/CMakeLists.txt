##############################################################################
#
# Hazel Build System
# Copyright 2020-2021 Timo Röhling <timo@gaussglocke.de>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
##############################################################################
cmake_minimum_required(VERSION 3.10)
project(hazel)

option(BUILD_DOCS "Build and install Sphinx documentation" ON)

include(cmake/all.cmake)
include(CMakePackageConfigHelpers)

configure_package_config_file(config.cmake.in "${PROJECT_NAME}Config.cmake"
    INSTALL_DESTINATION "${HAZEL_PACKAGE_CMAKE_DESTINATION}"
    NO_SET_AND_CHECK_MACRO NO_CHECK_REQUIRED_COMPONENTS_MACRO
)
hazel_write_package_version_file("${PROJECT_NAME}ConfigVersion.cmake" COMPATIBILITY SameMajorVersion)
if(HAZEL_DEVEL_PREFIX)
    file(COPY "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake" DESTINATION "${HAZEL_DEVEL_PREFIX}/${HAZEL_PACKAGE_CMAKE_DESTINATION}")
    configure_package_config_file(config.cmake.in "${HAZEL_DEVEL_PREFIX}/${HAZEL_PACKAGE_CMAKE_DESTINATION}/${PROJECT_NAME}Config.cmake"
        INSTALL_DESTINATION "${HAZEL_PACKAGE_CMAKE_DESTINATION}"
        NO_SET_AND_CHECK_MACRO NO_CHECK_REQUIRED_COMPONENTS_MACRO
        INSTALL_PREFIX "${HAZEL_DEVEL_PREFIX}"
    )
endif()

if(BUILD_DOCS)
    add_subdirectory(docs)
endif()

install(FILES
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
    DESTINATION "${HAZEL_PACKAGE_CMAKE_DESTINATION}"
)

install(DIRECTORY cmake/ DESTINATION "${HAZEL_PACKAGE_CMAKE_DESTINATION}")
if(HAZEL_DEVEL_PREFIX)
    file(COPY cmake/ DESTINATION "${HAZEL_DEVEL_PREFIX}/${HAZEL_PACKAGE_CMAKE_DESTINATION}")
endif()

hazel_python_setup(GLOBAL_SCRIPTS)
