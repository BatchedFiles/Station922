#ifndef IHTTPASYNCREADER_BI
#define IHTTPASYNCREADER_BI

#include once "IAsyncResult.bi"
#include once "IBaseAsyncStream.bi"
#include once "IString.bi"

Extern IID_IHttpAsyncReader Alias "IID_IHttpAsyncReader" As Const IID

' ITextReader.ReadLine:
' S_OK, S_FALSE

' ITextReader.BeginReadLine:
' HTTPREADER_S_IO_PENDING, Any E_FAIL

' ITextReader.EndReadLine:
' S_OK, S_FALSE, HTTPREADER_S_IO_PENDING, Any E_FAIL

Const HTTPREADER_S_IO_PENDING As HRESULT = MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0201)

Type IHttpAsyncReader As IHttpAsyncReader_

Type IHttpAsyncReaderVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IHttpAsyncReader Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IHttpAsyncReader Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IHttpAsyncReader Ptr _
	)As ULONG
	
	ReadLine As Function( _
		ByVal this As IHttpAsyncReader Ptr, _
		ByVal pLine As HeapBSTR Ptr _
	)As HRESULT
	
	BeginReadLine As Function( _
		ByVal this As IHttpAsyncReader Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndReadLine As Function( _
		ByVal this As IHttpAsyncReader Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal ppLine As HeapBSTR Ptr _
	)As HRESULT
	
	Clear As Function( _
		ByVal this As IHttpAsyncReader Ptr _
	)As HRESULT
	
	SetBaseStream As Function( _
		ByVal this As IHttpAsyncReader Ptr, _
		ByVal pIStream As IBaseAsyncStream Ptr _
	)As HRESULT
	
	GetPreloadedBytes As Function( _
		ByVal this As IHttpAsyncReader Ptr, _
		ByVal pPreloadedBytesLength As Integer Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As HRESULT
	
	GetRequestedBytes As Function( _
		ByVal this As IHttpAsyncReader Ptr, _
		ByVal pRequestedBytesLength As Integer Ptr, _
		ByVal ppRequestedBytes As UByte Ptr Ptr _
	)As HRESULT
	
	SetSkippedBytes As Function( _
		ByVal this As IHttpAsyncReader Ptr, _
		ByVal Length As LongInt _
	)As HRESULT
	
End Type

Type IHttpAsyncReader_
	lpVtbl As IHttpAsyncReaderVirtualTable Ptr
End Type

#define IHttpAsyncReader_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IHttpAsyncReader_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IHttpAsyncReader_Release(this) (this)->lpVtbl->Release(this)
#define IHttpAsyncReader_ReadLine(this, pLine) (this)->lpVtbl->ReadLine(this, pLine)
#define IHttpAsyncReader_BeginReadLine(this, pcb, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginReadLine(this, pcb, StateObject, ppIAsyncResult)
#define IHttpAsyncReader_EndReadLine(this, pIAsyncResult, pLine) (this)->lpVtbl->EndReadLine(this, pIAsyncResult, pLine)
#define IHttpAsyncReader_Clear(this) (this)->lpVtbl->Clear(this)
#define IHttpAsyncReader_SetBaseStream(this, pIStream) (this)->lpVtbl->SetBaseStream(this, pIStream)
#define IHttpAsyncReader_GetPreloadedBytes(this, pPreloadedBytesLength, ppPreloadedBytes) (this)->lpVtbl->GetPreloadedBytes(this, pPreloadedBytesLength, ppPreloadedBytes)
#define IHttpAsyncReader_GetRequestedBytes(this, pRequestedBytesLength, ppRequestedBytes) (this)->lpVtbl->GetRequestedBytes(this, pRequestedBytesLength, ppRequestedBytes)
#define IHttpAsyncReader_SetSkippedBytes(this, Length) (this)->lpVtbl->SetSkippedBytes(this, Length)

#endif
