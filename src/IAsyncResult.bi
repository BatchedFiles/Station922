#ifndef IASYNCRESULT_BI
#define IASYNCRESULT_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Extern IID_IAsyncResult Alias "IID_IAsyncResult" As Const IID

Type IAsyncResult As IAsyncResult_

Declare Function GetAsyncResultFromOverlappedWeakPtr( _
	ByVal pOverLap As OVERLAPPED Ptr _
)As IAsyncResult Ptr

Type AsyncCallback As Sub(ByVal ar As IAsyncResult Ptr)

Type IAsyncResultVirtualTable

	QueryInterface As Function( _
		ByVal self As IAsyncResult Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IAsyncResult Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IAsyncResult Ptr _
	)As ULONG

	GetAsyncStateWeakPtr As Function( _
		ByVal self As IAsyncResult Ptr, _
		ByVal ppState As Any Ptr Ptr _
	)As HRESULT

	SetAsyncStateWeakPtr As Function( _
		ByVal self As IAsyncResult Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal pState As Any Ptr _
	)As HRESULT

	GetCompleted As Function( _
		ByVal self As IAsyncResult Ptr, _
		ByVal pBytesTransferred As DWORD Ptr, _
		ByVal pCompleted As Boolean Ptr, _
		ByVal pdwError As DWORD Ptr _
	)As HRESULT

	SetCompleted As Function( _
		ByVal self As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal Completed As Boolean, _
		ByVal dwError As DWORD _
	)As HRESULT

	GetWsaOverlapped As Function( _
		ByVal self As IAsyncResult Ptr, _
		ByVal ppOverlapped As OVERLAPPED Ptr Ptr _
	)As HRESULT

	AllocBuffers As Function( _
		ByVal self As IAsyncResult Ptr, _
		ByVal Length As Integer, _
		ByVal ppBuffers As Any Ptr Ptr _
	)As HRESULT

	GetAsyncCallback As Function( _
		ByVal self As IAsyncResult Ptr, _
		ByVal ppcb As AsyncCallback Ptr _
	)As HRESULT

End Type

Type IAsyncResult_
	lpVtbl As IAsyncResultVirtualTable Ptr
End Type

#define IAsyncResult_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define IAsyncResult_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IAsyncResult_Release(self) (self)->lpVtbl->Release(self)
#define IAsyncResult_GetAsyncStateWeakPtr(self, ppState) (self)->lpVtbl->GetAsyncStateWeakPtr(self, ppState)
#define IAsyncResult_SetAsyncStateWeakPtr(self, pcb, pState) (self)->lpVtbl->SetAsyncStateWeakPtr(self, pcb, pState)
#define IAsyncResult_GetCompleted(self, pBytesTransferred, pCompleted, pdwError) (self)->lpVtbl->GetCompleted(self, pBytesTransferred, pCompleted, pdwError)
#define IAsyncResult_SetCompleted(self, BytesTransferred, Completed, dwError) (self)->lpVtbl->SetCompleted(self, BytesTransferred, Completed, dwError)
#define IAsyncResult_GetWsaOverlapped(self, ppRecvOverlapped) (self)->lpVtbl->GetWsaOverlapped(self, ppRecvOverlapped)
#define IAsyncResult_AllocBuffers(self, Count, ppBuffers) (self)->lpVtbl->AllocBuffers(self, Count, ppBuffers)
#define IAsyncResult_GetAsyncCallback(self, ppcb) (self)->lpVtbl->GetAsyncCallback(self, ppcb)

#endif
