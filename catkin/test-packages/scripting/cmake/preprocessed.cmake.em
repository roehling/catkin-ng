message(STATUS "I am installed to the prefix @(PREFIX)")
@[if DEVELSPACE]
message(STATUS "This is only printed in develspace")
@[end if]
@[if INSTALLSPACE]
message(STATUS "This is only printed in installspace")
@[end if]
