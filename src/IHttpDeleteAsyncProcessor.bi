#ifndef IHTTPDELETEASYNCPROCESSOR_BI
#define IHTTPDELETEASYNCPROCESSOR_BI

#include once "IHttpAsyncProcessor.bi"

Extern IID_IHttpDeleteAsyncProcessor Alias "IID_IHttpDeleteAsyncProcessor" As Const IID

Type IHttpDeleteAsyncProcessor As IHttpDeleteAsyncProcessor_

Type IHttpDeleteAsyncProcessorVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IHttpDeleteAsyncProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IHttpDeleteAsyncProcessor Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IHttpDeleteAsyncProcessor Ptr _
	)As ULONG
	
	Prepare As Function( _
		ByVal this As IHttpDeleteAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal ppIBuffer As IAttributedStream Ptr Ptr _
	)As HRESULT
	
	BeginProcess As Function( _
		ByVal this As IHttpDeleteAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndProcess As Function( _
		ByVal this As IHttpDeleteAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	
End Type

Type IHttpDeleteAsyncProcessor_
	lpVtbl As IHttpDeleteAsyncProcessorVirtualTable Ptr
End Type

#define IHttpDeleteAsyncProcessor_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IHttpDeleteAsyncProcessor_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IHttpDeleteAsyncProcessor_Release(this) (this)->lpVtbl->Release(this)
#define IHttpDeleteAsyncProcessor_Prepare(this, pContext, ppIBuffer) (this)->lpVtbl->Prepare(this, pContext, ppIBuffer)
#define IHttpDeleteAsyncProcessor_BeginProcess(this, pContext, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginProcess(this, pContext, StateObject, ppIAsyncResult)
#define IHttpDeleteAsyncProcessor_EndProcess(this, pContext, pIAsyncResult) (this)->lpVtbl->EndProcess(this, pContext, pIAsyncResult)

#endif
