#ifndef ITCPLISTENER_BI
#define ITCPLISTENER_BI

#include once "IAsyncResult.bi"

Type ITcpListener As ITcpListener_

Type LPITCPLISTENER As ITcpListener Ptr

Extern IID_ITcpListener Alias "IID_ITcpListener" As Const IID

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
		ByVal ClientSocket As SOCKET, _
		ByVal Buffer As Any Ptr, _
		ByVal BufferLength As DWORD, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndAccept As Function( _
		ByVal this As ITcpListener Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pReadedBytes As DWORD Ptr _
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
#define ITcpListener_BeginAccept(this, ClientSocket, Buffer, BufferLength, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginAccept(this, ClientSocket, Buffer, BufferLength, StateObject, ppIAsyncResult)
#define ITcpListener_EndAccept(this, pIAsyncResult, pReadedBytes) (this)->lpVtbl->EndAccept(this, pIAsyncResult, pReadedBytes)
#define ITcpListener_GetListenSocket(this, pListenSocket) (this)->lpVtbl->GetListenSocket(this, pListenSocket)
#define ITcpListener_SetListenSocket(this, ListenSocket) (this)->lpVtbl->SetListenSocket(this, ListenSocket)

#endif
