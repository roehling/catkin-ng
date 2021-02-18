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
import argparse
import os
import shlex
import shutil
import subprocess
import sys
from catkin_pkg.packages import find_packages
from ..workspace import create_dependency_graph, packages_in_topological_order


def prepare_args(parser):
    parser.add_argument("--directory", "-C", metavar="DIR", default=".", help="base path of the workspace")
    parser.add_argument("--source", metavar="DIR", default="src", help="path to the source space")
    parser.add_argument("--build", metavar="DIR", default="build", help="path to the build space")
    parser.add_argument("--devel", metavar="DIR", default="devel", help="path to the devel space")
    parser.add_argument("--use-ninja", action="store_true", help="use 'ninja' instead of 'make'")
    parser.add_argument("--pre-clean", action="store_true", help="clean build space first")
    parser.add_argument("--pkg", metavar="PACKAGE", nargs="+", help="act on specific packages only")
    parser.add_argument("-D", dest="cmake_defines", metavar="VAR[[:TYPE]=VALUE]", action="append", help="pass variable definitions to 'cmake'")
    parser.add_argument("--jobs", "-j", metavar="N", nargs="?", const=-1, type=int, help="number of parallel jobs")
    parser.add_argument("--keep-going", "-k", action="store_true", help="keep going even if some targets fail to build")
    parser.add_argument("--target", action="append", help="build specific target")
    m = parser.add_mutually_exclusive_group()
    m.add_argument("--with-depends", action="store_true", help="also act on dependencies of packages specified with --pkg")
    m.add_argument("--without-depends", action="store_false", dest="with_depends", help="do not act on dependencies of packages specified with --pkg")
    parser.add_argument("extra", nargs=argparse.REMAINDER, help="arbitrary arguments which are passed to 'make' or 'ninja'")


def shlex_join(args):
    if hasattr(shlex, "join"):
        return shlex.join(args)
    return " ".join(shlex.quote(s) for s in args)


def execute_cmd(args):
    print("$", shlex_join(args))
    subprocess.run(args, check=True)


def print_box(text):
    L = len(text)
    box = "┌─" + ("─" * L) + "─┒\n│ {} ┃\n┕━".format(text) + ("━" * L) + "━┛"
    print(box)


def add_default_arg(argument_list, argument):
    find_prefix = argument.split("=")[0]
    for arg in argument_list:
        arg_prefix = arg.split("=")[0]
        if arg_prefix[2:] == find_prefix[2:]:
            break
    else:
        argument_list.append(argument)


def common_cmake_args(context):
    args = context["args"]
    cmake_args = ["-S{}".format(context["pkgsrcdir"]), "-B{}".format(context["pkgbuilddir"])]
    if args.cmake_defines:
        cmake_args += ["-D{}".format(arg) for arg in args.cmake_defines]
    if args.use_ninja:
        cmake_args.append("-GNinja")
    add_default_arg(cmake_args, "-DCMAKE_BUILD_TYPE=RelWithDebInfo")
    add_default_arg(cmake_args, "-DBUILD_SHARED_LIBS=ON")
    return cmake_args


def common_build_args(context):
    args = context["args"]
    build_args = []
    extra_args = []
    for t in args.target or []:
        build_args += ["--target", t]
    if args.jobs:
        if args.jobs < 0:
            build_args.append("-j")
        elif args.jobs > 0:
            build_args.append("-j{}".format(args.jobs))

    if args.keep_going:
        extra_args.append("-k0" if args.use_ninja else "-k")
    if args.extra:
        extra_args += args.extra
    if extra_args:
        build_args.append("--")
        build_args += extra_args
    return build_args


def build_cmake_package(context):
    if not os.path.isfile(os.path.join(context["pkgbuilddir"], context["build_script"])):
        cmake_args = common_cmake_args(context)
        add_default_arg(cmake_args, "-DCMAKE_INSTALL_PREFIX={}".format(context["develdir"]))
        execute_cmd(["cmake"] + cmake_args)

    build_args = common_build_args(context)
    if not context["args"].targets or "install" not in context["args"].targets:
        build_args = ["--target", "install"] + build_args
    execute_cmd(["cmake", "--build", context["pkgbuilddir"]] + build_args)


def build_catkin_package(context):
    if not os.path.isfile(os.path.join(context["pkgbuilddir"], context["build_script"])):
        cmake_args = common_cmake_args(context)
        add_default_arg(cmake_args, "-DCATKIN_DEVEL_PREFIX={}".format(context["develdir"]))
        execute_cmd(["cmake"] + cmake_args)

    build_args = common_build_args(context)
    execute_cmd(["cmake", "--build", context["pkgbuilddir"]] + build_args)


def build_hazel_package(context):
    if not os.path.isfile(os.path.join(context["pkgbuilddir"], context["build_script"])):
        cmake_args = common_cmake_args(context)
        add_default_arg(cmake_args, "-DHAZEL_DEVEL_PREFIX={}".format(context["develdir"]))
        execute_cmd(["cmake"] + cmake_args)

    build_args = common_build_args(context)
    execute_cmd(["cmake", "--build", context["pkgbuilddir"]] + build_args)


def build_package(path, manifest, args):
    pkgsrcdir = os.path.join(args.directory, args.source, path)
    pkgbuilddir = os.path.join(args.directory, args.build, path)
    develdir = os.path.join(args.directory, args.devel)
    build_script = "build.ninja" if args.use_ninja else "Makefile"
    if args.pre_clean:
        shutil.rmtree(pkgbuilddir, ignore_errors=True)
    os.makedirs(pkgbuilddir, exist_ok=True)
    context = {"manifest": manifest, "pkgsrcdir": pkgsrcdir, "develdir": develdir, "pkgbuilddir": pkgbuilddir, "args": args, "build_script": build_script}
    build_type = manifest.get_build_type()
    if build_type == "cmake":
        build_cmake_package(context)
    elif build_type == "catkin":
        build_catkin_package(context)
    elif build_type == "hazel":
        build_hazel_package(context)
    else:
        raise ValueError("unknown build type '{}'".format(build_type))


def run(args):
    args.directory = os.path.normpath(os.path.join(os.getcwd(), args.directory))
    if not os.path.isdir(args.directory):
        sys.stderr.write("hazel_make: no such directory: {}\n".format(repr(args.directory)))
        return 1
    srcdir = os.path.join(args.directory, args.source)
    if not os.path.isdir(srcdir):
        sys.stderr.write("hazel_make: no such directory: {}\n".format(repr(srcdir)))
        return 1

    packages = find_packages(srcdir)
    workspace_packages = {manifest.name: path for path, manifest in packages.items()}
    dependency_graph = create_dependency_graph(packages)
    workset = workspace_packages.keys()
    if args.pkg:
        workset = workset & set(args.pkg)
    failed_packages = set()
    returncode = 0
    for tier in packages_in_topological_order(dependency_graph, workset):
        for name in tier:
            print_box(name)
            if failed_packages & dependency_graph[name]:
                print("*** Cannot be built because of previous failures")
            else:
                try:
                    build_package(workspace_packages[name], packages[workspace_packages[name]], args)
                except subprocess.CalledProcessError as e:
                    sys.stderr.write("hazel_make: process exited with return code {}\n".format(e.returncode))
                    failed_packages.add(name)
                    returncode = max(returncode, e.returncode)
                    if not args.keep_going:
                        return returncode
                except Exception as e:
                    sys.stderr.write("hazel_make: cannot build package: {}\n".format(str(e)))
                    failed_packages.add(name)
                    returncode = max(returncode, 1)
    return returncode


def create_standalone_argparse():
    parser = argparse.ArgumentParser(description="build packages in hazel workspace")
    prepare_args(parser)
    return parser


def main():
    parser = create_standalone_argparse()
    args = parser.parse_args()
    return run(args)
