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

Getting Started
===============

Introduction
------------

Hazel's design follows the concepts from the Gist `Effective Modern CMake`_.
Even if you do not read the whole document, there is one mantra that drives
pretty much all design decisions in Hazel: Think in terms of targets and
properties.

You may be familiar with GNU Make targets, which are basically recipes on how
to create files. CMake targets are subtly different: you do not tell CMake
`how` to create a target, but `what` the target should be, and it will figure
out the rest on its own. This may seem like pointless semantics to you, but it
makes all the difference. Far too many developers treat CMake like a fancy GNU
Make and tell it exactly how to do its job. They manually add compiler flags
and link dependencies, and when things break with a different compiler or
platform, they add complex detection code. They add code to deal with the
dependencies of their dependencies. After a while, when their CMake script has
accumulated a few hundred lines of cryptic variable assignments and conditional
statements, they come to the conclusion that CMake is a bad tool.

Did you know that you don't have to add the ``-fPIC`` flag to build position
independent code? Just tell CMake you want it with the target property
``POSITION_INDEPENDENT_CODE ON``. CMake will add ``-fPIC`` for you, or whatever
option your particular compiler needs.

Or did you know that you don't have to add the ``-std=c++11`` flag to ensure
the compiler understands C++11? Just tell CMake you want it with the target
compile feature ``cxx_std_11``. CMake will add ``-std=c++11`` or
``-std=gnu++11`` for you, but only if it is needed. No more accidental
downgrading from C++14.

This is a recurring pattern with CMake. The CMake developers are actually very
smart people who test their tool on a variety of platforms and compilers. You
are very unlikely to outsmart them with your ad-hoc CMake code, so why waste
the time?

Treat CMake targets like objects in C++. They have a type (executable,
library), some member variables (properties), and even something like member
functions (all functions with ``target_`` prefix). Just like you avoid global
variables in your C++ code, avoid setting global variables. It is a common
CMake anti-pattern to treat a CMake target ``foo`` like a dumb alias for
``-lfoo``, so you link against the library, but you also need to manually set
the include path and maybe some macro definitions, which are communicated
through global variables like ``foo_INCLUDE_DIRS``. But why should `I` have to
remember to set these properties when I use `your` library? Just tell CMake
which include paths and which macro definitions are needed when others link
against your target, and CMake will add everything automatically [#f1]_ .

The CMake developers have been extraordinarily careful to remain compatible
with older versions. Unfortunately, this means that many deprecated features
and obsolete design patterns are still in use today and even actively taught to
new developers, which is in no small part responsible for the prejudice that
CMake build scripts are an unmaintainable mess.

.. _Effective Modern CMake: https://gist.github.com/mbinna/c61dbb39bca0e4fb7d1f73b0d66a4fd1

Hello, World!
-------------

For our very first Hazel package, we build a simple "Hello World" program. Most
of it is not very different from any ROS package you would create. The main file
``hello_world.cpp`` is a simple C++ program:

.. code-block:: c++

    #include <iostream>

    int main (int argc, char** argv)
    {
        std::cout << "Hello, world!\n";
        return 0;
    }

As with any ROS package, we need an XML manifest named ``package.xml`` that
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

The ``CMakeLists.txt`` is the main CMake file that configures the package
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
``package.xml``. The ``VERSION`` and ``LANGUAGES`` options can be omitted.
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
program with ``rosrun``. By the way, it is very common to name the main target
like the package itself, and you are encouraged to follow this convention. It
is not required, though.

.. _CMake policy mechanism: https://cmake.org/cmake/help/latest/command/cmake_policy.html

.. [#f1]

    Since the library author is the one who has to tell CMake, you will
    inevitably run into third-party libraries whose authors do not know
    how to CMake. There are ways to deal with this using interface libraries
    though; it is how Hazel can provide you with nice targets such as
    ``catkin::package-name`` even though catkin itself does not.
