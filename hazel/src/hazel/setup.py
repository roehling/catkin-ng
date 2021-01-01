# encoding=utf-8
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
from setuptools import setup as _setup
from catkin_pkg.package import parse_package
from collections import defaultdict


def setup(**kwargs):
    package = parse_package(".")
    config = defaultdict(dict)
    if os.path.isfile("setup.cfg"):
        from setuptools.config import read_configuration
        config = read_configuration("setup.cfg")
    if "name" not in config["metadata"]:
        kwargs["name"] = kwargs.get("name", package.name)
    if "version" not in config["metadata"]:
        kwargs["version"] = kwargs.get("version", package.version)
    if "maintainer" not in kwargs and "maintainer" not in config["metadata"]:
        kwargs["maintainer"] = package.maintainers[0].name
        kwargs["maintainer_email"] = package.maintainers[0].email
    if "author" not in args and "author" not in config["metadata"] and package.authors and package.maintainers[0].name != package.authors[0].name:
        kwargs["author"] = package.authors[0].name
        if package.authors[0].email:
            kwargs["author_email"] = package.authors[0].email
        else:
            kwargs.pop("author_email", None)
    if "description" not in config["metadata"]:
        kwargs["description"] = kwargs.get("description", package.description.strip())
    if "license" not in config["metadata"]:
        kwargs["license"] = kwargs.get("license", " and ".join(package.licenses))

    _setup(**kwargs)
