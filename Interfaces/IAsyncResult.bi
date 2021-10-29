#ifndef IASYNCRESULT_BI
#define IASYNCRESULT_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Type ASYNCRESULTOVERLAPPED As _ASYNCRESULTOVERLAPPED

Type LPASYNCRESULTOVERLAPPED As _ASYNCRESULTOVERLAPPED Ptr

Type IAsyncResult As IAsyncResult_

Type LPIASYNCRESULT As IAsyncResult Ptr

Type AsyncCallback As Sub(ByVal ar As IAsyncResult Ptr, ByVal ReadedBytes As Integer)

Extern IID_IAsyncResult Alias "IID_IAsyncResult" As Const IID

Type _ASYNCRESULTOVERLAPPED
	OverLap As OVERLAPPED
	pIAsync As IAsyncResult Ptr
End Type

Type IAsyncResultVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IAsyncResult Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IAsyncResult Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IAsyncResult Ptr _
	)As ULONG
	
	GetAsyncState As Function( _
		ByVal this As IAsyncResult Ptr, _
		ByVal ppState As IUnknown Ptr Ptr _
	)As HRESULT
	
	GetWaitHandle As Function( _
		ByVal this As IAsyncResult Ptr, _
		ByVal pWaitHandle As HANDLE Ptr _
	)As HRESULT
	
	GetCompletedSynchronously As Function( _
		ByVal this As IAsyncResult Ptr, _
		ByVal pCompletedSynchronously As Boolean Ptr _
	)As HRESULT
	
End Type

Type IAsyncResult_
	lpVtbl As IAsyncResultVirtualTable Ptr
End Type

#define IAsyncResult_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IAsyncResult_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IAsyncResult_Release(this) (this)->lpVtbl->Release(this)
#define IAsyncResult_GetAsyncState(this, ppState) (this)->lpVtbl->GetAsyncState(this, ppState)
#define IAsyncResult_GetWaitHandle(this, pWaitHandle) (this)->lpVtbl->GetWaitHandle(this, pWaitHandle)
#define IAsyncResult_GetCompletedSynchronously(this, pCompletedSynchronously) (this)->lpVtbl->GetCompletedSynchronously(this, pCompletedSynchronously)

#endif
