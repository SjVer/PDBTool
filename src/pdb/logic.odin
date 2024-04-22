package pdb

// https://github.com/llvm/llvm-project/blob/48324f0f7b26b981e0f68e0faf9bb05d4a0e0fbb
// /llvm/lib/DebugInfo/PDB/Native/Hash.cpp#L20
hash_stream_name_map_key :: proc(name: string) -> (result: u32le) {
    longs := (transmute([^]u32le)raw_data(name))[0:len(name) / 4]

	for value in longs do result ~= auto_cast value

    remainder := raw_data(name)[len(name) - len(name) % 4:][:len(name) % 4]

    if len(remainder) >= 2 {
        value := (transmute([^]u16le)raw_data(remainder))[0]
        result ~= auto_cast value

        if len(remainder) == 3 {
            value := raw_data(remainder)[2]
            result ~= auto_cast value
        }
    }


    TO_LOWER_MASK :: 0x20202020
    result |= TO_LOWER_MASK
    result ~= (result >> 11)

    return result ~ (result >> 16)
}
