##############################################################################
#
# Hazel Build System
# Copyright 2020,2021 Timo Röhling <timo@gaussglocke.de>
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
function(hazel_import target)
    cmake_parse_arguments(arg "REQUIRED;QUIET" "" "" ${ARGN})
    if(arg_REQUIRED)
        set(is_required "REQUIRED")
    else()
        set(is_required)
    endif()
    if(arg_QUIET)
        set(is_quiet "QUIET")
    else()
        set(is_quiet)
    endif()
    if(target MATCHES "^([a-z0-9]+)::(.+)")
        set(type "${CMAKE_MATCH_1}")
        set(target "${CMAKE_MATCH_2}")
        set(extra_args "${arg_UNPARSED_ARGUMENTS}")
        if(EXISTS "${HAZEL_CMAKE_DIR}/import_${type}.cmake.in")
            set(HAZEL_GENERATED_DIR "${CMAKE_CURRENT_BINARY_DIR}/hazel-generated")
            file(MAKE_DIRECTORY "${HAZEL_GENERATED_DIR}")
            set(GENERATED_CONFIG "${HAZEL_GENERATED_DIR}/__import_${type}_${target}.cmake")
            if(NOT EXISTS "${GENERATED_CONFIG}")
                configure_file("${HAZEL_CMAKE_DIR}/import_${type}.cmake.in" "${GENERATED_CONFIG}" @ONLY)
                include("${GENERATED_CONFIG}")
                hazel_set_property(HAZEL_PACKAGE_IMPORT_FILE_${type}_${target} "${GENERATED_CONFIG}")
                hazel_append_property(HAZEL_PACKAGE_IMPORTED_TARGETS "${type}::${target}")
            else()
                message(FATAL_ERROR "hazel_import: duplicate import of target '${target}'")
            endif()
        else()
            message(FATAL_ERROR "hazel_import: unknown import source '${type}' for target '${target}'")
        endif()
    else()
        message(FATAL_ERROR "hazel_import: invalid target '${target}'. Supported targets are in the format \"SOURCE::NAME\"")
    endif()
endfunction()
