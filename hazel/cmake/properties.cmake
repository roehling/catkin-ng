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
function(hazel_define_property name brief_docs)
    define_property(DIRECTORY "${PROJECT_SOURCE_DIR}" PROPERTY "${name}" BRIEF_DOCS "${brief_docs}")
endfunction()

function(hazel_get_properties)
    foreach(name IN ITEMS ${ARGN})
        get_property(value DIRECTORY "${PROJECT_SOURCE_DIR}" PROPERTY "${name}")
        set(${name} "${value}" PARENT_SCOPE)
    endforeach()
endfunction()

function(hazel_set_property name)
    set_property(DIRECTORY "${PROJECT_SOURCE_DIR}" PROPERTY "${name}" ${ARGN})
endfunction()

function(hazel_append_property name)
    set_property(DIRECTORY "${PROJECT_SOURCE_DIR}" APPEND PROPERTY "${name}" ${ARGN})
endfunction()

function(hazel_append_property_unique name)
    get_property(old_value DIRECTORY "${PROJECT_SOURCE_DIR}" PROPERTY "${name}")
    foreach(value IN ITEMS ${ARGN})
        if(NOT value IN_LIST old_value)
            set_property(DIRECTORY "${PROJECT_SOURCE_DIR}" APPEND PROPERTY "${name}" "${value}")
            list(APPEND old_value "${value}")
        endif()
    endforeach()
endfunction()
