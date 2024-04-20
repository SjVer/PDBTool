package msf

import "../util"
import "core:log"
import "core:math"

read_superblock :: proc(reader: ^util.Reader) -> SuperBlock {
	superblock := util.reader_read_t(reader, SuperBlock)

	assert(superblock.file_magic == FILE_MAGIC, "Invalid superblock magic")
	assert(
		superblock.active_fpm == 1 || superblock.active_fpm == 2,
		"Invalid active fmp",
	)

	found_valid_size := false
	for size in BLOCK_SIZES do found_valid_size |= size == superblock.block_size
	assert(found_valid_size, "Invalid block size")

	reader.offset += auto_cast superblock.block_size - size_of(SuperBlock)

	return superblock
}

read_block :: proc(reader: ^util.Reader, block_size: int) -> []byte {
	return util.reader_read(reader, block_size)
}

read_fpm_block :: proc(
	reader: ^util.Reader,
	block_size: int,
) -> FreePageMapBlock {
	return {block_flags = read_block(reader, block_size)}
}

read_it_data_blocks :: proc(
	reader: ^util.Reader,
	block_size: int,
	block_count: int,
) -> []DataBlock {
	data_blocks := make([]DataBlock, block_count)
	for i in 0 ..< block_count {
		data_blocks[i] = read_block(reader, block_size)
	}

	return data_blocks
}

read_iteration_block :: proc(
	reader: ^util.Reader,
	block_size: int,
	it_block_count: int,
) -> (
	it: Iteration(DataBlock),
) {
	assert(it_block_count >= 3, "Invalid iteration block count")

	it.first_block = read_block(reader, block_size)
	it.fpm_1_block = read_fpm_block(reader, block_size)
	it.fpm_2_block = read_fpm_block(reader, block_size)
	it.data_blocks = read_it_data_blocks(
		reader,
		block_size,
		it_block_count - 3,
	)
	return it
}

read_msf_file :: proc(reader: ^util.Reader) -> (file: RawFile) {
	// read the superblock for some needed metadata
	file.first_interval.first_block = read_superblock(reader)
	log.debug(rawfile_sb(file))

	// check file size
	block_size := cast(int)rawfile_sb(file).block_size
	block_count := cast(int)rawfile_sb(file).block_count
	assert(len(reader.data) == block_size * block_count, "Invalid file size")

	// read the rest of the first interval
	file.first_interval.fpm_1_block = read_fpm_block(reader, block_size)
	file.first_interval.fpm_2_block = read_fpm_block(reader, block_size)

	data_blocks_left := block_count - 3

	// read the first iteration's data blocks
	{
		data_block_count := min(data_blocks_left, block_size - 3)
		file.first_interval.data_blocks = read_it_data_blocks(
			reader,
			block_size,
			data_block_count,
		)
		data_blocks_left -= data_block_count
	}

	// read the rest of the iterations
	iteration_count := util.ceil_div(data_blocks_left, block_size) 
	file.iterations = make([]Iteration(DataBlock), iteration_count)
	for i in 0 ..< iteration_count {
		data_block_count := min(data_blocks_left, block_size - 3)
		it := read_iteration_block(reader, block_size, data_block_count)
		file.iterations[i] = it
		data_blocks_left -= data_block_count

		assert(data_blocks_left >= 0, "Invalid data block count")
	}

	assert(data_blocks_left == 0, "Invalid data block count")
	assert(reader.offset == len(reader.data), "Invalid end of file offset")
	return file
}
