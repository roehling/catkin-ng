##############################################################################
#
# hazel
# Copyright 2020 Timo Röhling <timo@gaussglocke.de>
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
set(HAZEL_IMPORTED_CATKIN)
set(HAZEL_IMPORTED_PKGCONFIG)

function(hazel_import_pkgconfig target)
    cmake_parse_arguments(arg "REQUIRED;QUIET" "" "" ${ARGN})
    if(arg_REQUIRED)
        set(arg_REQUIRED "REQUIRED")
    else()
        set(arg_REQUIRED)
    endif()
    if(arg_QUIET)
        set(arg_QUIET "QUIET")
    else()
        set(arg_QUIET)
    endif()
    if(target MATCHES "^pkg-config::(.+)")
        set(target "${CMAKE_MATCH_1}")
    endif()
    if (NOT target MATCHES "^[A-Za-z0-9_-]+$")
        message(FATAL_ERROR "hazel_import_pkgconfig: invalid target '${target}'. Target name must look like \"pkg-config::NAME\" or \"NAME\", and NAME must be a valid identifier.")
    endif()
    set(HAZEL_GENERATED_DIR "${CMAKE_CURRENT_BINARY_DIR}/hazel-generated")
    file(MAKE_DIRECTORY "${HAZEL_GENERATED_DIR}")
    set(GENERATED_CONFIG "${HAZEL_GENERATED_DIR}/import_pkgconfig_${target}.cmake")
    configure_file("${HAZEL_CMAKE_DIR}/import_pkgconfig.cmake.in" "${GENERATED_CONFIG}" @ONLY)
    include("${GENERATED_CONFIG}")
    list(APPEND HAZEL_IMPORTED_PKGCONFIG "${target}")
    set(HAZEL_IMPORTED_PKGCONFIG "${HAZEL_IMPORTED_PKGCONFIG}" PARENT_SCOPE)
    set(HAZEL_PACKAGE_IMPORT_PKGCONFIG_${target} "${GENERATED_CONFIG}" PARENT_SCOPE)
endfunction()
