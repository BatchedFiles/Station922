#ifndef FILEASYNCSTREAM_BI
#define FILEASYNCSTREAM_BI

#include once "IFileAsyncStream.bi"

Extern CLSID_FILESTREAM Alias "CLSID_FILESTREAM" As Const CLSID

Const RTTI_ID_FILESTREAM             = !"\001File____Stream\001"
Const RTTI_ID_FILEBYTES              = !"\001File_____Bytes\001"

Declare Function CreateFileStream( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
