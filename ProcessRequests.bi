#ifndef PROCESSREQUESTS_BI
#define PROCESSREQUESTS_BI

#ifndef unicode
#define unicode
#endif
#include once "windows.bi"
#include once "win\winsock2.bi"
#include once "win\ws2tcpip.bi"
#include once "WebSite.bi"
#include once "ReadHeadersResult.bi"

' Максимальный размер полученного от клиента тела запроса
' TODO Вынести в конфигурацию ограничение на максимальный размер тела запроса
Const MaxRequestBodyContentLength As LongInt = 20 * 1024 * 1024

Declare Function ProcessConnectRequest( _
	ByVal ClientSocket As SOCKET, _
	ByVal state As ReadHeadersResult Ptr, _
	ByVal www As WebSite Ptr, _
	ByVal hOutput As Handle _
)As Boolean

Declare Function ProcessDeleteRequest( _
	ByVal ClientSocket As SOCKET, _
	ByVal state As ReadHeadersResult Ptr, _
	ByVal www As WebSite Ptr, _
	ByVal hOutput As Handle, _
	ByVal hFile As Handle _
)As Boolean

Declare Function ProcessGetHeadRequest( _
	ByVal ClientSocket As SOCKET, _
	ByVal state As ReadHeadersResult Ptr, _
	ByVal www As WebSite Ptr, _
	ByVal fileExtention As WString Ptr, _
	ByVal hOutput As Handle, _
	ByVal hFile As Handle _
)As Boolean

Declare Function ProcessOptionsRequest( _
	ByVal ClientSocket As SOCKET, _
	ByVal state As ReadHeadersResult Ptr, _
	ByVal hOutput As Handle _
)As Boolean

Declare Function ProcessPostRequest( _
	ByVal ClientSocket As SOCKET, _
	ByVal state As ReadHeadersResult Ptr, _
	ByVal www As WebSite Ptr, _
	ByVal hOutput As Handle _
)As Boolean

Declare Function ProcessPutRequest( _
	ByVal ClientSocket As SOCKET, _
	ByVal state As ReadHeadersResult Ptr, _
	ByVal www As WebSite Ptr, _
	ByVal hOutput As Handle _
)As Boolean

Declare Function ProcessTraceRequest( _
	ByVal ClientSocket As SOCKET, _
	ByVal state As ReadHeadersResult Ptr, _
	ByVal hOutput As Handle _
)As Boolean

#endif
