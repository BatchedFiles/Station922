#ifndef TCPLISTENER_BI
#define TCPLISTENER_BI

#include once "ITcpListener.bi"

Extern CLSID_TCPLISTENER Alias "CLSID_TCPLISTENER" As Const CLSID

Const RTTI_ID_TCPLISTENER  = !"\001Tcp___Listener\001"

Declare Function CreateTcpListener( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
