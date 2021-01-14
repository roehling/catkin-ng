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
macro(hazel_project)
    set(HAZEL_PACKAGE_XML "${PROJECT_SOURCE_DIR}/package.xml")
    if(NOT EXISTS "${HAZEL_PACKAGE_XML}")
        message(FATAL_ERROR "cannot find 'package.xml' in project source directory")
    endif()
    set(HAZEL_GENERATED_DIR "${CMAKE_CURRENT_BINARY_DIR}/hazel-generated")
    file(MAKE_DIRECTORY "${HAZEL_GENERATED_DIR}")
    execute_process(COMMAND ${HAZEL_PYTHON_EXECUTABLE} -m hazel package --cmake --main --source "${HAZEL_PACKAGE_XML}" OUTPUT_FILE "${HAZEL_GENERATED_DIR}/package-metadata.cmake" RESULT_VARIABLE hazel_package_info_result)
    if(NOT hazel_package_info_result EQUAL 0)
        message(FATAL_ERROR "failed to parse package metadata")
    endif()
    include("${HAZEL_GENERATED_DIR}/package-metadata.cmake")
    unset(HAZEL_GENERATED_DIR)
    if(NOT PROJECT_NAME STREQUAL "${HAZEL_PACKAGE_NAME}")
        message(FATAL_ERROR "project name '${PROJECT_NAME}' differs from package name '${HAZEL_PACKAGE_NAME}'")
    endif()
    if(PROJECT_VERSION)
        set(_hazel_version_mmp "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")
        if(NOT _hazel_version_mmp VERSION_EQUAL "${HAZEL_PACKAGE_VERSION}")
            message(AUTHOR_WARNING "project version '${PROJECT_VERSION}' differs from package version '${HAZEL_PACKAGE_VERSION}'")
        endif()
        unset(_hazel_version_mmp)
    endif()
    if(NOT PROJECT_VERSION)
        set(PROJECT_VERSION "${HAZEL_PACKAGE_VERSION}")
        if(HAZEL_PACKAGE_VERSION MATCHES "^([0-9]+)\\.([0-9]+)\\.([0-9]+)")
            set(PROJECT_VERSION_MAJOR "${CMAKE_MATCH_1}")
            set(PROJECT_VERSION_MINOR "${CMAKE_MATCH_2}")
            set(PROJECT_VERSION_PATCH "${CMAKE_MATCH_3}")
        endif()
    endif()
    if(NOT "hazel" IN_LIST HAZEL_PACKAGE_BUILDTOOL_DEPENDS AND NOT PROJECT_NAME STREQUAL "hazel")
        message(AUTHOR_WARNING "package '${PROJECT_NAME}' does not declare its buildtool_depend on 'hazel'")
    endif()
endmacro()
