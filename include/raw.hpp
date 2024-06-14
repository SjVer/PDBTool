#pragma once

#include "support.hpp"
#include <vector>
#include <bitset>

namespace pdbtool::raw
{

namespace msf
{

constexpr char FILE_MAGIC[] = "Microsoft C/C++ MSF 7.00\r\n\x1a\x44\x53\x00\x00";
constexpr int BLOCK_SIZES[] = {512, 1024, 2048, 4096};

struct SuperBlock
{
    char fileMagic[sizeof(FILE_MAGIC)];
    support::ulittle32_t blockSize;
    support::ulittle32_t activeFreePageMap;
    support::ulittle32_t numBlocks;
    support::ulittle32_t numDirectoryBytes;
    support::ulittle32_t _unknown;
    support::ulittle32_t blockMapAddr;
};

struct MultiStreamFile
{
    SuperBlock* SB;
    unsigned char** dataBlocks;
    unsigned char** freePageMap1;
    unsigned char** freePageMap2;

    MultiStreamFile(unsigned char* buffer, size_t size = 0);

    uint32_t NumIterations() const
    {
        return support::ceil_div(SB->numBlocks, SB->blockSize);
    }

    unsigned char** ActiveFPM() const
    {
        assert(SB->activeFreePageMap == 1 || SB->activeFreePageMap == 2);
        return SB->activeFreePageMap == 1 ? freePageMap1 : freePageMap2;
    }
};

} // namespace msf
} // namespace pdbtool::raw