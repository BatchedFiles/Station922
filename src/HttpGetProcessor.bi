#ifndef HTTPGETPROCESSOR_BI
#define HTTPGETPROCESSOR_BI

#include once "IHttpGetAsyncProcessor.bi"

Extern CLSID_HTTPGETASYNCPROCESSOR Alias "CLSID_HTTPGETASYNCPROCESSOR" As Const CLSID

Const RTTI_ID_HTTPGETPROCESSOR        = !"\001Get_______Proc\001"

Type HttpGetProcessor As _HttpGetProcessor

Type LPHttpGetProcessor As _HttpGetProcessor Ptr

Declare Function CreateHttpGetProcessor( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
