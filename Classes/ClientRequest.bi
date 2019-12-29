#ifndef CLIENTREQUEST_BI
#define CLIENTREQUEST_BI

#include "IClientRequest.bi"
#include "IStringable.bi"

Extern CLSID_CLIENTREQUEST Alias "CLSID_CLIENTREQUEST" As Const CLSID

Type ClientRequest
	Dim pClientRequestVirtualTable As IClientRequestVirtualTable Ptr
	Dim pStringableVirtualTable As IStringableVirtualTable Ptr
	Dim ReferenceCounter As ULONG
	Dim ExistsInStack As Boolean
	
	Dim RequestHeaders(HttpRequestHeadersMaximum - 1) As WString Ptr
	Dim HttpMethod As HttpMethods
	Dim ClientURI As URI
	Dim HttpVersion As HttpVersions
	Dim KeepAlive As Boolean
	Dim RequestZipModes(HttpZipModesMaximum - 1) As Boolean
	Dim RequestByteRange As ByteRange
	Dim ContentLength As LongInt
	
End Type

Declare Function InitializeClientRequestOfIClientRequest( _
	ByVal pClientRequest As ClientRequest Ptr _
)As IClientRequest Ptr

Declare Function ClientRequestQueryInterface( _
	ByVal pClientRequest As ClientRequest Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function ClientRequestAddRef( _
	ByVal pClientRequest As ClientRequest Ptr _
)As ULONG

Declare Function ClientRequestRelease( _
	ByVal pClientRequest As ClientRequest Ptr _
)As ULONG

Declare Function ClientRequestReadRequest( _
	ByVal pClientRequest As ClientRequest Ptr, _
	ByVal pIReader As IHttpReader Ptr _
)As HRESULT

Declare Function ClientRequestGetHttpMethod( _
	ByVal pClientRequest As ClientRequest Ptr, _
	ByVal pHttpMethod As HttpMethods Ptr _
)As HRESULT

Declare Function ClientRequestGetUri( _
	ByVal pClientRequest As ClientRequest Ptr, _
	ByVal pUri As Uri Ptr _
)As HRESULT

Declare Function ClientRequestGetHttpVersion( _
	ByVal pClientRequest As ClientRequest Ptr, _
	ByVal pHttpVersion As HttpVersions Ptr _
)As HRESULT

Declare Function ClientRequestGetHttpHeader( _
	ByVal pClientRequest As ClientRequest Ptr, _
	ByVal HeaderIndex As HttpRequestHeaders, _
	ByVal ppHeader As WString Ptr Ptr _
)As HRESULT

Declare Function ClientRequestGetKeepAlive( _
	ByVal pClientRequest As ClientRequest Ptr, _
	ByVal pKeepAlive As Boolean Ptr _
)As HRESULT

Declare Function ClientRequestGetContentLength( _
	ByVal pClientRequest As ClientRequest Ptr, _
	ByVal pContentLength As LongInt Ptr _
)As HRESULT

Declare Function ClientRequestGetByteRange( _
	ByVal pClientRequest As ClientRequest Ptr, _
	ByVal pRange As ByteRange Ptr _
)As HRESULT

Declare Function ClientRequestGetZipMode( _
	ByVal pClientRequest As ClientRequest Ptr, _
	ByVal ZipIndex As ZipModes, _
	ByVal pSupported As Boolean Ptr _
)As HRESULT

Declare Function ClientRequestStringableQueryInterface( _
	ByVal pClientRequest As ClientRequest Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function ClientRequestStringableAddRef( _
	ByVal pClientRequest As ClientRequest Ptr _
)As ULONG

Declare Function ClientRequestStringableRelease( _
	ByVal pClientRequest As ClientRequest Ptr _
)As ULONG

Declare Function ClientRequestStringableToString( _
	ByVal pClientRequest As ClientRequest Ptr, _
	ByVal ppResult As WString Ptr Ptr _
)As HRESULT

#endif
