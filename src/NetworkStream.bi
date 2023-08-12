#ifndef NETWORKSTREAM_BI
#define NETWORKSTREAM_BI

#include once "INetworkStream.bi"

Const RTTI_ID_NETWORKSTREAM           = !"\001Network_Stream\001"

Extern CLSID_NETWORKSTREAM Alias "CLSID_NETWORKSTREAM" As Const CLSID

Type NetworkStream As _NetworkStream

Type LPNetworkStream As _NetworkStream Ptr

Declare Function CreateNetworkStream( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
