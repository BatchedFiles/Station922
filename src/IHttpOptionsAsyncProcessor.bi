#ifndef IHTTPOPTIONSASYNCPROCESSOR_BI
#define IHTTPOPTIONSASYNCPROCESSOR_BI

#include once "IHttpAsyncProcessor.bi"

Extern IID_IHttpOptionsAsyncProcessor Alias "IID_IHttpOptionsAsyncProcessor" As Const IID

Type IHttpOptionsAsyncProcessor As IHttpOptionsAsyncProcessor_

Type IHttpOptionsAsyncProcessorVirtualTable

	QueryInterface As Function( _
		ByVal self As IHttpOptionsAsyncProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IHttpOptionsAsyncProcessor Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IHttpOptionsAsyncProcessor Ptr _
	)As ULONG

	Prepare As Function( _
		ByVal self As IHttpOptionsAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal ppIBuffer As IAttributedAsyncStream Ptr Ptr _
	)As HRESULT

	BeginProcess As Function( _
		ByVal self As IHttpOptionsAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	EndProcess As Function( _
		ByVal self As IHttpOptionsAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT

End Type

Type IHttpOptionsAsyncProcessor_
	lpVtbl As IHttpOptionsAsyncProcessorVirtualTable Ptr
End Type

#define IHttpOptionsAsyncProcessor_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define IHttpOptionsAsyncProcessor_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IHttpOptionsAsyncProcessor_Release(self) (self)->lpVtbl->Release(self)
#define IHttpOptionsAsyncProcessor_Prepare(self, pContext, ppIBuffer) (self)->lpVtbl->Prepare(self, pContext, ppIBuffer)
#define IHttpOptionsAsyncProcessor_BeginProcess(self, pContext, pcb, StateObject, ppIAsyncResult) (self)->lpVtbl->BeginProcess(self, pContext, pcb, StateObject, ppIAsyncResult)
#define IHttpOptionsAsyncProcessor_EndProcess(self, pContext, pIAsyncResult) (self)->lpVtbl->EndProcess(self, pContext, pIAsyncResult)

#endif
