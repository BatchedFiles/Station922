#ifndef INETWORKASYNCSTREAM_BI
#define INETWORKASYNCSTREAM_BI

#include once "IBaseAsyncStream.bi"
#include once "win\winsock2.bi"

Extern IID_INetworkAsyncStream Alias "IID_INetworkAsyncStream" As Const IID

Type INetworkAsyncStream As INetworkAsyncStream_

Type INetworkAsyncStreamVirtualTable

	QueryInterface As Function( _
		ByVal self As INetworkAsyncStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As INetworkAsyncStream Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As INetworkAsyncStream Ptr _
	)As ULONG

	BeginRead As Function( _
		ByVal self As INetworkAsyncStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	BeginWrite As Function( _
		ByVal self As INetworkAsyncStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	EndRead As Function( _
		ByVal self As INetworkAsyncStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pReadedBytes As DWORD Ptr _
	)As HRESULT

	EndWrite As Function( _
		ByVal self As INetworkAsyncStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pWritedBytes As DWORD Ptr _
	)As HRESULT

	BeginReadScatter As Function( _
		ByVal self As INetworkAsyncStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal Count As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	BeginWriteGather As Function( _
		ByVal self As INetworkAsyncStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal Count As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	BeginWriteGatherAndShutdown As Function( _
		ByVal self As INetworkAsyncStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal Count As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	GetSocket As Function( _
		ByVal self As INetworkAsyncStream Ptr, _
		ByVal pResult As SOCKET Ptr _
	)As HRESULT

	SetSocket As Function( _
		ByVal self As INetworkAsyncStream Ptr, _
		ByVal sock As SOCKET _
	)As HRESULT

	GetRemoteAddress As Function( _
		ByVal self As INetworkAsyncStream Ptr, _
		ByVal pRemoteAddress As SOCKADDR Ptr, _
		ByVal pRemoteAddressLength As Integer Ptr _
	)As HRESULT

	SetRemoteAddress As Function( _
		ByVal self As INetworkAsyncStream Ptr, _
		ByVal RemoteAddress As SOCKADDR Ptr, _
		ByVal RemoteAddressLength As Integer _
	)As HRESULT

End Type

Type INetworkAsyncStream_
	lpVtbl As INetworkAsyncStreamVirtualTable Ptr
End Type

#define INetworkAsyncStream_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define INetworkAsyncStream_AddRef(self) (self)->lpVtbl->AddRef(self)
#define INetworkAsyncStream_Release(self) (self)->lpVtbl->Release(self)
#define INetworkAsyncStream_BeginRead(self, Buffer, Count, pcb, StateObject, ppIAsyncResult) (self)->lpVtbl->BeginRead(self, Buffer, Count, pcb, StateObject, ppIAsyncResult)
#define INetworkAsyncStream_BeginWrite(self, Buffer, Count, pcb, StateObject, ppIAsyncResult) (self)->lpVtbl->BeginWrite(self, Buffer, Count, pcb, StateObject, ppIAsyncResult)
#define INetworkAsyncStream_EndRead(self, pIAsyncResult, pReadedBytes) (self)->lpVtbl->EndRead(self, pIAsyncResult, pReadedBytes)
#define INetworkAsyncStream_EndWrite(self, pIAsyncResult, pWritedBytes) (self)->lpVtbl->EndWrite(self, pIAsyncResult, pWritedBytes)
#define INetworkAsyncStream_BeginReadScatter(self, pBuffer, Count, pcb, StateObject, ppIAsyncResult) (self)->lpVtbl->BeginReadScatter(self, pBuffer, Count, pcb, StateObject, ppIAsyncResult)
#define INetworkAsyncStream_BeginWriteGather(self, pBuffer, Count, pcb, StateObject, ppIAsyncResult) (self)->lpVtbl->BeginWriteGather(self, pBuffer, Count, pcb, StateObject, ppIAsyncResult)
#define INetworkAsyncStream_BeginWriteGatherAndShutdown(self, pBuffer, Count, pcb, StateObject, ppIAsyncResult) (self)->lpVtbl->BeginWriteGatherAndShutdown(self, pBuffer, Count, pcb, StateObject, ppIAsyncResult)
#define INetworkAsyncStream_GetSocket(self, pResult) (self)->lpVtbl->GetSocket(self, pResult)
#define INetworkAsyncStream_SetSocket(self, sock) (self)->lpVtbl->SetSocket(self, sock)
#define INetworkAsyncStream_GetRemoteAddress(self, pRemoteAddress, pRemoteAddressLength) (self)->lpVtbl->GetRemoteAddress(self, pRemoteAddress, pRemoteAddressLength)
#define INetworkAsyncStream_SetRemoteAddress(self, RemoteAddress, RemoteAddressLength) (self)->lpVtbl->SetRemoteAddress(self, RemoteAddress, RemoteAddressLength)

#endif
