#ifndef ITEXTREADER_BI
#define ITEXTREADER_BI

#include once "windows.bi"
#include once "win\ole2.bi"

' ITextReader.ReadLine:
' S_OK, S_FALSE, E_FAIL

' ITextReader.BeginReadLine:
' TEXTREADER_S_IO_PENDING, Any E_FAIL

' ITextReader.EndReadLine:
' S_OK, S_FALSE, TEXTREADER_S_IO_PENDING, E_FAIL

Const TEXTREADER_S_IO_PENDING As HRESULT = MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0201)

Type LPITEXTREADER As ITextReader Ptr

Type ITextReader As ITextReader_

Extern IID_ITextReader Alias "IID_ITextReader" As Const IID

Type ITextReaderVirtualTable
	
	QueryInterface As Function( _
		ByVal this As ITextReader Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As ITextReader Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As ITextReader Ptr _
	)As ULONG
	
	Peek As Function( _
		ByVal this As ITextReader Ptr, _
		ByVal pChar As wchar_t Ptr _
	)As HRESULT
	
	ReadChar As Function( _
		ByVal this As ITextReader Ptr, _
		ByVal pChar As wchar_t Ptr _
	)As HRESULT
	
	ReadCharArray As Function( _
		ByVal this As ITextReader Ptr, _
		ByVal Buffer As WString Ptr, _
		ByVal Count As Integer, _
		ByVal pReadedChars As Integer Ptr _
	)As HRESULT
	
	ReadLine As Function( _
		ByVal this As ITextReader Ptr, _
		ByVal pLineLength As Integer Ptr, _
		ByVal pLine As WString Ptr Ptr _
	)As HRESULT
	
	ReadToEnd As Function( _
		ByVal this As ITextReader Ptr, _
		ByVal pLinesLength As Integer Ptr, _
		ByVal pLines As WString Ptr Ptr _
	)As HRESULT
	
	BeginReadLine As Function( _
		ByVal this As ITextReader Ptr, _
		ByVal callback As AsyncCallback, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndReadLine As Function( _
		ByVal this As ITextReader Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pLineLength As Integer Ptr, _
		ByVal pLine As WString Ptr Ptr _
	)As HRESULT
	
	BeginReadToEnd As Function( _
		ByVal this As ITextReader Ptr, _
		ByVal callback As AsyncCallback, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndReadToEnd As Function( _
		ByVal this As ITextReader Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pLinesLength As Integer Ptr, _
		ByVal pLines As WString Ptr Ptr _
	)As HRESULT
	
End Type

Type ITextReader_
	lpVtbl As ITextReaderVirtualTable Ptr
End Type

#define ITextReader_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define ITextReader_AddRef(this) (this)->lpVtbl->AddRef(this)
#define ITextReader_Release(this) (this)->lpVtbl->Release(this)
' #define ITextReader_Peek(this, pChar) (this)->lpVtbl->Peek(this, pChar)
' #define ITextReader_ReadChar(this, pChar) (this)->lpVtbl->ReadChar(this, pChar)
' #define ITextReader_ReadCharArray(this, Buffer, Count, pReadedChars) (this)->lpVtbl->ReadCharArray(this, Buffer, Count, pReadedChars)
#define ITextReader_ReadLine(this, pLineLength, pLine) (this)->lpVtbl->ReadLine(this, pLineLength, pLine)
' #define ITextReader_ReadToEnd(this, pLineLength, pLine) (this)->lpVtbl->ReadToEnd(this, pLineLength, pLine)
#define ITextReader_BeginReadLine(this, callback, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginReadLine(this, callback, StateObject, ppIAsyncResult)
#define ITextReader_EndReadLine(this, pIAsyncResult, pLineLength, pLine) (this)->lpVtbl->EndReadLine(this, pIAsyncResult, pLineLength, pLine)

#endif
