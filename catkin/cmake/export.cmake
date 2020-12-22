##############################################################################
#
# catkin-ng
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
set(CATKIN_PACKAGE_EXPORTS)
set(CATKIN_PACKAGE_CMAKE_FILES)

function(catkin_export)
    cmake_parse_arguments(arg "" "EXPORT;FILE;NAMESPACE" "TARGETS;SCRIPTS" ${ARGN})
    if(arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "package '${PROJECT_NAME}' called catkin_export() with invalid parameters: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT DEFINED arg_NAMESPACE)
        set(arg_NAMESPACE "${PROJECT_NAME}::")
    endif()
    if(arg_TARGETS AND NOT arg_EXPORT)
        set(arg_EXPORT "${PROJECT_NAME}Targets")
        set(number 1)
        while(arg_EXPORT IN_LIST CATKIN_PACKAGE_EXPORTS)
            math(EXPR number "${number} + 1")
            set(arg_EXPORT "${PROJECT_NAME}Targets-${number}")
        endwhile()
    endif()
    if(arg_EXPORT)
        if(arg_EXPORT IN_LIST CATKIN_PACKAGE_EXPORTS)
            message(FATAL_ERROR "package '${PROJECT_NAME}' exports '${arg_EXPORT}' multiple times")
        endif()
        if(NOT arg_FILE)
            set(arg_FILE "${arg_EXPORT}")
        endif()
    endif()
    if(arg_FILE)
        if(arg_FILE MATCHES "^(.*)\\.cmake$")
            set(arg_FILE "${CMAKE_MATCH_1}")
        endif()
        if(NOT arg_FILE MATCHES "^.+Targets?$" AND NOT arg_FILE MATCHES "^.+-targets?$")
            set(arg_FILE "${arg_FILE}Targets")
        endif()
        set(file_stem "${arg_FILE}")
        set(number 1)
        while(arg_FILE IN_LIST CATKIN_PACKAGE_CMAKE_FILES)
            math(EXPR number "${number} + 1")
            set(arg_FILE "${file_stem}-${number}")
        endwhile()
    endif()
    if(arg_TARGETS)
        install(TARGETS "${arg_TARGETS}" EXPORT "${arg_EXPORT}"
            RUNTIME DESTINATION "${CATKIN_PACKAGE_BIN_DESTINATION}"
            ARCHIVE DESTINATION "${CATKIN_PACKAGE_LIB_DESTINATION}"
            LIBRARY DESTINATION "${CATKIN_PACKAGE_LIB_DESTINATION}"
            OBJECTS DESTINATION "${CATKIN_PACKAGE_OBJECTS_DESTINATION}"
            PUBLIC_HEADER DESTINATION "${CATKIN_PACKAGE_INCLUDE_DESTINATION}"
            INCLUDES DESTINATION "${CATKIN_GLOBAL_INCLUDE_DESTINATION}"
        )
    endif()
    if(CATKIN_DEVEL_PREFIX)
        file(MAKE_DIRECTORY "${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_CMAKE_DESTINATION}")
    endif()
    if(arg_EXPORT)
        install(EXPORT "${arg_EXPORT}" NAMESPACE "${arg_NAMESPACE}" DESTINATION "${CATKIN_PACKAGE_CMAKE_DESTINATION}" FILE "${arg_FILE}.cmake")
        if(CATKIN_DEVEL_PREFIX)
            export(EXPORT "${arg_EXPORT}" NAMESPACE "${arg_NAMESPACE}" FILE "${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_CMAKE_DESTINATION}/${arg_FILE}.cmake")
        endif()
        list(APPEND CATKIN_PACKAGE_EXPORTS "${arg_EXPORT}")
        list(APPEND CATKIN_PACKAGE_CMAKE_FILES "${arg_FILE}")
    endif()
    if(arg_SCRIPTS)
        _catkin_export_scripts(arg_SCRIPTS)
    endif()
    set(CATKIN_PACKAGE_EXPORTS "${CATKIN_PACKAGE_EXPORTS}" PARENT_SCOPE)
    set(CATKIN_PACKAGE_CMAKE_FILES "${CATKIN_PACKAGE_CMAKE_FILES}" PARENT_SCOPE)
endfunction()

macro(_catkin_export_scripts)
    set(CATKIN_GENERATED_DIR "${CMAKE_CURRENT_BINARY_DIR}/catkin-generated")
    file(MAKE_DIRECTORY "${CATKIN_GENERATED_DIR}" "${CATKIN_GENERATED_DIR}/scripts" "${CATKIN_GENERATED_DIR}/scripts/develspace" "${CATKIN_GENERATED_DIR}/scripts/installspace")
    set(PREFIX "\${PACKAGE_PREFIX_DIR}")
    if(CATKIN_DEVEL_PREFIX)
        set(DEVELSPACE TRUE)
        set(INSTALLSPACE FALSE)
        configure_file("${CATKIN_CMAKE_DIR}/script.context.in" "${CATKIN_GENERATED_DIR}/script.develspace.context")
    endif()
    set(DEVELSPACE FALSE)
    set(INSTALLSPACE TRUE)
    configure_file("${CATKIN_CMAKE_DIR}/script.context.in" "${CATKIN_GENERATED_DIR}/script.installspace.context")
    unset(DEVELSPACE)
    unset(INSTALLSPACE)
    foreach(script IN LISTS ARGN)
        if(script MATCHES "^(.*)\\.cmake(\\.in|\\.em|\\.develspace\\.em|\\.installspace\\.em)?$")
            set(script "${CMAKE_MATCH_1}")
        endif()
        get_filename_component(script_name "${script}" NAME)
        if(script_name IN_LIST CATKIN_PACKAGE_CMAKE_FILES)
            message(FATAL_ERROR "package '${PROJECT_NAME}' installs CMake script '${script_name}' more than once")
        endif()
        set(devel_script)
        set(install_script)
        if(EXISTS "${script}.cmake")  # install as-is
            set(devel_script "${script}.cmake")
            set(install_script "${script}.cmake")
        elseif(EXISTS "${script}.cmake.in")  # run configure_file() on it
            set(install_script "${CATKIN_GENERATED_DIR}/scripts/${script_name}.cmake")
            if(CATKIN_DEVEL_PREFIX)
                set(devel_script "${install_script}")
            endif()
        elseif(EXISTS "${script}.cmake.em")  # run empy on it
            if(CATKIN_DEVEL_PREFIX)
                set(devel_script "${CATKIN_GENERATED_DIR}/scripts/develspace/${script_name}.cmake")
                execute_process(COMMAND "${CATKIN_PYTHON_EXECUTABLE}" -m em -F "${CATKIN_GENERATED_DIR}/script.develspace.context" -o "${devel_script}" "${script}.cmake.em")
            endif()
            set(install_script "${CATKIN_GENERATED_DIR}/scripts/installspace/${script_name}.cmake")
            execute_process(COMMAND "${CATKIN_PYTHON_EXECUTABLE}" -m em -F "${CATKIN_GENERATED_DIR}/script.installspace.context" -o "${install_script}" "${script}.cmake.em")
        elseif(EXISTS "${script}.cmake.develspace.em" OR EXISTS "${script}.cmake.installspace.em")  # run empy on it, different versions for develspace and installspace
            if(CATKIN_DEVEL_PREFIX)
                set(devel_script "${CATKIN_GENERATED_DIR}/scripts/develspace/${script_name}.cmake")
                if(EXISTS "${script}.cmake.develspace.em")
                    execute_process(COMMAND "${CATKIN_PYTHON_EXECUTABLE}" -m em -F "${CATKIN_GENERATED_DIR}/script.develspace.context" -o "${devel_script}" "${script}.cmake.develspace.em")
                else()
                    file(WRITE "${devel_script}" "# This script is unavailable in develspace")
                endif()
            endif()
            set(install_script "${CATKIN_GENERATED_DIR}/scripts/installspace/${script_name}.cmake")
            if(EXISTS "${script}.cmake.installspace.em")
                execute_process(COMMAND "${CATKIN_PYTHON_EXECUTABLE}" -m em -F "${CATKIN_GENERATED_DIR}/script.installspace.context" -o "${install_script}" "${script}.cmake.installspace.em")
            else()
                file(WRITE "${install_script}" "# This script is unavailable in installspace")
            endif()
        else()
            message(SEND_ERROR "cannot find installable CMake script '${script_name}' for package '${PROJECT_NAME}'")
        endif()
        if(devel_script)
            file(COPY "${devel_script}" DESTINATION "${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_CMAKE_DESTINATION}")
        endif()
        if(install_script)
            install(FILES "${install_script}" DESTINATION "${CATKIN_PACKAGE_CMAKE_DESTINATION}")
        endif()
        list(APPEND CATKIN_PACKAGE_CMAKE_FILES "${script_name}")
    endforeach()
endmacro()
