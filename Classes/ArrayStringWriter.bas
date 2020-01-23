#include "ArrayStringWriter.bi"
#include "IntegerToWString.bi"
#include "StringConstants.bi"

Extern CLSID_ARRAYSTRINGWRITER Alias "CLSID_ARRAYSTRINGWRITER" As Const CLSID

Dim Shared GlobalArrayStringWriterVirtualTable As IArrayStringWriterVirtualTable

Sub InitializeArrayStringWriterVirtualTable()
	GlobalArrayStringWriterVirtualTable.InheritedTable.InheritedTable.QueryInterface = CPtr(Any Ptr, @ArrayStringWriterQueryInterface)
	GlobalArrayStringWriterVirtualTable.InheritedTable.InheritedTable.AddRef = Cast(Any Ptr, @ArrayStringWriterAddRef)
	GlobalArrayStringWriterVirtualTable.InheritedTable.InheritedTable.Release = Cast(Any Ptr, @ArrayStringWriterRelease)
	GlobalArrayStringWriterVirtualTable.InheritedTable.CloseTextWriter = Cast(Any Ptr, @ArrayStringWriterCloseTextWriter)
	GlobalArrayStringWriterVirtualTable.InheritedTable.OpenTextWriter = Cast(Any Ptr, @ArrayStringWriterCloseTextWriter)
	GlobalArrayStringWriterVirtualTable.InheritedTable.Flush = Cast(Any Ptr, @ArrayStringWriterCloseTextWriter)
	GlobalArrayStringWriterVirtualTable.InheritedTable.GetCodePage = Cast(Any Ptr, @ArrayStringWriterGetCodePage)
	GlobalArrayStringWriterVirtualTable.InheritedTable.SetCodePage = Cast(Any Ptr, @ArrayStringWriterSetCodePage)
	GlobalArrayStringWriterVirtualTable.InheritedTable.WriteNewLine = Cast(Any Ptr, @ArrayStringWriterWriteNewLine)
	GlobalArrayStringWriterVirtualTable.InheritedTable.WriteStringLine = Cast(Any Ptr, @ArrayStringWriterWriteStringLine)
	GlobalArrayStringWriterVirtualTable.InheritedTable.WriteLengthStringLine = Cast(Any Ptr, @ArrayStringWriterWriteLengthStringLine)
	GlobalArrayStringWriterVirtualTable.InheritedTable.WriteString = Cast(Any Ptr, @ArrayStringWriterWriteString)
	GlobalArrayStringWriterVirtualTable.InheritedTable.WriteLengthString = Cast(Any Ptr, @ArrayStringWriterWriteLengthString)
	GlobalArrayStringWriterVirtualTable.InheritedTable.WriteChar = Cast(Any Ptr, @ArrayStringWriterWriteChar)
	GlobalArrayStringWriterVirtualTable.InheritedTable.WriteInt32 = Cast(Any Ptr, @ArrayStringWriterWriteInt32)
	GlobalArrayStringWriterVirtualTable.InheritedTable.WriteInt64 = Cast(Any Ptr, @ArrayStringWriterWriteInt64)
	GlobalArrayStringWriterVirtualTable.InheritedTable.WriteUInt64 = Cast(Any Ptr, @ArrayStringWriterWriteUInt64)
	GlobalArrayStringWriterVirtualTable.SetBuffer = Cast(Any Ptr, @ArrayStringWriterSetBuffer)
End Sub

Sub InitializeArrayStringWriter( _
		ByVal this As ArrayStringWriter Ptr _
	)
	
	this->pVirtualTable = @GlobalArrayStringWriterVirtualTable
	this->ReferenceCounter = 0
	this->CodePage = 1200
	this->MaxBufferLength = 0
	this->BufferLength = 0
	this->Buffer = 0
	
End Sub

Function InitializeArrayStringWriterOfIArrayStringWriter( _
		ByVal this As ArrayStringWriter Ptr _
	)As IArrayStringWriter Ptr
	
	InitializeArrayStringWriter(this)
	this->ExistsInStack = True
	
	Dim pIWriter As IArrayStringWriter Ptr = Any
	
	ArrayStringWriterQueryInterface( _
		this, @IID_IArrayStringWriter, @pIWriter _
	)
	
	Return pIWriter
	
End Function

Function ArrayStringWriterQueryInterface( _
		ByVal this As ArrayStringWriter Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IArrayStringWriter, riid) Then
		*ppv = @this->pVirtualTable
	Else
		If IsEqualIID(@IID_ITextWriter, riid) Then
			*ppv = @this->pVirtualTable
		Else
			If IsEqualIID(@IID_IUnknown, riid) Then
				*ppv = @this->pVirtualTable
			Else
				*ppv = NULL
				Return E_NOINTERFACE
			End If
		End If
	End If
	
	ArrayStringWriterAddRef(this)
	
	Return S_OK
	
End Function

Function ArrayStringWriterAddRef( _
		ByVal this As ArrayStringWriter Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return this->ReferenceCounter
	
End Function

Function ArrayStringWriterRelease( _
		ByVal this As ArrayStringWriter Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter = 0 Then
		
		If this->ExistsInStack = False Then
		
		End If
		
		Return 0
	End If
	
	Return this->ReferenceCounter
	
End Function

Function ArrayStringWriterWriteLengthString( _
		ByVal this As ArrayStringWriter Ptr, _
		ByVal w As WString Ptr, _
		ByVal Length As Integer _
	)As HRESULT
	
	If this->BufferLength + Length > this->MaxBufferLength Then
		Return E_OUTOFMEMORY
	End If
	
	lstrcpyn(@this->Buffer[this->BufferLength], w, Length + 1)
	this->BufferLength += Length
	
	Return S_OK
	
End Function

Function ArrayStringWriterWriteNewLine( _
		ByVal this As ArrayStringWriter Ptr _
	)As HRESULT
	
	Return ArrayStringWriterWriteLengthString(this, @NewLineString, 2)
	
End Function

Function ArrayStringWriterWriteString( _
		ByVal this As ArrayStringWriter Ptr, _
		ByVal w As WString Ptr _
	)As HRESULT
	
	Return ArrayStringWriterWriteLengthString(this, w, lstrlen(w))
	
End Function

Function ArrayStringWriterWriteLengthStringLine( _
		ByVal this As ArrayStringWriter Ptr, _
		ByVal w As WString Ptr, _
		ByVal Length As Integer _
	)As HRESULT
	
	If FAILED(ArrayStringWriterWriteLengthString(this, w, Length)) Then
		Return E_OUTOFMEMORY
	End If
	
	If FAILED(ArrayStringWriterWriteNewLine(this)) Then
		Return E_OUTOFMEMORY
	End If
	
	Return S_OK
	
End Function

Function ArrayStringWriterWriteStringLine( _
		ByVal this As ArrayStringWriter Ptr, _
		ByVal w As WString Ptr _
	)As HRESULT
	
	Return ArrayStringWriterWriteLengthStringLine(this, w, lstrlen(w))
	
End Function

Function ArrayStringWriterWriteChar( _
		ByVal this As ArrayStringWriter Ptr, _
		ByVal wc As wchar_t _
	)As HRESULT
	
	If this->BufferLength + 1 > this->MaxBufferLength Then
		Return E_OUTOFMEMORY
	End If
	
	this->Buffer[this->BufferLength] = wc
	this->Buffer[this->BufferLength + 1] = 0
	this->BufferLength += 1
	
	Return S_OK
	
End Function

Function ArrayStringWriterWriteInt32( _
		ByVal this As ArrayStringWriter Ptr, _
		ByVal Value As Long _
	)As HRESULT

	Dim strValue As WString * (64) = Any
	itow(Value, @strValue, 10)
	
	Return ArrayStringWriterWriteString(this, @strValue)
	
End Function

Function ArrayStringWriterWriteInt64( _
		ByVal this As ArrayStringWriter Ptr, _
		ByVal Value As LongInt _
	)As HRESULT

	Dim strValue As WString * (64) = Any
	i64tow(Value, @strValue, 10)
	
	Return ArrayStringWriterWriteString(this, @strValue)
	
End Function

Function ArrayStringWriterWriteUInt64( _
		ByVal this As ArrayStringWriter Ptr, _
		ByVal Value As ULongInt _
	)As HRESULT

	Dim strValue As WString * (64) = Any
	ui64tow(Value, @strValue, 10)
	
	Return ArrayStringWriterWriteString(this, @strValue)
	
End Function

Function ArrayStringWriterGetCodePage( _
		ByVal this As ArrayStringWriter Ptr, _
		ByVal CodePage As Integer Ptr _
	)As HRESULT
	
	*CodePage = this->CodePage
	
	Return S_OK
	
End Function

Function ArrayStringWriterSetCodePage( _
		ByVal this As ArrayStringWriter Ptr, _
		ByVal CodePage As Integer _
	)As HRESULT
	
	this->CodePage = CodePage
	
	Return S_OK
	
End Function

Function ArrayStringWriterCloseTextWriter( _
		ByVal this As ArrayStringWriter Ptr _
	)As HRESULT
	
	Return S_OK
	
End Function

Function ArrayStringWriterSetBuffer( _
		ByVal this As ArrayStringWriter Ptr, _
		ByVal Buffer As WString Ptr, _
		ByVal MaxBufferLength As Integer _
	)As HRESULT
	
	this->MaxBufferLength = MaxBufferLength
	this->Buffer = Buffer
	this->BufferLength = 0
	this->Buffer[0] = 0
	
	Return S_OK
	
End Function
