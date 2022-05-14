#ifndef IARRAYATRINGWRITER_BI
#define IARRAYATRINGWRITER_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Type IArrayStringWriter As IArrayStringWriter_

Type LPIARRAYSTRINGWRITER As IArrayStringWriter Ptr

Extern IID_IArrayStringWriter Alias "IID_IArrayStringWriter" As Const IID

Type IArrayStringWriterVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IArrayStringWriter Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IArrayStringWriter Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IArrayStringWriter Ptr _
	)As ULONG
	
	GetCodePage As Function( _
		ByVal this As IArrayStringWriter Ptr, _
		ByVal pCodePage As Integer Ptr _
	)As HRESULT
	
	SetCodePage As Function( _
		ByVal this As IArrayStringWriter Ptr, _
		ByVal CodePage As Integer _
	)As HRESULT
	
	WriteNewLine As Function( _
		ByVal this As IArrayStringWriter Ptr _
	)As HRESULT
	
	WriteStringLine As Function( _
		ByVal this As IArrayStringWriter Ptr, _
		ByVal w As WString Ptr _
	)As HRESULT
	
	WriteLengthStringLine As Function( _
		ByVal this As IArrayStringWriter Ptr, _
		ByVal w As WString Ptr, _
		ByVal Length As Integer _
	)As HRESULT
	
	WriteString As Function( _
		ByVal this As IArrayStringWriter Ptr, _
		ByVal w As WString Ptr _
	)As HRESULT
	
	WriteLengthString As Function( _
		ByVal this As IArrayStringWriter Ptr, _
		ByVal w As WString Ptr, _
		ByVal Length As Integer _
	)As HRESULT
	
	WriteChar As Function( _
		ByVal this As IArrayStringWriter Ptr, _
		ByVal wc As wchar_t _
	)As HRESULT
	
	WriteInt32 As Function( _
		ByVal this As IArrayStringWriter Ptr, _
		ByVal Value As Long _
	)As HRESULT
	
	WriteUInt32 As Function( _
		ByVal this As IArrayStringWriter Ptr, _
		ByVal Value As ULong _
	)As HRESULT
	
	WriteInt64 As Function( _
		ByVal this As IArrayStringWriter Ptr, _
		ByVal Value As LongInt _
	)As HRESULT
	
	WriteUInt64 As Function( _
		ByVal this As IArrayStringWriter Ptr, _
		ByVal Value As ULongInt _
	)As HRESULT
	
	SetBuffer As Function( _
		ByVal this As IArrayStringWriter Ptr, _
		ByVal Buffer As WString Ptr, _
		ByVal Capacity As Integer _
	)As HRESULT
	
	GetLength As Function( _
		ByVal this As IArrayStringWriter Ptr, _
		ByVal pLength As Integer Ptr _
	)As HRESULT
	
End Type

Type IArrayStringWriter_
	lpVtbl As IArrayStringWriterVirtualTable Ptr
End Type

#define IArrayStringWriter_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IArrayStringWriter_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IArrayStringWriter_Release(this) (this)->lpVtbl->Release(this)
#define IArrayStringWriter_CloseTextWriter(this) (this)->lpVtbl->CloseTextWriter(this)
#define IArrayStringWriter_OpenTextWriter(this) (this)->lpVtbl->OpenTextWriter(this)
#define IArrayStringWriter_Flush(this) (this)->lpVtbl->Flush(this)
#define IArrayStringWriter_GetCodePage(this, pCodePage) (this)->lpVtbl->GetCodePage(this, pCodePage)
#define IArrayStringWriter_SetCodePage(this, CodePage) (this)->lpVtbl->GetCodePage(this, CodePage)
#define IArrayStringWriter_WriteNewLine(this) (this)->lpVtbl->WriteNewLine(this)
#define IArrayStringWriter_WriteStringLine(this, w) (this)->lpVtbl->WriteStringLine(this, w)
#define IArrayStringWriter_WriteLengthStringLine(this, w, Length) (this)->lpVtbl->WriteLengthStringLine(this, w, Length)
#define IArrayStringWriter_WriteString(this, w) (this)->lpVtbl->WriteString(this, w)
#define IArrayStringWriter_WriteLengthString(this, w, Length) (this)->lpVtbl->WriteLengthString(this, w, Length)
#define IArrayStringWriter_WriteChar(this, wc) (this)->lpVtbl->WriteChar(this, wc)
#define IArrayStringWriter_WriteInt32(this, Value) (this)->lpVtbl->WriteInt32(this, Value)
#define IArrayStringWriter_WriteUInt32(this, Value) (this)->lpVtbl->WriteUInt32(this, Value)
#define IArrayStringWriter_WriteInt64(this, Value) (this)->lpVtbl->WriteInt64(this, Value)
#define IArrayStringWriter_WriteUInt64(this, Value) (this)->lpVtbl->WriteUInt64(this, Value)
#define IArrayStringWriter_SetBuffer(this, Buffer, MaxBufferLength) (this)->lpVtbl->SetBuffer(this, Buffer, MaxBufferLength)
#define IArrayStringWriter_GetLength(this, pLength) (this)->lpVtbl->GetLength(this, pLength)

#endif
