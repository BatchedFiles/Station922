#ifndef IHTTPGETASYNCPROCESSOR_BI
#define IHTTPGETASYNCPROCESSOR_BI

#include once "IHttpAsyncProcessor.bi"

Extern IID_IHttpGetAsyncProcessor Alias "IID_IHttpGetAsyncProcessor" As Const IID

Type IHttpGetAsyncProcessor As IHttpGetAsyncProcessor_

Type IHttpGetAsyncProcessorVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IHttpGetAsyncProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IHttpGetAsyncProcessor Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IHttpGetAsyncProcessor Ptr _
	)As ULONG
	
	Prepare As Function( _
		ByVal this As IHttpGetAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal ppIBuffer As IAttributedStream Ptr Ptr _
	)As HRESULT
	
	BeginProcess As Function( _
		ByVal this As IHttpGetAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndProcess As Function( _
		ByVal this As IHttpGetAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	
End Type

Type IHttpGetAsyncProcessor_
	lpVtbl As IHttpGetAsyncProcessorVirtualTable Ptr
End Type

#define IHttpGetAsyncProcessor_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IHttpGetAsyncProcessor_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IHttpGetAsyncProcessor_Release(this) (this)->lpVtbl->Release(this)
#define IHttpGetAsyncProcessor_Prepare(this, pContext, ppIBuffer) (this)->lpVtbl->Prepare(this, pContext, ppIBuffer)
#define IHttpGetAsyncProcessor_BeginProcess(this, pContext, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginProcess(this, pContext, StateObject, ppIAsyncResult)
#define IHttpGetAsyncProcessor_EndProcess(this, pContext, pIAsyncResult) (this)->lpVtbl->EndProcess(this, pContext, pIAsyncResult)

#endif
