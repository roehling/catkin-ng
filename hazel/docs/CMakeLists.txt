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

find_program(SPHINXBUILD sphinx-build)
if(SPHINXBUILD)
    set(SPHINX_STAMP "${CMAKE_CURRENT_BINARY_DIR}/sphinx.stamp")
    set(SPHINX_BUILDDIR "${CMAKE_CURRENT_BINARY_DIR}/_build")
    set(SPHINX_SOURCEDIR "${CMAKE_CURRENT_SOURCE_DIR}")
    add_custom_command(OUTPUT "${SPHINX_STAMP}"
        MAIN_DEPENDENCY "${SPHINX_SOURCEDIR}/index.rst"
        DEPENDS "${SPHINX_SOURCEDIR}/conf.py"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${SPHINX_BUILDDIR}"
        COMMAND "${SPHINXBUILD}" -M html "${SPHINX_SOURCEDIR}" "${SPHINX_BUILDDIR}"
        COMMAND "${CMAKE_COMMAND}" -E touch "${SPHINX_STAMP}"
        VERBATIM
    )
    add_custom_target(sphinx-build-html ALL DEPENDS "${SPHINX_STAMP}")
    install(DIRECTORY "${SPHINX_BUILDDIR}/html" DESTINATION ${HAZEL_PACKAGE_DOC_DESTINATION}
        PATTERN ".*" EXCLUDE
    )
endif()
