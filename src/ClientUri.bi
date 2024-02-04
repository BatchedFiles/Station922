#ifndef CLIENTURI_BI
#define CLIENTURI_BI

#include once "IClientUri.bi"

Extern CLSID_CLIENTURI Alias "CLSID_CLIENTURI" As Const CLSID

Const RTTI_ID_CLIENTURI               = !"\001Client_____Uri\001"

Declare Function CreateClientUri( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
