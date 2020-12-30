
##############################################################################
#
# Hazel Build System
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
function(hazel_paths)
    hazel_list_from_path_var(path_list "${HAZEL_PREFIX_PATH}" "$ENV{HAZEL_PREFIX_PATH}")
    list(REVERSE path_list)
    if(HAZEL_DEVEL_PREFIX)
        list(APPEND path_list "${HAZEL_DEVEL_PREFIX}")
    endif()
    set(HAZEL_PREFIX_PATH)
    foreach(item IN LISTS path_list)
        if(NOT item IN_LIST HAZEL_PREFIX_PATH)
            list(INSERT HAZEL_PREFIX_PATH 0 "${item}")
        endif()
        if(NOT item IN_LIST CMAKE_PREFIX_PATH)
            list(INSERT CMAKE_PREFIX_PATH 0 "${item}")
        endif()
    endforeach()
    set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}" PARENT_SCOPE)
    set(HAZEL_PREFIX_PATH "${HAZEL_PREFIX_PATH}" PARENT_SCOPE)
endfunction()

function(hazel_list_from_path_var outvar)
    set(path_list ${ARGN})
    if(UNIX)
        string(REPLACE ":" ";" path_list "${path_list}")
    endif()
    set(${outvar} "${path_list}" PARENT_SCOPE)
endfunction()
