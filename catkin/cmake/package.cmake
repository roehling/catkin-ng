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
function(catkin_package)
    cmake_parse_arguments(arg "" "COMPATIBILITY;EXPORT;NAMESPACE" "DEPENDS;TARGETS;SCRIPTS" ${ARGN})
    if(arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "package '${PROJECT_NAME}' called catkin_package() with invalid parameters: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT DEFINED arg_NAMESPACE)
        set(arg_NAMESPACE "${PROJECT_NAME}::")
    endif()
    if(NOT DEFINED arg_COMPATIBILITY)
        set(arg_COMPATIBILITY ExactVersion)
    endif()

    include(CMakePackageConfigHelpers)
    set(CATKIN_GENERATED_DIR "${CMAKE_CURRENT_BINARY_DIR}/catkin-generated")
    file(MAKE_DIRECTORY "${CATKIN_GENERATED_DIR}")
    list(TRANSFORM arg_LIBRARIES PREPEND "${arg_NAMESPACE}")
    set(CATKIN_PACKAGE_LIBRARIES "${arg_LIBRARIES}")

    catkin_export(EXPORT "${arg_EXPORT}" NAMESPACE "${arg_NAMESPACE}" FILE "${PROJECT_NAME}Targets" TARGETS ${arg_TARGETS} SCRIPTS ${arg_SCRIPTS})

    configure_file("${CATKIN_CMAKE_DIR}/package-config.context.in" "${CATKIN_GENERATED_DIR}/package-config.context" @ONLY)
    execute_process(COMMAND "${CATKIN_PYTHON_EXECUTABLE}" -m em -F "${CATKIN_GENERATED_DIR}/package-config.context" -o "${CATKIN_GENERATED_DIR}/package-config.cmake.in" "${CATKIN_CMAKE_DIR}/package-config.cmake.em")
    if(CATKIN_PACKAGE_ARCHITECTURE_INDEPENDENT)
        set(arch_indep ARCH_INDEPENDENT)
    else()
        set(arch_indep)
    endif()
    write_basic_package_version_file("${CATKIN_GENERATED_DIR}/${PROJECT_NAME}ConfigVersion.cmake" VERSION "${PROJECT_VERSION}" COMPATIBILITY "${arg_COMPATIBILITY}" ${arch_indep})
    if(CATKIN_DEVEL_PREFIX)
        file(COPY "${CATKIN_GENERATED_DIR}/${PROJECT_NAME}ConfigVersion.cmake" DESTINATION "${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_CMAKE_DESTINATION}")
        configure_package_config_file("${CATKIN_GENERATED_DIR}/package-config.cmake.in" "${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_CMAKE_DESTINATION}/${PROJECT_NAME}Config.cmake"
            INSTALL_DESTINATION "${CATKIN_PACKAGE_CMAKE_DESTINATION}"
            NO_SET_AND_CHECK_MACRO NO_CHECK_REQUIRED_COMPONENTS_MACRO
            INSTALL_PREFIX "${CATKIN_DEVEL_PREFIX}"
        )
    endif()
    configure_package_config_file("${CATKIN_GENERATED_DIR}/package-config.cmake.in" "${CATKIN_GENERATED_DIR}/${PROJECT_NAME}Config.cmake"
        INSTALL_DESTINATION "${CATKIN_PACKAGE_CMAKE_DESTINATION}"
        NO_SET_AND_CHECK_MACRO NO_CHECK_REQUIRED_COMPONENTS_MACRO
    )
    install(FILES
            "${CATKIN_GENERATED_DIR}/${PROJECT_NAME}Config.cmake"
            "${CATKIN_GENERATED_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
        DESTINATION "${CATKIN_PACKAGE_CMAKE_DESTINATION}"
    )
endfunction()
