package pdb

Guid :: struct {
	data1: u32le,
	data2: u16le,
	data3: u16le,
	data4: [8]byte,
}

PdbVersion :: enum u32le {
	VC2     = 19941610,
	VC4     = 19950623,
	VC41    = 19950814,
	VC50    = 19960307,
	VC98    = 19970604,
	VC70Dep = 19990604,
	VC70    = 20000404,
	VC80    = 20030901,
	VC110   = 20091201,
	VC140   = 20140508,
}

PdbHeader :: struct {
	version:   PdbVersion,
	signature: u32le,
	age:       u32le,
	unique_id: Guid,
}

ProgramDatabase :: struct {
	using header: PdbHeader,
}
