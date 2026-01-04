#ifndef IHTTPDELETEASYNCPROCESSOR_BI
#define IHTTPDELETEASYNCPROCESSOR_BI

#include once "IHttpAsyncProcessor.bi"

Extern IID_IHttpDeleteAsyncProcessor Alias "IID_IHttpDeleteAsyncProcessor" As Const IID

Type IHttpDeleteAsyncProcessor As IHttpDeleteAsyncProcessor_

Type IHttpDeleteAsyncProcessorVirtualTable

	QueryInterface As Function( _
		ByVal self As IHttpDeleteAsyncProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IHttpDeleteAsyncProcessor Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IHttpDeleteAsyncProcessor Ptr _
	)As ULONG

	Prepare As Function( _
		ByVal self As IHttpDeleteAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal ppIBuffer As IAttributedAsyncStream Ptr Ptr _
	)As HRESULT

	BeginProcess As Function( _
		ByVal self As IHttpDeleteAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	EndProcess As Function( _
		ByVal self As IHttpDeleteAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT

End Type

Type IHttpDeleteAsyncProcessor_
	lpVtbl As IHttpDeleteAsyncProcessorVirtualTable Ptr
End Type

#define IHttpDeleteAsyncProcessor_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define IHttpDeleteAsyncProcessor_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IHttpDeleteAsyncProcessor_Release(self) (self)->lpVtbl->Release(self)
#define IHttpDeleteAsyncProcessor_Prepare(self, pContext, ppIBuffer) (self)->lpVtbl->Prepare(self, pContext, ppIBuffer)
#define IHttpDeleteAsyncProcessor_BeginProcess(self, pContext, pcb, StateObject, ppIAsyncResult) (self)->lpVtbl->BeginProcess(self, pContext, pcb, StateObject, ppIAsyncResult)
#define IHttpDeleteAsyncProcessor_EndProcess(self, pContext, pIAsyncResult) (self)->lpVtbl->EndProcess(self, pContext, pIAsyncResult)

#endif
