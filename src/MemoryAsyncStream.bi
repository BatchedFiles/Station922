#ifndef MEMORYASYNCSTREAM_BI
#define MEMORYASYNCSTREAM_BI

#include once "IMemoryAsyncStream.bi"

Const RTTI_ID_MEMORYSTREAM            = !"\001Memory__Stream\001"
Const RTTI_ID_MEMORYBODY        = !"\001Body____Buffer\001"

Extern CLSID_MEMORYSTREAM Alias "CLSID_MEMORYSTREAM" As Const CLSID

Declare Function CreateMemoryStream( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
