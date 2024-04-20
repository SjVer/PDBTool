# Multi-Stream Format (MSF)

The Multi-Stream format is basically a file system inside a single file. These 'sub-files' are called streams.

(See [LLVM's MSF format documentation](https://llvm.org/docs/PDB/MsfFile.html).)

## Layout

The MSF format has the following components:

1. Superblock
2. Free Block Map (Free Page Map, FPM)
3. Data

These components are repeated once or more in the following order:

1. 1 block of data
2. Free Block Map 1
3. Free Block Map 2
4. blocks of data

In the first _iteration_, the first block is used to store the Superblock.

The amount of blocks of data is the file's `BlockSize`, minus 3.

## The Superblock

At offset 0:

```cpp
struct SuperBlock {
    char FileMagic[sizeof(Magic)];
    ulittle32_t BlockSize;
    ulittle32_t FreePageMapBlock;
    ulittle32_t NumBlocks;
    ulittle32_t NumDirectoryBytes;
    ulittle32_t Unknown;
    ulittle32_t BlockMapAddr;
};
```

- **FileMagic**: Must be equal to "Microsoft C / C++ MSF 7.00\\r\\n" followed by the bytes 1A 44 53 00 00 00.
- **BlockSize**: The size of each block of the internal file system, can be 512, 1024, 2048 or 4096 bytes.
- **FreePageMapBlock**: The active Free Block Map (1 or 2).
- **NumBlocks**: The total number of blocks in the file. The file size should be _NumBlocks * BlockSize_.
- **NumDirectoryBytes**: The size of the stream directory, in bytes.
- **BlockMapAddr**: An index to a block that contains the indices of the blocks used for the stream directory, which may be larger than one block.

## The Free Block Map

The Free Block Map (Free Page Map, FPM) is spread over a series of blocks which contain a bit flag for every block in the file. The flag indicates if the block is used (0) or unused (1).

Each file contains to FPMs to support incremental updates. When one is active, the other can be modified.

As mentioned, each iteration has an FPM block as second and third block. This means that there will be an FPM block at indices `{1,2} + SuperBlock.BlockSize * k`.

## The Stream Directory

Beginning at byte 0 in the file:

```cpp
struct StreamDirectory {
  ulittle32_t NumStreams;
  ulittle32_t StreamSizes[NumStreams];
  ulittle32_t StreamBlocks[NumStreams][];
};
```

- **NumStreams**: The number of streams in the file
- **StreamSizes**: The size of each stream, in bytes.
- **StreamBlocks**: The blocks used by each stream.