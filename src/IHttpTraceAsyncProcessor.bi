#ifndef IHTTPTRACEASYNCPROCESSOR_BI
#define IHTTPTRACEASYNCPROCESSOR_BI

#include once "IHttpAsyncProcessor.bi"

Extern IID_IHttpTraceAsyncProcessor Alias "IID_IHttpTraceAsyncProcessor" As Const IID

Type IHttpTraceAsyncProcessor As IHttpTraceAsyncProcessor_

Type IHttpTraceAsyncProcessorVirtualTable

	QueryInterface As Function( _
		ByVal self As IHttpTraceAsyncProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IHttpTraceAsyncProcessor Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IHttpTraceAsyncProcessor Ptr _
	)As ULONG

	Prepare As Function( _
		ByVal self As IHttpTraceAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal ppIBuffer As IAttributedAsyncStream Ptr Ptr _
	)As HRESULT

	BeginProcess As Function( _
		ByVal self As IHttpTraceAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	EndProcess As Function( _
		ByVal self As IHttpTraceAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT

End Type

Type IHttpTraceAsyncProcessor_
	lpVtbl As IHttpTraceAsyncProcessorVirtualTable Ptr
End Type

#define IHttpTraceAsyncProcessor_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define IHttpTraceAsyncProcessor_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IHttpTraceAsyncProcessor_Release(self) (self)->lpVtbl->Release(self)
#define IHttpTraceAsyncProcessor_Prepare(self, pContext, ppIBuffer) (self)->lpVtbl->Prepare(self, pContext, ppIBuffer)
#define IHttpTraceAsyncProcessor_BeginProcess(self, pContext, pcb, StateObject, ppIAsyncResult) (self)->lpVtbl->BeginProcess(self, pContext, pcb, StateObject, ppIAsyncResult)
#define IHttpTraceAsyncProcessor_EndProcess(self, pContext, pIAsyncResult) (self)->lpVtbl->EndProcess(self, pContext, pIAsyncResult)

#endif
