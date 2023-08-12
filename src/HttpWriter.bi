#ifndef HTTPWRITER_BI
#define HTTPWRITER_BI

#include once "IHttpWriter.bi"

Const RTTI_ID_HTTPWRITER              = !"\001Http____Writer\001"

Extern CLSID_HTTPWRITER Alias "CLSID_HTTPWRITER" As Const CLSID

Type HttpWriter As _HttpWriter

Type LPHttpWriter As _HttpWriter Ptr

Declare Function CreateHttpWriter( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
