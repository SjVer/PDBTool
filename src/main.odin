package pdbtool

import "core:log"
import "util"
import "msf"

main :: proc() {
    context.logger = log.create_console_logger(
        opt = {.Terminal_Color, .Level, .Short_File_Path, .Line},
        lowest = .Debug when ODIN_DEBUG else .Info
    )
    
    input_file := "bin/pdbtool.pdb"
    reader := util.reader_from_filename(input_file)

    raw_file := msf.read_msf_file(&reader)
    msf.parse_msf_file(raw_file)
}