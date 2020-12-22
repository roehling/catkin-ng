@@PACKAGE_INIT@@
@[if EXPORT_DEPENDS]
include(CMakeFindDependencyMacro)
@[for dep in EXPORT_DEPENDS]@
find_dependency(@dep)
@[end for]@
@[end if]
@[for inc in CMAKE_FILES]@
include("${CMAKE_CURRENT_LIST_DIR}/@(inc).cmake")
@[end for]@
set(@@PROJECT_NAME@@_CATKIN_PACKAGE TRUE)
set(@@PROJECT_NAME@@_CATKIN_VERSION "@@CATKIN_VERSION@@")
