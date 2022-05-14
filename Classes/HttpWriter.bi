#ifndef HTTPWRITER_BI
#define HTTPWRITER_BI

#include once "IHttpWriter.bi"

Extern CLSID_HTTPWRITER Alias "CLSID_HTTPWRITER" As Const CLSID

Type HttpWriter As _HttpWriter

Type LPHttpWriter As _HttpWriter Ptr

Declare Function CreateHttpWriter( _
	ByVal pIMemoryAllocator As IMalloc Ptr _
)As HttpWriter Ptr

Declare Sub DestroyHttpWriter( _
	ByVal this As HttpWriter Ptr _
)

Declare Function HttpWriterQueryInterface( _
	ByVal this As HttpWriter Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function HttpWriterAddRef( _
	ByVal this As HttpWriter Ptr _
)As ULONG

Declare Function HttpWriterRelease( _
	ByVal this As HttpWriter Ptr _
)As ULONG

#endif
