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
    cmake_parse_arguments(arg "REQUIRED;QUIET;PKG_SEARCH_MODULE;PKG_CHECK_MODULES" "" "" ${ARGN})
    if(arg_REQUIRED)
        set(is_required "REQUIRED")
    else()
        set(is_required)
    endif()
    if(arg_PKG_SEARCH_MODULE AND arg_PKG_CHECK_MODULES)
        message(FATAL_ERROR "hazel_import: PKG_SEARCH_MODULE AND PKG_CHECK_MODULES are mutually exclusive options")
    endif()
    if(arg_QUIET)
        set(is_quiet "QUIET")
    else()
        set(is_quiet)
    endif()
    if(arg_PKG_SEARCH_MODULE)
        set(pkg_func "pkg_search_module")
    else()
        set(pkg_func "pkg_check_modules")
    endif()
    if(target MATCHES "^([A-Za-z0-9]+)::(.+)")
        set(type "${CMAKE_MATCH_1}")
        set(target "${CMAKE_MATCH_2}")
        string(TOLOWER "${type}" type_lc)
        string(TOLOWER "${target}" target_lc)
        string(REGEX REPLACE "[^a-z0-9_]" "_" target_lc "${target_lc}")
        if(NOT type STREQUAL "PkgConfig" AND (arg_PKG_SEARCH_MODULE OR arg_PKG_CHECK_MODULES))
            message(FATAL_ERROR "hazel_import: PKG_SEARCH_MODULE AND PKG_CHECK_MODULES are valid with PkgConfig modules only")
        endif()
        set(target_version "")
        set(extra_args "${arg_UNPARSED_ARGUMENTS}")
        if(extra_args)
            list(GET extra_args 0 maybe_version)
            if(maybe_version MATCHES "^[0-9].*")
                set(target_version "${maybe_version}")
                list(REMOVE_AT extra_args 0)
            endif()
        endif()
        if(EXISTS "${HAZEL_CMAKE_DIR}/import_${type_lc}.cmake.in")
            set(HAZEL_GENERATED_DIR "${CMAKE_CURRENT_BINARY_DIR}/hazel-generated")
            file(MAKE_DIRECTORY "${HAZEL_GENERATED_DIR}")
            set(GENERATED_CONFIG "${HAZEL_GENERATED_DIR}/__import_${type_lc}_${target_lc}.cmake")
            if(NOT EXISTS "${GENERATED_CONFIG}")
                configure_file("${HAZEL_CMAKE_DIR}/import_${type_lc}.cmake.in" "${GENERATED_CONFIG}" @ONLY)
                include("${GENERATED_CONFIG}")
                if(${target}_VERSION)
                    set(target_version "${${target}_VERSION}")
                    configure_file("${HAZEL_CMAKE_DIR}/import_${type_lc}.cmake.in" "${GENERATED_CONFIG}" @ONLY)
                endif()
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
