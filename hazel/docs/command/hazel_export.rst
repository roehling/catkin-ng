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

hazel_export
============

Declare exports for usage in other packages.

.. code-block:: cmake

    hazel_export(
        [CMAKE_SCRIPTS <script> ...]
        [EXPORT <export>]
        [FILE <file>]
        [NAMESPACE <namespace>]
        [TARGETS <target> ...]
    )

The ``hazel_export()`` command makes functionality of your package available
for other packages. It can export target sets, CMake scripts, and will assist
in the dependency resolution for the :cmake:command:`hazel_package` command.

The following options are available:

``CMAKE_SCRIPTS``

    Export custom CMake configuration scripts. Each named script is installed
    with the package, and a corresponding :cmake:command:`include` command is
    added to the main configuration script. Relative paths are assumed to be
    relative to :cmake:variable:`CMAKE_CURRENT_SOURCE_DIR`.

    Hazel will automatically invoke certain preprocessors if the corresponding
    templates are found. The ``.cmake`` suffix, if any, will be stripped from
    ``<script>``. Then:

    * If ``<script>.cmake`` exists, it is installed verbatim.

    * If ``<script>.cmake.in`` exists, the :cmake:command:`configure_file`
      command is invoked (with ``@ONLY``) to create ``<script>.cmake``.

    * If ``<script>.cmake.em`` exists, the Empy preprocessor is invoked to
      create ``<script>.cmake``.
    
    * If ``<script>.cmake.installspace.em`` and/or
      ``<script>.cmake.develspace.em`` exist, the Empy preprocessor is invoked
      to create separate ``<script>.cmake`` versions for installation and the
      local develspace.

    The Empy preprocessor is provided with the following predefined variables:

    * ``DEVELSPACE`` and ``INSTALLSPACE`` are set to ``True`` or ``False``
      depending on the location where the preprocessed file ends up.
    
    * ``PREFIX`` is set to either :cmake:variable:`HAZEL_DEVEL_PREFIX` or
      :cmake:variable:`CMAKE_INSTALL_PREFIX`.
    
    * ``CMAKE_CURRENT_SOURCE_DIR``, ``CMAKE_CURRENT_BINARY_DIR``,
      ``PROJECT_NAME``, ``PROJECT_VERSION``, ``PROJECT_SOURCE_DIR``, and
      ``PROJECT_BINARY_DIR`` are set to the corresponding CMake variables.

    * ``HAZEL_GLOBAL_<type>DIR`` and
      ``HAZEL_PACKAGE_<type>DIR`` are set to absolute paths of various
      install locations. ``<type>`` can be one of ``BIN``,
      ``ETC``, ``INCLUDE``, ``LIB``, ``LIBEXEC``, ``PYTHON``, ``OBJECTS``,
      or ``SHARE``.

``EXPORT``

    Export a target set. You can add targets to the set with the ``TARGETS``
    option, or with

    .. code-block:: cmake

        install(TARGETS ... EXPORT <export>)

``FILE``

    Override the file name for the exported target set. If omitted, it will
    default to ``<export>.cmake``.

``NAMESPACE``

    Prefix all exported targets with ``<namespace>``. If omitted, it will
    default to ``${PROJECT_NAME}::``.

``TARGETS``

    Add targets to the export set. If the ``EXPORT`` option is omitted, an
    implicit ``EXPORT ${PROJECT_NAME}Targets`` is assumed. The targets will
    also automatically be installed to the proper locations.

    The ``TARGETS`` option is the recommended way to export targets, because it
    provides Hazel with an opportunity to scan the targets for known external
    dependencies and implicitly add them to the ``DEPENDS`` option of the
    :cmake:command:`hazel_package` command.
