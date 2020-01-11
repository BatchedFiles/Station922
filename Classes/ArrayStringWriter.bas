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
		ByVal pArrayStringWriter As ArrayStringWriter Ptr _
	)
	
	pArrayStringWriter->pVirtualTable = @GlobalArrayStringWriterVirtualTable
	pArrayStringWriter->ReferenceCounter = 0
	pArrayStringWriter->CodePage = 1200
	pArrayStringWriter->MaxBufferLength = 0
	pArrayStringWriter->BufferLength = 0
	pArrayStringWriter->Buffer = 0
	
End Sub

Function InitializeArrayStringWriterOfIArrayStringWriter( _
		ByVal pArrayStringWriter As ArrayStringWriter Ptr _
	)As IArrayStringWriter Ptr
	
	InitializeArrayStringWriter(pArrayStringWriter)
	pArrayStringWriter->ExistsInStack = True
	
	Dim pIWriter As IArrayStringWriter Ptr = Any
	
	ArrayStringWriterQueryInterface( _
		pArrayStringWriter, @IID_IArrayStringWriter, @pIWriter _
	)
	
	Return pIWriter
	
End Function

Function ArrayStringWriterQueryInterface( _
		ByVal pArrayStringWriter As ArrayStringWriter Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IArrayStringWriter, riid) Then
		*ppv = @pArrayStringWriter->pVirtualTable
	Else
		If IsEqualIID(@IID_ITextWriter, riid) Then
			*ppv = @pArrayStringWriter->pVirtualTable
		Else
			If IsEqualIID(@IID_IUnknown, riid) Then
				*ppv = @pArrayStringWriter->pVirtualTable
			Else
				*ppv = NULL
				Return E_NOINTERFACE
			End If
		End If
	End If
	
	ArrayStringWriterAddRef(pArrayStringWriter)
	
	Return S_OK
	
End Function

Function ArrayStringWriterAddRef( _
		ByVal pArrayStringWriter As ArrayStringWriter Ptr _
	)As ULONG
	
	pArrayStringWriter->ReferenceCounter += 1
	
	Return pArrayStringWriter->ReferenceCounter
	
End Function

Function ArrayStringWriterRelease( _
		ByVal pArrayStringWriter As ArrayStringWriter Ptr _
	)As ULONG
	
	pArrayStringWriter->ReferenceCounter -= 1
	
	If pArrayStringWriter->ReferenceCounter = 0 Then
		
		If pArrayStringWriter->ExistsInStack = False Then
		
		End If
		
		Return 0
	End If
	
	Return pArrayStringWriter->ReferenceCounter
	
End Function

Function ArrayStringWriterWriteLengthString( _
		ByVal pArrayStringWriter As ArrayStringWriter Ptr, _
		ByVal w As WString Ptr, _
		ByVal Length As Integer _
	)As HRESULT
	
	If pArrayStringWriter->BufferLength + Length > pArrayStringWriter->MaxBufferLength Then
		Return E_OUTOFMEMORY
	End If
	
	lstrcpyn(@pArrayStringWriter->Buffer[pArrayStringWriter->BufferLength], w, Length + 1)
	pArrayStringWriter->BufferLength += Length
	
	Return S_OK
	
End Function

Function ArrayStringWriterWriteNewLine( _
		ByVal pArrayStringWriter As ArrayStringWriter Ptr _
	)As HRESULT
	
	Return ArrayStringWriterWriteLengthString(pArrayStringWriter, @NewLineString, 2)
	
End Function

Function ArrayStringWriterWriteString( _
		ByVal pArrayStringWriter As ArrayStringWriter Ptr, _
		ByVal w As WString Ptr _
	)As HRESULT
	
	Return ArrayStringWriterWriteLengthString(pArrayStringWriter, w, lstrlen(w))
	
End Function

Function ArrayStringWriterWriteLengthStringLine( _
		ByVal pArrayStringWriter As ArrayStringWriter Ptr, _
		ByVal w As WString Ptr, _
		ByVal Length As Integer _
	)As HRESULT
	
	If FAILED(ArrayStringWriterWriteLengthString(pArrayStringWriter, w, Length)) Then
		Return E_OUTOFMEMORY
	End If
	
	If FAILED(ArrayStringWriterWriteNewLine(pArrayStringWriter)) Then
		Return E_OUTOFMEMORY
	End If
	
	Return S_OK
	
End Function

Function ArrayStringWriterWriteStringLine( _
		ByVal pArrayStringWriter As ArrayStringWriter Ptr, _
		ByVal w As WString Ptr _
	)As HRESULT
	
	Return ArrayStringWriterWriteLengthStringLine(pArrayStringWriter, w, lstrlen(w))
	
End Function

Function ArrayStringWriterWriteChar( _
		ByVal pArrayStringWriter As ArrayStringWriter Ptr, _
		ByVal wc As wchar_t _
	)As HRESULT
	
	If pArrayStringWriter->BufferLength + 1 > pArrayStringWriter->MaxBufferLength Then
		Return E_OUTOFMEMORY
	End If
	
	pArrayStringWriter->Buffer[pArrayStringWriter->BufferLength] = wc
	pArrayStringWriter->Buffer[pArrayStringWriter->BufferLength + 1] = 0
	pArrayStringWriter->BufferLength += 1
	
	Return S_OK
	
End Function

Function ArrayStringWriterWriteInt32( _
		ByVal pArrayStringWriter As ArrayStringWriter Ptr, _
		ByVal Value As Long _
	)As HRESULT

	Dim strValue As WString * (64) = Any
	itow(Value, @strValue, 10)
	
	Return ArrayStringWriterWriteString(pArrayStringWriter, @strValue)
	
End Function

Function ArrayStringWriterWriteInt64( _
		ByVal pArrayStringWriter As ArrayStringWriter Ptr, _
		ByVal Value As LongInt _
	)As HRESULT

	Dim strValue As WString * (64) = Any
	i64tow(Value, @strValue, 10)
	
	Return ArrayStringWriterWriteString(pArrayStringWriter, @strValue)
	
End Function

Function ArrayStringWriterWriteUInt64( _
		ByVal pArrayStringWriter As ArrayStringWriter Ptr, _
		ByVal Value As ULongInt _
	)As HRESULT

	Dim strValue As WString * (64) = Any
	ui64tow(Value, @strValue, 10)
	
	Return ArrayStringWriterWriteString(pArrayStringWriter, @strValue)
	
End Function

Function ArrayStringWriterGetCodePage( _
		ByVal pArrayStringWriter As ArrayStringWriter Ptr, _
		ByVal CodePage As Integer Ptr _
	)As HRESULT
	
	*CodePage = pArrayStringWriter->CodePage
	
	Return S_OK
	
End Function

Function ArrayStringWriterSetCodePage( _
		ByVal pArrayStringWriter As ArrayStringWriter Ptr, _
		ByVal CodePage As Integer _
	)As HRESULT
	
	pArrayStringWriter->CodePage = CodePage
	
	Return S_OK
	
End Function

Function ArrayStringWriterCloseTextWriter( _
		ByVal pArrayStringWriter As ArrayStringWriter Ptr _
	)As HRESULT
	
	Return S_OK
	
End Function

Function ArrayStringWriterSetBuffer( _
		ByVal pArrayStringWriter As ArrayStringWriter Ptr, _
		ByVal Buffer As WString Ptr, _
		ByVal MaxBufferLength As Integer _
	)As HRESULT
	
	pArrayStringWriter->MaxBufferLength = MaxBufferLength
	pArrayStringWriter->Buffer = Buffer
	pArrayStringWriter->BufferLength = 0
	pArrayStringWriter->Buffer[0] = 0
	
	Return S_OK
	
End Function
