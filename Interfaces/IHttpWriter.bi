#ifndef IHTTPWRITER_BI
#define IHTTPWRITER_BI

#include once "IAsyncResult.bi"
#include once "IBaseStream.bi"
#include once "IBuffer.bi"

' ITextWriter.BeginWrite:
' HTTPWRITER_S_IO_PENDING, Any E_FAIL

' ITextWriter.EndWrite:
' S_OK, S_FALSE, HTTPWRITER_S_IO_PENDING, Any E_FAIL

Const HTTPWRITER_S_IO_PENDING As HRESULT = MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0201)

Type IHttpWriter As IHttpWriter_

Type LPIHTTPWRITER As IHttpWriter Ptr

Extern IID_IHttpWriter Alias "IID_IHttpWriter" As Const IID

Type IHttpWriterVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IHttpWriter Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IHttpWriter Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IHttpWriter Ptr _
	)As ULONG
	
	GetBaseStream As Function( _
		ByVal this As IHttpWriter Ptr, _
		ByVal ppResult As IBaseStream Ptr Ptr _
	)As HRESULT
	
	SetBaseStream As Function( _
		ByVal this As IHttpWriter Ptr, _
		ByVal pIStream As IBaseStream Ptr _
	)As HRESULT
	
	GetBuffer As Function( _
		ByVal this As IHttpWriter Ptr, _
		ByVal ppResult As IBuffer Ptr Ptr _
	)As HRESULT
	
	SetBuffer As Function( _
		ByVal this As IHttpWriter Ptr, _
		ByVal pIBuffer As IBuffer Ptr _
	)As HRESULT
	
	BeginWrite As Function( _
		ByVal this As IHttpWriter Ptr, _
		ByVal Headers As LPVOID, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndWrite As Function( _
		ByVal this As IHttpWriter Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	
End Type

Type IHttpWriter_
	lpVtbl As IHttpWriterVirtualTable Ptr
End Type

#define IHttpWriter_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IHttpWriter_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IHttpWriter_Release(this) (this)->lpVtbl->Release(this)
#define IHttpWriter_GetBaseStream(this, ppResult) (this)->lpVtbl->GetBaseStream(this, ppResult)
#define IHttpWriter_SetBaseStream(this, pIStream) (this)->lpVtbl->SetBaseStream(this, pIStream)
#define IHttpWriter_GetBuffer(this, ppResult) (this)->lpVtbl->GetBuffer(this, ppResult)
#define IHttpWriter_SetBuffer(this, pIBuffer) (this)->lpVtbl->SetBuffer(this, pIBuffer)
#define IHttpWriter_BeginWrite(this, Headers, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginWrite(this, Headers, StateObject, ppIAsyncResult)
#define IHttpWriter_EndWrite(this, pIAsyncResult) (this)->lpVtbl->EndWrite(this, pIAsyncResult)

#endif
