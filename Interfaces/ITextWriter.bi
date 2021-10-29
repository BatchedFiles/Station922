#ifndef ITEXTWRITER_BI
#define ITEXTWRITER_BI

#include once "windows.bi"
#include once "win\ole2.bi"

' IStreamWriter
' IArrayStringWriter

Type ITextWriter As ITextWriter_

Type LPITEXTWRITER As ITextWriter Ptr

Extern IID_ITextWriter Alias "IID_ITextWriter" As Const IID

Type ITextWriterVirtualTable
	
	QueryInterface As Function( _
		ByVal this As ITextWriter Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As ITextWriter Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As ITextWriter Ptr _
	)As ULONG
	
	GetCodePage As Function( _
		ByVal this As ITextWriter Ptr, _
		ByVal pCodePage As Integer Ptr _
	)As HRESULT
	
	SetCodePage As Function( _
		ByVal this As ITextWriter Ptr, _
		ByVal CodePage As Integer _
	)As HRESULT
	
	WriteNewLine As Function( _
		ByVal this As ITextWriter Ptr _
	)As HRESULT
	
	WriteStringLine As Function( _
		ByVal this As ITextWriter Ptr, _
		ByVal w As WString Ptr _
	)As HRESULT
	
	WriteLengthStringLine As Function( _
		ByVal this As ITextWriter Ptr, _
		ByVal w As WString Ptr, _
		ByVal Length As Integer _
	)As HRESULT
	
	WriteString As Function( _
		ByVal this As ITextWriter Ptr, _
		ByVal w As WString Ptr _
	)As HRESULT
	
	WriteLengthString As Function( _
		ByVal this As ITextWriter Ptr, _
		ByVal w As WString Ptr, _
		ByVal Length As Integer _
	)As HRESULT
	
	WriteChar As Function( _
		ByVal this As ITextWriter Ptr, _
		ByVal wc As wchar_t _
	)As HRESULT
	
	WriteInt32 As Function( _
		ByVal this As ITextWriter Ptr, _
		ByVal Value As Long _
	)As HRESULT
	
	WriteInt64 As Function( _
		ByVal this As ITextWriter Ptr, _
		ByVal Value As LongInt _
	)As HRESULT
	
	WriteUInt64 As Function( _
		ByVal this As ITextWriter Ptr, _
		ByVal Value As ULongInt _
	)As HRESULT
	
End Type

Type ITextWriter_
	lpVtbl As ITextWriterVirtualTable Ptr
End Type

#define ITextWriter_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define ITextWriter_AddRef(this) (this)->lpVtbl->AddRef(this)
#define ITextWriter_Release(this) (this)->lpVtbl->Release(this)
#define ITextWriter_CloseTextWriter(this) (this)->lpVtbl->CloseTextWriter(this)
#define ITextWriter_OpenTextWriter(this) (this)->lpVtbl->OpenTextWriter(this)
#define ITextWriter_Flush(this) (this)->lpVtbl->Flush(this)
#define ITextWriter_GetCodePage(this, pCodePage) (this)->lpVtbl->GetCodePage(this, pCodePage)
#define ITextWriter_SetCodePage(this, CodePage) (this)->lpVtbl->GetCodePage(this, CodePage)
#define ITextWriter_WriteNewLine(this) (this)->lpVtbl->WriteNewLine(this)
#define ITextWriter_WriteStringLine(this, w) (this)->lpVtbl->WriteStringLine(this, w)
#define ITextWriter_WriteLengthStringLine(this, w, Length) (this)->lpVtbl->WriteLengthStringLine(this, w, Length)
#define ITextWriter_WriteString(this, w) (this)->lpVtbl->WriteString(this, w)
#define ITextWriter_WriteLengthString(this, w, Length) (this)->lpVtbl->WriteLengthString(this, w, Length)
#define ITextWriter_WriteChar(this, wc) (this)->lpVtbl->WriteChar(this, wc)
#define ITextWriter_WriteInt32(this, Value) (this)->lpVtbl->WriteInt32(this, Value)
#define ITextWriter_WriteInt64(this, Value) (this)->lpVtbl->WriteInt64(this, Value)
#define ITextWriter_WriteUInt64(this, Value) (this)->lpVtbl->WriteUInt64(this, Value)

#endif
