#include <gtest/gtest.h>
#include "load_test_pdb.hpp"
#include "raw.hpp"

#define SUITE MultiStreamFile

TEST(SUITE, Read)
{
    if (!load_test_pdb()) FAIL();
    using namespace pdbtool::raw::msf;
    
    MultiStreamFile msf(test_pdb_buffer, test_pdb_buffer_size);
    ASSERT_EQ(msf.SB->blockSize, 4096);
    ASSERT_EQ(msf.SB->activeFreePageMap, 1);
}
