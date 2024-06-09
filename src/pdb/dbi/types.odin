package dbi

DbiVersion :: enum u32 {
	VC41 = 930803,
	V50  = 19960307,
	V60  = 19970606,
	V70  = 19990903,
	V110 = 20091201,
}

DbiHeader :: struct {
	version: DbiVersion,
	age:     u32,
}

ModuleInfo :: struct {
	module_name:   string,
	obj_file_name: string,
}

DebugInfo :: struct {
	using header: DbiHeader,
	modules:      []ModuleInfo,
}
