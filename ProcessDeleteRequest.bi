#ifndef PROCESSDELETEREQUEST_BI
#define PROCESSDELETEREQUEST_BI

#ifndef unicode
#define unicode
#endif
#include once "windows.bi"
#include once "win\winsock2.bi"
#include once "win\ws2tcpip.bi"
#include once "WebSite.bi"
#include once "ReadHeadersResult.bi"

Declare Function ProcessDeleteRequest( _
	ByVal state As ReadHeadersResult Ptr, _
	ByVal ClientSocket As SOCKET, _
	ByVal www As WebSite Ptr, _
	ByVal hOutput As Handle, _
	ByVal hFile As Handle _
)As Boolean

#endif
