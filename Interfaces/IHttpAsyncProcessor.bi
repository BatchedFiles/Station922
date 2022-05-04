#ifndef IHTTPASYNCPROCESSOR_BI
#define IHTTPASYNCPROCESSOR_BI

#include once "IAsyncResult.bi"
#include once "IClientRequest.bi"
#include once "INetworkStream.bi"
#include once "IServerResponse.bi"
#include once "IWebSite.bi"

Const HTTPASYNCPROCESSOR_S_IO_PENDING As HRESULT = MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0201)

Const HTTPASYNCPROCESSOR_E_FILENOTFOUND As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0201)
Const HTTPASYNCPROCESSOR_E_FILEGONE As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0202)
Const HTTPASYNCPROCESSOR_E_FORBIDDEN As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0203)
Const HTTPASYNCPROCESSOR_E_RANGENOTSATISFIABLE As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0204)

Type _ProcessorContext
	pIRequest As IClientRequest Ptr
	pIResponse As IServerResponse Ptr
	pINetworkStream As INetworkStream Ptr
	pIWebSite As IWebSite Ptr
	pIClientReader As ITextReader Ptr
	pIRequestedFile As IRequestedFile Ptr
	pIMemoryAllocator As IMalloc Ptr
End Type

Type ProcessorContext As _ProcessorContext

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
	
	BeginProcess As Function( _
		ByVal this As IHttpAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndProcess As Function( _
		ByVal this As IHttpAsyncProcessor Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	
End Type

Type IHttpAsyncProcessor_
	lpVtbl As IHttpAsyncProcessorVirtualTable Ptr
End Type

#define IHttpAsyncProcessor_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IHttpAsyncProcessor_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IHttpAsyncProcessor_Release(this) (this)->lpVtbl->Release(this)

#endif
