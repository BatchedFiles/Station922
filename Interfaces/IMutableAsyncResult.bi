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
	
	GetCompleted As Function( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal pBytesTransferred As DWORD Ptr, _
		ByVal pCompleted As Boolean Ptr _
	)As HRESULT
	
	SetCompleted As Function( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal Completed As Boolean _
	)As HRESULT
	
	SetAsyncState As Function( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal pState As IUnknown Ptr _
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
' #define IMutableAsyncResult_GetCompleted(this, pBytesTransferred, pCompleted) (this)->lpVtbl->GetCompleted(this, pBytesTransferred, pCompleted)
' #define IMutableAsyncResult_SetCompleted(this, BytesTransferred, Completed) (this)->lpVtbl->SetCompleted(this, BytesTransferred, Completed)
#define IMutableAsyncResult_SetAsyncState(this, pState) (this)->lpVtbl->SetAsyncState(this, pState)
#define IMutableAsyncResult_GetAsyncCallback(this, pcallback) (this)->lpVtbl->GetAsyncCallback(this, pcallback)
#define IMutableAsyncResult_SetAsyncCallback(this, callback) (this)->lpVtbl->SetAsyncCallback(this, callback)
#define IMutableAsyncResult_GetWsaOverlapped(this, ppRecvOverlapped) (this)->lpVtbl->GetWsaOverlapped(this, ppRecvOverlapped)

#endif
