#ifndef PROCESSOPTIONSREQUEST_BI
#define PROCESSOPTIONSREQUEST_BI

#ifndef unicode
#define unicode
#endif
#include once "windows.bi"
#include once "win\winsock2.bi"
#include once "win\ws2tcpip.bi"
#include once "ReadHeadersResult.bi"

Declare Function ProcessOptionsRequest( _
	ByVal state As ReadHeadersResult Ptr, _
	ByVal ClientSocket As SOCKET, _
	ByVal hOutput As Handle _
)As Boolean

#endif
