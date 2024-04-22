package pdbtool

import "core:log"
import "util"
import "msf"
import "pdb"

main :: proc() {
    context.logger = log.create_console_logger(
        opt = {.Terminal_Color, .Level, .Short_File_Path, .Line},
        lowest = .Debug when ODIN_DEBUG else .Info
    )
    
    input_file := "bin/pdbtool.pdb"
    reader := util.reader_from_filename(input_file)

    raw_file := msf.read_msf_file(&reader)
    stream_dir := msf.parse_msf_file(raw_file)
    log.debugf("stream count: %d", len(stream_dir))
    pdb := pdb.parse_pdb_msf(&stream_dir)
}