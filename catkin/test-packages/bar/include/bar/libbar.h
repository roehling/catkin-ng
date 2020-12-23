#ifndef INCLUDE_BAR_LIBBAR_H_
#define INCLUDE_BAR_LIBBAR_H_

#include <foo/libfoo.h>

namespace bar
{
    using foo::hello_world;
    void goodbye_world();
}

#endif
