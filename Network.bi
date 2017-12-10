#ifndef NETWORK_BI
#define NETWORK_BI

#ifndef unicode
#define unicode
#endif
#include once "windows.bi"
#include once "win\winsock2.bi"
#include once "win\ws2tcpip.bi"

' Соединиться с сервером и вернуть сокет
Declare Function ConnectToServer( _
	ByVal Server As WString Ptr, _
	ByVal Port As WString Ptr, _
	ByVal LocalAddress As WString Ptr, _
	ByVal LocalPort As WString Ptr _
)As SOCKET

' Создать прослушивающий сокет, привязанный к адресу
Declare Function CreateSocketAndListen( _
	ByVal LocalAddress As WString Ptr, _
	ByVal LocalPort As WString Ptr _
)As SOCKET

' Закрывает сокет
Declare Sub CloseSocketConnection( _
	ByVal mSock As SOCKET _
)

' Создать сокет, привязанный к адресу
Declare Function CreateSocketAndBind( _
	ByVal LocalAddress As WString Ptr, _
	ByVal LocalPort As WString Ptr _
)As SOCKET

' Разрешение доменного имени
Declare Function ResolveHost( _
	ByVal Server As WString Ptr, _
	ByVal Port As WString Ptr _
)As addrinfoW Ptr

#endif
