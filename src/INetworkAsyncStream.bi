#ifndef INETWORKASYNCSTREAM_BI
#define INETWORKASYNCSTREAM_BI

#include once "IBaseAsyncStream.bi"
#include once "win\winsock2.bi"

Extern IID_INetworkAsyncStream Alias "IID_INetworkAsyncStream" As Const IID

Type INetworkAsyncStream As INetworkAsyncStream_

Type INetworkAsyncStreamVirtualTable
	
	QueryInterface As Function( _
		ByVal this As INetworkAsyncStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As INetworkAsyncStream Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As INetworkAsyncStream Ptr _
	)As ULONG
	
	BeginRead As Function( _
		ByVal this As INetworkAsyncStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	BeginWrite As Function( _
		ByVal this As INetworkAsyncStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndRead As Function( _
		ByVal this As INetworkAsyncStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pReadedBytes As DWORD Ptr _
	)As HRESULT
	
	EndWrite As Function( _
		ByVal this As INetworkAsyncStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pWritedBytes As DWORD Ptr _
	)As HRESULT
	
	BeginReadScatter As Function( _
		ByVal this As INetworkAsyncStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal Count As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	BeginWriteGather As Function( _
		ByVal this As INetworkAsyncStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal Count As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	BeginWriteGatherAndShutdown As Function( _
		ByVal this As INetworkAsyncStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal Count As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	GetSocket As Function( _
		ByVal this As INetworkAsyncStream Ptr, _
		ByVal pResult As SOCKET Ptr _
	)As HRESULT
	
	SetSocket As Function( _
		ByVal this As INetworkAsyncStream Ptr, _
		ByVal sock As SOCKET _
	)As HRESULT
	
	GetRemoteAddress As Function( _
		ByVal this As INetworkAsyncStream Ptr, _
		ByVal pRemoteAddress As SOCKADDR Ptr, _
		ByVal pRemoteAddressLength As Integer Ptr _
	)As HRESULT
	
	SetRemoteAddress As Function( _
		ByVal this As INetworkAsyncStream Ptr, _
		ByVal RemoteAddress As SOCKADDR Ptr, _
		ByVal RemoteAddressLength As Integer _
	)As HRESULT
	
End Type

Type INetworkAsyncStream_
	lpVtbl As INetworkAsyncStreamVirtualTable Ptr
End Type

#define INetworkAsyncStream_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define INetworkAsyncStream_AddRef(this) (this)->lpVtbl->AddRef(this)
#define INetworkAsyncStream_Release(this) (this)->lpVtbl->Release(this)
#define INetworkAsyncStream_BeginRead(this, Buffer, Count, pcb, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginRead(this, Buffer, Count, pcb, StateObject, ppIAsyncResult)
#define INetworkAsyncStream_BeginWrite(this, Buffer, Count, pcb, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginWrite(this, Buffer, Count, pcb, StateObject, ppIAsyncResult)
#define INetworkAsyncStream_EndRead(this, pIAsyncResult, pReadedBytes) (this)->lpVtbl->EndRead(this, pIAsyncResult, pReadedBytes)
#define INetworkAsyncStream_EndWrite(this, pIAsyncResult, pWritedBytes) (this)->lpVtbl->EndWrite(this, pIAsyncResult, pWritedBytes)
#define INetworkAsyncStream_BeginReadScatter(this, pBuffer, Count, pcb, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginReadScatter(this, pBuffer, Count, pcb, StateObject, ppIAsyncResult)
#define INetworkAsyncStream_BeginWriteGather(this, pBuffer, Count, pcb, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginWriteGather(this, pBuffer, Count, pcb, StateObject, ppIAsyncResult)
#define INetworkAsyncStream_BeginWriteGatherAndShutdown(this, pBuffer, Count, pcb, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginWriteGatherAndShutdown(this, pBuffer, Count, pcb, StateObject, ppIAsyncResult)
#define INetworkAsyncStream_GetSocket(this, pResult) (this)->lpVtbl->GetSocket(this, pResult)
#define INetworkAsyncStream_SetSocket(this, sock) (this)->lpVtbl->SetSocket(this, sock)
#define INetworkAsyncStream_GetRemoteAddress(this, pRemoteAddress, pRemoteAddressLength) (this)->lpVtbl->GetRemoteAddress(this, pRemoteAddress, pRemoteAddressLength)
#define INetworkAsyncStream_SetRemoteAddress(this, RemoteAddress, RemoteAddressLength) (this)->lpVtbl->SetRemoteAddress(this, RemoteAddress, RemoteAddressLength)

#endif
