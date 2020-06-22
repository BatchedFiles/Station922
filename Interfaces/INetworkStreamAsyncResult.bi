#ifndef INETWORKSTREAMASYNCRESULT_BI
#define INETWORKSTREAMASYNCRESULT_BI

#include "IAsyncResult.bi"
#include "win\winsock2.bi"

Type INetworkStreamAsyncResult As INetworkStreamAsyncResult_

Type LPINETWORKSTREAMASYNCRESULT As INetworkStreamAsyncResult Ptr

Extern IID_INetworkStreamAsyncResult Alias "IID_INetworkStreamAsyncResult" As Const IID

Type INetworkStreamAsyncResultVirtualTable
	
	Dim QueryInterface As Function( _
		ByVal this As INetworkStreamAsyncResult Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	Dim AddRef As Function( _
		ByVal this As INetworkStreamAsyncResult Ptr _
	)As ULONG
	
	Dim Release As Function( _
		ByVal this As INetworkStreamAsyncResult Ptr _
	)As ULONG
	
	Dim GetAsyncState As Function( _
		ByVal this As INetworkStreamAsyncResult Ptr, _
		ByVal ppState As IUnknown Ptr Ptr _
	)As HRESULT
	
	Dim GetWaitHandle As Function( _
		ByVal this As INetworkStreamAsyncResult Ptr, _
		ByVal pWaitHandle As HANDLE Ptr _
	)As HRESULT
	
	Dim GetCompletedSynchronously As Function( _
		ByVal this As INetworkStreamAsyncResult Ptr, _
		ByVal pCompletedSynchronously As Boolean Ptr _
	)As HRESULT
	
	Dim SetAsyncState As Function( _
		ByVal this As INetworkStreamAsyncResult Ptr, _
		ByVal pState As IUnknown Ptr _
	)As HRESULT
	
	Dim SetWaitHandle As Function( _
		ByVal this As INetworkStreamAsyncResult Ptr, _
		ByVal WaitHandle As HANDLE _
	)As HRESULT
	
	Dim SetCompletedSynchronously As Function( _
		ByVal this As INetworkStreamAsyncResult Ptr, _
		ByVal CompletedSynchronously As Boolean _
	)As HRESULT
	
	Dim GetAsyncCallback As Function( _
		ByVal this As INetworkStreamAsyncResult Ptr, _
		ByVal pcallback As AsyncCallback Ptr _
	)As HRESULT
	
	Dim SetAsyncCallback As Function( _
		ByVal this As INetworkStreamAsyncResult Ptr, _
		ByVal callback As AsyncCallback _
	)As HRESULT
	
	Dim GetWsaOverlapped As Function( _
		ByVal this As INetworkStreamAsyncResult Ptr, _
		ByVal ppRecvOverlapped As LPASYNCRESULTOVERLAPPED Ptr _
	)As HRESULT
	
End Type

Type INetworkStreamAsyncResult_
	Dim lpVtbl As INetworkStreamAsyncResultVirtualTable Ptr
End Type

#define INetworkStreamAsyncResult_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define INetworkStreamAsyncResult_AddRef(this) (this)->lpVtbl->AddRef(this)
#define INetworkStreamAsyncResult_Release(this) (this)->lpVtbl->Release(this)
' #define INetworkStreamAsyncResult_GetAsyncState(this, ppState) (this)->lpVtbl->GetAsyncState(this, ppState)
' #define INetworkStreamAsyncResult_GetWaitHandle(this, pWaitHandle) (this)->lpVtbl->GetWaitHandle(this, pWaitHandle)
' #define INetworkStreamAsyncResult_GetCompletedSynchronously(this, pCompletedSynchronously) (this)->lpVtbl->GetCompletedSynchronously(this, pCompletedSynchronously)
#define INetworkStreamAsyncResult_SetAsyncState(this, pState) (this)->lpVtbl->SetAsyncState(this, pState)
#define INetworkStreamAsyncResult_SetWaitHandle(this, WaitHandle) (this)->lpVtbl->SetWaitHandle(this, WaitHandle)
#define INetworkStreamAsyncResult_SetCompletedSynchronously(this, CompletedSynchronously) (this)->lpVtbl->SetCompletedSynchronously(this, CompletedSynchronously)
#define INetworkStreamAsyncResult_GetAsyncCallback(this, pcallback) (this)->lpVtbl->GetAsyncCallback(this, pcallback)
#define INetworkStreamAsyncResult_SetAsyncCallback(this, callback) (this)->lpVtbl->SetAsyncCallback(this, callback)
#define INetworkStreamAsyncResult_GetWsaOverlapped(this, ppRecvOverlapped) (this)->lpVtbl->GetWsaOverlapped(this, ppRecvOverlapped)

#endif
