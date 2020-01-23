#include "HttpReader.bi"
#include "FindNewLineIndex.bi"
#include "StringConstants.bi"

Dim Shared GlobalHttpReaderVirtualTable As IHttpReaderVirtualTable

Sub InitializeHttpReaderVirtualTable()
	' TODO Реализовать функции HttpReader
	GlobalHttpReaderVirtualTable.InheritedTable.InheritedTable.QueryInterface = @HttpReaderQueryInterface
	GlobalHttpReaderVirtualTable.InheritedTable.InheritedTable.AddRef = @HttpReaderAddRef
	GlobalHttpReaderVirtualTable.InheritedTable.InheritedTable.Release = @HttpReaderRelease
	GlobalHttpReaderVirtualTable.InheritedTable.Peek = NULL
	GlobalHttpReaderVirtualTable.InheritedTable.ReadChar = NULL
	GlobalHttpReaderVirtualTable.InheritedTable.ReadCharArray = NULL
	GlobalHttpReaderVirtualTable.InheritedTable.ReadLine = @HttpReaderReadLine
	GlobalHttpReaderVirtualTable.InheritedTable.ReadToEnd = NULL
	GlobalHttpReaderVirtualTable.Clear = @HttpReaderClear
	GlobalHttpReaderVirtualTable.GetBaseStream = @HttpReaderGetBaseStream
	GlobalHttpReaderVirtualTable.SetBaseStream = @HttpReaderSetBaseStream
	GlobalHttpReaderVirtualTable.GetPreloadedBytes = @HttpReaderGetPreloadedBytes
	GlobalHttpReaderVirtualTable.GetRequestedBytes = @HttpReaderGetRequestedBytes
End Sub

Sub InitializeHttpReader( _
		ByVal pHttpReader As HttpReader Ptr _
	)
	
	pHttpReader->pVirtualTable = @GlobalHttpReaderVirtualTable
	pHttpReader->ReferenceCounter = 0
	
	pHttpReader->pIStream = NULL
	pHttpReader->Buffer[0] = 0
	pHttpReader->Buffer[HttpReader.MaxBufferLength] = 0
	pHttpReader->BufferLength = 0
	pHttpReader->LinesBuffer[0] = 0
	pHttpReader->LinesBufferLength = 0
	pHttpReader->IsAllBytesReaded = False
	pHttpReader->StartLineIndex = 0
	
End Sub

Sub UnInitializeHttpReader( _
		ByVal pHttpReader As HttpReader Ptr _
	)
	
	If pHttpReader->pIStream <> NULL Then
		IBaseStream_Release(pHttpReader->pIStream)
	End If
	
End Sub

Function CreateHttpReader( _
	)As HttpReader Ptr
	
	Dim pReader As HttpReader Ptr = HeapAlloc( _
		GetProcessHeap(), _
		0, _
		SizeOf(HttpReader) _
	)
	
	If pReader = NULL Then
		Return NULL
	End If
	
	InitializeHttpReader(pReader)
	
	Return pReader
	
End Function

Sub DestroyHttpReader( _
		ByVal pReader As HttpReader Ptr _
	)
	
	UnInitializeHttpReader(pReader)
	
	HeapFree(GetProcessHeap(), 0, pReader)
	
End Sub

Function HttpReaderQueryInterface( _
		ByVal pHttpReader As HttpReader Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IHttpReader, riid) Then
		*ppv = @pHttpReader->pVirtualTable
	Else
		If IsEqualIID(@IID_ITextReader, riid) Then
			*ppv = @pHttpReader->pVirtualTable
		Else
			If IsEqualIID(@IID_IUnknown, riid) Then
				*ppv = @pHttpReader->pVirtualTable
			Else
				*ppv = NULL
				Return E_NOINTERFACE
			End If
		End If
	End If
	
	HttpReaderAddRef(pHttpReader)
	
	Return S_OK
	
End Function

Function HttpReaderAddRef( _
		ByVal pHttpReader As HttpReader Ptr _
	)As ULONG
	
	pHttpReader->ReferenceCounter += 1
	
	Return pHttpReader->ReferenceCounter
	
End Function

Function HttpReaderRelease( _
		ByVal pHttpReader As HttpReader Ptr _
	)As ULONG
	
	pHttpReader->ReferenceCounter -= 1
	
	If pHttpReader->ReferenceCounter = 0 Then
		
		DestroyHttpReader(pHttpReader)
		
		Return 0
	End If
	
	Return pHttpReader->ReferenceCounter
	
End Function

Function HttpReaderReadAllBytes( _
		ByVal pHttpReader As HttpReader Ptr, _
		ByVal pDoubleCrLfIndex As Integer Ptr _
	)As HRESULT
	
	Dim DoubleCrLfIndex As Integer = Any
	Dim FindResult As Boolean = Any
	
	Do
		Dim ReceivedBytesCount As Integer = Any
		
		Dim hr As HRESULT = IBaseStream_Read( _
			pHttpReader->pIStream, _
			@pHttpReader->Buffer, _
			pHttpReader->BufferLength, _
			HttpReader.MaxBufferLength - pHttpReader->BufferLength, _
			@ReceivedBytesCount _
		)
		
		If FAILED(hr) Then
			Return HTTPREADER_E_SOCKETERROR
		End If
		
		If hr = S_FALSE Then
			Return HTTPREADER_E_CLIENTCLOSEDCONNECTION
		End If
		
		pHttpReader->BufferLength += ReceivedBytesCount
		pHttpReader->Buffer[pHttpReader->BufferLength] = 0
		
		If pHttpReader->BufferLength >= HttpReader.MaxBufferLength Then
			Return HTTPREADER_E_INTERNALBUFFEROVERFLOW
		End If
		
		FindResult = FindDoubleCrLfIndexA( _
			@pHttpReader->Buffer, _
			pHttpReader->BufferLength, _
			@DoubleCrLfIndex _
		)
		
	Loop While FindResult = False
	
	*pDoubleCrLfIndex = DoubleCrLfIndex
	pHttpReader->IsAllBytesReaded = True
	
	Return S_OK
	
End Function

Function HttpReaderConvertBytesToString( _
		ByVal pHttpReader As HttpReader Ptr, _
		ByVal DoubleCrLfIndex As Integer _
	)As HRESULT
	
	Const dwFlags As DWORD = 0
	
	Dim CharsLength As Integer = MultiByteToWideChar( _
		CP_UTF8, _
		dwFlags, _
		@pHttpReader->Buffer, _
		DoubleCrLfIndex + 2 * NewLineStringLength, _
		@pHttpReader->LinesBuffer, _
		HttpReader.MaxBufferLength _
	)
	
	pHttpReader->LinesBufferLength = CharsLength
	pHttpReader->LinesBuffer[CharsLength] = 0
	
	If CharsLength = 0 Then
		Dim dwError As DWORD = GetLastError()
		Return HTTPREADER_E_BUFFERTOOSMALL
	End If
	
	Return S_OK
	
End Function

Function HttpReaderReadLine( _
		ByVal pHttpReader As HttpReader Ptr, _
		ByVal pLineLength As Integer Ptr, _
		ByVal pLine As WString Ptr Ptr _
	)As HRESULT
	
	If pHttpReader->IsAllBytesReaded = False Then
		
		Dim DoubleCrLfIndex As Integer = Any
		Dim hr As HRESULT = HttpReaderReadAllBytes(pHttpReader, @DoubleCrLfIndex)
		
		If FAILED(hr) Then
			*pLineLength = 0
			*pLine = @pHttpReader->LinesBuffer
			Return hr
		End If
		
		hr = HttpReaderConvertBytesToString(pHttpReader, DoubleCrLfIndex)
		
		If FAILED(hr) Then
			*pLineLength = 0
			*pLine = @pHttpReader->LinesBuffer
			Return hr
		End If
		
	End If
	
	' Найти CrLf
	Dim CrLfIndex As Integer = Any
	
	FindCrLfIndexW( _
		@pHttpReader->LinesBuffer[pHttpReader->StartLineIndex], _
		pHttpReader->LinesBufferLength - pHttpReader->StartLineIndex, _
		@CrLfIndex _
	)
	
	*pLineLength = CrLfIndex
	*pLine = @pHttpReader->LinesBuffer[pHttpReader->StartLineIndex]
	
	pHttpReader->LinesBuffer[pHttpReader->StartLineIndex + CrLfIndex] = 0
	pHttpReader->StartLineIndex += CrLfIndex + NewLineStringLength
	
	Return S_OK
	
	' TODO Проверить, начинается ли строка за CrLf с пробела
	' Если начинается — сдвинуть до начала непробела
	
	' If pLine[0] = Characters.WhiteSpace Then
		' Do
			' pLine += 1
		' Loop While pLine[0] = Characters.WhiteSpace
		
		' lstrcat(pClientRequest->RequestHeaders(PreviousHeaderIndex), pLine)
		
	' End If
	
End Function

Function HttpReaderClear( _
		ByVal pHttpReader As HttpReader Ptr _
	)As HRESULT
	
	If pHttpReader->StartLineIndex <> 0 Then
		
		If pHttpReader->BufferLength - pHttpReader->StartLineIndex <= 0 Then
			pHttpReader->Buffer[0] = 0
			pHttpReader->BufferLength = 0
		Else
			RtlMoveMemory( _
				@pHttpReader->Buffer, _
				@pHttpReader->Buffer[pHttpReader->StartLineIndex], _
				HttpReader.MaxBufferLength - pHttpReader->StartLineIndex + 1 _
			)
			pHttpReader->BufferLength -= pHttpReader->StartLineIndex
		End If
		
		pHttpReader->StartLineIndex = 0
	End If
	
	pHttpReader->LinesBuffer[0] = 0
	pHttpReader->LinesBufferLength = 0
	pHttpReader->IsAllBytesReaded = False
	pHttpReader->StartLineIndex = 0
	
	Return S_OK
	
End Function

Function HttpReaderGetBaseStream( _
		ByVal pHttpReader As HttpReader Ptr, _
		ByVal ppResult As IBaseStream Ptr Ptr _
	)As HRESULT
	
	If pHttpReader->pIStream = NULL Then
		*ppResult = NULL
		Return S_FALSE
	End If
	
	IBaseStream_AddRef(pHttpReader->pIStream)
	*ppResult = pHttpReader->pIStream
	
	Return S_OK
	
End Function

Function HttpReaderSetBaseStream( _
		ByVal pHttpReader As HttpReader Ptr, _
		ByVal pIStream As IBaseStream Ptr _
	)As HRESULT
	
	If pHttpReader->pIStream <> NULL Then
		IBaseStream_Release(pHttpReader->pIStream)
	End If
	
	If pIStream <> NULL Then
		IBaseStream_AddRef(pIStream)
	End If
	
	pHttpReader->pIStream = pIStream
	
	Return S_OK
	
End Function

Function HttpReaderGetPreloadedBytes( _
		ByVal pHttpReader As HttpReader Ptr, _
		ByVal pPreloadedBytesLength As Integer Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As HRESULT
	
	*pPreloadedBytesLength = pHttpReader->BufferLength - pHttpReader->StartLineIndex
	*ppPreloadedBytes = @pHttpReader->Buffer[pHttpReader->StartLineIndex]
	
	Return S_OK
	
End Function

Function HttpReaderGetRequestedBytes( _
		ByVal pHttpReader As HttpReader Ptr, _
		ByVal pRequestedBytesLength As Integer Ptr, _
		ByVal ppRequestedBytes As UByte Ptr Ptr _
	)As HRESULT
	
	*pRequestedBytesLength = pHttpReader->BufferLength
	*ppRequestedBytes = @pHttpReader->Buffer
	
	Return S_OK
	
End Function
