#include once "ClientBuffer.bi"
#include once "HeapBSTR.bi"

Const DoubleNewLineStringA = Str(!"\r\n\r\n")
Const NewLineStringA = Str(!"\r\n")

Sub InitializeClientRequestBuffer( _
		ByVal this As ClientRequestBuffer Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->RttiClassName(0), _
			@Str(RTTI_ID_CLIENTREQUESTBUFFER), _
			UBound(this->RttiClassName) - LBound(this->RttiClassName) + 1 _
		)
	#endif
	' No Need ZeroMemory this.Bytes
	this->cbLength = 0
	this->EndOfHeaders = 0
	
End Sub

Function ClientRequestBufferGetFreeSpaceLength( _
		ByVal this As ClientRequestBuffer Ptr _
	)As Integer
	
	Dim FreeSpace As Integer = RAWBUFFER_CAPACITY - this->cbLength
	
	Return FreeSpace
	
End Function

Private Function FindStringA( _
		ByVal buffer As UByte Ptr, _
		ByVal BufferLength As Integer, _
		ByVal pStr As UByte Ptr, _
		ByVal Length As Integer _
	)As UByte Ptr
	
	Dim BytesCount As Integer = Length * SizeOf(UByte)
	
	For i As Integer = 0 To BufferLength - Length
		Dim pDestination As UByte Ptr = @buffer[i]
		Dim Finded As Long = memcmp( _
			pDestination, _
			pStr, _
			BytesCount _
		)
		If Finded = 0 Then
			Return pDestination
		End If
	Next
	
	Return NULL
	
End Function

Function ClientRequestBufferFindDoubleCrLfIndexA( _
		ByVal this As ClientRequestBuffer Ptr, _
		ByVal pFindIndex As Integer Ptr _
	)As Boolean
	
	Dim pDoubleCrLf As UByte Ptr = FindStringA( _
		@this->Bytes(0), _
		this->cbLength, _
		@DoubleNewLineStringA, _
		Len(DoubleNewLineStringA) _
	)
	If pDoubleCrLf = NULL Then
		*pFindIndex = 0
		Return False
	End If
	
	Dim FindIndex As Integer = pDoubleCrLf - @this->Bytes(0)
	*pFindIndex = FindIndex
	
	Return True
	
End Function

Function ClientRequestBufferFindCrLfIndexA( _
		ByVal this As ClientRequestBuffer Ptr, _
		ByVal pFindIndex As Integer Ptr _
	)As Boolean
	
	Dim pCrLf As UByte Ptr = FindStringA( _
		@this->Bytes(this->StartLine), _
		this->EndOfHeaders, _
		@NewLineStringA, _
		Len(NewLineStringA) _
	)
	If pCrLf = NULL Then
		*pFindIndex = 0
		Return False
	End If
	
	Dim FindIndex As Integer = pCrLf - @this->Bytes(this->StartLine)
	*pFindIndex = FindIndex
	
	Return True
	
End Function

Function ClientRequestBufferGetLine( _
		ByVal this As ClientRequestBuffer Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As HeapBSTR
	
	Dim CrLfIndex As Integer = Any
	Dim Finded As Boolean = ClientRequestBufferFindCrLfIndexA( _
		this, _
		@CrLfIndex _
	)
	If Finded = False Then
		Return NULL
	End If
	
	' TODO Проверить, начинается ли строка за CrLf с пробела
	' Если начинается — объединить обе строки
	
	Dim LineLength As Integer = CrLfIndex
	Dim StartLineIndex As Integer = this->StartLine
	
	Dim bstrLine As HeapBSTR = CreateHeapZStringLen( _
		pIMemoryAllocator, _
		@this->Bytes(StartLineIndex), _
		LineLength _
	)
	If bstrLine = NULL Then
		Return NULL
	End If
	
	Dim NewStartIndex As Integer = StartLineIndex + LineLength + Len(NewLineStringA)
	this->StartLine = NewStartIndex
	
	Return bstrLine
	
End Function

Sub ClientRequestBufferClear( _
		ByVal this As ClientRequestBuffer Ptr _
	)
	
	this->cbLength = 0
	this->EndOfHeaders = 0
	
End Sub
