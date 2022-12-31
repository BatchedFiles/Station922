#include once "ClientBuffer.bi"
#include once "HeapBSTR.bi"

Const DoubleNewLineStringA = Str(!"\r\n\r\n")
Const NewLineStringA = Str(!"\r\n")

Sub InitializeClientRequestBuffer( _
		ByVal pBufer As ClientRequestBuffer Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@pBufer->IdString, _
			@Str(RTTI_ID_CLIENTREQUESTBUFFER), _
			Len(ClientRequestBuffer.IdString) _
		)
	#endif
	' No Need ZeroMemory pBufer.Bytes
	pBufer->cbLength = 0
	pBufer->EndOfHeaders = 0
	
End Sub

Function ClientRequestBufferGetFreeSpaceLength( _
		ByVal pBufer As ClientRequestBuffer Ptr _
	)As Integer
	
	Dim FreeSpace As Integer = RAWBUFFER_CAPACITY - pBufer->cbLength
	
	Return FreeSpace
	
End Function

Function FindStringA( _
		ByVal pBufer As UByte Ptr, _
		ByVal BufferLength As Integer, _
		ByVal pStr As UByte Ptr, _
		ByVal Length As Integer _
	)As UByte Ptr
	
	Dim BytesCount As Integer = Length * SizeOf(UByte)
	
	For i As Integer = 0 To BufferLength - Length
		Dim pDestination As UByte Ptr = @pBufer[i]
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
		ByVal pBufer As ClientRequestBuffer Ptr, _
		ByVal pFindIndex As Integer Ptr _
	)As Boolean
	
	Dim pDoubleCrLf As UByte Ptr = FindStringA( _
		@pBufer->Bytes(0), _
		pBufer->cbLength, _
		@DoubleNewLineStringA, _
		Len(DoubleNewLineStringA) _
	)
	If pDoubleCrLf = NULL Then
		*pFindIndex = 0
		Return False
	End If
	
	Dim FindIndex As Integer = pDoubleCrLf - @pBufer->Bytes(0)
	*pFindIndex = FindIndex
	
	Return True
	
End Function

Function ClientRequestBufferFindCrLfIndexA( _
		ByVal pBufer As ClientRequestBuffer Ptr, _
		ByVal pFindIndex As Integer Ptr _
	)As Boolean
	
	Dim pCrLf As UByte Ptr = FindStringA( _
		@pBufer->Bytes(pBufer->StartLine), _
		pBufer->EndOfHeaders, _
		@NewLineStringA, _
		Len(NewLineStringA) _
	)
	If pCrLf = NULL Then
		*pFindIndex = 0
		Return False
	End If
	
	Dim FindIndex As Integer = pCrLf - @pBufer->Bytes(pBufer->StartLine)
	*pFindIndex = FindIndex
	
	Return True
	
End Function

Function ClientRequestBufferGetLine( _
		ByVal pBufer As ClientRequestBuffer Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As HeapBSTR
	
	Dim CrLfIndex As Integer = Any
	Dim Finded As Boolean = ClientRequestBufferFindCrLfIndexA( _
		pBufer, _
		@CrLfIndex _
	)
	If Finded = False Then
		Return NULL
	End If
	
	' TODO Проверить, начинается ли строка за CrLf с пробела
	' Если начинается — объединить обе строки
	
	Dim LineLength As Integer = CrLfIndex
	Dim StartLineIndex As Integer = pBufer->StartLine
	
	Dim bstrLine As HeapBSTR = CreateHeapZStringLen( _
		pIMemoryAllocator, _
		@pBufer->Bytes(StartLineIndex), _
		LineLength _
	)
	If bstrLine = NULL Then
		Return NULL
	End If
	
	Dim NewStartIndex As Integer = StartLineIndex + LineLength + Len(NewLineStringA)
	pBufer->StartLine = NewStartIndex
	
	Return bstrLine
	
End Function

Sub ClientRequestBufferClear( _
		ByVal this As ClientRequestBuffer Ptr _
	)
	
	Dim cbPreloadedBytes As Integer = this->cbLength - this->EndOfHeaders
	
	If cbPreloadedBytes Then
		Dim Index As Integer = this->EndOfHeaders
		Dim Destination As UByte Ptr = @this->Bytes(0)
		Dim Source As UByte Ptr = @this->Bytes(Index)
		MoveMemory( _
			Destination, _
			Source, _
			cbPreloadedBytes _
		)
		this->EndOfHeaders = 0
		this->cbLength = cbPreloadedBytes
	Else
		this->EndOfHeaders = 0
		this->cbLength = 0
	End If
	
End Sub
