#ifndef TCPLISTENER_BI
#define TCPLISTENER_BI

#include once "ITcpListener.bi"

Extern CLSID_TCPLISTENER Alias "CLSID_TCPLISTENER" As Const CLSID

Const RTTI_ID_TCPLISTENER  = !"\001Tcp___Listener\001"

Type TcpListener As _TcpListener

Type LPTcpListener As _TcpListener Ptr

Declare Function CreateTcpListener( _
	ByVal pIMemoryAllocator As IMalloc Ptr _
)As TcpListener Ptr

Declare Sub DestroyTcpListener( _
	ByVal this As TcpListener Ptr _
)

Declare Function TcpListenerQueryInterface( _
	ByVal this As TcpListener Ptr, _
	ByVal riid As REFIID, _
	ByVal ppvObject As Any Ptr Ptr _
)As HRESULT

Declare Function TcpListenerAddRef( _
	ByVal this As TcpListener Ptr _
)As ULONG

Declare Function TcpListenerRelease( _
	ByVal this As TcpListener Ptr _
)As ULONG

Declare Function TcpListenerBeginAccept( _
	ByVal this As TcpListener Ptr, _
	ByVal Buffer As ClientRequestBuffer Ptr, _
	ByVal StateObject As IUnknown Ptr, _
	ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
)As HRESULT

Declare Function TcpListenerEndAccept( _
	ByVal this As TcpListener Ptr, _
	ByVal pIAsyncResult As IAsyncResult Ptr, _
	ByVal ReadedBytes As DWORD, _
	ByVal pClientSocket As SOCKET Ptr _
)As HRESULT

Declare Function TcpListenerGetListenSocket( _
	ByVal this As TcpListener Ptr, _
	ByVal pListenSocket As SOCKET Ptr _
)As HRESULT

Declare Function TcpListenerSetListenSocket( _
	ByVal this As TcpListener Ptr, _
	ByVal ListenSocket As SOCKET _
)As HRESULT

#endif
