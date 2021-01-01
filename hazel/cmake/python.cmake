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

function(hazel_find_python_interpreter)
    set(PYTHON_VERSION "$ENV{ROS_PYTHON_VERSION}" CACHE STRING "Use specific Python version")
    find_package(Python ${PYTHON_VERSION} REQUIRED COMPONENTS Interpreter)
    execute_process(COMMAND "${Python_EXECUTABLE}" -c "import os, sysconfig;print(os.path.relpath(sysconfig.get_path('purelib'), sysconfig.get_path('data')))" OUTPUT_VARIABLE packages_dir OUTPUT_STRIP_TRAILING_WHITESPACE)    
    set(HAZEL_PYTHON_EXECUTABLE "${Python_EXECUTABLE}" PARENT_SCOPE)
    set(HAZEL_PYTHON_SITE_PACKAGES_DIR "${packages_dir}" PARENT_SCOPE)
    set(use_deb_layout OFF)
    if(EXISTS /etc/debian_version)
        set(use_deb_layout ON)
    endif()
    option(SETUPTOOLS_DEB_LAYOUT "Enable Debian-style python package layout" ${use_deb_layout})
    set(HAZEL_PYTHON_INSTALL_LAYOUT "" PARENT_SCOPE)
    if(SETUPTOOLS_DEB_LAYOUT)
        if(Python_VERSION VERSION_GREATER_EQUAL "3.0")
            set(packages_dir "lib/python${Python_VERSION_MAJOR}/dist-packages")
        else()
            set(packages_dir "lib/python${Python_VERSION_MAJOR}.${Python_VERSION_MINOR}/dist-packages")
        endif()
        set(HAZEL_PYTHON_INSTALL_LAYOUT "--install-layout=deb" PARENT_SCOPE)
    endif()
    set(HAZEL_PYTHON_INSTALL_PACKAGES_DIR "${packages_dir}" PARENT_SCOPE)
    hazel_list_from_path_var(path_list "$ENV{PYTHONPATH}")
    list(REVERSE HAZEL_PREFIX_PATH)
    foreach(prefix IN LISTS HAZEL_PREFIX_PATH)
        if(NOT "${prefix}/${packages_dir}" IN_LIST path_list)
            list(INSERT path_list 0 "${prefix}/${packages_dir}")
        endif()
    endforeach()
    if(PROJECT_NAME STREQUAL "hazel")
        list(REMOVE_ITEM path_list "${PROJECT_SOURCE_DIR}/src")
        list(INSERT path_list 0 "${PROJECT_SOURCE_DIR}/src")
    endif()
    if(UNIX)
        string(REPLACE ";" ":" path_list "${path_list}")
    endif()
    set(ENV{PYTHONPATH} "${path_list}")
endfunction()

function(hazel_python_setup)
    cmake_parse_arguments(arg "GLOBAL" "SRCDIR" "" ${ARGN})
    if(arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "package '${PROJECT_NAME}' called hazel_python_setup() with invalid parameters: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT DEFINED arg_SRCDIR)
        set(arg_SRCDIR "${CMAKE_CURRENT_SOURCE_DIR}")
    endif()
    if(arg_GLOBAL)
        set(script_bindir "${HAZEL_GLOBAL_BIN_DESTINATION}")
    else()
        set(script_bindir "${HAZEL_PACKAGE_BIN_DESTINATION}")
    endif()
    if(EXISTS "${arg_SRCDIR}/setup.py")
        if(HAZEL_DEVEL_PREFIX)
            set(HAZEL_GENERATED_DIR "${CMAKE_CURRENT_BINARY_DIR}/hazel-generated")
            set(HAZEL_DEVEL_PYTHON_DIR "${HAZEL_DEVEL_PREFIX}/${HAZEL_PYTHON_INSTALL_PACKAGES_DIR}")
            file(MAKE_DIRECTORY "${HAZEL_GENERATED_DIR}" "${HAZEL_DEVEL_PYTHON_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/python-setup/build")
            hazel_list_from_path_var(path_list "$ENV{PYTHONPATH}")
            if(PROJECT_NAME STREQUAL "hazel")
                list(REMOVE_ITEM path_list "${PROJECT_SOURCE_DIR}/src")
            endif()
            if(UNIX)
                string(REPLACE ";" ":" path_list "${path_list}")
            endif()
            set(PYTHONPATH "${path_list}")
            add_custom_command(OUTPUT "${HAZEL_GENERATED_DIR}/python-develspace.stamp"
                MAIN_DEPENDENCY "${arg_SRCDIR}/setup.py"
                WORKING_DIRECTORY "${arg_SRCDIR}"
                COMMAND "${CMAKE_COMMAND}" -E env "PYTHONPATH=${PYTHONPATH}" "${HAZEL_PYTHON_EXECUTABLE}" -m pip install --no-deps -b "${CMAKE_CURRENT_BINARY_DIR}/python-setup/build" --prefix "${HAZEL_DEVEL_PREFIX}" "--install-option=--install-dir=${HAZEL_DEVEL_PYTHON_DIR}" "--install-option=--script-dir=${HAZEL_DEVEL_PREFIX}/${script_bindir}" --editable "${arg_SRCDIR}"
                COMMAND "${CMAKE_COMMAND}" -E touch "${HAZEL_GENERATED_DIR}/python-develspace.stamp"
                VERBATIM)
            add_custom_target(python-develspace ALL DEPENDS "${HAZEL_GENERATED_DIR}/python-develspace.stamp")
        endif()
        file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/python-setup/build" "${CMAKE_CURRENT_BINARY_DIR}/python-setup/egg-info")
        install(CODE "execute_process(WORKING_DIRECTORY \"${arg_SRCDIR}\" COMMAND \"${HAZEL_PYTHON_EXECUTABLE}\" setup.py build -b \"${CMAKE_CURRENT_BINARY_DIR}/python-setup/build\" egg_info -e \"${CMAKE_CURRENT_BINARY_DIR}/python-setup/egg-info\" install \"--install-scripts=${CMAKE_INSTALL_PREFIX}/${script_bindir}\" \"--install-lib=${CMAKE_INSTALL_PREFIX}/${HAZEL_PYTHON_INSTALL_PACKAGES_DIR}\" --root \"\$ENV{DESTDIR}/\" --prefix \"${CMAKE_INSTALL_PREFIX}\" ${HAZEL_PYTHON_INSTALL_LAYOUT})")
    else()
        message(SEND_ERROR "hazel_python_setup: 'setup.py' not found in '${arg_SRCDIR}'")
    endif()
endfunction()
