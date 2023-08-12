#ifndef FILESTREAM_BI
#define FILESTREAM_BI

#include once "IFileStream.bi"

Extern CLSID_FILESTREAM Alias "CLSID_FILESTREAM" As Const CLSID

Const RTTI_ID_FILESTREAM              = !"\001File____Stream\001"
Const RTTI_ID_FILEBYTES              = !"\001File_____Bytes\001"

Type FileStream As _FileStream

Type LPFileStream As _FileStream Ptr

Declare Function CreateFileStream( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
