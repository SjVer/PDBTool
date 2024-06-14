#pragma once

#include "support.hpp"

namespace pdbtool::raw
{

class Reader
{
  public:
    void* buffer;
    const size_t size;
    size_t offset = 0;

    Reader(size_t size, void* buffer) : size(size), buffer(buffer) {}

    template <typename T>
    T* Read()
    {
        assert(offset + sizeof(T) <= size);

        T* result = reinterpret_cast<T*>(buffer + offset);
        offset += sizeof(T);
        return result;
    }
};

} // namespace pdbtool::raw