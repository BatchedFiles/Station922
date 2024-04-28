#ifndef IHTTPASYNCWRITER_BI
#define IHTTPASYNCWRITER_BI

#include once "IAsyncResult.bi"
#include once "IBaseAsyncStream.bi"
#include once "IAttributedAsyncStream.bi"
#include once "IServerResponse.bi"

Extern IID_IHttpAsyncWriter Alias "IID_IHttpAsyncWriter" As Const IID

' ITextWriter.BeginWrite:
' HTTPWRITER_S_IO_PENDING, Any E_FAIL

' ITextWriter.EndWrite:
' S_OK, S_FALSE, HTTPWRITER_S_IO_PENDING, Any E_FAIL

Const HTTPWRITER_S_IO_PENDING As HRESULT = MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0201)

Type IHttpAsyncWriter As IHttpAsyncWriter_

Type IHttpAsyncWriterVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IHttpAsyncWriter Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IHttpAsyncWriter Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IHttpAsyncWriter Ptr _
	)As ULONG
	
	GetBaseStream As Function( _
		ByVal this As IHttpAsyncWriter Ptr, _
		ByVal ppResult As IBaseAsyncStream Ptr Ptr _
	)As HRESULT
	
	SetBaseStream As Function( _
		ByVal this As IHttpAsyncWriter Ptr, _
		ByVal pIStream As IBaseAsyncStream Ptr _
	)As HRESULT
	
	GetBuffer As Function( _
		ByVal this As IHttpAsyncWriter Ptr, _
		ByVal ppResult As IAttributedAsyncStream Ptr Ptr _
	)As HRESULT
	
	SetBuffer As Function( _
		ByVal this As IHttpAsyncWriter Ptr, _
		ByVal pIBuffer As IAttributedAsyncStream Ptr _
	)As HRESULT
	
	Prepare As Function( _
		ByVal this As IHttpAsyncWriter Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal ContentLength As LongInt, _
		ByVal fFileAccess As FileAccess _
	)As HRESULT
	
	BeginWrite As Function( _
		ByVal this As IHttpAsyncWriter Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndWrite As Function( _
		ByVal this As IHttpAsyncWriter Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	
	SetKeepAlive As Function( _
		ByVal this As IHttpAsyncWriter Ptr, _
		ByVal KeepAlive As Boolean _
	)As HRESULT
	
	SetNeedWrite100Continue As Function( _
		ByVal this As IHttpAsyncWriter Ptr, _
		ByVal NeedWrite100Continue As Boolean _
	)As HRESULT
	
End Type

Type IHttpAsyncWriter_
	lpVtbl As IHttpAsyncWriterVirtualTable Ptr
End Type

#define IHttpAsyncWriter_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IHttpAsyncWriter_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IHttpAsyncWriter_Release(this) (this)->lpVtbl->Release(this)
#define IHttpAsyncWriter_GetBaseStream(this, ppResult) (this)->lpVtbl->GetBaseStream(this, ppResult)
#define IHttpAsyncWriter_SetBaseStream(this, pIStream) (this)->lpVtbl->SetBaseStream(this, pIStream)
#define IHttpAsyncWriter_GetBuffer(this, ppResult) (this)->lpVtbl->GetBuffer(this, ppResult)
#define IHttpAsyncWriter_SetBuffer(this, pIBuffer) (this)->lpVtbl->SetBuffer(this, pIBuffer)
#define IHttpAsyncWriter_Prepare(this, pIResponse, ContentLength, fFileAccess) (this)->lpVtbl->Prepare(this, pIResponse, ContentLength, fFileAccess)
#define IHttpAsyncWriter_BeginWrite(this, pcb, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginWrite(this, pcb, StateObject, ppIAsyncResult)
#define IHttpAsyncWriter_EndWrite(this, pIAsyncResult) (this)->lpVtbl->EndWrite(this, pIAsyncResult)
#define IHttpAsyncWriter_SetKeepAlive(this, KeepAlive) (this)->lpVtbl->SetKeepAlive(this, KeepAlive)
#define IHttpAsyncWriter_SetNeedWrite100Continue(this, NeedWrite100Continue) (this)->lpVtbl->SetNeedWrite100Continue(this, NeedWrite100Continue)

#endif
