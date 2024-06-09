# The PDB Debug Info (DBI) Stream

The DBI stream contains a variety of information about the compilation unit in the PDB file. It is the third stream in the PDB file, and is located at the index specified by the PDB stream's named stream map.

This stream's index in the MSF file is always 3.

## DBI Stream Header

At offset 0:

```cpp
struct DbiStreamHeader {
  int32_t VersionSignature;
  uint32_t VersionHeader;
  uint32_t Age;
  uint16_t GlobalStreamIndex;
  uint16_t BuildNumber;
  uint16_t PublicStreamIndex;
  uint16_t PdbDllVersion;
  uint16_t SymRecordStream;
  uint16_t PdbDllRbld;
  int32_t ModInfoSize;
  int32_t SectionContributionSize;
  int32_t SectionMapSize;
  int32_t SourceInfoSize;
  int32_t TypeServerMapSize;
  uint32_t MFCTypeServerIndex;
  int32_t OptionalDbgHeaderSize;
  int32_t ECSubstreamSize;
  uint16_t Flags;
  uint16_t Machine;
  uint32_t Padding;
};
```

- **VersionSignature**: Unknown, but always seems to be -1.
- **VersionHeader**: One of the following enum:
  ```cpp
  enum DbiStreamVersion {
    VC41 = 930803,
    V50 = 19960307,
    V60 = 19970606,
    V70 = 19990903,
    V110 = 20091201
  };
  ```
- **Age**: The number of times the PDB file has been written.
- **GlobalStreamIndex**: The index of the global symbol stream which contains the CodeView symbol table for all global symbols.
- **BuildNumber**: The build number of the compiler that generated the PDB file, with the following layout:
  ```cpp
  uint16_t MinorVersion : 8;
  uint16_t MajorVersion : 7;
  uint16_t NewVersionFormat : 1;
  ```
- **PublicStreamIndex**: <TODO>
- **PdbDllVersion**: <TODO>
- **SymRecordStream**: <TODO>
- **PdbDllRbld**: <TODO>
- **ModInfoSize**: The size of the module information substream.
- **SectionContributionSize**: <TODO>
- **SectionMapSize**: <TODO>
- **SourceInfoSize**: <TODO>
- **TypeServerMapSize**: <TODO>
- **MFCTypeServerIndex**: <TODO>
- **OptionalDbgHeaderSize**: <TODO>
- **ECSubstreamSize**: <TODO>
- **Flags**: <TODO>
- **Machine**: <TODO>

## Module Information Substream

Immediately following the DBI stream header is an array of variable-length records each describing a single module linked into the program.

Each entry has the following layout:
  
```cpp
struct ModInfo {
  uint32_t Unused1;
  struct SectionContribEntry SectionContr; // 28 bytes
  uint16_t Flags;
  uint16_t ModuleSymStream;
  uint32_t SymByteSize;
  uint32_t C11ByteSize;
  uint32_t C13ByteSize;
  uint16_t SourceFileCount;
  char Padding[2];
  uint32_t Unused2;
  uint32_t SourceFileNameIndex;
  uint32_t PdbFilePathNameIndex;
  char ModuleName[];
  char ObjFileName[];
};
```

- **ModuleSymStream**: The index of the module's symbol stream. This stream includes both the CodeView symbol information and line information. (-1 if not present.)
- **SymByteSize**: The size of the stream indentified by `ModuleSymStream`.
- **C11ByteSize**: The size of the stream containing the C11 line information.
- **C13ByteSize**: The size of the stream containing the C13 line information.
- **SourceFileCount**: The number of source source files in the module.
- **ModuleName**: The name of the module.
- **ObjFileName**: The name of the object file.

See [LLVM's documentation](https://llvm.org/docs/PDB/DbiStream.html#module-info-substream) for details on the other fields. 