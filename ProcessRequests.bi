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

Declare Function ProcessConnectRequest(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal hOutput As Handle)As Boolean

Declare Function ProcessDeleteRequest(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal fileExtention As WString Ptr, ByVal hOutput As Handle, ByVal hFile As Handle)As Boolean

Declare Function ProcessGetHeadRequest(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal fileExtention As WString Ptr, ByVal hOutput As Handle, ByVal hFile As Handle)As Boolean

Declare Function ProcessOptionsRequest(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal hOutput As Handle)As Boolean

Declare Function ProcessPostRequest(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal hOutput As Handle)As Boolean

Declare Function ProcessPutRequest(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal fileExtention As WString Ptr, ByVal hOutput As Handle)As Boolean

Declare Function ProcessTraceRequest(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal hOutput As Handle)As Boolean
