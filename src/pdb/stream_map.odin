package pdb

import "../util"
import "core:log"
import "core:slice"

read_bit_vector :: proc(reader: ^util.Reader) -> []bool {
	word_count := cast(int)util.reader_read_t(reader, u32le)
	bytes := util.reader_read(reader, word_count * 4)

	bits := make([]bool, word_count * 32)
	for b, byte_index in bytes {
		for bit_index in 0 ..< 8 {
			mask := 1 << cast(uint)bit_index
			bits[byte_index * 8 + bit_index] = (b & auto_cast mask) != 0
		}
	}

	return bits
}

NamedStreamMap :: struct {
	capacity:    int,
	entries:     map[string]int,
}

read_named_stream_map :: proc(reader: ^util.Reader) -> (m: NamedStreamMap) {
	// parse the string buffer
	buffer_size := cast(int)util.reader_read_t(reader, u32le)
	name_buffer := transmute(string)util.reader_read(reader, buffer_size)

	// parse the hash map properties
	map_size := cast(int)util.reader_read_t(reader, u32le)
	m.capacity = cast(int)util.reader_read_t(reader, u32le)
	present := read_bit_vector(reader)
	_deleted := read_bit_vector(reader)

	assert(slice.count(present, true) == map_size)

	// parse the buckets
	m.entries = make(type_of(m.entries), m.capacity)
	for i in 0 ..< cast(uint)map_size {
		key := cast(int)util.reader_read_t(reader, u32le)
		value := cast(int)util.reader_read_t(reader, u32le)

		name_length := 0
		for name_buffer[key + name_length] != '\x00' {
			name_length += 1
		}
		name := name_buffer[key:][:name_length]

        m.entries[name] = value
		if !present[i] {
			log.warnf("PDB stream `{}` seems to be deleted", name)
		}
	}

	// assert(len(buckets) == map_size)
	return m
}
