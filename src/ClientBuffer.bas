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

Function ClientRequestBufferFindDoubleCrLfIndexA( _
		ByVal pBufer As ClientRequestBuffer Ptr, _
		ByVal pFindIndex As Integer Ptr _
	)As Boolean
	
	For i As Integer = 0 To pBufer->cbLength - Len(DoubleNewLineStringA)
		
		Dim Destination As UByte Ptr = @pBufer->Bytes(i)
		Dim Finded As BOOL = RtlEqualMemory( _
			Destination, _
			@DoubleNewLineStringA, _
			Len(DoubleNewLineStringA) * SizeOf(ZString) _
		)
		
		If Finded Then
			*pFindIndex = i
			Return True
		End If
		
	Next
	
	*pFindIndex = 0
	Return False
	
End Function

Function ClientRequestBufferFindCrLfIndexA( _
		ByVal pBufer As ClientRequestBuffer Ptr, _
		ByVal pFindIndex As Integer Ptr _
	)As Boolean
	
	For i As Integer = pBufer->StartLine To pBufer->EndOfHeaders - Len(NewLineStringA)
		
		Dim Destination As UByte Ptr = @pBufer->Bytes(i)
		Dim Finded As BOOL = RtlEqualMemory( _
			Destination, _
			@NewLineStringA, _
			Len(NewLineStringA) * SizeOf(ZString) _
		)
		
		If Finded Then
			Dim FindIndex As Integer = i - pBufer->StartLine
			*pFindIndex = FindIndex
			Return True
		End If
		
	Next
	
	*pFindIndex = 0
	Return False
	
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
	
	If LineLength = 0 Then
		Return NULL
	End If
	
	Dim StartLineIndex As Integer = pBufer->StartLine
	
	Dim bstrLine As HeapBSTR = CreateHeapZStringLen( _
		pIMemoryAllocator, _
		@pBufer->Bytes(StartLineIndex), _
		LineLength _
	)
	
	Dim NewStartIndex As Integer = StartLineIndex + LineLength + Len(NewLineStringA)
	pBufer->StartLine = NewStartIndex
	
	Return bstrLine
	
End Function
