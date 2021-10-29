#ifndef IMUTABLEASYNCRESULT_BI
#define IMUTABLEASYNCRESULT_BI

#include once "IAsyncResult.bi"
#include once "win\winsock2.bi"

Type IMutableAsyncResult As IMutableAsyncResult_

Type LPIMUTABLEASYNCRESULT As IMutableAsyncResult Ptr

Extern IID_IMutableAsyncResult Alias "IID_IMutableAsyncResult" As Const IID

Type IMutableAsyncResultVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IMutableAsyncResult Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IMutableAsyncResult Ptr _
	)As ULONG
	
	GetAsyncState As Function( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal ppState As IUnknown Ptr Ptr _
	)As HRESULT
	
	GetWaitHandle As Function( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal pWaitHandle As HANDLE Ptr _
	)As HRESULT
	
	GetCompletedSynchronously As Function( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal pCompletedSynchronously As Boolean Ptr _
	)As HRESULT
	
	SetAsyncState As Function( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal pState As IUnknown Ptr _
	)As HRESULT
	
	SetWaitHandle As Function( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal WaitHandle As HANDLE _
	)As HRESULT
	
	SetCompletedSynchronously As Function( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal CompletedSynchronously As Boolean _
	)As HRESULT
	
	GetAsyncCallback As Function( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal pcallback As AsyncCallback Ptr _
	)As HRESULT
	
	SetAsyncCallback As Function( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal callback As AsyncCallback _
	)As HRESULT
	
	GetWsaOverlapped As Function( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal ppRecvOverlapped As LPASYNCRESULTOVERLAPPED Ptr _
	)As HRESULT
	
End Type

Type IMutableAsyncResult_
	lpVtbl As IMutableAsyncResultVirtualTable Ptr
End Type

#define IMutableAsyncResult_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IMutableAsyncResult_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IMutableAsyncResult_Release(this) (this)->lpVtbl->Release(this)
' #define IMutableAsyncResult_GetAsyncState(this, ppState) (this)->lpVtbl->GetAsyncState(this, ppState)
' #define IMutableAsyncResult_GetWaitHandle(this, pWaitHandle) (this)->lpVtbl->GetWaitHandle(this, pWaitHandle)
' #define IMutableAsyncResult_GetCompletedSynchronously(this, pCompletedSynchronously) (this)->lpVtbl->GetCompletedSynchronously(this, pCompletedSynchronously)
#define IMutableAsyncResult_SetAsyncState(this, pState) (this)->lpVtbl->SetAsyncState(this, pState)
#define IMutableAsyncResult_SetWaitHandle(this, WaitHandle) (this)->lpVtbl->SetWaitHandle(this, WaitHandle)
#define IMutableAsyncResult_SetCompletedSynchronously(this, CompletedSynchronously) (this)->lpVtbl->SetCompletedSynchronously(this, CompletedSynchronously)
#define IMutableAsyncResult_GetAsyncCallback(this, pcallback) (this)->lpVtbl->GetAsyncCallback(this, pcallback)
#define IMutableAsyncResult_SetAsyncCallback(this, callback) (this)->lpVtbl->SetAsyncCallback(this, callback)
#define IMutableAsyncResult_GetWsaOverlapped(this, ppRecvOverlapped) (this)->lpVtbl->GetWsaOverlapped(this, ppRecvOverlapped)

#endif
