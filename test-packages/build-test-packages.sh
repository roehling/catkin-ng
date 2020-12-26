#!/bin/bash
##############################################################################
#
# hazel
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
set -e
packagedir=$(cd "$(dirname "$0")"; pwd)
pyver=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')

if [ "${KEEP_WS:-0}" -eq 1 ]
then
    wsdir="/tmp/hazel_ws"
	if [ "${NOCLEAN_WS:-0}" -eq 0 ]
	then
		rm -rf "$wsdir"
	fi
    mkdir -p "$wsdir"
else
    wsdir="$(mktemp -d)"
    trap "rm -rf $wsdir" EXIT
fi

mkdir -p "$wsdir/src"
ln -sf "$packagedir/../hazel" "$wsdir/src"
for pkg in "$packagedir/"*
do
	if [ -d "$pkg" ]
	then
		ln -sf "$pkg" "$wsdir/src"
	fi
done

cd "$wsdir"

run()
{
    env -i ROS_PYTHON_VERSION=3 LANG=C.UTF-8 \
        PATH="$wsdir/devel/bin:/usr/bin:/bin" \
        CMAKE_PREFIX_PATH="$wsdir/devel" \
        PYTHONPATH="$wsdir/devel/lib/python$pyver/site-packages" \
        "$@"
}

run "$wsdir/src/hazel/bootstrap.sh" --pkg hazel "$@"
run hazel_make "$@"
run DESTDIR="$wsdir/install" hazel_make --target install "$@"

