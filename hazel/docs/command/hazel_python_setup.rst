.. Hazel Build System
   Copyright 2020,2021 Timo Röhling <timo@gaussglocke.de>
   .
   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at
   .
   http://www.apache.org/licenses/LICENSE-2.0
   .
   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

hazel_python_setup
==================

Install Python modules.

.. code-block:: cmake

    hazel_python_setup(
        [GLOBAL]
        [SRCDIR <srcdir>]
    )

The ``hazel_python_setup()`` command ensures that the ``setup.py`` of a wrapped
Python package is invoked at build time and installs to the correct locations.

When the ``GLOBAL`` option is given, Python scripts will be installed to the
global ``<prefix>/bin`` directory. By default, Python scripts will be installed
to the package-specific ``<prefix>/lib/<package>`` directory, where they can be
found by ``rosrun`` or ``ros2 run``.

You should avoid polluting the global namespace with scripts unless they are
independently useful and not specific to your package. Also, their name should
not collide with system binaries.

The ``SRCDIR`` option specifies the source location of ``setup.py`` if it is
not in the same location as the ``CMakeLists.txt`` that calls
``hazel_python_setup()``. Relative paths are interpreted relative to
:cmake:variable:`CMAKE_CURRENT_SOURCE_DIR`.

Hazel provides a setuptools wrapper to automatically add metadata from the
``package.xml`` to the Python package manifest. Assuming that the sources for
your Python packages are in the ``src`` subdirectory, a minimal working
``setup.py`` would be:

.. code-block:: python

    from hazel.setup import setup

    setup(
        package_dir={"": "src"}
    )

Hazel also supports ``setup.cfg`` configuration files. However, Hazel does not
support `PEP 517`_ style builds, i.e., packages without ``setup.py``.

.. _PEP 517: https://www.python.org/dev/peps/pep-0517/
