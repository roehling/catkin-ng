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
import sys
from catkin_pkg.package import parse_package
from shlex import quote

PROPERTIES = ["name", "version", "build_depends", "architecture_independent"]


def prepare_args(parser):
    parser.add_argument("--source", metavar="DIR", default=".", help="package source directory")
    parser.add_argument("--cmake", action="store_true", help="write CMake script that can be included")
    parser.add_argument("--main", action="store_true", help="use HAZEL_PACKAGE as prefix instead of <package_name>")


def run(args):
    try:
        package = parse_package(args.source)
        if args.cmake:
            prefix = "HAZEL_PACKAGE" if args.main else f"{package.name}"
            output_cmake_property("HAZEL_PACKAGE_NAME", package.name)
            output_cmake_property(f"{prefix}_VERSION", package.version)
            output_cmake_property(f"{prefix}_MAINTAINER", package.maintainers)
            output_cmake_property(f"{prefix}_PACKAGE_FORMAT", package.package_format)
            output_cmake_property(f"{prefix}_BUILD_DEPENDS", package.build_depends)
            output_cmake_property(f"{prefix}_BUILD_EXPORT_DEPENDS", package.build_export_depends)
            output_cmake_property(f"{prefix}_BUILDTOOL_DEPENDS", package.buildtool_depends)
            output_cmake_property(f"{prefix}_BUILDTOOL_EXPORT_DEPENDS", package.buildtool_export_depends)
            output_cmake_property(f"{prefix}_EXEC_DEPENDS", package.exec_depends)
            output_cmake_property(f"{prefix}_TEST_DEPENDS", package.test_depends)
            output_cmake_property(f"{prefix}_DOC_DEPENDS", package.doc_depends)
            output_cmake_property(f"{prefix}_ARCHITECTURE_INDEPENDENT", "TRUE" if next((e for e in package.exports if e.tagname == "architecture_independent"), None) else "FALSE")
            return 0
        sys.stderr.write("not implemented")
        return 1
    except Exception as e:
        sys.stderr.write(f"failed to parse package: {str(e)}\n")
        return 1


def output_cmake_property(name, value):
    if isinstance(value, list) or isinstance(value, tuple):
        list_value = ";".join(str(v) for v in value)
        print(f"set({name} \"{list_value}\")")
    else:
        print(f"set({name} \"{value}\")")
