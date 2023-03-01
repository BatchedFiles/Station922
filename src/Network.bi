#ifndef BATCHEDFILES_NETWORK_BI
#define BATCHEDFILES_NETWORK_BI

#include once "windows.bi"
#include once "win\winsock2.bi"
#include once "win\ws2tcpip.bi"
#include once "win\mswsock.bi"

Extern GUID_WSAID_ACCEPTEX Alias "GUID_WSAID_ACCEPTEX" As GUID
Extern GUID_WSAID_GETACCEPTEXSOCKADDRS Alias "GUID_WSAID_GETACCEPTEXSOCKADDRS" As GUID
Extern GUID_WSAID_TRANSMITPACKETS Alias "GUID_WSAID_TRANSMITPACKETS" As GUID

Extern lpfnAcceptEx Alias "lpfnAcceptEx" As LPFN_ACCEPTEX
Extern lpfnGetAcceptExSockaddrs Alias "lpfnGetAcceptExSockaddrs" As LPFN_GETACCEPTEXSOCKADDRS
Extern lpfnTransmitPackets Alias "lpfnTransmitPackets" As LPFN_TRANSMITPACKETS

Type SocketNode
	ClientSocket As SOCKET
	Padding1 As Integer
	AddressFamily As Long
	SocketType As Long
	Protocol As Long
	Padding2 As Long
End Type

Declare Function NetworkStartUp()As HRESULT

Declare Function NetworkCleanUp()As HRESULT

Declare Function LoadWsaFunctions()As HRESULT

Declare Function ResolveHostA Alias "ResolveHostA"( _
	ByVal Host As PCSTR, _
	ByVal Port As PCSTR, _
	ByVal ppAddressList As addrinfo Ptr Ptr _
)As HRESULT

Declare Function ResolveHostW Alias "ResolveHostW"( _
	ByVal Host As PCWSTR, _
	ByVal Port As PCWSTR, _
	ByVal ppAddressList As ADDRINFOW Ptr Ptr _
)As HRESULT

#ifdef UNICODE
	Declare Function ResolveHost Alias "ResolveHostW"( _
		ByVal Host As PCWSTR, _
		ByVal Port As PCWSTR, _
		ByVal ppAddressList As ADDRINFOW Ptr Ptr _
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
	ByVal pSocketList As SocketNode Ptr, _
	ByVal Count As Integer, _
	ByVal pSockets As Integer Ptr _
)As HRESULT

Declare Function CreateSocketAndBindW Alias "CreateSocketAndBindW"( _
	ByVal LocalAddress As PCWSTR, _
	ByVal LocalPort As PCWSTR, _
	ByVal pSocketList As SocketNode Ptr, _
	ByVal Count As Integer, _
	ByVal pSockets As Integer Ptr _
)As HRESULT

#ifdef UNICODE
	Declare Function CreateSocketAndBind Alias "CreateSocketAndBindW"( _
		ByVal LocalAddress As PCWSTR, _
		ByVal LocalPort As PCWSTR, _
		ByVal pSocketList As SocketNode Ptr, _
		ByVal Count As Integer, _
		ByVal pSockets As Integer Ptr _
	)As HRESULT
#else
	Declare Function CreateSocketAndBind Alias "CreateSocketAndBindA"( _
		ByVal LocalAddress As PCSTR, _
		ByVal LocalPort As PCSTR, _
		ByVal pSocketList As SocketNode Ptr, _
		ByVal Count As Integer, _
		ByVal pSockets As Integer Ptr _
	)As HRESULT
#endif

Declare Function SetReceiveTimeout Alias "SetReceiveTimeout"( _
	ByVal ClientSocket As SOCKET, _
	ByVal dwMilliseconds As DWORD _
)As HRESULT

Declare Function CloseSocketConnection Alias "CloseSocketConnection"( _
	ByVal ClientSocket As SOCKET _
)As HRESULT

Declare Function ConnectToServerA Alias "ConnectToServerA"( _
	ByVal LocalAddress As PCSTR, _
	ByVal LocalPort As PCSTR, _
	ByVal RemoteAddress As PCSTR, _
	ByVal RemotePort As PCSTR, _
	ByVal pSocket As SOCKET Ptr _
)As HRESULT

Declare Function ConnectToServerW Alias "ConnectToServerW"( _
	ByVal LocalAddress As PCWSTR, _
	ByVal LocalPort As PCWSTR, _
	ByVal RemoteAddress As PCWSTR, _
	ByVal RemotePort As PCWSTR, _
	ByVal pSocket As SOCKET Ptr _
)As HRESULT

#ifdef UNICODE
	Declare Function ConnectToServer Alias "ConnectToServerW"( _
		ByVal LocalAddress As PCWSTR, _
		ByVal LocalPort As PCWSTR, _
		ByVal RemoteAddress As PCWSTR, _
		ByVal RemotePort As PCWSTR, _
		ByVal pSocket As SOCKET Ptr _
	)As HRESULT
#else
	Declare Function ConnectToServer Alias "ConnectToServerA"( _
		ByVal LocalAddress As PCSTR, _
		ByVal LocalPort As PCSTR, _
		ByVal RemoteAddress As PCSTR, _
		ByVal RemotePort As PCSTR, _
		ByVal pSocket As SOCKET Ptr _
	)As HRESULT
#endif

Declare Function CreateSocketAndListenA Alias "CreateSocketAndListenA"( _
	ByVal LocalAddress As PCSTR, _
	ByVal LocalPort As PCSTR, _
	ByVal pSocketList As SocketNode Ptr, _
	ByVal Count As Integer, _
	ByVal pSockets As Integer Ptr _
)As HRESULT

Declare Function CreateSocketAndListenW Alias "CreateSocketAndListenW"( _
	ByVal LocalAddress As PCWSTR, _
	ByVal LocalPort As PCWSTR, _
	ByVal pSocketList As SocketNode Ptr, _
	ByVal Count As Integer, _
	ByVal pSockets As Integer Ptr _
)As HRESULT

#ifdef UNICODE
	Declare Function CreateSocketAndListen Alias "CreateSocketAndListenW"( _
		ByVal LocalAddress As PCWSTR, _
		ByVal LocalPort As PCWSTR, _
		ByVal pSocketList As SocketNode Ptr, _
		ByVal Count As Integer, _
		ByVal pSockets As Integer Ptr _
	)As HRESULT
#else
	Declare Function CreateSocketAndListen Alias "CreateSocketAndListenA"( _
		ByVal LocalAddress As PCSTR, _
		ByVal LocalPort As PCSTR, _
		ByVal pSocketList As SocketNode Ptr, _
		ByVal Count As Integer, _
		ByVal pSockets As Integer Ptr _
	)As HRESULT
#endif

#endif
