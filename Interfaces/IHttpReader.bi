#ifndef IHTTPREADER_BI
#define IHTTPREADER_BI

#include once "IAsyncResult.bi"
#include once "IBaseStream.bi"
#include once "IString.bi"

' ITextReader.ReadLine:
' S_OK, S_FALSE

' ITextReader.BeginReadLine:
' HTTPREADER_S_IO_PENDING, Any E_FAIL

' ITextReader.EndReadLine:
' S_OK, S_FALSE, HTTPREADER_S_IO_PENDING, Any E_FAIL

Const HTTPREADER_S_IO_PENDING As HRESULT = MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0201)

Type IHttpReader As IHttpReader_

Type LPIHTTPREADER As IHttpReader Ptr

Extern IID_IHttpReader Alias "IID_IHttpReader" As Const IID

Type IHttpReaderVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IHttpReader Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IHttpReader Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IHttpReader Ptr _
	)As ULONG
	
	Peek As Function( _
		ByVal this As IHttpReader Ptr, _
		ByVal pChar As wchar_t Ptr _
	)As HRESULT
	
	ReadChar As Function( _
		ByVal this As IHttpReader Ptr, _
		ByVal pChar As wchar_t Ptr _
	)As HRESULT
	
	ReadCharArray As Function( _
		ByVal this As IHttpReader Ptr, _
		ByVal Buffer As WString Ptr, _
		ByVal Count As Integer, _
		ByVal pReadedChars As Integer Ptr _
	)As HRESULT
	
	ReadLine As Function( _
		ByVal this As IHttpReader Ptr, _
		ByVal pLine As HeapBSTR Ptr _
	)As HRESULT
	
	ReadToEnd As Function( _
		ByVal this As IHttpReader Ptr, _
		ByVal ppLine As HeapBSTR Ptr _
	)As HRESULT
	
	BeginReadLine As Function( _
		ByVal this As IHttpReader Ptr, _
		ByVal callback As AsyncCallback, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndReadLine As Function( _
		ByVal this As IHttpReader Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal ppLine As HeapBSTR Ptr _
	)As HRESULT
	
	BeginReadToEnd As Function( _
		ByVal this As IHttpReader Ptr, _
		ByVal callback As AsyncCallback, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndReadToEnd As Function( _
		ByVal this As IHttpReader Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pLines As HeapBSTR Ptr _
	)As HRESULT
	
	Clear As Function( _
		ByVal this As IHttpReader Ptr _
	)As HRESULT
	
	GetBaseStream As Function( _
		ByVal this As IHttpReader Ptr, _
		ByVal ppResult As IBaseStream Ptr Ptr _
	)As HRESULT
	
	SetBaseStream As Function( _
		ByVal this As IHttpReader Ptr, _
		ByVal pIStream As IBaseStream Ptr _
	)As HRESULT
	
	GetPreloadedBytes As Function( _
		ByVal this As IHttpReader Ptr, _
		ByVal pPreloadedBytesLength As Integer Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As HRESULT
	
	GetRequestedBytes As Function( _
		ByVal this As IHttpReader Ptr, _
		ByVal pRequestedBytesLength As Integer Ptr, _
		ByVal ppRequestedBytes As UByte Ptr Ptr _
	)As HRESULT
	
	IsCompleted As Function( _
		ByVal this As IHttpReader Ptr, _
		ByVal pCompleted As Boolean Ptr _
	)As HRESULT
	
End Type

Type IHttpReader_
	lpVtbl As IHttpReaderVirtualTable Ptr
End Type

#define IHttpReader_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IHttpReader_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IHttpReader_Release(this) (this)->lpVtbl->Release(this)
#define IHttpReader_ReadLine(this, pLine) (this)->lpVtbl->ReadLine(this, pLine)
#define IHttpReader_BeginReadLine(this, callback, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginReadLine(this, callback, StateObject, ppIAsyncResult)
#define IHttpReader_EndReadLine(this, pIAsyncResult, pLine) (this)->lpVtbl->EndReadLine(this, pIAsyncResult, pLine)
#define IHttpReader_Clear(this) (this)->lpVtbl->Clear(this)
' #define IHttpReader_GetBaseStream(this, ppResult) (this)->lpVtbl->GetBaseStream(this, ppResult)
#define IHttpReader_SetBaseStream(this, pIStream) (this)->lpVtbl->SetBaseStream(this, pIStream)
#define IHttpReader_GetPreloadedBytes(this, pPreloadedBytesLength, ppPreloadedBytes) (this)->lpVtbl->GetPreloadedBytes(this, pPreloadedBytesLength, ppPreloadedBytes)
#define IHttpReader_GetRequestedBytes(this, pRequestedBytesLength, ppRequestedBytes) (this)->lpVtbl->GetRequestedBytes(this, pRequestedBytesLength, ppRequestedBytes)
' #define IHttpReader_IsCompleted(this, pCompleted) (this)->lpVtbl->IsCompleted(this, pCompleted)

#endif
