package msf

// types for the raw data from the file

FILE_MAGIC :: "Microsoft C/C++ MSF 7.00\r\n\x1a\x44\x53\x00\x00"

BLOCK_SIZES :: []u32le{512, 1024, 2048, 4096}

SuperBlock :: struct {
	file_magic:     [len(FILE_MAGIC)]byte `fmt:"-"`,
	block_size:     u32le, // == blocks per iteration
	active_fpm:     u32le,
	block_count:    u32le,
	directory_size: u32le,
	_unknown:       u32le `fmt:"-"`,
	dir_map_index:  u32le,
}

FreePageMapBlock :: struct {
	// one bit set per 8 blocks
	block_flags: []byte,
}

DataBlock :: []byte

Iteration :: struct($FirstBlock: typeid) {
	first_block: FirstBlock,
	fpm_1_block: FreePageMapBlock,
	fpm_2_block: FreePageMapBlock,
	data_blocks: []DataBlock,
}

RawFile :: struct {
	first_interval: Iteration(SuperBlock),
	iterations:     []Iteration(DataBlock),
}

// abstracted types for the parsed file
// there isn't much of the original structure left here

Stream :: []byte

StreamDirectory :: []Stream
