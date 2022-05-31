#ifndef IHTTPASYNCPROCESSOR_BI
#define IHTTPASYNCPROCESSOR_BI

#include once "IAsyncResult.bi"
#include once "IBaseStream.bi"
#include once "IClientRequest.bi"
#include once "IServerResponse.bi"
#include once "IWebSite.bi"

Const HTTPASYNCPROCESSOR_S_IO_PENDING As HRESULT = MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0201)
Const HTTPASYNCPROCESSOR_E_RANGENOTSATISFIABLE As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0204)

Type ProcessorContext
	pIMemoryAllocator As IMalloc Ptr
	pIWebSite As IWebSite Ptr
	pIRequest As IClientRequest Ptr
	pIResponse As IServerResponse Ptr
	pIReader As IHttpReader Ptr
	pIWriter As IHttpWriter Ptr
End Type

Type LPProcessorContext As _ProcessorContext Ptr

Type IHttpAsyncProcessor As IHttpAsyncProcessor_

Type LPIHTTPASYNCPROCESSOR As IHttpAsyncProcessor Ptr

Extern IID_IHttpAsyncProcessor Alias "IID_IHttpAsyncProcessor" As Const IID

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
		ByVal ppIBuffer As IBuffer Ptr Ptr _
	)As HRESULT
	
	BeginProcess As Function( _
		ByVal this As IHttpAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal StateObject As IUnknown Ptr, _
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
#define IHttpAsyncProcessor_BeginProcess(this, pContext, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginProcess(this, pContext, StateObject, ppIAsyncResult)
#define IHttpAsyncProcessor_EndProcess(this, pContext, pIAsyncResult) (this)->lpVtbl->EndProcess(this, pContext, pIAsyncResult)

#endif
