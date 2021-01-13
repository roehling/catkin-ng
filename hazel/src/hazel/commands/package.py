# encoding=utf-8
##############################################################################
#
# Hazel Build System
# Copyright 2020-2021 Timo Röhling <timo@gaussglocke.de>
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


def prepare_args(parser):
    parser.add_argument("--source", metavar="DIR", default=".", help="package source directory")
    parser.add_argument("--cmake", action="store_true", help="write CMake script that can be included")
    parser.add_argument("--main", action="store_true", help="use HAZEL_PACKAGE as prefix instead of <package_name>")


def run(args):
    try:
        package = parse_package(args.source)
        if args.cmake:
            prefix = "HAZEL_PACKAGE" if args.main else package.name
            output_cmake_property("HAZEL_PACKAGE_NAME", package.name)
            output_cmake_property("{}_VERSION".format(prefix), package.version)
            output_cmake_property("{}_MAINTAINER".format(prefix), package.maintainers)
            output_cmake_property("{}_PACKAGE_FORMAT".format(prefix), package.package_format)
            output_cmake_property("{}_BUILD_DEPENDS".format(prefix), package.build_depends)
            output_cmake_property("{}_BUILD_EXPORT_DEPENDS".format(prefix), package.build_export_depends)
            output_cmake_property("{}_BUILDTOOL_DEPENDS".format(prefix), package.buildtool_depends)
            output_cmake_property("{}_BUILDTOOL_EXPORT_DEPENDS".format(prefix), package.buildtool_export_depends)
            output_cmake_property("{}_EXEC_DEPENDS".format(prefix), package.exec_depends)
            output_cmake_property("{}_TEST_DEPENDS".format(prefix), package.test_depends)
            output_cmake_property("{}_DOC_DEPENDS".format(prefix), package.doc_depends)
            output_cmake_property("{}_ARCHITECTURE_INDEPENDENT".format(prefix), "TRUE" if next((e for e in package.exports if e.tagname == "architecture_independent"), None) else "FALSE")
            return 0
        sys.stderr.write("not implemented\n")
        return 1
    except Exception as e:
        sys.stderr.write("failed to parse package: {}\n".format(str(e)))
        return 1


def output_cmake_property(name, value):
    if isinstance(value, list) or isinstance(value, tuple):
        list_value = ";".join(str(v) for v in value)
        print("set({} \"{}\")".format(name, list_value))
    else:
        print("set({} \"{}\")".format(name, value))
