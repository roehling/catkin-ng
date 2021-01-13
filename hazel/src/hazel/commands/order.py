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
from ..workspace import create_dependency_graph, packages_in_topological_order
from catkin_pkg.packages import find_packages


def prepare_args(parser):
    parser.add_argument("--underlay-workspaces", metavar="WORKSPACE", nargs="*", default=[], help="paths to underlay workspaces which are only used to resolve dependencies")
    m = parser.add_mutually_exclusive_group()
    m.add_argument("--only-folders", action="store_true", help="only output the package folders")
    m.add_argument("--only-names", action="store_true", help="only output the package names")
    m.add_argument("--with-level", action="store_true", help="also output the level. Packages in level N will only depend on packages which are at most in level N-1")
    parser.add_argument("workspace", nargs="?", default=".", help="workspace folder")


def run(args):
    packages = find_packages(args.workspace)
    workspace_packages = {manifest.name: path for path, manifest in packages.items()}
    for u in args.underlay_workspaces:
        packages.update({os.path.join(u, p): m for p, m in find_packages(u).items() if m.name not in workspace_packages})

    dependency_graph = create_dependency_graph(packages)
    for level, tier in enumerate(packages_in_topological_order(dependency_graph, set(workspace_packages.keys()))):
        for name in tier:
            if args.only_folders:
                print(workspace_packages[name])
            elif args.only_names:
                print(name)
            elif args.with_level:
                print("{} {} {}".format(level, name, workspace_packages[name]))
            else:
                print("{} {}".format(name, workspace_packages[name]))


def main():
    parser = argparse.ArgumentParser(description="build packages in hazel workspace")
    prepare_args(parser)
    args = parser.parse_args()
    return run(args)
