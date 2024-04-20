package msf

rawfile_sb :: #force_inline proc(raw_file: RawFile) -> SuperBlock {
    return raw_file.first_interval.first_block
}

rawfile_get_data_block :: proc(raw_file: RawFile, index: uint) -> DataBlock {
    assert(index != 0, "Data block index is superblock index")

    superblock := raw_file.first_interval.first_block
    iteration := index / auto_cast superblock.block_size
    in_it_index := index % auto_cast superblock.block_size

    assert(in_it_index != 1 && in_it_index != 2, "Data block index is FPM block index")
    
    if iteration == 0 {
        // we already checked that index != 0
        return raw_file.first_interval.data_blocks[in_it_index - 3]
    } else {
        iteration := raw_file.iterations[iteration - 1]
        if in_it_index == 0 do return iteration.first_block
        else do return iteration.data_blocks[in_it_index - 3]
    }
}
