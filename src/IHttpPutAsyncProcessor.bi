#ifndef IHTTPPUTASYNCPROCESSOR_BI
#define IHTTPPUTASYNCPROCESSOR_BI

#include once "IHttpAsyncProcessor.bi"

Extern IID_IHttpPutAsyncProcessor Alias "IID_IHttpPutAsyncProcessor" As Const IID

Type IHttpPutAsyncProcessor As IHttpPutAsyncProcessor_

Type IHttpPutAsyncProcessorVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IHttpPutAsyncProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IHttpPutAsyncProcessor Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IHttpPutAsyncProcessor Ptr _
	)As ULONG
	
	Prepare As Function( _
		ByVal this As IHttpPutAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal ppIBuffer As IAttributedStream Ptr Ptr _
	)As HRESULT
	
	BeginProcess As Function( _
		ByVal this As IHttpPutAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndProcess As Function( _
		ByVal this As IHttpPutAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	
End Type

Type IHttpPutAsyncProcessor_
	lpVtbl As IHttpPutAsyncProcessorVirtualTable Ptr
End Type

#define IHttpPutAsyncProcessor_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IHttpPutAsyncProcessor_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IHttpPutAsyncProcessor_Release(this) (this)->lpVtbl->Release(this)
#define IHttpPutAsyncProcessor_Prepare(this, pContext, ppIBuffer) (this)->lpVtbl->Prepare(this, pContext, ppIBuffer)
#define IHttpPutAsyncProcessor_BeginProcess(this, pContext, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginProcess(this, pContext, StateObject, ppIAsyncResult)
#define IHttpPutAsyncProcessor_EndProcess(this, pContext, pIAsyncResult) (this)->lpVtbl->EndProcess(this, pContext, pIAsyncResult)

#endif
