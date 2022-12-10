#include once "ArrayStringWriter.bi"
#include once "windows.bi"

Const NewLineString = WStr(!"\r\n")

Sub InitializeArrayStringWriter( _
		ByVal this As ArrayStringWriter Ptr _
	)
	
	this->CodePage = 1200
	this->Capacity = 0
	this->BufferLength = 0
	this->Buffer = NULL
	
End Sub

Function ArrayStringWriter.WriteLengthString( _
		ByVal w As WString Ptr, _
		ByVal Length As Integer _
	)As Boolean
	
	If BufferLength + Length > Capacity Then
		Return False
	End If
	
	lstrcpynW(@Buffer[BufferLength], w, Length + 1)
	BufferLength += Length
	
	Return True
	
End Function

Function ArrayStringWriter.WriteNewLine( _
	)As Boolean
	
	Dim resResult As Boolean = WriteLengthString(@NewLineString, Len(NewLineString))
	
	Return resResult
	
End Function

Function ArrayStringWriter.WriteString( _
		ByVal w As WString Ptr _
	)As Boolean
	
	Dim resResult As Boolean = WriteLengthString(w, lstrlenW(w))
	
	Return resResult
	
End Function

Function ArrayStringWriter.WriteLengthStringLine( _
		ByVal w As WString Ptr, _
		ByVal Length As Integer _
	)As Boolean
	
	Dim resWriteLengthString As Boolean = WriteLengthString(w, Length)
	If resWriteLengthString = False Then
		Return False
	End If
	
	Dim resWriteNewLine As Boolean = WriteNewLine()
	If resWriteNewLine = False Then
		Return False
	End If
	
	Return True
	
End Function

Function ArrayStringWriter.WriteStringLine( _
		ByVal w As WString Ptr _
	)As Boolean
	
	Dim resResult As Boolean = WriteLengthStringLine(w, lstrlenW(w))
	
	Return resResult
	
End Function

Function ArrayStringWriter.WriteChar( _
		ByVal wc As Integer _
	)As Boolean
	
	If BufferLength + 1 > Capacity Then
		Return False
	End If
	
	Buffer[BufferLength] = wc
	Buffer[BufferLength + 1] = 0
	BufferLength += 1
	
	Return True
	
End Function

Function ArrayStringWriter.WriteInt32( _
		ByVal Value As Long _
	)As Boolean

	Dim strValue As WString * (64) = Any
	_itow(Value, @strValue, 10)
	
	Dim resResult As Boolean = WriteString(@strValue)
	
	Return resResult
	
End Function

Function ArrayStringWriter.WriteUInt32( _
		ByVal Value As ULong _
	)As Boolean

	Dim strValue As WString * (64) = Any
	Dim ulValue As ULongInt = Cast(ULongInt, Value)
	_ui64tow(ulValue, @strValue, 16)
	
	Dim resResult As Boolean = WriteString(@strValue)
	
	Return resResult
	
End Function

Function ArrayStringWriter.WriteInt64( _
		ByVal Value As LongInt _
	)As Boolean

	Dim strValue As WString * (64) = Any
	_i64tow(Value, @strValue, 10)
	
	Dim resResult As Boolean = WriteString(@strValue)
	
	Return resResult
	
End Function

Function ArrayStringWriter.WriteUInt64( _
		ByVal Value As ULongInt _
	)As Boolean

	Dim strValue As WString * (64) = Any
	_ui64tow(Value, @strValue, 10)
	
	Dim resResult As Boolean = WriteString(@strValue)
	
	Return resResult
	
End Function

Function ArrayStringWriter.GetCodePage( _
	)As Integer
	
	Return CodePage
	
End Function

Sub ArrayStringWriter.SetCodePage( _
		ByVal CodePage As Integer _
	)
	
	this.CodePage = CodePage
	
End Sub

Sub ArrayStringWriter.SetBuffer( _
		ByVal Buffer As WString Ptr, _
		ByVal Capacity As Integer _
	)
	
	this.Capacity = Capacity
	this.Buffer = Buffer
	this.BufferLength = 0
	this.Buffer[0] = 0
	
End Sub

Function ArrayStringWriter.GetLength( _
	)As Integer
	
	Return BufferLength
	
End Function
