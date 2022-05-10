#ifndef CLIENTREQUEST_BI
#define CLIENTREQUEST_BI

#include once "IClientRequest.bi"

Extern CLSID_CLIENTREQUEST Alias "CLSID_CLIENTREQUEST" As Const CLSID

Type ClientRequest As _ClientRequest

Type LPClientRequest As _ClientRequest Ptr

Declare Function CreateClientRequest( _
	ByVal pIMemoryAllocator As IMalloc Ptr _
)As ClientRequest Ptr

Declare Sub DestroyClientRequest( _
	ByVal this As ClientRequest Ptr _
)

Declare Function ClientRequestQueryInterface( _
	ByVal this As ClientRequest Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function ClientRequestAddRef( _
	ByVal this As ClientRequest Ptr _
)As ULONG

Declare Function ClientRequestRelease( _
	ByVal this As ClientRequest Ptr _
)As ULONG

Declare Function ClientRequestReadRequest( _
	ByVal this As ClientRequest Ptr _
)As HRESULT

Declare Function ClientRequestBeginReadRequest( _
	ByVal this As ClientRequest Ptr, _
	ByVal StateObject As IUnknown Ptr, _
	ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
)As HRESULT

Declare Function ClientRequestEndReadRequest( _
	ByVal this As ClientRequest Ptr, _
	ByVal pIAsyncResult As IAsyncResult Ptr _
)As HRESULT

Declare Function ClientRequestParse( _
	ByVal this As ClientRequest Ptr _
)As HRESULT

Declare Function ClientRequestGetHttpMethod( _
	ByVal this As ClientRequest Ptr, _
	ByVal ppHttpMethod As HeapBSTR Ptr _
)As HRESULT

Declare Function ClientRequestGetUri( _
	ByVal this As ClientRequest Ptr, _
	ByVal ppUri As IClientUri Ptr Ptr _
)As HRESULT

Declare Function ClientRequestGetHttpVersion( _
	ByVal this As ClientRequest Ptr, _
	ByVal pHttpVersion As HttpVersions Ptr _
)As HRESULT

Declare Function ClientRequestGetHttpHeader( _
	ByVal this As ClientRequest Ptr, _
	ByVal HeaderIndex As HttpRequestHeaders, _
	ByVal ppHeader As HeapBSTR Ptr _
)As HRESULT

Declare Function ClientRequestGetKeepAlive( _
	ByVal this As ClientRequest Ptr, _
	ByVal pKeepAlive As Boolean Ptr _
)As HRESULT

Declare Function ClientRequestGetContentLength( _
	ByVal this As ClientRequest Ptr, _
	ByVal pContentLength As LongInt Ptr _
)As HRESULT

Declare Function ClientRequestGetByteRange( _
	ByVal this As ClientRequest Ptr, _
	ByVal pRange As ByteRange Ptr _
)As HRESULT

Declare Function ClientRequestGetZipMode( _
	ByVal this As ClientRequest Ptr, _
	ByVal ZipIndex As ZipModes, _
	ByVal pSupported As Boolean Ptr _
)As HRESULT

Declare Function ClientRequestGetTextReader( _
	ByVal this As ClientRequest Ptr, _
	ByVal ppIReader As IHttpReader Ptr Ptr _
)As HRESULT

Declare Function ClientRequestSetTextReader( _
	ByVal this As ClientRequest Ptr, _
	ByVal pIReader As IHttpReader Ptr _
)As HRESULT

#endif
