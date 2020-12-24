@@PACKAGE_INIT@@

set(@@PROJECT_NAME@@_IS_CATKIN_PACKAGE TRUE)
set(@@PROJECT_NAME@@_CATKIN_VERSION "@@CATKIN_VERSION@@")
set(@@PROJECT_NAME@@_EXPORTED_TARGETS)

@[if EXPORTED_DEPENDS]@
include(CMakeFindDependencyMacro)
@[for dep in EXPORTED_DEPENDS]@
find_dependency(@dep)
@[end for]@
@[end if]
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
list(APPEND CATKIN_IMPORTED_PACKAGES "@@PROJECT_NAME@@")

if(NOT @@PROJECT_NAME@@_FIND_QUIETLY)
    list(LENGTH @@PROJECT_NAME@@_EXPORTED_TARGETS target_count)
    message(STATUS "Found @@PROJECT_NAME@@: ${PACKAGE_PREFIX_DIR} (found version \"@@PROJECT_VERSION@@\") imported targets: ${target_count}")
endif()
set(@@PROJECT_NAME@@_FOUND TRUE)