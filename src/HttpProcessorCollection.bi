#ifndef HTTPPROCESSORCOLLECTION_BI
#define HTTPPROCESSORCOLLECTION_BI

#include once "IHttpProcessorCollection.bi"

Const RTTI_ID_HTTPPROCESSORCOLLECTION = !"\001Coll_Processor\001"

Extern CLSID_HTTPPROCESSORCOLLECTION Alias "CLSID_HTTPPROCESSORCOLLECTION" As Const CLSID

Type HttpProcessorCollection As _HttpProcessorCollection

Type LPHttpProcessorCollection As _HttpProcessorCollection Ptr

Declare Function CreateHttpProcessorCollection( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
