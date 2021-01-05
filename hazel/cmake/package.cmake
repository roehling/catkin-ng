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
    if(arg_EXPORT)
        set(export_file "${arg_EXPORT}")
    else()
        set(export_file "${PROJECT_NAME}Targets")
    endif()

    include(CMakePackageConfigHelpers)
    set(HAZEL_GENERATED_DIR "${CMAKE_CURRENT_BINARY_DIR}/hazel-generated")
    file(MAKE_DIRECTORY "${HAZEL_GENERATED_DIR}")

    hazel_export(ONLY_LIBRARIES
        EXPORT "${arg_EXPORT}" NAMESPACE "${arg_NAMESPACE}" FILE "${export_file}"
        TARGETS ${arg_TARGETS} CMAKE_SCRIPTS ${arg_CMAKE_SCRIPTS}
    )

    hazel_get_properties(
        HAZEL_PACKAGE_EXPORTED_CMAKE_FILES
        HAZEL_PACKAGE_EXPORTED_DEPENDS
        HAZEL_PACKAGE_EXPORTED_TARGET_FILES
        HAZEL_PACKAGE_IMPORTED_TARGETS
    )

    list(APPEND HAZEL_PACKAGE_EXPORTED_DEPENDS ${arg_DEPENDS})
    list(REMOVE_DUPLICATES HAZEL_PACKAGE_EXPORTED_DEPENDS)

    set(regular_depends)
    foreach(dep IN LISTS HAZEL_PACKAGE_EXPORTED_DEPENDS)
        if(dep IN_LIST HAZEL_PACKAGE_IMPORTED_TARGETS AND dep MATCHES "([A-Za-z0-9]+)::(.+)")
            hazel_get_properties(HAZEL_PACKAGE_IMPORT_FILE_${CMAKE_MATCH_1}_${CMAKE_MATCH_2})
            _hazel_export_cmake_scripts(${HAZEL_PACKAGE_IMPORT_FILE_${CMAKE_MATCH_1}_${CMAKE_MATCH_2}})
        else()
            if(${dep}_VERSION)
                list(APPEND regular_depends "${dep} ${${dep}_VERSION}")
            else()
                list(APPEND regular_depends "${dep}")
            endif()
        endif()
    endforeach()
    _hazel_merge_find_package_calls(HAZEL_PACKAGE_EXPORTED_DEPENDS "${regular_depends}")

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

function(_hazel_merge_find_package_calls outvar depends)
    set(result)
    set(known_deps)
    foreach(dep IN LISTS depends)
        string(REPLACE " " ";" dep_line "${dep}")
        cmake_parse_arguments(dep "REQUIRED;QUIET;EXACT" "" "COMPONENTS;OPTIONAL_COMPONENTS" ${dep_line})
        list(LENGTH dep_UNPARSED_ARGUMENTS len)
        if(len EQUAL 0)
            message(FATAL_ERROR "malformed dependency '${dep}'")
        endif()
        list(GET dep_UNPARSED_ARGUMENTS 0 dep_NAME)
        if(len GREATER_EQUAL 2)
            list(GET dep_UNPARSED_ARGUMENTS 1 dep_VERSION)
        else()
            set(dep_VERSION)
        endif()
        string(TOLOWER "${dep_NAME}" dep)
        if(NOT dep IN_LIST known_deps)
            list(APPEND known_deps "${dep}")
            set(final_${dep}_NAME "${dep_NAME}")
            set(final_${dep}_VERSION "${dep_VERSION}")
            set(final_${dep}_COMPONENTS)
            set(final_${dep}_OPTIONAL_COMPONENTS)
            set(final_${dep}_EXACT "${dep_EXACT}")
        endif()
        foreach(comp IN LISTS dep_COMPONENTS)
            if(NOT comp IN_LIST final_${dep}_COMPONENTS)
                list(APPEND final_${dep}_COMPONENTS "${comp}")
            endif()
            list(REMOVE_ITEM final_${dep}_OPTIONAL_COMPONENTS "${comp}")
        endforeach()
        foreach(comp IN LISTS dep_OPTIONAL_COMPONENTS)
            if(NOT comp IN_LIST final_${dep}_COMPONENTS AND NOT comp IN_LIST final_${dep}_OPTIONAL_COMPONENTS)
                list(APPEND final_${dep}_OPTIONAL_COMPONENTS "${comp}")
            endif()
        endforeach()
        if(dep_VERSION)
            if(final_${dep}_VERSION AND final_${dep}_EXACT)
                if (dep_EXACT AND NOT dep_VERSION VERSION_EQUAL "${final_${dep}_VERSION}")
                    message(FATAL_ERROR "conflicting version requirements for '${dep_NAME}': cannot both satisfy 'exactly ${dep_VERSION}' and 'exactly ${final_${dep}_VERSION}'")
                elseif(dep_VERSION VERSION_GREATER "${final_${dep}_VERSION}")
                    message(FATAL_ERROR "conflicting version requirements for '${dep_NAME}': cannot both satisfy 'at least ${dep_VERSION}' and 'exactly ${final_${dep}_VERSION}'")
                endif()
            endif()
            if(final_${dep}_VERSION AND NOT final_${dep}_EXACT)
                if(dep_EXACT AND dep_VERSION VERSION_LESS "${final_${dep}_VERSION}")
                    message(FATAL_ERROR "conflicting version requirements for '${dep_NAME}': cannot both satisfy 'exactly ${dep_VERSION}' and 'at least ${final_${dep}_VERSION}'")
                endif()
            endif()
            if (NOT final_${dep}_VERSION OR final_${dep}_VERSION VERSION_LESS dep_VERSION)
                set(final_${dep}_VERSION "${dep_VERSION}")
                if(dep_EXACT)
                    set(final_${dep}_EXACT TRUE)
                endif()
            endif()
        endif()
    endforeach()
    foreach(dep IN LISTS known_deps)
        set(dep_line "${final_${dep}_NAME}")
        if(final_${dep}_VERSION)
            set(dep_line "${dep_line} ${final_${dep}_VERSION}")
            if(final_${dep}_EXACT)
                set(dep_line "${dep_line} EXACT")
            endif()
        endif()
        if(final_${dep}_COMPONENTS)
            string(REPLACE ";" " " comp "${final_${dep}_COMPONENTS}")
            set(dep_line "${dep_line} COMPONENTS ${comp}")
        endif()
        if(final_${dep}_OPTIONAL_COMPONENTS)
            string(REPLACE ";" " " comp "${final_${dep}_OPTIONAL_COMPONENTS}")
            set(dep_line "${dep_line} OPTIONAL_COMPONENTS ${comp}")
        endif()
        list(APPEND result "${dep_line}")
    endforeach()
    set(${outvar} "${result}" PARENT_SCOPE)
endfunction()
