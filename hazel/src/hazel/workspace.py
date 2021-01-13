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
import os
from .toposort import toposort


def create_dependency_graph(packages):
    # Add direct build dependencies
    dependency_graph = {manifest.name: set(dep.name for dep in manifest.build_depends + manifest.buildtool_depends) for manifest in packages.values()}
    # Add export build dependencies, which come implicitly from the direct dependencies
    export_graph = {manifest.name: set(dep.name for dep in manifest.build_export_depends + manifest.buildtool_export_depends) for manifest in packages.values()}
    for name, depends in dependency_graph.items():
        export_depends = set(d for dep in depends for d in export_graph.get(dep, set()))
        depends |= export_depends
    return dependency_graph


def packages_in_topological_order(dependency_graph, filter_set=None):
    for tier in toposort(dependency_graph):
        if filter_set:
            tier = tier & filter_set
        if tier:
            yield sorted(tier)
