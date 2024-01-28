#ifndef ITCPLISTENER_BI
#define ITCPLISTENER_BI

#include once "windows.bi"
#include once "win\winsock2.bi"
#include once "IAsyncResult.bi"

Extern IID_ITcpListener Alias "IID_ITcpListener" As Const IID

' BeginAccept:
' TCPLISTENER_S_IO_PENDING
' Any E_FAIL

' EndAccept:
' S_OK
' Any E_FAIL

Const TCPLISTENER_S_IO_PENDING As HRESULT = MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0201)

Type ITcpListener As ITcpListener_

Type ITcpListenerVirtualTable
	
	QueryInterface As Function( _
		ByVal this As ITcpListener Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As ITcpListener Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As ITcpListener Ptr _
	)As ULONG
	
	BeginAccept As Function( _
		ByVal this As ITcpListener Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndAccept As Function( _
		ByVal this As ITcpListener Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal ReadedBytes As DWORD, _
		ByVal pClientSocket As SOCKET Ptr _
	)As HRESULT
	
	GetListenSocket As Function( _
		ByVal this As ITcpListener Ptr, _
		ByVal pListenSocket As SOCKET Ptr _
	)As HRESULT
	
	SetListenSocket As Function( _
		ByVal this As ITcpListener Ptr, _
		ByVal ListenSocket As SOCKET _
	)As HRESULT
	
End Type

Type ITcpListener_
	lpVtbl As ITcpListenerVirtualTable Ptr
End Type

#define ITcpListener_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define ITcpListener_AddRef(this) (this)->lpVtbl->AddRef(this)
#define ITcpListener_Release(this) (this)->lpVtbl->Release(this)
#define ITcpListener_BeginAccept(this, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginAccept(this, StateObject, ppIAsyncResult)
#define ITcpListener_EndAccept(this, pIAsyncResult, ReadedBytes, pClientSocket) (this)->lpVtbl->EndAccept(this, pIAsyncResult, ReadedBytes, pClientSocket)
#define ITcpListener_GetListenSocket(this, pListenSocket) (this)->lpVtbl->GetListenSocket(this, pListenSocket)
#define ITcpListener_SetListenSocket(this, ListenSocket) (this)->lpVtbl->SetListenSocket(this, ListenSocket)

#endif
