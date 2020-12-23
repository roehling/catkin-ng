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
macro(catkin_find_python_interpreter)
    if("$ENV{ROS_PYTHON_VERSION}" STREQUAL "2")
        find_package(Python2 COMPONENTS Interpreter REQUIRED)
        set(CATKIN_PYTHON_EXECUTABLE "${Python2_EXECUTABLE}")
        if(CATKIN_DEVEL_PREFIX)
            set(CATKIN_DEVEL_PYTHON_DIR "${CATKIN_DEVEL_PREFIX}/lib/python${Python2_VERSION_MAJOR}.${Python2_VERSION_MINOR}/site-packages")
        endif()
        if(EXISTS /etc/debian_version)
            set(CATKIN_GLOBAL_PYTHON_DESTINATION "lib/python${Python2_VERSION_MAJOR}.${Python2_VERSION_MINOR}/dist-packages")
        else()
            set(CATKIN_GLOBAL_PYTHON_DESTINATION "lib/python${Python2_VERSION_MAJOR}.${Python2_VERSION_MINOR}/site-packages")
        endif()
    else()
        find_package(Python3 COMPONENTS Interpreter REQUIRED)
        set(CATKIN_PYTHON_EXECUTABLE "${Python3_EXECUTABLE}")
        if(CATKIN_DEVEL_PREFIX)
            set(CATKIN_DEVEL_PYTHON_DIR "${CATKIN_DEVEL_PREFIX}/lib/python${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}/site-packages")
        endif()
        if(EXISTS /etc/debian_version)
            set(CATKIN_GLOBAL_PYTHON_DESTINATION "lib/python${Python3_VERSION_MAJOR}/dist-packages")
        else()
            set(CATKIN_GLOBAL_PYTHON_DESTINATION "lib/python${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}/site-packages")
        endif()
    endif()
    set(CATKIN_PACKAGE_PYTHON_DESTINATION "${CATKIN_GLOBAL_PYTHON_DESTINATION}/${PROJECT_NAME}")
endmacro()

function(catkin_python_setup)
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/setup.py")
        if(CATKIN_DEVEL_PREFIX)
            file(MAKE_DIRECTORY "${CATKIN_DEVEL_PYTHON_DIR}")
            set(CATKIN_GENERATED_DIR "${CMAKE_CURRENT_BINARY_DIR}/catkin-generated")
            add_custom_command(OUTPUT "${CATKIN_GENERATED_DIR}/python-develspace.stamp"
                MAIN_DEPENDENCY "${CMAKE_CURRENT_SOURCE_DIR}/setup.py"
                COMMAND "${CMAKE_COMMAND}" -E env "PYTHONPATH=${CATKIN_DEVEL_PYTHON_DIR}" "${CATKIN_PYTHON_EXECUTABLE}" -m pip install --no-deps --prefix "${CATKIN_DEVEL_PREFIX}" --editable "${CMAKE_CURRENT_SOURCE_DIR}"
                COMMAND "${CMAKE_COMMAND}" -E touch "${CATKIN_GENERATED_DIR}/python-develspace.stamp"
                VERBATIM)
            add_custom_target(python-develspace ALL DEPENDS "${CATKIN_GENERATED_DIR}/python-develspace.stamp")
        endif()
        if(EXISTS /etc/debian_version)
            set(CATKIN_PYTHON_LAYOUT "--install-layout=deb")
        endif()
        install(CODE "execute_process(WORKING_DIRECTORY \"${CMAKE_CURRENT_SOURCE_DIR}\" COMMAND ${CATKIN_PYTHON_EXECUTABLE} setup.py install ${CATKIN_PYTHON_LAYOUT} --root \"\$ENV{DESTDIR}/\" --prefix \"${CMAKE_INSTALL_PREFIX}\")")
    else()
        message(SEND_ERROR "catkin_python_setup: 'setup.py' not found in current source directory '${CMAKE_CURRENT_SOURCE_DIR}'")
    endif()
endfunction()
