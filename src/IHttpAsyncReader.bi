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
		ByVal self As IHttpAsyncReader Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IHttpAsyncReader Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IHttpAsyncReader Ptr _
	)As ULONG

	ReadLine As Function( _
		ByVal self As IHttpAsyncReader Ptr, _
		ByVal pLine As HeapBSTR Ptr _
	)As HRESULT

	BeginReadLine As Function( _
		ByVal self As IHttpAsyncReader Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	EndReadLine As Function( _
		ByVal self As IHttpAsyncReader Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal ppLine As HeapBSTR Ptr _
	)As HRESULT

	Clear As Function( _
		ByVal self As IHttpAsyncReader Ptr _
	)As HRESULT

	GetBaseStream As Function( _
		ByVal self As IHttpAsyncReader Ptr, _
		ByVal ppStream As IBaseAsyncStream Ptr Ptr _
	)As HRESULT

	SetBaseStream As Function( _
		ByVal self As IHttpAsyncReader Ptr, _
		byVal pStream As IBaseAsyncStream Ptr _
	)As HRESULT

	GetPreloadedBytes As Function( _
		ByVal self As IHttpAsyncReader Ptr, _
		ByVal pPreloadedBytesLength As Integer Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As HRESULT

	GetRequestedBytes As Function( _
		ByVal self As IHttpAsyncReader Ptr, _
		ByVal pRequestedBytesLength As Integer Ptr, _
		ByVal ppRequestedBytes As UByte Ptr Ptr _
	)As HRESULT

	SetSkippedBytes As Function( _
		ByVal self As IHttpAsyncReader Ptr, _
		ByVal Length As LongInt _
	)As HRESULT

End Type

Type IHttpAsyncReader_
	lpVtbl As IHttpAsyncReaderVirtualTable Ptr
End Type

#define IHttpAsyncReader_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define IHttpAsyncReader_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IHttpAsyncReader_Release(self) (self)->lpVtbl->Release(self)
#define IHttpAsyncReader_ReadLine(self, pLine) (self)->lpVtbl->ReadLine(self, pLine)
#define IHttpAsyncReader_BeginReadLine(self, pcb, StateObject, ppIAsyncResult) (self)->lpVtbl->BeginReadLine(self, pcb, StateObject, ppIAsyncResult)
#define IHttpAsyncReader_EndReadLine(self, pIAsyncResult, pLine) (self)->lpVtbl->EndReadLine(self, pIAsyncResult, pLine)
#define IHttpAsyncReader_Clear(self) (self)->lpVtbl->Clear(self)
#define IHttpAsyncReader_GetBaseStream(self, ppIStream) (self)->lpVtbl->GetBaseStream(self, ppIStream)
#define IHttpAsyncReader_SetBaseStream(self, pIStream) (self)->lpVtbl->SetBaseStream(self, pIStream)
#define IHttpAsyncReader_GetPreloadedBytes(self, pPreloadedBytesLength, ppPreloadedBytes) (self)->lpVtbl->GetPreloadedBytes(self, pPreloadedBytesLength, ppPreloadedBytes)
#define IHttpAsyncReader_GetRequestedBytes(self, pRequestedBytesLength, ppRequestedBytes) (self)->lpVtbl->GetRequestedBytes(self, pRequestedBytesLength, ppRequestedBytes)
#define IHttpAsyncReader_SetSkippedBytes(self, Length) (self)->lpVtbl->SetSkippedBytes(self, Length)

#endif
