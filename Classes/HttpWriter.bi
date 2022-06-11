#ifndef HTTPWRITER_BI
#define HTTPWRITER_BI

#include once "IHttpWriter.bi"

Const RTTI_ID_HTTPWRITER              = !"\001Http____Writer\001"

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

Declare Function HttpWriterGetBaseStream( _
	ByVal this As HttpWriter Ptr, _
	ByVal ppResult As IBaseStream Ptr Ptr _
)As HRESULT

Declare Function HttpWriterSetBaseStream( _
	ByVal this As HttpWriter Ptr, _
	ByVal pIStream As IBaseStream Ptr _
)As HRESULT

Declare Function HttpWriterGetBuffer( _
	ByVal this As HttpWriter Ptr, _
	ByVal ppResult As IBuffer Ptr Ptr _
)As HRESULT

Declare Function HttpWriterSetBuffer( _
	ByVal this As HttpWriter Ptr, _
	ByVal pIBuffer As IBuffer Ptr _
)As HRESULT

Declare Function HttpWriterPrepare( _
	ByVal this As HttpWriter Ptr, _
	ByVal pIResponse As IServerResponse Ptr, _
	ByVal ContentLength As LongInt _
)As HRESULT

Declare Function HttpWriterBeginWrite( _
	ByVal this As HttpWriter Ptr, _
	ByVal StateObject As IUnknown Ptr, _
	ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
)As HRESULT

Declare Function HttpWriterEndWrite( _
	ByVal this As HttpWriter Ptr, _
	ByVal pIAsyncResult As IAsyncResult Ptr _
)As HRESULT

#endif
