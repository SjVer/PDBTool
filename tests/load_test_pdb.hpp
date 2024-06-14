#pragma once

#include <cstdio>

static unsigned char* test_pdb_buffer;
static size_t test_pdb_buffer_size;

static bool load_test_pdb()
{
    FILE* file = fopen("test-files/pdbtool.pdb", "rb");
    if (!file) return false;

    fseek(file, 0, SEEK_END);
    test_pdb_buffer_size = ftell(file);
    fseek(file, 0, SEEK_SET);

    test_pdb_buffer = new unsigned char[test_pdb_buffer_size];
    fread(test_pdb_buffer, 1, test_pdb_buffer_size, file);

    fclose(file);

    return true;
}