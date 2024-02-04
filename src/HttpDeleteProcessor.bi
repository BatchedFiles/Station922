#ifndef HTTPDELETEPROCESSOR_BI
#define HTTPDELETEPROCESSOR_BI

#include once "IHttpDeleteAsyncProcessor.bi"

Extern CLSID_HTTPDELETEASYNCPROCESSOR Alias "CLSID_HTTPDELETEASYNCPROCESSOR" As Const CLSID

Const RTTI_ID_HTTPDELETEPROCESSOR        = !"\001Delete____Proc\001"

Declare Function CreateHttpDeleteProcessor( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
