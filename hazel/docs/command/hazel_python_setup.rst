.. Hazel Build System
   Copyright 2020-2021 Timo Röhling <timo@gaussglocke.de>
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
        [DIRECTORY <srcdir>]
        [GLOBAL_SCRIPTS]
    )

The ``hazel_python_setup()`` command ensures that the :file:`setup.py` of a
wrapped Python package is invoked at build time and installs to the correct
locations.

The ``DIRECTORY`` option specifies the source location of :file:`setup.py` if
it is not in the same location as the :file:`CMakeLists.txt` that calls
``hazel_python_setup()``. Relative paths are interpreted relative to
:cmake:variable:`CMAKE_CURRENT_SOURCE_DIR`.

When the ``GLOBAL_SCRIPTS`` option is given, Python scripts will be installed
to the global :file:`{prefix}/bin` directory. By default, Python scripts will
be installed to the package-specific :file:`{prefix}/lib/{package}` directory,
where they can be found by :command:`rosrun` or :command:`ros2 run`.

You should avoid polluting the global namespace with scripts unless they are
essential for the ROS ecosystem and used frequently enough to warrant the
global visibility. Of course, their names must not collide with system
binaries.

setuptools
----------

Hazel provides a setuptools wrapper to automatically add metadata from
:file:`package.xml` to the Python package manifest. Assuming that the sources
for your Python packages are in the :file:`src` subdirectory, a minimal working
:file:`setup.py` would be:

.. code-block:: python

    from hazel.setup import setup

    setup(
        package_dir={"": "src"}
    )

Hazel also supports :file:`setup.cfg` configuration files. However, Hazel does
not support pure :pep:`517` style builds, you must have a :file:`setup.py` even
if it does nothing but invoke :py:func:`setup` without arguments.

Develspace limitations
----------------------

Hazel performs an `editable install`_ for the develspace. This is functionally
similar to a symlink from the develspace into the actual package source
directory, but implemented in a Python specific way, so it also works on
platforms and filesystems which do not support symlinks.

This method supports almost all setuptools features, including entry point
scripts. There are two important limitations of which you need to be aware:

1. Your Python source tree layout must mirror the install layout. It should
   look similar to::

        └── ros_package/
            ├── package.xml
            ├── CMakeLists.txt
            ├── setup.py
            └── src/
                ├── py_package_a/
                │   ├── __init__.py
                │   └── ...
                ├── py_package_b/
                │   ├── __init__.py
                │   └── ...
                └── ...

   Basically, if your :py:func:`setup` call needs a ``package_dir`` map that is
   more complicated than ``{"": "relative/path/to/my/sources"}``, it will not
   work properly.
2. If your Python package has the same name as your ROS package (which is
   arguably the common case) and your package exports ROS messages, you must
   implement your package as a :pep:`420` namespace package, so that Hazel can
   generate an overlay for the :py:mod:`msg` and/or :py:mod:`srv` modules
   without writing them to your source tree::

        └── ros_package/
            ├── package.xml
            ├── CMakeLists.txt
            ├── setup.py
            └── src/
                └── ros_package/
                    ├── subpackage_a/
                    │   ├── __init__.py
                    │   └── ...
                    ├── subpackage_b/
                    │   ├── __init__.py
                    │   └── ...
                    ├── toplevel_module_1.py
                    ├── toplevel_module_2.py
                    └── ...

   Essentially, your top level module :py:mod:`ros_package` cannot have an
   :file:`__init__.py`, and if you use :py:func:`find_packages` in your
   :file:`setup.py`, you need to replace it with
   :py:func:`find_namespace_packages`.

   Unfortunately, this only works with Python 3.3+, so you may have to
   separate your messages into a dedicated package if you need to support
   older systems. On the other hand, this is best practise anyway.

.. _editable install: https://pip.pypa.io/en/stable/reference/pip_install/#editable-installs
