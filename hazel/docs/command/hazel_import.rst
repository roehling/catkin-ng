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

hazel_import
============

Import legacy packages and wrap them in a linkable CMake target.

The ``hazel_import()`` command wraps the :cmake:module:`PkgConfig` module and
provides linkable import targets for legacy catkin and ament packages.
Additionally, ``hazel_import()`` makes those targets exportable. If an imported
target is needed by an exported target, the import logic is automatically
replicated in the exported package configuration. In theory, this makes the
Hazel packages fully relocatable as there are no hardcoded paths. However, both
catkin and ament packages may have recursive dependencies embedded with
hardcoded paths.

If your package exports dependencies on catkin or ament packages, you should
port those packages to Hazel. The re-export of imported
targets is a stop-gap measure to ease the transition in mixed workspaces.

pkg-config
----------

.. code-block:: cmake

    hazel_import(
        PkgConfig::<target> 
        [REQUIRED] [QUIET]
        [PKG_CHECK_MODULES | PKG_SEARCH_MODULE]
        <moduleSpec> [<moduleSpec> ...]
    )

Creates an imported target ``PkgConfig::<target>`` from one or more given
pkg-config modules.

When ``REQUIRED`` is given, the command will fail with a fatal error if the
target cannot be created.

When ``QUIET`` is given, no status messages will be printed.

When ``PKG_CHECK_MODULES`` is given, ``hazel_import()`` will create the
imported target from all given modules and fail if one or more modules cannot
be found. This is also the default behavior if neither ``PKG_CHECK_MODULES``
nor ``PKG_SEARCH_MODULE`` is given.

When ``PKG_SEARCH_MODULE`` is given, ``hazel_import()`` will treat the given
modules as alternatives and use the first available for the imported target. It
will only fail if none of the modules can be found.

Each ``<moduleSpec>`` can be either a bare module name or it can be a module
name with a version constraint (operators ``=``, ``<``, ``>``, ``<=``, and
``>=`` are supported). For example:

* ``foo`` matches any version
* ``foo<2`` only matches versions before 2
* ``foo>=3.1`` matches any version from 3.1 or later
* ``foo=1.2.3`` requires that foo must be exactly version 1.2.3

catkin
------

.. code-block:: cmake

    hazel_import(
        catkin::<package>
        [<version> [EXACT]]
        [REQUIRED] [QUIET]
        [...]
    )

Creates an imported target ``catkin::<package>`` that wraps the exported
:cmake:variable:`<package>_INCLUDE_DIRS` and
:cmake:variable:`<package>_LIBRARIES` variables.

When ``REQUIRED`` is given, the command will fail with a fatal error if the
package cannot be found or if the package is not a catkin package.

When ``QUIET`` is given, no status messages will be printed.

When ``<version>`` is given, the package must be compatible with the requested
version (which usually means that the package must have at least the given version).
The ``EXACT`` option forces an exact match.

All other arguments are passed verbatim to the :cmake:command:`find_package`
call that searches for the package.

ament
-----

.. code-block:: cmake

    hazel_import(
        ament::<package>
        [<version> [EXACT]]
        [REQUIRED] [QUIET]
        [...]
    )

Creates an imported target ``ament::<package>`` that wraps the exported
:cmake:variable:`<package>_DEFINITIONS`,
:cmake:variable:`<package>_INCLUDE_DIRS` and
:cmake:variable:`<package>_LIBRARIES` variables and can be linked against your
own targets. If the ament package supports modern CMake targets, the imported
target will link against those instead.

When ``REQUIRED`` is given, the command will fail with a fatal error if the
package cannot be found or if the package is not an ament package.

When ``QUIET`` is given, no status messages will be printed.

When ``<version>`` is given, the package must be compatible with the requested
version (which usually means that the package must have at least the given version).
The ``EXACT`` option forces an exact match.

All other arguments are passed verbatim to the :cmake:command:`find_package`
call that searches for the package.
