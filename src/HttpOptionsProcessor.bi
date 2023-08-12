#ifndef HTTPOPTIONSPROCESSOR_BI
#define HTTPOPTIONSPROCESSOR_BI

#include once "IHttpOptionsAsyncProcessor.bi"

Extern CLSID_HTTPOPTIONSASYNCPROCESSOR Alias "CLSID_HTTPOPTIONSASYNCPROCESSOR" As Const CLSID

Const RTTI_ID_HTTPOPTIONSPROCESSOR        = !"\001Options___Proc\001"

Type HttpOptionsProcessor As _HttpOptionsProcessor

Type LPHttpOptionsProcessor As _HttpOptionsProcessor Ptr

Declare Function CreateHttpOptionsProcessor( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
