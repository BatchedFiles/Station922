#ifndef IASYNCRESULT_BI
#define IASYNCRESULT_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Type IAsyncResult As IAsyncResult_

Type LPIASYNCRESULT As IAsyncResult Ptr

Type AsyncCallback As Sub(ByVal ar As IAsyncResult Ptr, ByVal ReadedBytes As Integer)

Extern IID_IAsyncResult Alias "IID_IAsyncResult" As Const IID

Type ASYNCRESULTOVERLAPPED
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
	
	GetAsyncStateWeakPtr As Function( _
		ByVal this As IAsyncResult Ptr, _
		ByVal ppState As Any Ptr Ptr _
	)As HRESULT
	
	GetCompleted As Function( _
		ByVal this As IAsyncResult Ptr, _
		ByVal pBytesTransferred As DWORD Ptr, _
		ByVal pCompleted As Boolean Ptr _
	)As HRESULT
	
	SetCompleted As Function( _
		ByVal this As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal Completed As Boolean _
	)As HRESULT
	
End Type

Type IAsyncResult_
	lpVtbl As IAsyncResultVirtualTable Ptr
End Type

#define IAsyncResult_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IAsyncResult_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IAsyncResult_Release(this) (this)->lpVtbl->Release(this)
#define IAsyncResult_GetAsyncStateWeakPtr(this, ppState) (this)->lpVtbl->GetAsyncStateWeakPtr(this, ppState)
#define IAsyncResult_GetCompleted(this, pBytesTransferred, pCompleted) (this)->lpVtbl->GetCompleted(this, pBytesTransferred, pCompleted)
#define IAsyncResult_SetCompleted(this, BytesTransferred, Completed) (this)->lpVtbl->SetCompleted(this, BytesTransferred, Completed)

#endif
