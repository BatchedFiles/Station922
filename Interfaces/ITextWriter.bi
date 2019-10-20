#ifndef ITEXTWRITER_BI
#define ITEXTWRITER_BI

#ifndef unicode
#define unicode
#endif
#include "windows.bi"
#include "win\ole2.bi"

Type ITextWriter As ITextWriter_

Type LPITEXTWRITER As ITextWriter Ptr

Extern IID_ITextWriter Alias "IID_ITextWriter" As Const IID

Type ITextWriterVirtualTable
	Dim InheritedTable As IUnknownVtbl
	
	Dim CloseTextWriter As Function( _
		ByVal this As ITextWriter Ptr _
	)As HRESULT
	
	Dim OpenTextWriter As Function( _
		ByVal this As ITextWriter Ptr _
	)As HRESULT
	
	Dim Flush As Function( _
		ByVal this As ITextWriter Ptr _
	)As HRESULT
	
	Dim GetCodePage As Function( _
		ByVal this As ITextWriter Ptr, _
		ByVal pCodePage As Integer Ptr _
	)As HRESULT
	
	Dim SetCodePage As Function( _
		ByVal this As ITextWriter Ptr, _
		ByVal CodePage As Integer _
	)As HRESULT
	
	Dim WriteNewLine As Function( _
		ByVal this As ITextWriter Ptr _
	)As HRESULT
	
	Dim WriteStringLine As Function( _
		ByVal this As ITextWriter Ptr, _
		ByVal w As WString Ptr _
	)As HRESULT
	
	Dim WriteLengthStringLine As Function( _
		ByVal this As ITextWriter Ptr, _
		ByVal w As WString Ptr, _
		ByVal Length As Integer _
	)As HRESULT
	
	Dim WriteString As Function( _
		ByVal this As ITextWriter Ptr, _
		ByVal w As WString Ptr _
	)As HRESULT
	
	Dim WriteLengthString As Function( _
		ByVal this As ITextWriter Ptr, _
		ByVal w As WString Ptr, _
		ByVal Length As Integer _
	)As HRESULT
	
	Dim WriteChar As Function( _
		ByVal this As ITextWriter Ptr, _
		ByVal wc As Integer _
	)As HRESULT
	
	Dim WriteInt32 As Function( _
		ByVal this As ITextWriter Ptr, _
		ByVal Value As Long _
	)As HRESULT
	
	Dim WriteInt64 As Function( _
		ByVal this As ITextWriter Ptr, _
		ByVal Value As LongInt _
	)As HRESULT
	
	Dim WriteUInt64 As Function( _
		ByVal this As ITextWriter Ptr, _
		ByVal Value As ULongInt _
	)As HRESULT
	
End Type

Type ITextWriter_
	Dim pVirtualTable As ITextWriterVirtualTable Ptr
End Type

#define ITextWriter_QueryInterface(this, riid, ppv) (this)->pVirtualTable->InheritedTable.QueryInterface(CPtr(IUnknown Ptr, this), riid, ppv)
#define ITextWriter_AddRef(this) (this)->pVirtualTable->InheritedTable.AddRef(CPtr(IUnknown Ptr, this))
#define ITextWriter_Release(this) (this)->pVirtualTable->InheritedTable.Release(CPtr(IUnknown Ptr, this))
#define ITextWriter_CloseTextWriter(this) (this)->pVirtualTable->CloseTextWriter(this)
#define ITextWriter_OpenTextWriter(this) (this)->pVirtualTable->OpenTextWriter(this)
#define ITextWriter_Flush(this) (this)->pVirtualTable->Flush(this)
#define ITextWriter_GetCodePage(this, pCodePage) (this)->pVirtualTable->GetCodePage(this, pCodePage)
#define ITextWriter_SetCodePage(this, CodePage) (this)->pVirtualTable->GetCodePage(this, CodePage)
#define ITextWriter_WriteNewLine(this) (this)->pVirtualTable->WriteNewLine(this)
#define ITextWriter_WriteStringLine(this, w) (this)->pVirtualTable->WriteStringLine(this, w)
#define ITextWriter_WriteLengthStringLine(this, w, Length) (this)->pVirtualTable->WriteLengthStringLine(this, w, Length)
#define ITextWriter_WriteString(this, w) (this)->pVirtualTable->WriteString(this, w)
#define ITextWriter_WriteLengthString(this, w, Length) (this)->pVirtualTable->WriteLengthString(this, w, Length)
#define ITextWriter_WriteChar(this, wc) (this)->pVirtualTable->WriteChar(this, wc)
#define ITextWriter_WriteInt32(this, Value) (this)->pVirtualTable->WriteInt32(this, Value)
#define ITextWriter_WriteInt64(this, Value) (this)->pVirtualTable->WriteInt64(this, Value)
#define ITextWriter_WriteUInt64(this, Value) (this)->pVirtualTable->WriteUInt64(this, Value)

#endif
