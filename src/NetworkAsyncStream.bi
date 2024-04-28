#ifndef NETWORKASYNCSTREAM_BI
#define NETWORKASYNCSTREAM_BI

#include once "INetworkAsyncStream.bi"

Const RTTI_ID_NETWORKSTREAM           = !"\001Network_Stream\001"

Extern CLSID_NETWORKSTREAM Alias "CLSID_NETWORKSTREAM" As Const CLSID

Declare Function CreateNetworkStream( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
