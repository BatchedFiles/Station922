#ifndef INETWORKSTREAM_BI
#define INETWORKSTREAM_BI

#include once "IBaseStream.bi"
#include once "win\winsock2.bi"

Type INetworkStream As INetworkStream_

Type LPINETWORKSTREAM As INetworkStream Ptr

Extern IID_INetworkStream Alias "IID_INetworkStream" As Const IID

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
	
	CanRead As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal pResult As WINBOOLEAN Ptr _
	)As HRESULT
	
	CanSeek As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal pResult As WINBOOLEAN Ptr _
	)As HRESULT
	
	CanWrite As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal pResult As WINBOOLEAN Ptr _
	)As HRESULT
	
	Flush As Function( _
		ByVal this As INetworkStream Ptr _
	)As HRESULT
	
	GetLength As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal pResult As LARGE_INTEGER Ptr _
	)As HRESULT
	
	Position As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal pResult As LARGE_INTEGER Ptr _
	)As HRESULT
	
	Read As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal pReadedBytes As DWORD Ptr _
	)As HRESULT
	
	Seek As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal Offset As LARGE_INTEGER, _
		ByVal Origin As SeekOrigin _
	)As HRESULT
	
	SetLength As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal Length As LARGE_INTEGER _
	)As HRESULT
	
	Write As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal pWritedBytes As DWORD Ptr _
	)As HRESULT
	
	BeginRead As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal callback As AsyncCallback, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	BeginWrite As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal callback As AsyncCallback, _
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
	
	Close As Function( _
		ByVal this As INetworkStream Ptr _
	)As HRESULT
	
End Type

Type INetworkStream_
	lpVtbl As INetworkStreamVirtualTable Ptr
End Type

#define INetworkStream_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define INetworkStream_AddRef(this) (this)->lpVtbl->AddRef(this)
#define INetworkStream_Release(this) (this)->lpVtbl->Release(this)
' #define INetworkStream_CanRead(this, pResult) (this)->lpVtbl->CanRead(this, pResult)
' #define INetworkStream_CanSeek(this, pResult) (this)->lpVtbl->CanSeek(this, pResult)
' #define INetworkStream_CanWrite(this, pResult) (this)->lpVtbl->CanWrite(this, pResult)
' #define INetworkStream_Flush(this) (this)->lpVtbl->Flush(this)
' #define INetworkStream_GetLength(this, pResult) (this)->lpVtbl->GetLength(this, pResult)
' #define INetworkStream_Position(this, pResult) (this)->lpVtbl->Position(this, pResult)
#define INetworkStream_Read(this, Buffer, Count, pReadedBytes) (this)->lpVtbl->Read(this, Buffer, Count, pReadedBytes)
' #define INetworkStream_Seek(this, Offset, Origin) (this)->lpVtbl->Seek(this, Offset, Origin)
' #define INetworkStream_SetLength(this, Length) (this)->lpVtbl->SetLength(this, Length)
#define INetworkStream_Write(this, Buffer, Count, pWritedBytes) (this)->lpVtbl->Write(this, Buffer, Count, pWritedBytes)
#define INetworkStream_BeginRead(this, Buffer, Count, callback, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginRead(this, Buffer, Count, callback, StateObject, ppIAsyncResult)
#define INetworkStream_BeginWrite(this, Buffer, Count, callback, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginWrite(this, Buffer, Count, callback, StateObject, ppIAsyncResult)
#define INetworkStream_EndRead(this, pIAsyncResult, pReadedBytes) (this)->lpVtbl->EndRead(this, pIAsyncResult, pReadedBytes)
#define INetworkStream_EndWrite(this, pIAsyncResult, pWritedBytes) (this)->lpVtbl->EndWrite(this, pIAsyncResult, pWritedBytes)
#define INetworkStream_GetSocket(this, pResult) (this)->lpVtbl->GetSocket(this, pResult)
#define INetworkStream_SetSocket(this, sock) (this)->lpVtbl->SetSocket(this, sock)
#define INetworkStream_GetRemoteAddress(this, pRemoteAddress, pRemoteAddressLength) (this)->lpVtbl->GetRemoteAddress(this, pRemoteAddress, pRemoteAddressLength)
#define INetworkStream_SetRemoteAddress(this, RemoteAddress, RemoteAddressLength) (this)->lpVtbl->SetRemoteAddress(this, RemoteAddress, RemoteAddressLength)
#define INetworkStream_Close(this) (this)->lpVtbl->Close(this)

#endif
