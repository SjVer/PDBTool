#include "raw.hpp"

namespace pdbtool::raw::msf
{

MultiStreamFile::MultiStreamFile(unsigned char* buffer, size_t size)
{
    // read the superblock

    SB = (SuperBlock*)buffer;

    assert(strcmp(SB->fileMagic, FILE_MAGIC) == 0);
    assert(
        std::find(std::begin(BLOCK_SIZES), std::end(BLOCK_SIZES), SB->blockSize) !=
        std::end(BLOCK_SIZES)
    );
    assert(size == 0 || size == SB->blockSize * SB->numBlocks);

    // read the blocks

    dataBlocks = new unsigned char*[SB->numBlocks];
    freePageMap1 = new unsigned char*[NumIterations()];
    freePageMap2 = new unsigned char*[NumIterations()];

    uint32_t iterI = 0;
    for (uint32_t blockI = 0; blockI < SB->numBlocks; blockI++)
    {
        unsigned char* block = buffer + blockI * SB->blockSize;
        dataBlocks[blockI] = block;

        if (blockI > 0 && blockI % SB->blockSize == 0) iterI++;
        if (blockI % SB->blockSize == 1) freePageMap1[iterI] = block;
        if (blockI % SB->blockSize == 2) freePageMap2[iterI] = block;
    }
    assert(iterI == NumIterations() - 1);
}

} // namespace pdbtool::raw::msf
