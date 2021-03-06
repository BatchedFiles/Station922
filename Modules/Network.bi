#ifndef BATCHEDFILES_NETWORK_BI
#define BATCHEDFILES_NETWORK_BI

#include once "windows.bi"
#include once "win\winsock2.bi"
#include once "win\ws2tcpip.bi"

Declare Function ResolveHostA Alias "ResolveHostA"( _
	ByVal Host As PCSTR, _
	ByVal Port As PCSTR, _
	ByVal ppAddressList As addrinfo Ptr Ptr _
)As HRESULT

Declare Function ResolveHostW Alias "ResolveHostW"( _
	ByVal Host As PCWSTR, _
	ByVal Port As PCWSTR, _
	ByVal ppAddressList As addrinfoW Ptr Ptr _
)As HRESULT

#ifdef UNICODE
	Declare Function ResolveHost Alias "ResolveHostW"( _
		ByVal Host As PCWSTR, _
		ByVal Port As PCWSTR, _
		ByVal ppAddressList As addrinfoW Ptr Ptr _
	)As HRESULT
#else
	Declare Function ResolveHost Alias "ResolveHostA"( _
		ByVal Host As PCSTR, _
		ByVal Port As PCSTR, _
		ByVal ppAddressList As addrinfo Ptr Ptr _
	)As HRESULT
#endif

Declare Function CreateSocketAndBindA Alias "CreateSocketAndBindA"( _
	ByVal LocalAddress As PCSTR, _
	ByVal LocalPort As PCSTR, _
	ByVal pSocket As SOCKET Ptr _
)As HRESULT

Declare Function CreateSocketAndBindW Alias "CreateSocketAndBindW"( _
	ByVal LocalAddress As PCWSTR, _
	ByVal LocalPort As PCWSTR, _
	ByVal pSocket As SOCKET Ptr _
)As HRESULT

#ifdef UNICODE
	Declare Function CreateSocketAndBind Alias "CreateSocketAndBindW"( _
		ByVal LocalAddress As PCWSTR, _
		ByVal LocalPort As PCWSTR, _
		ByVal pSocket As SOCKET Ptr _
	)As HRESULT
#else
	Declare Function CreateSocketAndBind Alias "CreateSocketAndBindA"( _
		ByVal LocalAddress As PCSTR, _
		ByVal LocalPort As PCSTR, _
		ByVal pSocket As SOCKET Ptr _
	)As HRESULT
#endif

Declare Function SetReceiveTimeout Alias "SetReceiveTimeout"( _
	ByVal ClientSocket As SOCKET, _
	ByVal dwMilliseconds As DWORD _
)As HRESULT

Declare Function CloseSocketConnection Alias "CloseSocketConnection"( _
	ByVal ClientSocket As SOCKET _
)As HRESULT

#endif
