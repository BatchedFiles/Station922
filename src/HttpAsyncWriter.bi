#ifndef HTTPWRITER_BI
#define HTTPWRITER_BI

#include once "IHttpAsyncWriter.bi"

Const RTTI_ID_HTTPWRITER              = !"\001Http____Writer\001"

Extern CLSID_HTTPWRITER Alias "CLSID_HTTPWRITER" As Const CLSID

Declare Function CreateHttpWriter( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
