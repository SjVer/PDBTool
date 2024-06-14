#pragma once

#include <cstdint>
#include <cassert>

namespace pdbtool::support
{

// TODO: make better
typedef uint32_t ulittle32_t;

template <typename T>
T ceil_div(T a, T b)
{
    return 1 + ((a - 1) / b);
}

} // namespace pdbtool::support