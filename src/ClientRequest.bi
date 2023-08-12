#ifndef CLIENTREQUEST_BI
#define CLIENTREQUEST_BI

#include once "IClientRequest.bi"

Const RTTI_ID_CLIENTREQUEST           = !"\001Client_Request\001"

Extern CLSID_CLIENTREQUEST Alias "CLSID_CLIENTREQUEST" As Const CLSID

Type ClientRequest As _ClientRequest

Type LPClientRequest As _ClientRequest Ptr

Declare Function CreateClientRequest( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
