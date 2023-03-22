#include once "ClientBuffer.bi"
#include once "HeapBSTR.bi"

Const DoubleNewLineStringA = Str(!"\r\n\r\n")
Const NewLineStringA = Str(!"\r\n")

Sub InitializeClientRequestBuffer( _
		ByVal pBuffer As ClientRequestBuffer Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@pBuffer->IdString, _
			@Str(RTTI_ID_CLIENTREQUESTBUFFER), _
			Len(ClientRequestBuffer.IdString) _
		)
	#endif
	' No Need ZeroMemory pBuffer.Bytes
	pBuffer->cbLength = 0
	pBuffer->EndOfHeaders = 0
	
End Sub

Function ClientRequestBufferGetFreeSpaceLength( _
		ByVal pBuffer As ClientRequestBuffer Ptr _
	)As Integer
	
	Dim FreeSpace As Integer = RAWBUFFER_CAPACITY - pBuffer->cbLength
	
	Return FreeSpace
	
End Function

Function FindStringA( _
		ByVal pBuffer As UByte Ptr, _
		ByVal BufferLength As Integer, _
		ByVal pStr As UByte Ptr, _
		ByVal Length As Integer _
	)As UByte Ptr
	
	Dim BytesCount As Integer = Length * SizeOf(UByte)
	
	For i As Integer = 0 To BufferLength - Length
		Dim pDestination As UByte Ptr = @pBuffer[i]
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
		ByVal pBuffer As ClientRequestBuffer Ptr, _
		ByVal pFindIndex As Integer Ptr _
	)As Boolean
	
	Dim pDoubleCrLf As UByte Ptr = FindStringA( _
		@pBuffer->Bytes(0), _
		pBuffer->cbLength, _
		@DoubleNewLineStringA, _
		Len(DoubleNewLineStringA) _
	)
	If pDoubleCrLf = NULL Then
		*pFindIndex = 0
		Return False
	End If
	
	Dim FindIndex As Integer = pDoubleCrLf - @pBuffer->Bytes(0)
	*pFindIndex = FindIndex
	
	Return True
	
End Function

Function ClientRequestBufferFindCrLfIndexA( _
		ByVal pBuffer As ClientRequestBuffer Ptr, _
		ByVal pFindIndex As Integer Ptr _
	)As Boolean
	
	Dim pCrLf As UByte Ptr = FindStringA( _
		@pBuffer->Bytes(pBuffer->StartLine), _
		pBuffer->EndOfHeaders, _
		@NewLineStringA, _
		Len(NewLineStringA) _
	)
	If pCrLf = NULL Then
		*pFindIndex = 0
		Return False
	End If
	
	Dim FindIndex As Integer = pCrLf - @pBuffer->Bytes(pBuffer->StartLine)
	*pFindIndex = FindIndex
	
	Return True
	
End Function

Function ClientRequestBufferGetLine( _
		ByVal pBuffer As ClientRequestBuffer Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As HeapBSTR
	
	Dim CrLfIndex As Integer = Any
	Dim Finded As Boolean = ClientRequestBufferFindCrLfIndexA( _
		pBuffer, _
		@CrLfIndex _
	)
	If Finded = False Then
		Return NULL
	End If
	
	' TODO Проверить, начинается ли строка за CrLf с пробела
	' Если начинается — объединить обе строки
	
	Dim LineLength As Integer = CrLfIndex
	Dim StartLineIndex As Integer = pBuffer->StartLine
	
	Dim bstrLine As HeapBSTR = CreateHeapZStringLen( _
		pIMemoryAllocator, _
		@pBuffer->Bytes(StartLineIndex), _
		LineLength _
	)
	If bstrLine = NULL Then
		Return NULL
	End If
	
	Dim NewStartIndex As Integer = StartLineIndex + LineLength + Len(NewLineStringA)
	pBuffer->StartLine = NewStartIndex
	
	Return bstrLine
	
End Function

Sub ClientRequestBufferClear( _
		ByVal this As ClientRequestBuffer Ptr _
	)
	
	this->cbLength = 0
	this->EndOfHeaders = 0
	
End Sub
