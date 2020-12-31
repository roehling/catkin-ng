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
@# The following license applies to all configuration files which are
@# generated from this template:
##############################################################################
#
# package configuration file generated by the Hazel Build System
# Copyright 2020 Timo Röhling <timo@@gaussglocke.de>
#
# Copying and distribution of this file, with or without modification, are
# permitted in any medium without royalty, provided the copyright notice and
# this notice are preserved. This file is offered as-is, without any warranty.
#
##############################################################################
@@PACKAGE_INIT@@

@# Prevent circular dependencies leading into an infinite loop
if(@@PROJECT_NAME@@_FOUND)
    return()
endif()

set(@@PROJECT_NAME@@_IS_HAZEL_PACKAGE TRUE)
set(@@PROJECT_NAME@@_HAZEL_VERSION "@@HAZEL_VERSION@@")
set(@@PROJECT_NAME@@_TARGETS)
set(@@PROJECT_NAME@@_FOUND TRUE)

@[if EXPORTED_DEPENDS]@
include(CMakeFindDependencyMacro)
@[for dep in EXPORTED_DEPENDS]@
find_dependency(@dep)
@[end for]@
@[end if]@

@[for inc in EXPORTED_CMAKE_FILES]@
include("${CMAKE_CURRENT_LIST_DIR}/@(inc).cmake")
@[end for]@

if(NOT @@PROJECT_NAME@@_FOUND)
    return()
endif()

@[if EXPORTED_TARGET_FILES]@
find_package(Python REQUIRED QUIET COMPONENTS Interpreter)
execute_process(WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" COMMAND "${Python_EXECUTABLE}" "list_exported_targets.py"
    @(" ".join("\"%s.cmake\"" % f for f in EXPORTED_TARGET_FILES))
    OUTPUT_VARIABLE @@PROJECT_NAME@@_DISCOVERED_TARGETS OUTPUT_STRIP_TRAILING_WHITESPACE)
list(APPEND @@PROJECT_NAME@@_TARGETS ${@@PROJECT_NAME@@_DISCOVERED_TARGETS})
@[end if]@

list(APPEND HAZEL_IMPORTED_PACKAGES "@@PROJECT_NAME@@")

if(NOT @@PROJECT_NAME@@_FIND_QUIETLY)
@[if EXPORTED_TARGET_FILES]@
    list(LENGTH @@PROJECT_NAME@@_TARGETS target_count)
    message(STATUS "Found @@PROJECT_NAME@@: ${PACKAGE_PREFIX_DIR} (found version \"@@PROJECT_VERSION@@\") imported targets: ${target_count}")
@[else]@
    message(STATUS "Found @@PROJECT_NAME@@: ${PACKAGE_PREFIX_DIR} (found version \"@@PROJECT_VERSION@@\")")
@[end if]@
endif()

if(DEFINED HAZEL_PACKAGE_NAME AND NOT "@@PROJECT_NAME@@" IN_LIST HAZEL_PACKAGE_BUILD_DEPENDS)
    message(AUTHOR_WARNING "Package '${HAZEL_PACKAGE_NAME}' does not declare its build_depend on '@@PROJECT_NAME@@'")
endif()
