#ifndef IHTTPPUTASYNCPROCESSOR_BI
#define IHTTPPUTASYNCPROCESSOR_BI

#include once "IHttpAsyncProcessor.bi"

Extern IID_IHttpPutAsyncProcessor Alias "IID_IHttpPutAsyncProcessor" As Const IID

Type IHttpPutAsyncProcessor As IHttpPutAsyncProcessor_

Type IHttpPutAsyncProcessorVirtualTable

	QueryInterface As Function( _
		ByVal self As IHttpPutAsyncProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IHttpPutAsyncProcessor Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IHttpPutAsyncProcessor Ptr _
	)As ULONG

	Prepare As Function( _
		ByVal self As IHttpPutAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal ppIBuffer As IAttributedAsyncStream Ptr Ptr _
	)As HRESULT

	BeginProcess As Function( _
		ByVal self As IHttpPutAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	EndProcess As Function( _
		ByVal self As IHttpPutAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT

End Type

Type IHttpPutAsyncProcessor_
	lpVtbl As IHttpPutAsyncProcessorVirtualTable Ptr
End Type

#define IHttpPutAsyncProcessor_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define IHttpPutAsyncProcessor_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IHttpPutAsyncProcessor_Release(self) (self)->lpVtbl->Release(self)
#define IHttpPutAsyncProcessor_Prepare(self, pContext, ppIBuffer) (self)->lpVtbl->Prepare(self, pContext, ppIBuffer)
#define IHttpPutAsyncProcessor_BeginProcess(self, pContext, pcb, StateObject, ppIAsyncResult) (self)->lpVtbl->BeginProcess(self, pContext, pcb, StateObject, ppIAsyncResult)
#define IHttpPutAsyncProcessor_EndProcess(self, pContext, pIAsyncResult) (self)->lpVtbl->EndProcess(self, pContext, pIAsyncResult)

#endif
