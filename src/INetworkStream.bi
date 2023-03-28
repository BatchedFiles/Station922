#ifndef INETWORKSTREAM_BI
#define INETWORKSTREAM_BI

#include once "IBaseStream.bi"
#include once "win\winsock2.bi"

Extern IID_INetworkStream Alias "IID_INetworkStream" As Const IID

Type INetworkStream As INetworkStream_

Type INetworkStreamVirtualTable
	
	QueryInterface As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As INetworkStream Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As INetworkStream Ptr _
	)As ULONG
	
	BeginRead As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	BeginWrite As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndRead As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pReadedBytes As DWORD Ptr _
	)As HRESULT
	
	EndWrite As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pWritedBytes As DWORD Ptr _
	)As HRESULT
	
	BeginReadScatter As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal Count As DWORD, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	BeginWriteGather As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal Count As DWORD, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	BeginWriteGatherAndShutdown As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal Count As DWORD, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	GetSocket As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal pResult As SOCKET Ptr _
	)As HRESULT
	
	SetSocket As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal sock As SOCKET _
	)As HRESULT
	
	GetRemoteAddress As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal pRemoteAddress As SOCKADDR Ptr, _
		ByVal pRemoteAddressLength As Integer Ptr _
	)As HRESULT
	
	SetRemoteAddress As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal RemoteAddress As SOCKADDR Ptr, _
		ByVal RemoteAddressLength As Integer _
	)As HRESULT
	
End Type

Type INetworkStream_
	lpVtbl As INetworkStreamVirtualTable Ptr
End Type

#define INetworkStream_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define INetworkStream_AddRef(this) (this)->lpVtbl->AddRef(this)
#define INetworkStream_Release(this) (this)->lpVtbl->Release(this)
#define INetworkStream_BeginRead(this, Buffer, Count, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginRead(this, Buffer, Count, StateObject, ppIAsyncResult)
#define INetworkStream_BeginWrite(this, Buffer, Count, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginWrite(this, Buffer, Count, StateObject, ppIAsyncResult)
#define INetworkStream_EndRead(this, pIAsyncResult, pReadedBytes) (this)->lpVtbl->EndRead(this, pIAsyncResult, pReadedBytes)
#define INetworkStream_EndWrite(this, pIAsyncResult, pWritedBytes) (this)->lpVtbl->EndWrite(this, pIAsyncResult, pWritedBytes)
#define INetworkStream_BeginReadScatter(this, pBuffer, Count, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginReadScatter(this, pBuffer, Count, StateObject, ppIAsyncResult)
#define INetworkStream_BeginWriteGather(this, pBuffer, Count, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginWriteGather(this, pBuffer, Count, StateObject, ppIAsyncResult)
#define INetworkStream_BeginWriteGatherAndShutdown(this, pBuffer, Count, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginWriteGatherAndShutdown(this, pBuffer, Count, StateObject, ppIAsyncResult)
#define INetworkStream_GetSocket(this, pResult) (this)->lpVtbl->GetSocket(this, pResult)
#define INetworkStream_SetSocket(this, sock) (this)->lpVtbl->SetSocket(this, sock)
#define INetworkStream_GetRemoteAddress(this, pRemoteAddress, pRemoteAddressLength) (this)->lpVtbl->GetRemoteAddress(this, pRemoteAddress, pRemoteAddressLength)
#define INetworkStream_SetRemoteAddress(this, RemoteAddress, RemoteAddressLength) (this)->lpVtbl->SetRemoteAddress(this, RemoteAddress, RemoteAddressLength)

#endif
