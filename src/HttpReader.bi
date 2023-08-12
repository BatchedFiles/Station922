#ifndef HTTPREADER_BI
#define HTTPREADER_BI

#include once "IHttpReader.bi"

Const RTTI_ID_HTTPREADER              = !"\001Http____Reader\001"

Extern CLSID_HTTPREADER Alias "CLSID_HTTPREADER" As Const CLSID

Type HttpReader As _HttpReader

Type LPHttpReader As _HttpReader Ptr

Declare Function CreateHttpReader( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT
#endif
