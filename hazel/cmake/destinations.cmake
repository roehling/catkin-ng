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
macro(hazel_destinations)
    if(UNIX)
        include(GNUInstallDirs)
        set(HAZEL_GLOBAL_BIN_DESTINATION "${CMAKE_INSTALL_BINDIR}")
        set(HAZEL_GLOBAL_ETC_DESTINATION "${CMAKE_INSTALL_SYSCONFDIR}")
        set(HAZEL_GLOBAL_INCLUDE_DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
        set(HAZEL_GLOBAL_LIB_DESTINATION "${CMAKE_INSTALL_LIBDIR}")
        set(HAZEL_GLOBAL_LIBEXEC_DESTINATION "${CMAKE_INSTALL_LIBEXECDIR}")
        set(HAZEL_GLOBAL_SHARE_DESTINATION "${CMAKE_INSTALL_DATADIR}")
    else()
        set(HAZEL_GLOBAL_BIN_DESTINATION "bin")
        set(HAZEL_GLOBAL_ETC_DESTINATION "etc")
        set(HAZEL_GLOBAL_INCLUDE_DESTINATION "include")
        set(HAZEL_GLOBAL_LIB_DESTINATION "lib")
        set(HAZEL_GLOBAL_LIBEXEC_DESTINATION "lib")
        set(HAZEL_GLOBAL_SHARE_DESTINATION "share")
    endif()
    set(HAZEL_PACKAGE_BIN_DESTINATION "${HAZEL_GLOBAL_LIB_DESTINATION}/${PROJECT_NAME}")
    set(HAZEL_PACKAGE_ETC_DESTINATION "${HAZEL_GLOBAL_ETC_DESTINATION}/${PROJECT_NAME}")
    set(HAZEL_PACKAGE_INCLUDE_DESTINATION "${HAZEL_GLOBAL_INCLUDE_DESTINATION}/${PROJECT_NAME}")
    set(HAZEL_PACKAGE_LIB_DESTINATION "${HAZEL_GLOBAL_LIB_DESTINATION}")
    set(HAZEL_PACKAGE_LIBEXEC_DESTINATION "${HAZEL_GLOBAL_LIBEXEC_DESTINATION}/${PROJECT_NAME}")
    set(HAZEL_PACKAGE_OBJECTS_DESTINATION "${HAZEL_GLOBAL_LIB_DESTINATION}/${PROJECT_NAME}/objects")
    set(HAZEL_PACKAGE_SHARE_DESTINATION "${HAZEL_GLOBAL_SHARE_DESTINATION}/${PROJECT_NAME}")
    if(HAZEL_PACKAGE_ARCHITECTURE_INDEPENDENT)
        set(HAZEL_PACKAGE_CMAKE_DESTINATION "${HAZEL_GLOBAL_SHARE_DESTINATION}/${PROJECT_NAME}/cmake")
    else()
        set(HAZEL_PACKAGE_CMAKE_DESTINATION "${HAZEL_GLOBAL_LIB_DESTINATION}/${PROJECT_NAME}/cmake")
    endif()
    if(HAZEL_DEVEL_PREFIX)
        set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${HAZEL_DEVEL_PREFIX}/${HAZEL_PACKAGE_LIB_DESTINATION}")
        set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${HAZEL_DEVEL_PREFIX}/${HAZEL_PACKAGE_LIB_DESTINATION}")
        set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${HAZEL_DEVEL_PREFIX}/${HAZEL_PACKAGE_BIN_DESTINATION}")
    endif()
endmacro()
