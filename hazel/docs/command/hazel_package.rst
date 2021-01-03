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

hazel_package
=============

Create the CMake configuration files for the Hazel package.

.. code-block:: cmake

    hazel_package(
        [COMPATIBILITY <compat>]
        [CMAKE_SCRIPTS <script> ...]
        [DEPENDS <depend> ...]
        [EXPORT <export>]
        [NAMESPACE <namespace>]
        [TARGETS <target> ...]
    )

The ``hazel_package()`` command should be the final Hazel command in the
``CMakeLists.txt`` and finalizes the package configuration. For convenience,
``hazel_package()`` also accepts most options for the :cmake:command:`hazel_export`
command and will invoke it implicitly if required.

The following options are available:

``COMPATIBILITY``

    This option determines which requested package versions will be considered
    compatible by :cmake:command:`find_package`. The compatibility mode is used
    internally as argument for
    :cmake:command:`write_basic_package_version_file` and may take one of the
    following values:

    * ``AnyNewerVersion`` means that the installed package version will be
      considered compatible if it is newer or exactly the same as the
      requested version. This mode should be used for packages which are
      fully backwards compatible, even across major versions.
    * ``SameMajorVersion`` means that the major version must be the same as
      requested, e.g. version 2.0 will not be considered compatible if
      version 1.0 is requested.
    * ``SameMinorVersion`` means that both major and minor version must be
      the same as requested, e.g. version 0.2 will not be compatiblle if
      0.1 is requested.
    * ``ExactVersion`` means that the package is only considered compatible
      if the requested version matches exactly the installed version.
    
    If the ``COMPATIBILITY`` option is not given, ``ExactVersion`` is assumed.

``CMAKE_SCRIPTS``

    Export custom CMake configuration scripts. Each named script is installed
    with the package, and a corresponding :cmake:command:`include` command is
    added to the main configuration script. Relative paths are assumed to be
    relative to :cmake:variable:`CMAKE_CURRENT_SOURCE_DIR`.

    Hazel will automatically invoke certain preprocessors if the corresponding
    templates are found. For details, refer to the
    :cmake:command:`hazel_export` command.

``DEPENDS``

    Declare package dependencies. If you want to export a target for other
    packages, you also need to export the public dependencies of your target.
    That means if you used :cmake:command:`find_package` to find a public
    dependency, you need to tell everyone who use your package to call
    :cmake:command:`find_package` for that dependency, too.
    
    If you use the ``TARGETS`` option to export your targets, Hazel will assist
    you and automatically depend on other Hazel packages or any target you
    imported using the :cmake:command:`hazel_import` command if they are needed
    by your exported targets.

    You need to declare package dependencies manually if you use targets from a
    non-Hazel package, or if you compose your export set with
    :cmake:command:`install(TARGETS)` and do not use the ``TARGETS``
    option.

    The ``DEPENDS`` option accepts a list of all packages which need to be
    found and their targets imported for your exported targets to work. You can
    also request a particular version and/or package components just as you
    would with the :cmake:command:`find_package` command, e.g. ``"Boost 1.70
    COMPONENTS system"``. In that case, you must also use quotes to protect the
    whitespaces in the dependency string.

    Multiple depends on the same package are allowed and will be combined.
    Contradicting dependencies such as ``"Boost 1.60 EXACT"`` and ``"Boost 1.70
    EXACT"`` are not allowed and, if not detected by Hazel at build time, will
    render your package unusable.

``EXPORT``

    Export a target set. You can add targets to the set with the ``TARGETS``
    option, or with the :cmake:command:`install(TARGETS)` command.

``NAMESPACE``

    Prefix all exported targets with ``<namespace>``. If omitted, it will
    default to ``${PROJECT_NAME}::``.

``TARGETS``

    Add targets to the export set. If the ``EXPORT`` option is omitted, an
    implicit ``EXPORT ${PROJECT_NAME}Targets`` is assumed. The targets will
    also automatically be installed to the proper locations.

    The ``TARGETS`` option is the recommended way to export targets, because it
    provides Hazel with an opportunity to scan the targets for known external
    dependencies and implicitly add them to the ``DEPENDS`` option.
