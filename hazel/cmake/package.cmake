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
function(hazel_package)
    cmake_parse_arguments(arg "" "COMPATIBILITY;EXPORT;NAMESPACE" "DEPENDS;TARGETS;CMAKE_SCRIPTS" ${ARGN})
    if(arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "package '${PROJECT_NAME}' called hazel_package() with invalid parameters: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT DEFINED arg_NAMESPACE)
        set(arg_NAMESPACE "${PROJECT_NAME}::")
    endif()
    if(NOT DEFINED arg_COMPATIBILITY)
        set(arg_COMPATIBILITY ExactVersion)
    endif()

    include(CMakePackageConfigHelpers)
    set(HAZEL_GENERATED_DIR "${CMAKE_CURRENT_BINARY_DIR}/hazel-generated")
    file(MAKE_DIRECTORY "${HAZEL_GENERATED_DIR}")

    hazel_export(EXPORT "${arg_EXPORT}" NAMESPACE "${arg_NAMESPACE}" FILE "${PROJECT_NAME}Targets" TARGETS ${arg_TARGETS} CMAKE_SCRIPTS ${arg_CMAKE_SCRIPTS})

    list(APPEND HAZEL_PACKAGE_EXPORTED_DEPENDS ${arg_DEPENDS})
    list(REMOVE_DUPLICATES HAZEL_PACKAGE_EXPORTED_DEPENDS)

    # Special handling for pkg-config:: and catkin:: dependencies
    set(special_depends "${HAZEL_PACKAGE_EXPORTED_DEPENDS}")
    list(FILTER special_depends INCLUDE REGEX "^(pkg-config|catkin)::")
    list(FILTER HAZEL_PACKAGE_EXPORTED_DEPENDS EXCLUDE REGEX "^(pkg-config|catkin)::")
    foreach(target IN LISTS special_depends)
        if(target MATCHES "^pkg-config::([^:]+)")
            _hazel_export_cmake_scripts(${HAZEL_PACKAGE_IMPORT_PKGCONFIG_${CMAKE_MATCH_1}})
        else()
            message(SEND_ERROR "Cannot handle imported target '${target}' for package '${PROJECT_NAME}'")
        endif()
    endforeach()

    configure_file("${HAZEL_CMAKE_DIR}/package-config.context.in" "${HAZEL_GENERATED_DIR}/package-config.context" @ONLY)
    execute_process(COMMAND "${HAZEL_PYTHON_EXECUTABLE}" -m em -F "${HAZEL_GENERATED_DIR}/package-config.context" -o "${HAZEL_GENERATED_DIR}/package-config.cmake.in" "${HAZEL_CMAKE_DIR}/package-config.cmake.em")
    if(HAZEL_PACKAGE_ARCHITECTURE_INDEPENDENT)
        set(arch_indep ARCH_INDEPENDENT)
    else()
        set(arch_indep)
    endif()
    write_basic_package_version_file("${HAZEL_GENERATED_DIR}/${PROJECT_NAME}ConfigVersion.cmake" VERSION "${PROJECT_VERSION}" COMPATIBILITY "${arg_COMPATIBILITY}" ${arch_indep})
    if(HAZEL_DEVEL_PREFIX)
        if(HAZEL_PACKAGE_EXPORTED_TARGET_FILES)
            file(COPY "${HAZEL_CMAKE_DIR}/list_exported_targets.py" DESTINATION "${HAZEL_DEVEL_PREFIX}/${HAZEL_PACKAGE_CMAKE_DESTINATION}")
        endif()
        file(COPY "${HAZEL_GENERATED_DIR}/${PROJECT_NAME}ConfigVersion.cmake" DESTINATION "${HAZEL_DEVEL_PREFIX}/${HAZEL_PACKAGE_CMAKE_DESTINATION}")
        configure_package_config_file("${HAZEL_GENERATED_DIR}/package-config.cmake.in" "${HAZEL_DEVEL_PREFIX}/${HAZEL_PACKAGE_CMAKE_DESTINATION}/${PROJECT_NAME}Config.cmake"
            INSTALL_DESTINATION "${HAZEL_PACKAGE_CMAKE_DESTINATION}"
            NO_SET_AND_CHECK_MACRO NO_CHECK_REQUIRED_COMPONENTS_MACRO
            INSTALL_PREFIX "${HAZEL_DEVEL_PREFIX}"
        )
    endif()
    configure_package_config_file("${HAZEL_GENERATED_DIR}/package-config.cmake.in" "${HAZEL_GENERATED_DIR}/${PROJECT_NAME}Config.cmake"
        INSTALL_DESTINATION "${HAZEL_PACKAGE_CMAKE_DESTINATION}"
        NO_SET_AND_CHECK_MACRO NO_CHECK_REQUIRED_COMPONENTS_MACRO
    )
    install(FILES
            "${HAZEL_GENERATED_DIR}/${PROJECT_NAME}Config.cmake"
            "${HAZEL_GENERATED_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
        DESTINATION "${HAZEL_PACKAGE_CMAKE_DESTINATION}"
    )
    if(HAZEL_PACKAGE_EXPORTED_TARGET_FILES)
        install(FILES "${HAZEL_CMAKE_DIR}/list_exported_targets.py" DESTINATION "${HAZEL_PACKAGE_CMAKE_DESTINATION}")
    endif()
    # Preliminary support for ament resource index
    file(TOUCH "${HAZEL_GENERATED_DIR}/${PROJECT_NAME}")
    install(FILES "${HAZEL_GENERATED_DIR}/${PROJECT_NAME}" DESTINATION "${HAZEL_GLOBAL_SHARE_DESTINATION}/ament_index/resource_index/packages")
    # Install package.xml
    install(FILES "${HAZEL_PACKAGE_XML}" DESTINATION "${HAZEL_PACKAGE_SHARE_DESTINATION}")
endfunction()
