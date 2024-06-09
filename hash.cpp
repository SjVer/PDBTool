#include <cstdint>
#include <string>
#include <iostream>

#pragma scalar_storage_order little - endian

#if 0

// assume little endian
typedef uint16_t ulittle16_t;
typedef uint32_t ulittle32_t;

// https://github.com/llvm/llvm-project/blob/main/llvm/lib/DebugInfo/PDB/Native/Hash.cpp#L20
uint32_t hashStringV1(std::string Str)
{
    uint32_t Result = 0;
    uint32_t Size = Str.size();

    ulittle32_t *Longs = reinterpret_cast<ulittle32_t *>(Str.data());
    uint32_t NumLongs = Size / 4;

    for (int i = 0; i < NumLongs; ++i)
        Result ^= Longs[i];

    const uint8_t *Remainder = reinterpret_cast<const uint8_t *>(Longs + NumLongs);
    uint32_t RemainderSize = Size % 4;

    // Maximum of 3 bytes left.  Hash a 2 byte word if possible, then hash the
    // possibly remaining 1 byte.
    if (RemainderSize >= 2)
    {
        uint16_t Value = *reinterpret_cast<const ulittle16_t *>(Remainder);
        Result ^= static_cast<uint32_t>(Value);
        Remainder += 2;
        RemainderSize -= 2;
    }

    // hash possible odd byte
    if (RemainderSize == 1)
    {
        Result ^= *(Remainder++);
    }

    const uint32_t toLowerMask = 0x20202020;
    Result |= toLowerMask;
    Result ^= (Result >> 11);

    return Result ^ (Result >> 16);
}

#else

unsigned long hashStringV1(std::string str)
{
    uint8_t *pb = (uint8_t *)str.data();
    size_t cb = str.size();

    unsigned long ulHash = 0;

    // hash leading dwords using Duff's Device
    size_t cl = cb >> 2;
    unsigned long *pul = (unsigned long *)pb;
    unsigned long *pulMac = pul + cl;
    size_t dcul = cl & 7;

    switch (dcul)
    {
        do
        {
            dcul = 8;
            ulHash ^= pul[7];
        case 7:
            ulHash ^= pul[6];
        case 6:
            ulHash ^= pul[5];
        case 5:
            ulHash ^= pul[4];
        case 4:
            ulHash ^= pul[3];
        case 3:
            ulHash ^= pul[2];
        case 2:
            ulHash ^= pul[1];
        case 1:
            ulHash ^= pul[0];
        case 0:;
        } while ((pul += dcul) < pulMac);
    }

    pb = (uint8_t *)pul;

    // hash possible odd word
    if (cb & 2)
    {
        ulHash ^= *(unsigned short *)pb;
        pb = (uint8_t *)((unsigned short *)pb + 1);
    }

    // hash possible odd byte
    if (cb & 1)
    {
        ulHash ^= *(pb++);
    }

    const unsigned long toLowerMask = 0x20202020;
    ulHash |= toLowerMask;
    ulHash ^= (ulHash >> 11);

    return (ulHash ^ (ulHash >> 16));
}

#endif

int main()
{
    const uint32_t capacity = 10;

    {
        std::string str = "/LinkInfo";
        uint16_t hash = hashStringV1(str);
        std::cout << str << " -> " << hash << " = " << hash % capacity << std::endl;
    }
    {
        std::string str = "/TMCache";
        uint16_t hash = hashStringV1(str);
        std::cout << str << " -> " << hash << " = " << hash % capacity << std::endl;
    }
}