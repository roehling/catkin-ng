#!/bin/bash
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
set -e
[[ "${ROS_PYTHON_VERSION:-3}" =~ [23] ]] || (echo>&2 "invalid ROS_PYTHON_VERSION=$ROS_PYTHON_VERSION"; exit 1)

for PYTHON in python python3
do
    if PYTHON=$(type -p $PYTHON) &>/dev/null
    then
        if $PYTHON -c "import sys; sys.exit(0 if sys.version_info[0] == ${ROS_PYTHON_VERSION:-3} else 1)" &>/dev/null
        then
            break
        fi
    fi
done
packagedir=$(cd "$(dirname "$0")"; pwd)
export PYTHONPATH="${packagedir}/src${PYTHONPATH:+:}$PYTHONPATH"
exec $PYTHON -m hazel make "$@"
