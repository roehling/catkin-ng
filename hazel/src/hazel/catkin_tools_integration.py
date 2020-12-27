# encoding=utf-8
##############################################################################
#
# Hazel Build System
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
import os

from catkin_tools.argument_parsing import handle_make_arguments

from catkin_tools.common import mkdir_p

from catkin_tools.execution.jobs import Job
from catkin_tools.execution.stages import CommandStage
from catkin_tools.execution.stages import FunctionStage

from catkin_tools.jobs.catkin import link_devel_products, create_catkin_clean_job

from catkin_tools.jobs.commands.cmake import CMAKE_EXEC
from catkin_tools.jobs.commands.cmake import CMakeIOBufferProtocol
from catkin_tools.jobs.commands.cmake import CMakeMakeIOBufferProtocol
from catkin_tools.jobs.commands.cmake import get_installed_files
from catkin_tools.jobs.commands.make import MAKE_EXEC

from catkin_tools.jobs.utils import copyfiles
from catkin_tools.jobs.utils import loadenv
from catkin_tools.jobs.utils import makedirs
from catkin_tools.jobs.utils import require_command
from catkin_tools.jobs.utils import rmfiles


def create_hazel_build_job(context, package, package_path, dependencies, force_cmake, pre_clean, prebuild=False):
    """Job class for building catkin packages"""

    # Package source space path
    pkg_dir = os.path.join(context.source_space_abs, package_path)

    # Package build space path
    build_space = context.package_build_space(package)
    # Package devel space path
    devel_space = context.package_devel_space(package)
    # Package install space path
    install_space = context.package_install_space(package)
    # Package metadata path
    metadata_path = context.package_metadata_path(package)
    # Environment dictionary for the job, which will be built
    # up by the executions in the loadenv stage.
    job_env = dict(os.environ)

    # Create job stages
    stages = []

    # Load environment for job.
    stages.append(FunctionStage(
        'loadenv',
        loadenv,
        locked_resource=None if context.isolate_install else 'installspace',
        job_env=job_env,
        package=package,
        context=context
    ))

    # Create package build space
    stages.append(FunctionStage(
        'mkdir',
        makedirs,
        path=build_space
    ))

    # Create package metadata dir
    stages.append(FunctionStage(
        'mkdir',
        makedirs,
        path=metadata_path
    ))

    # Copy source manifest
    stages.append(FunctionStage(
        'cache-manifest',
        copyfiles,
        source_paths=[os.path.join(context.source_space_abs, package_path, 'package.xml')],
        dest_path=os.path.join(metadata_path, 'package.xml')
    ))

    # Only run CMake if the Makefile doesn't exist or if --force-cmake is given
    # TODO: This would need to be different with `cmake --build`
    makefile_path = os.path.join(build_space, 'Makefile')

    if not os.path.isfile(makefile_path) or force_cmake:

        require_command('cmake', CMAKE_EXEC)

        # CMake command
        stages.append(CommandStage(
            'cmake',
            [
                CMAKE_EXEC,
                pkg_dir,
                '--no-warn-unused-cli',
                '-DHAZEL_DEVEL_PREFIX=' + devel_space,
                '-DCMAKE_INSTALL_PREFIX=' + install_space
            ] + context.cmake_args,
            cwd=build_space,
            logger_factory=CMakeIOBufferProtocol.factory_factory(pkg_dir),
            occupy_job=True
        ))
    else:
        # Check buildsystem command
        stages.append(CommandStage(
            'check',
            [MAKE_EXEC, 'cmake_check_build_system'],
            cwd=build_space,
            logger_factory=CMakeIOBufferProtocol.factory_factory(pkg_dir),
            occupy_job=True
        ))

    # Filter make arguments
    make_args = handle_make_arguments(
        context.make_args +
        context.catkin_make_args)

    # Pre-clean command
    if pre_clean:
        # TODO: Remove target args from `make_args`
        stages.append(CommandStage(
            'preclean',
            [MAKE_EXEC, 'clean'] + make_args,
            cwd=build_space,
        ))

    require_command('make', MAKE_EXEC)

    # Make command
    stages.append(CommandStage(
        'make',
        [MAKE_EXEC] + make_args,
        cwd=build_space,
        logger_factory=CMakeMakeIOBufferProtocol.factory
    ))

    # Symlink command if using a linked develspace
    if context.link_devel:
        stages.append(FunctionStage(
            'symlink',
            link_devel_products,
            locked_resource='symlink-collisions-file',
            package=package,
            package_path=package_path,
            devel_manifest_path=context.package_metadata_path(package),
            source_devel_path=context.package_devel_space(package),
            dest_devel_path=context.devel_space_abs,
            metadata_path=context.metadata_path(),
            prebuild=prebuild
        ))

    # Make install command, if installing
    if context.install:
        stages.append(CommandStage(
            'install',
            [MAKE_EXEC, 'install'],
            cwd=build_space,
            logger_factory=CMakeMakeIOBufferProtocol.factory,
            locked_resource=None if context.isolate_install else 'installspace'
        ))

    return Job(
        jid=package.name,
        deps=dependencies,
        env=job_env,
        stages=stages)


description = {
    "build_type": "hazel",
    "description": "builds a package with the 'hazel' build type",
    "create_build_job": create_hazel_build_job,
    "create_clean_job": create_catkin_clean_job,
}
