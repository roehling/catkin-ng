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
import argparse
import importlib
import sys


COMMANDS = {
    "make": {"help": "build packages in the workspace"},
    "package": {"help": "parse values from package.xml"},
    "order": {"help": "print packages in topological order"}
}


def main():
    main_parser = argparse.ArgumentParser(prog=f"python{sys.version_info.major} -m hazel", description="hazel build system tool")
    sub_parsers = main_parser.add_subparsers(dest="command", metavar="ACTION")
    sub_parsers.required = True
    for command, info in COMMANDS.items():
        module = importlib.import_module(info.get("module", f".{command}"), "hazel.commands")
        func = getattr(module, info.get("prepare_args", "prepare_args"))
        p = sub_parsers.add_parser(command, help=info.get("help", "undocumented action"))
        func(p)
    args = main_parser.parse_args()
    info = COMMANDS.get(args.command)
    module = importlib.import_module(info.get("module", f".{args.command}"), "hazel.commands")
    func = getattr(module, info.get("run", "run"))
    return func(args)


if __name__ == "__main__":
    sys.exit(main())
