#ifndef HTTPASYNCREADER_BI
#define HTTPASYNCREADER_BI

#include once "IHttpAsyncReader.bi"

Const RTTI_ID_HTTPREADER              = !"\001Http____Reader\001"
Const RTTI_ID_CLIENTREQUESTBUFFER     = !"\001Request_Buffer\001"

Extern CLSID_HTTPREADER Alias "CLSID_HTTPREADER" As Const CLSID

Declare Function CreateHttpReader( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function CreateHttpReaderPool( _
	pMalloc As IMalloc Ptr _
)As HRESULT

Declare Sub DestroyHttpReaderPool( _
	pMalloc As IMalloc Ptr _
)

#endif
