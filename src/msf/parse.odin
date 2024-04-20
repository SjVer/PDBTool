package msf

import "../util"
import "core:log"

RawStreamDirectory :: struct {
	stream_count:  u32le,
	stream_sizes:  []u32le,
	stream_blocks: [][]u32le,
}

extract_raw_stream_dir :: proc(raw_file: RawFile) -> []byte {
	block_size := rawfile_sb(raw_file).block_size
	directory_size := rawfile_sb(raw_file).directory_size
	dir_map_index := cast(uint)rawfile_sb(raw_file).dir_map_index

	dir_block_count := util.ceil_div(directory_size, block_size)

	raw_dir := make([]byte, directory_size)

	raw_directory_map := rawfile_get_data_block(raw_file, dir_map_index)
	indices_reader := util.reader_from_data(raw_directory_map)
	for i in 0 ..< dir_block_count {
		index := util.reader_read_t(&indices_reader, u32le)
		block := rawfile_get_data_block(raw_file, auto_cast index)

		dst_size := directory_size - i * block_size
		copy_size := min(len(block), cast(int)dst_size)
		copy(raw_dir[i * block_size:][:copy_size], block[0:][:copy_size])
	}

	return raw_dir
}

parse_directory :: proc(raw_file: RawFile) -> (dir: RawStreamDirectory) {
	raw_dir := extract_raw_stream_dir(raw_file)
	dir_reader := util.reader_from_data(raw_dir)

	dir.stream_count = util.reader_read_t(&dir_reader, u32le)
    
    // read stream sizes
	dir.stream_sizes = make([]u32le, dir.stream_count)
	for i in 0 ..< dir.stream_count {
		dir.stream_sizes[i] = util.reader_read_t(&dir_reader, u32le)

		// sometimes the size is UINT32_MAX, fuck knows why. even LLVM doesn't know:
		// https://github.com/llvm/llvm-project/blob/eefee382186005d3662958e076c8e61e286ea1ab/
		// llvm/lib/DebugInfo/PDB/Native/PDBFile.cpp#L201 
		if dir.stream_sizes[i] == 0xffffffff {
			dir.stream_sizes[i] = 0
		}
	}

    // read stream block indices
	dir.stream_blocks = make([][]u32le, dir.stream_count)
	for s in 0 ..< dir.stream_count {

		block_count := util.ceil_div(
			dir.stream_sizes[s],
			rawfile_sb(raw_file).block_size,
		)

		dir.stream_blocks[s] = make([]u32le, block_count)

		for b in 0 ..< block_count {
			dir.stream_blocks[s][b] = util.reader_read_t(&dir_reader, u32le)
		}
	}

	return dir
}

parse_msf_file :: proc(raw_file: RawFile) -> StreamDirectory {
	raw_dir := parse_directory(raw_file)

    // per stream, concat all its blocks into one big blop
    streams := make([]Stream, raw_dir.stream_count)
    for s in 0..<raw_dir.stream_count {
        stream := make([]byte, raw_dir.stream_sizes[s])

        offset := 0
        for block_index in raw_dir.stream_blocks[s] {
			block := rawfile_get_data_block(raw_file, auto_cast block_index)

			copy_size := min(
				cast(int) rawfile_sb(raw_file).block_size,
				len(stream) - offset,
			)
			copy(stream[offset:][:copy_size], block[0:][:copy_size])

			offset += copy_size
        }

		streams[s] = stream
    }

	return streams
}
