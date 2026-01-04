#ifndef IHTTPGETASYNCPROCESSOR_BI
#define IHTTPGETASYNCPROCESSOR_BI

#include once "IHttpAsyncProcessor.bi"

Extern IID_IHttpGetAsyncProcessor Alias "IID_IHttpGetAsyncProcessor" As Const IID

Type IHttpGetAsyncProcessor As IHttpGetAsyncProcessor_

Type IHttpGetAsyncProcessorVirtualTable

	QueryInterface As Function( _
		ByVal self As IHttpGetAsyncProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IHttpGetAsyncProcessor Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IHttpGetAsyncProcessor Ptr _
	)As ULONG

	Prepare As Function( _
		ByVal self As IHttpGetAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal ppIBuffer As IAttributedAsyncStream Ptr Ptr _
	)As HRESULT

	BeginProcess As Function( _
		ByVal self As IHttpGetAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	EndProcess As Function( _
		ByVal self As IHttpGetAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT

End Type

Type IHttpGetAsyncProcessor_
	lpVtbl As IHttpGetAsyncProcessorVirtualTable Ptr
End Type

#define IHttpGetAsyncProcessor_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define IHttpGetAsyncProcessor_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IHttpGetAsyncProcessor_Release(self) (self)->lpVtbl->Release(self)
#define IHttpGetAsyncProcessor_Prepare(self, pContext, ppIBuffer) (self)->lpVtbl->Prepare(self, pContext, ppIBuffer)
#define IHttpGetAsyncProcessor_BeginProcess(self, pContext, pcb, StateObject, ppIAsyncResult) (self)->lpVtbl->BeginProcess(self, pContext, pcb, StateObject, ppIAsyncResult)
#define IHttpGetAsyncProcessor_EndProcess(self, pContext, pIAsyncResult) (self)->lpVtbl->EndProcess(self, pContext, pIAsyncResult)

#endif
