package pdb

import "core:log"
import "core:slice"
import "core:strings"

import "../msf"
import "../util"
import "dbi"

PDB_STREAM_INDEX :: 1

parse_pdb_header :: proc(dir: ^msf.StreamDirectory) -> PdbHeader {
	reader := util.reader_from_data(dir[PDB_STREAM_INDEX])
	header := util.reader_read_t(&reader, PdbHeader)

	stream_map := read_named_stream_map(&reader)
	log.debug(stream_map)

	return header
}

parse_pdb_msf :: proc(dir: ^msf.StreamDirectory) -> (pdb: ProgramDatabase) {
	pdb.header = parse_pdb_header(dir)
	pdb.debug_info = dbi.parse_dbi_stream(dir)
	log.debug(pdb.debug_info)

	return
}
