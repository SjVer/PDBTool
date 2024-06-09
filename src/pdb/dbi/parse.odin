package dbi

import "../../msf"
import "../../util"
import "core:log"
import "core:slice"
import "core:strings"

DBI_STREAM_INDEX :: 3

parse_dbi_header :: proc(
	reader: ^util.Reader,
) -> (
	hdr: DbiHeader,
	mod_info_size: i32,
) {
	util.reader_skip_t(reader, u32) // int32_t VersionSignature

	hdr.version = util.reader_read_t(reader, DbiVersion)
	hdr.age = util.reader_read_t(reader, u32)

	util.reader_skip_t(reader, u16) // uint16_t GlobalStreamIndex
	util.reader_skip_t(reader, u16) // uint16_t BuildNumber
	util.reader_skip_t(reader, u16) // uint16_t PublicStreamIndex
	util.reader_skip_t(reader, u16) // uint16_t PdbDllVersion
	util.reader_skip_t(reader, u16) // uint16_t SymRecordStream
	util.reader_skip_t(reader, u16) // uint16_t PdbDllRbld

	mod_info_size = util.reader_read_t(reader, i32)

	util.reader_skip_t(reader, i32) // int32_t SectionContributionSize
	util.reader_skip_t(reader, i32) // int32_t SectionMapSize
	util.reader_skip_t(reader, i32) // int32_t SourceInfoSize
	util.reader_skip_t(reader, i32) // int32_t TypeServerMapSize
	util.reader_skip_t(reader, u32) // uint32_t MFCTypeServerIndex
	util.reader_skip_t(reader, i32) // int32_t OptionalDbgHeaderSize
	util.reader_skip_t(reader, i32) // int32_t ECSubstreamSize
	util.reader_skip_t(reader, u16) // uint16_t Flags
	util.reader_skip_t(reader, u16) // uint16_t Machine
	util.reader_skip_t(reader, u32) // uint32_t Padding

	return
}

SECTION_CONTR_SIZE :: 28
MOD_INFO_RAW_MIN_SIZE :: 64

parse_mod_info :: proc(reader: ^util.Reader) -> (mod_info: ModuleInfo) {
	util.reader_skip_t(reader, u32) // uint32_t Unused1
	reader.offset += SECTION_CONTR_SIZE // struct SectionContribEntry SectionContr
	util.reader_skip_t(reader, u16) // uint16_t Flags
	util.reader_skip_t(reader, u16) // uint16_t ModuleSymStream
	util.reader_skip_t(reader, u32) // uint32_t SymByteSize
	util.reader_skip_t(reader, u32) // uint32_t C11ByteSize
	util.reader_skip_t(reader, u32) // uint32_t C13ByteSize
	util.reader_skip_t(reader, u16) // uint16_t SourceFileCount
	reader.offset += 2 // char Padding[2]
	util.reader_skip_t(reader, u32) // uint32_t Unused2
	util.reader_skip_t(reader, u32) // uint32_t SourceFileNameIndex
	util.reader_skip_t(reader, u32) // uint32_t PdbFilePathNameIndex

	mod_info.module_name = util.reader_read_cstring(reader)
	mod_info.obj_file_name = util.reader_read_cstring(reader)

    // TODO: if a module is weird somehow it takes less bytes 
    // which fucks things up for the following modules

	return
}

parse_dbi_stream :: proc(dir: ^msf.StreamDirectory) -> (dbi: DebugInfo) {
	reader := util.reader_from_data(dir[DBI_STREAM_INDEX])

	mod_info_size: i32
	dbi.header, mod_info_size = parse_dbi_header(&reader)

	mods: [dynamic]ModuleInfo
	for mod_info_size >= MOD_INFO_RAW_MIN_SIZE {
		start := reader.offset

		mod_info := parse_mod_info(&reader)
		append(&mods, mod_info)

		log.debug(mod_info.module_name, ":", mod_info.obj_file_name)
		// if len(mods) == 4 do break

		mod_info_size -= auto_cast (reader.offset - start)
	}

	return
}
