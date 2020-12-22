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
macro(catkin_destinations)
    if(UNIX)
        include(GNUInstallDirs)
        set(CATKIN_GLOBAL_BIN_DESTINATION "${CMAKE_INSTALL_BINDIR}")
        set(CATKIN_GLOBAL_ETC_DESTINATION "${CMAKE_INSTALL_SYSCONFDIR}")
        set(CATKIN_GLOBAL_INCLUDE_DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
        set(CATKIN_GLOBAL_LIB_DESTINATION "${CMAKE_INSTALL_LIBDIR}")
        set(CATKIN_GLOBAL_LIBEXEC_DESTINATION "${CMAKE_INSTALL_LIBEXECDIR}")
        set(CATKIN_GLOBAL_SHARE_DESTINATION "${CMAKE_INSTALL_DATADIR}")
    else()
        set(CATKIN_GLOBAL_BIN_DESTINATION "bin")
        set(CATKIN_GLOBAL_ETC_DESTINATION "etc")
        set(CATKIN_GLOBAL_INCLUDE_DESTINATION "include")
        set(CATKIN_GLOBAL_LIB_DESTINATION "lib")
        set(CATKIN_GLOBAL_LIBEXEC_DESTINATION "lib")
        set(CATKIN_GLOBAL_SHARE_DESTINATION "share")
    endif()
    set(CATKIN_PACKAGE_BIN_DESTINATION "${CATKIN_GLOBAL_LIB_DESTINATION}/${PROJECT_NAME}")
    set(CATKIN_PACKAGE_ETC_DESTINATION "${CATKIN_GLOBAL_ETC_DESTINATION}/${PROJECT_NAME}")
    set(CATKIN_PACKAGE_INCLUDE_DESTINATION "${CATKIN_GLOBAL_INCLUDE_DESTINATION}/${PROJECT_NAME}")
    set(CATKIN_PACKAGE_LIB_DESTINATION "${CATKIN_GLOBAL_LIB_DESTINATION}")
    set(CATKIN_PACKAGE_LIBEXEC_DESTINATION "${CATKIN_GLOBAL_LIBEXEC_DESTINATION}/${PROJECT_NAME}")
    set(CATKIN_PACKAGE_OBJECTS_DESTINATION "${CATKIN_GLOBAL_LIB_DESTINATION}/${PROJECT_NAME}/objects")
    set(CATKIN_PACKAGE_SHARE_DESTINATION "${CATKIN_GLOBAL_SHARE_DESTINATION}/${PROJECT_NAME}")
    if(CATKIN_PACKAGE_ARCHITECTURE_INDEPENDENT)
        set(CATKIN_PACKAGE_CMAKE_DESTINATION "${CATKIN_GLOBAL_SHARE_DESTINATION}/${PROJECT_NAME}/cmake")
    else()
        set(CATKIN_PACKAGE_CMAKE_DESTINATION "${CATKIN_GLOBAL_LIB_DESTINATION}/${PROJECT_NAME}/cmake")
    endif()
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_LIB_DESTINATION}")
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_LIB_DESTINATION}")
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_BIN_DESTINATION}")
endmacro()
