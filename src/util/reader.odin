package util

import "core:os"

Reader :: struct {
	data:   []byte,
	offset: int,
}

reader_from_data :: proc(data: []byte) -> Reader {
	return Reader{data = data, offset = 0}
}

reader_from_filename :: proc(filename: string) -> Reader {
	data, ok := os.read_entire_file_from_filename(filename)
	assert(ok, "Failed to read file")

	return reader_from_data(data)
}

reader_read :: proc(reader: ^Reader, size: int) -> []byte {
	assert(
		reader.offset + size <= len(reader.data),
		"Buffer read out of bounds",
	)
	reader.offset += size
	return reader.data[reader.offset - size:reader.offset]
}

reader_read_t :: proc(reader: ^Reader, $T: typeid) -> T {
	data := reader_read(reader, size_of(T))
	return (^T)(raw_data(data))^
}

reader_read_into :: proc(reader: ^Reader, dest: ^$T) {
	dest^ = reader_read_t(reader, T)
}

reader_read_cstring :: proc(reader: ^Reader) -> string {
	start := reader.offset
	for reader.data[reader.offset] != 0 {
		reader.offset += 1
		assert(reader.offset < len(reader.data), "Unterminated string")
	}
	
	reader.offset += 1 // skip null terminator
	assert(reader.offset <= len(reader.data), "Unterminated string")

	return string(reader.data[start:reader.offset - 1])
}

reader_skip_t :: proc(reader: ^Reader, $T: typeid) {
	reader.offset += size_of(T)
}
