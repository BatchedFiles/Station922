#ifndef SERVERSTATE_BI
#define SERVERSTATE_BI

#include "IBaseStream.bi"
#include "IClientRequest.bi"
#include "IServerState.bi"
#include "IWebSite.bi"
#include "WebResponse.bi"

Const MaxClientBufferLength As Integer = 512 * 1024

Type ServerState
	Dim pVirtualTable As IServerStateVirtualTable Ptr
	Dim ReferenceCounter As ULONG
	Dim ExistsInStack As Boolean
	
	Dim pStream As IBaseStream Ptr
	Dim pIRequest As IClientRequest Ptr
	Dim pResponse As WebResponse Ptr
	Dim pIWebSite As IWebSite Ptr
	
	' Буфер памяти для сохранения клиентского ответа
	Dim hMapFile As Handle
	Dim ClientBuffer As Any Ptr
	Dim BufferLength As Integer
End Type

Declare Function ServerStateDllCgiGetRequestHeader( _
	ByVal objState As ServerState Ptr, _
	ByVal Value As WString Ptr, _
	ByVal BufferLength As Integer, _
	ByVal HeaderIndex As HttpRequestHeaders _
)As Integer

Declare Function ServerStateDllCgiGetHttpMethod( _
	ByVal objState As ServerState Ptr _
)As HttpMethods

Declare Function ServerStateDllCgiGetHttpVersion( _
	ByVal objState As ServerState Ptr _
)As HttpVersions

Declare Sub ServerStateDllCgiSetStatusCode( _
	ByVal objState As ServerState Ptr, _
	ByVal Code As Integer _
)

Declare Sub ServerStateDllCgiSetStatusDescription( _
	ByVal objState As ServerState Ptr, _
	ByVal Description As WString Ptr _
)

Declare Sub ServerStateDllCgiSetResponseHeader( _
	ByVal objState As ServerState Ptr, _
	ByVal HeaderIndex As HttpResponseHeaders, _
	ByVal Value As WString Ptr _
)

Declare Function ServerStateDllCgiWriteData( _
	ByVal objState As ServerState Ptr, _
	ByVal Buffer As Any Ptr, _
	ByVal BytesCount As Integer _
)As Boolean

Declare Function ServerStateDllCgiReadData( _
	ByVal objState As ServerState Ptr, _
	ByVal Buffer As Any Ptr, _
	ByVal BufferLength As Integer, _
	ByVal ReadedBytesCount As Integer Ptr _
)As Boolean

Declare Function ServerStateDllCgiGetHtmlSafeString( _
	ByVal objState As IServerState Ptr, _
	ByVal Buffer As WString Ptr, _
	ByVal BufferLength As Integer, _
	ByVal HtmlSafe As WString Ptr, _
	ByVal HtmlSafeLength As Integer Ptr _
)As Boolean

Declare Sub InitializeServerState( _
	ByVal pServerState As ServerState Ptr, _
	ByVal pStream As IBaseStream Ptr, _
	ByVal pIRequest As IClientRequest Ptr, _
	ByVal pResponse As WebResponse Ptr, _
	ByVal pIWebSite As IWebSite Ptr, _
	ByVal hMapFile As HANDLE, _
	ByVal ClientBuffer As Any Ptr _
)

#endif
