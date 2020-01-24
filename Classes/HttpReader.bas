#include "HttpReader.bi"
#include "FindNewLineIndex.bi"
#include "StringConstants.bi"

Type _HttpReader
	
	Dim pVirtualTable As IHttpReaderVirtualTable Ptr
	Dim ReferenceCounter As ULONG
	Dim hHeap As HANDLE
	
	Dim pIStream As IBaseStream Ptr
	
	Dim Buffer As ZString * (HTTPREADER_MAXBUFFER_LENGTH + 1)
	Dim BufferLength As Integer
	
	Dim LinesBuffer As WString * (HTTPREADER_MAXBUFFER_LENGTH + 1)
	Dim LinesBufferLength As Integer
	
	Dim IsAllBytesReaded As Boolean
	
	Dim StartLineIndex As Integer
	
End Type

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
		ByVal this As HttpReader Ptr, _
		ByVal hHeap As HANDLE _
	)
	
	this->pVirtualTable = @GlobalHttpReaderVirtualTable
	this->ReferenceCounter = 0
	this->hHeap = hHeap
	
	this->pIStream = NULL
	this->Buffer[0] = 0
	this->Buffer[HTTPREADER_MAXBUFFER_LENGTH] = 0
	this->BufferLength = 0
	this->LinesBuffer[0] = 0
	this->LinesBufferLength = 0
	this->IsAllBytesReaded = False
	this->StartLineIndex = 0
	
End Sub

Sub UnInitializeHttpReader( _
		ByVal this As HttpReader Ptr _
	)
	
	If this->pIStream <> NULL Then
		IBaseStream_Release(this->pIStream)
	End If
	
End Sub

Function CreateHttpReader( _
		ByVal hHeap As HANDLE _
	)As HttpReader Ptr
	
	Dim this As HttpReader Ptr = HeapAlloc( _
		hHeap, _
		HEAP_NO_SERIALIZE, _
		SizeOf(HttpReader) _
	)
	
	If this = NULL Then
		Return NULL
	End If
	
	InitializeHttpReader(this, hHeap)
	
	Return this
	
End Function

Sub DestroyHttpReader( _
		ByVal this As HttpReader Ptr _
	)
	
	UnInitializeHttpReader(this)
	
	HeapFree(this->hHeap, HEAP_NO_SERIALIZE, this)
	
End Sub

Function HttpReaderQueryInterface( _
		ByVal this As HttpReader Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IHttpReader, riid) Then
		*ppv = @this->pVirtualTable
	Else
		If IsEqualIID(@IID_ITextReader, riid) Then
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
	
	HttpReaderAddRef(this)
	
	Return S_OK
	
End Function

Function HttpReaderAddRef( _
		ByVal this As HttpReader Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return this->ReferenceCounter
	
End Function

Function HttpReaderRelease( _
		ByVal this As HttpReader Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter = 0 Then
		
		DestroyHttpReader(this)
		
		Return 0
	End If
	
	Return this->ReferenceCounter
	
End Function

Function HttpReaderReadAllBytes( _
		ByVal this As HttpReader Ptr, _
		ByVal pDoubleCrLfIndex As Integer Ptr _
	)As HRESULT
	
	Dim DoubleCrLfIndex As Integer = Any
	Dim FindResult As Boolean = Any
	
	Do
		Dim ReceivedBytesCount As Integer = Any
		
		Dim hr As HRESULT = IBaseStream_Read( _
			this->pIStream, _
			@this->Buffer, _
			this->BufferLength, _
			HTTPREADER_MAXBUFFER_LENGTH - this->BufferLength, _
			@ReceivedBytesCount _
		)
		
		If FAILED(hr) Then
			Return HTTPREADER_E_SOCKETERROR
		End If
		
		If hr = S_FALSE Then
			Return HTTPREADER_E_CLIENTCLOSEDCONNECTION
		End If
		
		this->BufferLength += ReceivedBytesCount
		this->Buffer[this->BufferLength] = 0
		
		If this->BufferLength >= HTTPREADER_MAXBUFFER_LENGTH Then
			Return HTTPREADER_E_INTERNALBUFFEROVERFLOW
		End If
		
		FindResult = FindDoubleCrLfIndexA( _
			@this->Buffer, _
			this->BufferLength, _
			@DoubleCrLfIndex _
		)
		
	Loop While FindResult = False
	
	*pDoubleCrLfIndex = DoubleCrLfIndex
	this->IsAllBytesReaded = True
	
	Return S_OK
	
End Function

Function HttpReaderConvertBytesToString( _
		ByVal this As HttpReader Ptr, _
		ByVal DoubleCrLfIndex As Integer _
	)As HRESULT
	
	Const dwFlags As DWORD = 0
	
	Dim CharsLength As Integer = MultiByteToWideChar( _
		CP_UTF8, _
		dwFlags, _
		@this->Buffer, _
		DoubleCrLfIndex + 2 * NewLineStringLength, _
		@this->LinesBuffer, _
		HTTPREADER_MAXBUFFER_LENGTH _
	)
	
	this->LinesBufferLength = CharsLength
	this->LinesBuffer[CharsLength] = 0
	
	If CharsLength = 0 Then
		Dim dwError As DWORD = GetLastError()
		Return HTTPREADER_E_BUFFERTOOSMALL
	End If
	
	Return S_OK
	
End Function

Function HttpReaderReadLine( _
		ByVal this As HttpReader Ptr, _
		ByVal pLineLength As Integer Ptr, _
		ByVal pLine As WString Ptr Ptr _
	)As HRESULT
	
	If this->IsAllBytesReaded = False Then
		
		Dim DoubleCrLfIndex As Integer = Any
		Dim hr As HRESULT = HttpReaderReadAllBytes(this, @DoubleCrLfIndex)
		
		If FAILED(hr) Then
			*pLineLength = 0
			*pLine = @this->LinesBuffer
			Return hr
		End If
		
		hr = HttpReaderConvertBytesToString(this, DoubleCrLfIndex)
		
		If FAILED(hr) Then
			*pLineLength = 0
			*pLine = @this->LinesBuffer
			Return hr
		End If
		
	End If
	
	' Найти CrLf
	Dim CrLfIndex As Integer = Any
	
	FindCrLfIndexW( _
		@this->LinesBuffer[this->StartLineIndex], _
		this->LinesBufferLength - this->StartLineIndex, _
		@CrLfIndex _
	)
	
	*pLineLength = CrLfIndex
	*pLine = @this->LinesBuffer[this->StartLineIndex]
	
	this->LinesBuffer[this->StartLineIndex + CrLfIndex] = 0
	this->StartLineIndex += CrLfIndex + NewLineStringLength
	
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
		ByVal this As HttpReader Ptr _
	)As HRESULT
	
	If this->StartLineIndex <> 0 Then
		
		If this->BufferLength - this->StartLineIndex <= 0 Then
			this->Buffer[0] = 0
			this->BufferLength = 0
		Else
			RtlMoveMemory( _
				@this->Buffer, _
				@this->Buffer[this->StartLineIndex], _
				HTTPREADER_MAXBUFFER_LENGTH - this->StartLineIndex + 1 _
			)
			this->BufferLength -= this->StartLineIndex
		End If
		
		this->StartLineIndex = 0
	End If
	
	this->LinesBuffer[0] = 0
	this->LinesBufferLength = 0
	this->IsAllBytesReaded = False
	this->StartLineIndex = 0
	
	Return S_OK
	
End Function

Function HttpReaderGetBaseStream( _
		ByVal this As HttpReader Ptr, _
		ByVal ppResult As IBaseStream Ptr Ptr _
	)As HRESULT
	
	If this->pIStream = NULL Then
		*ppResult = NULL
		Return S_FALSE
	End If
	
	IBaseStream_AddRef(this->pIStream)
	*ppResult = this->pIStream
	
	Return S_OK
	
End Function

Function HttpReaderSetBaseStream( _
		ByVal this As HttpReader Ptr, _
		ByVal pIStream As IBaseStream Ptr _
	)As HRESULT
	
	If this->pIStream <> NULL Then
		IBaseStream_Release(this->pIStream)
	End If
	
	If pIStream <> NULL Then
		IBaseStream_AddRef(pIStream)
	End If
	
	this->pIStream = pIStream
	
	Return S_OK
	
End Function

Function HttpReaderGetPreloadedBytes( _
		ByVal this As HttpReader Ptr, _
		ByVal pPreloadedBytesLength As Integer Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As HRESULT
	
	*pPreloadedBytesLength = this->BufferLength - this->StartLineIndex
	*ppPreloadedBytes = @this->Buffer[this->StartLineIndex]
	
	Return S_OK
	
End Function

Function HttpReaderGetRequestedBytes( _
		ByVal this As HttpReader Ptr, _
		ByVal pRequestedBytesLength As Integer Ptr, _
		ByVal ppRequestedBytes As UByte Ptr Ptr _
	)As HRESULT
	
	*pRequestedBytesLength = this->BufferLength
	*ppRequestedBytes = @this->Buffer
	
	Return S_OK
	
End Function
