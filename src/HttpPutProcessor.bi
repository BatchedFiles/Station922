#ifndef HTTPPUTPROCESSOR_BI
#define HTTPPUTPROCESSOR_BI

#include once "IHttpPutAsyncProcessor.bi"

Extern CLSID_HTTPPUTASYNCPROCESSOR Alias "CLSID_HTTPPUTASYNCPROCESSOR" As Const CLSID

Const RTTI_ID_HTTPPUTPROCESSOR        = !"\001Put_______Proc\001"

Declare Function CreateHttpPutProcessor( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
