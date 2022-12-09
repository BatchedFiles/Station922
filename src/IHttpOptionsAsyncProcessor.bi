#ifndef IHTTPOPTIONSASYNCPROCESSOR_BI
#define IHTTPOPTIONSASYNCPROCESSOR_BI

#include once "IHttpAsyncProcessor.bi"

Type IHttpOptionsAsyncProcessor As IHttpOptionsAsyncProcessor_

Type LPIHTTPOPTIONSASYNCPROCESSOR As IHttpOptionsAsyncProcessor Ptr

Extern IID_IHttpOptionsAsyncProcessor Alias "IID_IHttpOptionsAsyncProcessor" As Const IID

Type IHttpOptionsAsyncProcessorVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IHttpOptionsAsyncProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IHttpOptionsAsyncProcessor Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IHttpOptionsAsyncProcessor Ptr _
	)As ULONG
	
	Prepare As Function( _
		ByVal this As IHttpOptionsAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal ppIBuffer As IAttributedStream Ptr Ptr _
	)As HRESULT
	
	BeginProcess As Function( _
		ByVal this As IHttpOptionsAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndProcess As Function( _
		ByVal this As IHttpOptionsAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	
End Type

Type IHttpOptionsAsyncProcessor_
	lpVtbl As IHttpOptionsAsyncProcessorVirtualTable Ptr
End Type

#define IHttpOptionsAsyncProcessor_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IHttpOptionsAsyncProcessor_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IHttpOptionsAsyncProcessor_Release(this) (this)->lpVtbl->Release(this)
#define IHttpOptionsAsyncProcessor_Prepare(this, pContext, ppIBuffer) (this)->lpVtbl->Prepare(this, pContext, ppIBuffer)
#define IHttpOptionsAsyncProcessor_BeginProcess(this, pContext, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginProcess(this, pContext, StateObject, ppIAsyncResult)
#define IHttpOptionsAsyncProcessor_EndProcess(this, pContext, pIAsyncResult) (this)->lpVtbl->EndProcess(this, pContext, pIAsyncResult)

#endif
