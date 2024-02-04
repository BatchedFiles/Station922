#ifndef ASYNCRESULT_BI
#define ASYNCRESULT_BI

#include once "IAsyncResult.bi"

Extern CLSID_ASYNCRESULT Alias "CLSID_ASYNCRESULT" As Const CLSID

Const RTTI_ID_ASYNCRESULT             = !"\001Async___Result\001"

Declare Function CreateAsyncResult( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
