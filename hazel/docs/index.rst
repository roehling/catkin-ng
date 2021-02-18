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

Welcome to Hazel!
=================

Hazel is a build system for ROS. It is primarily intended as a replacement for
catkin, but in principle, it can be used for both ROS 1 and ROS 2 packages.

Why Hazel?
----------

Etymologically, because hazel trees produce catkins.

Technologically, because Hazel takes advantage of many modern CMake features
which makes the dependency management much simpler and more robust compared to
catkin and, to a degree, ament [#f1]_ . Hazel's design follows the modern,
target-centric CMake philosophy. You will find that structuring your projects
in terms of CMake targets makes your CMake scripts both easier to write and
easier to read. In addition, Hazel provides a number of helpful CMake support
functions to simplify common tasks. Hazel nudges beginners towards a good,
modern CMake style, but tries to stay out of your way if you are a CMake
expert.

Compatibility
-------------

Hazel exports self-contained configuration scripts. Dependent packages can use
the regular CMake :cmake:command:`find_package()` mechanism to discover and
import the targets. Hazel can also import caktin packages, ament packages, and
pkg-config modules.


.. rubric:: Footnotes

.. [#f1]
    Starting with ROS Foxy, ament added support for a target-oriented CMake
    approach, but as of this writing, targets are far from being a first-class
    citizen in the ROS ecosystem.

.. toctree::
    :maxdepth: 2
    :hidden:

    tutorial
    reference
    cli
