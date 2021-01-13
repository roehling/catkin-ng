Hazel Build System
==================

Hazel is a successor for the ROS catkin build system. Its design follows the
[Modern CMake](https://cliutils.gitlab.io/modern-cmake/) principles. In
particular, it uses the available CMake facilities for target import and
export. Hazel tries very hard not to mess with CMake's dependency management,
so you will not need (or forget to use) any opaque variable references such as
`${catkin_LIBRARIES}` or `${catkin_INCLUDE_DIRS}`: everything is a target.
CMake scripts written for Hazel are pretty much regular CMake scripts, with a
few helpful macros to reduce boilerplate code:

```cmake
cmake_minimum_required(VERSION 3.10)  # Hazel needs CMake 3.10+

project(foo VERSION 1.2.3 LANGUAGES CXX)

# Hazel
find_package(hazel REQUIRED)

# Discover build dependencies.
find_package(bar REQUIRED)                          # another Hazel package
find_package(Boost REQUIRED COMPONENTS filesystem)  # system library

# Build a library.
add_library(foo src/libfoo.cpp)

# Link against dependencies.
# This will also take care of include paths and other required settings.
target_link_libraries(foo
    PUBLIC bar::bar
    PRIVATE Boost::filesystem
)

# Declare local includes.
# Note that you don't need to set include paths for linked dependencies.
# CMake does this automatically for you.
target_include_directories(foo
    PUBLIC
        # BUILD_INTERFACE is for the build itself and the develspace
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        # INSTALL_INTERFACE is relative to CMAKE_INSTALL_PREFIX
        $<INSTALL_INTERFACE:include>
)

# Install public headers.
install(DIRECTORY include/foo DESTINATION include)

# Build a program that uses the library.
add_executable(foo-cli src/cli.cpp)
target_link_libraries(foo-cli
    PRIVATE foo
)

# Export the library and the program so other packages can use it.
# Hazel is smart enough to install them and figure out that you need the
# Hazel package bar as transitive dependency for foo.
hazel_package(TARGETS foo foo-cli)
```

Note that Hazel is still in the pre-alpha stage and not yet meant for production use.
