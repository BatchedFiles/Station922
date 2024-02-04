#ifndef SERVERRESPONSE_BI
#define SERVERRESPONSE_BI

#include once "IServerResponse.bi"

Extern CLSID_SERVERRESPONSE Alias "CLSID_SERVERRESPONSE" As Const CLSID

Const RTTI_ID_SERVERRESPONSE          = !"\001ServerResponse\001"

Declare Function CreateServerResponse( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
