#ifndef SERVERSTATE_BI
#define SERVERSTATE_BI

#include "IBaseStream.bi"
#include "IClientRequest.bi"
#include "IServerResponse.bi"
#include "IServerState.bi"
#include "IWebSite.bi"

Const MaxClientBufferLength As Integer = 512 * 1024

Const ProgID_ServerState = "BatchedFiles.Station922"

Const CLSIDS_SERVERSTATE = "{E9BE6663-1ED6-45A4-9090-01FF8A82AB99}"

Extern CLSID_SERVERSTATE Alias "CLSID_SERVERSTATE" As Const CLSID

Type ServerState
	Dim pVirtualTable As IServerStateVirtualTable Ptr
	Dim ReferenceCounter As ULONG
	Dim ExistsInStack As Boolean
	
	Dim pStream As IBaseStream Ptr
	Dim pIRequest As IClientRequest Ptr
	Dim pIResponse As IServerResponse Ptr
	Dim pIWebSite As IWebSite Ptr
	
	' Буфер памяти для сохранения клиентского ответа
	Dim hMapFile As Handle
	Dim ClientBuffer As Any Ptr
	Dim BufferLength As Integer
End Type

Declare Function ServerStateDllCgiGetRequestHeader( _
	ByVal this As ServerState Ptr, _
	ByVal Value As WString Ptr, _
	ByVal BufferLength As Integer, _
	ByVal HeaderIndex As HttpRequestHeaders _
)As Integer

Declare Function ServerStateDllCgiGetHttpMethod( _
	ByVal this As ServerState Ptr _
)As HttpMethods

Declare Function ServerStateDllCgiGetHttpVersion( _
	ByVal this As ServerState Ptr _
)As HttpVersions

Declare Sub ServerStateDllCgiSetStatusCode( _
	ByVal this As ServerState Ptr, _
	ByVal Code As Integer _
)

Declare Sub ServerStateDllCgiSetStatusDescription( _
	ByVal this As ServerState Ptr, _
	ByVal Description As WString Ptr _
)

Declare Sub ServerStateDllCgiSetResponseHeader( _
	ByVal this As ServerState Ptr, _
	ByVal HeaderIndex As HttpResponseHeaders, _
	ByVal Value As WString Ptr _
)

Declare Function ServerStateDllCgiWriteData( _
	ByVal this As ServerState Ptr, _
	ByVal Buffer As Any Ptr, _
	ByVal BytesCount As Integer _
)As Boolean

Declare Function ServerStateDllCgiReadData( _
	ByVal this As ServerState Ptr, _
	ByVal Buffer As Any Ptr, _
	ByVal BufferLength As Integer, _
	ByVal ReadedBytesCount As Integer Ptr _
)As Boolean

Declare Function ServerStateDllCgiGetHtmlSafeString( _
	ByVal this As IServerState Ptr, _
	ByVal Buffer As WString Ptr, _
	ByVal BufferLength As Integer, _
	ByVal HtmlSafe As WString Ptr, _
	ByVal HtmlSafeLength As Integer Ptr _
)As Boolean

Declare Sub InitializeServerState( _
	ByVal pServerState As ServerState Ptr, _
	ByVal pIStream As IBaseStream Ptr, _
	ByVal pIRequest As IClientRequest Ptr, _
	ByVal pIResponse As IServerResponse Ptr, _
	ByVal pIWebSite As IWebSite Ptr, _
	ByVal hMapFile As HANDLE, _
	ByVal ClientBuffer As Any Ptr _
)

#endif
