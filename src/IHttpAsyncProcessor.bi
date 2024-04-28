#ifndef IHTTPASYNCPROCESSOR_BI
#define IHTTPASYNCPROCESSOR_BI

Type IHttpAsyncProcessor As IHttpAsyncProcessor_

#include once "IClientRequest.bi"
#include once "IHttpAsyncWriter.bi"
#include once "IWebSite.bi"

Extern IID_IHttpAsyncProcessor Alias "IID_IHttpAsyncProcessor" As Const IID

Const HTTPASYNCPROCESSOR_S_IO_PENDING As HRESULT = MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0201)

Type ProcessorContext
	pIMemoryAllocator As IMalloc Ptr
	pIWebSite As IWebSite Ptr
	pIRequest As IClientRequest Ptr
	pIResponse As IServerResponse Ptr
	pIReader As IHttpAsyncReader Ptr
	pIWriter As IHttpAsyncWriter Ptr
End Type

Type IHttpAsyncProcessorVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IHttpAsyncProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IHttpAsyncProcessor Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IHttpAsyncProcessor Ptr _
	)As ULONG
	
	Prepare As Function( _
		ByVal this As IHttpAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal ppIBuffer As IAttributedAsyncStream Ptr Ptr _
	)As HRESULT
	
	BeginProcess As Function( _
		ByVal this As IHttpAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndProcess As Function( _
		ByVal this As IHttpAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	
End Type

Type IHttpAsyncProcessor_
	lpVtbl As IHttpAsyncProcessorVirtualTable Ptr
End Type

#define IHttpAsyncProcessor_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IHttpAsyncProcessor_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IHttpAsyncProcessor_Release(this) (this)->lpVtbl->Release(this)
#define IHttpAsyncProcessor_Prepare(this, pContext, ppIBuffer) (this)->lpVtbl->Prepare(this, pContext, ppIBuffer)
#define IHttpAsyncProcessor_BeginProcess(this, pContext, pcb, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginProcess(this, pContext, pcb, StateObject, ppIAsyncResult)
#define IHttpAsyncProcessor_EndProcess(this, pContext, pIAsyncResult) (this)->lpVtbl->EndProcess(this, pContext, pIAsyncResult)

#endif
