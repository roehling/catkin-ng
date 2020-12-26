@##############################################################################
@#
@# Hazel Build System
@# Copyright 2020 Timo Röhling <timo@gaussglocke.de>
@#
@# Licensed under the Apache License, Version 2.0 (the "License");
@# you may not use this file except in compliance with the License.
@# You may obtain a copy of the License at
@#
@# http://www.apache.org/licenses/LICENSE-2.0
@#
@# Unless required by applicable law or agreed to in writing, software
@# distributed under the License is distributed on an "AS IS" BASIS,
@# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@# See the License for the specific language governing permissions and
@# limitations under the License.
@#
@##############################################################################
@@PACKAGE_INIT@@

if(@@PROJECT_NAME@@_FOUND AND "@@PROJECT_NAME@@" IN_LIST HAZEL_IMPORTED_PACKAGES)
    return()
endif()

set(@@PROJECT_NAME@@_IS_HAZEL_PACKAGE TRUE)
set(@@PROJECT_NAME@@_HAZEL_VERSION "@@HAZEL_VERSION@@")
set(@@PROJECT_NAME@@_EXPORTED_TARGETS)

@[if EXPORTED_DEPENDS]@
include(CMakeFindDependencyMacro)
@[for dep in EXPORTED_DEPENDS]@
find_dependency(@dep)
@[end for]@
@[end if]@

@[for inc in EXPORTED_CMAKE_FILES]@
include("${CMAKE_CURRENT_LIST_DIR}/@(inc).cmake")
@[end for]@

@[if EXPORTED_TARGET_FILES]@
find_package(Python QUIET COMPONENTS Interpreter)
if(Python_FOUND)
    foreach(file IN ITEMS @(" ".join(EXPORTED_TARGET_FILES)))
        execute_process(COMMAND "${Python_EXECUTABLE}" "${CMAKE_CURRENT_LIST_DIR}/list_exported_targets.py" "${CMAKE_CURRENT_LIST_DIR}/${file}.cmake" OUTPUT_VARIABLE exported_targets OUTPUT_STRIP_TRAILING_WHITESPACE)
        foreach(target IN LISTS exported_targets)
            list(APPEND @@PROJECT_NAME@@_EXPORTED_TARGETS "${target}")
        endforeach()
    endforeach()
endif()

@[end if]@
list(APPEND HAZEL_IMPORTED_PACKAGES "@@PROJECT_NAME@@")

if(NOT @@PROJECT_NAME@@_FIND_QUIETLY)
    list(LENGTH @@PROJECT_NAME@@_EXPORTED_TARGETS target_count)
    message(STATUS "Found @@PROJECT_NAME@@: ${PACKAGE_PREFIX_DIR} (found version \"@@PROJECT_VERSION@@\") imported targets: ${target_count}")
endif()
set(@@PROJECT_NAME@@_FOUND TRUE)

if(DEFINED HAZEL_PACKAGE_NAME AND NOT "@@PROJECT_NAME@@" IN_LIST HAZEL_PACKAGE_BUILD_DEPENDS)
    message(AUTHOR_WARNING "Package '${HAZEL_PACKAGE_NAME}' does not declare its build_depend on '@@PROJECT_NAME@@'")
endif()
