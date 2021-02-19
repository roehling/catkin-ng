Hello, World!
=============

For our very first Hazel package, we build a simple "Hello World" program. Most
of it is not very different from any ROS package you would create. The main
file :file:`hello_world.cpp` is a simple C++ program:

.. code-block:: c++

    #include <iostream>

    int main (int argc, char** argv)
    {
        std::cout << "Hello, world!\n";
        return 0;
    }

As with any ROS package, we need an XML manifest named :file:`package.xml` that
describes our package metadata. Here, we add a ``buildtool_depend`` on
``hazel`` and set the ``build_type`` in the ``export`` block. Everything else
is business as usual:

.. code-block:: xml

    <?xml version="1.0"?>
    <?xml-model
      href="http://download.ros.org/schema/package_format3.xsd"
      schematypens="http://www.w3.org/2001/XMLSchema"?>
    <package format="3">
      <name>hello_world</name>
      <version>1.2.3</version>
      <description>my first Hazel package</description>
      <license>Apache-2.0</license>
      <author>Timo Röhling</author>
      <maintainer email="timo@gaussglocke.de">Timo Röhling</maintainer>
      <buildtool_depend>hazel</buildtool_depend>
      <export>
        <build_type>hazel</build_type>
      </export>
    </package>

All these files end up in a folder structure like this::

    └── hello_world
        ├── package.xml
        ├── CMakeLists.txt
        └── src
            └── hello_world.cpp

The :file:`CMakeLists.txt` is the main CMake file that configures the package
build. This is where most of the Hazel-specific stuff happens:

.. code-block:: cmake
    :linenos:

    cmake_minimum_required(VERSION 3.10)
    project(hello_world VERSION 1.2.3 LANGUAGES CXX)

    find_package(hazel REQUIRED)

    add_executable(hello_world
       src/hello_world.cpp
    )

    hazel_package(TARGETS hello_world)

We will go through this line by line.

The :cmake:command:`cmake_minimum_required` command in line 1 sets the baseline
version for CMake compatibility. As mentioned before, the CMake developers put
a lot of effort into backwards compatibility. If a later CMake version changes
behavior in an incompatible way, you will receive a warning and (at least for
some time) the possibility to keep the old behavior with the `CMake policy
mechanism`_.

The :cmake:command:`project` command in line 2 sets the project metadata and
initializes a few project-related CMake variables. Hazel expects and enforces
that the project name is the same as the package name you used in the
:file:`package.xml`. The ``VERSION`` and ``LANGUAGES`` options can be omitted.
Hazel will automatically use the version number from the ``package.xml`` and
complain if you use a different version here.

The :cmake:command:`find_package` command in line 4 searches for and
initializes Hazel. Under most circumstances, you should add the ``REQUIRED``
option, so CMake will abort if Hazel is not available. Note that you cannot add
additional package dependencies with the ``COMPONENTS`` keyword as you do with
catkin. This mechanism exists only to add those dependencies to the
:cmake:variable:`catkin_LIBRARIES` and :cmake:variable:`catkin_INCLUDE_DIRS`
variables, which are not needed with Hazel. If we had additional dependencies,
however, we would add the corresponding :cmake:command:`find_package` or
:cmake:command:`hazel_import` commands after this line.

The :cmake:command:`add_executable` command in line 6 tells CMake which source
files need to be compiled and linked to produce our Hello World program.
Executables and libraries are the most common build targets.

The :cmake:command:`hazel_package` command in line 10 is the final command in
every Hazel package and makes the created targets available for others. In this
case, we want to export our ``hello_world`` target, so users can run our
program with :command:`rosrun`. By the way, it is very common to name the main
target like the package itself, and you are encouraged to follow this
convention. It is not required, though.

.. _CMake policy mechanism: https://cmake.org/cmake/help/latest/command/cmake_policy.html

