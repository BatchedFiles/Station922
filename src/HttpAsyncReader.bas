#include once "HttpAsyncReader.bi"
#include once "Http.bi"
#include once "HeapBSTR.bi"

Extern GlobalHttpReaderVirtualTable As Const IHttpAsyncReaderVirtualTable

Const DoubleNewLineStringA = Str(!"\r\n\r\n")
Const NewLineStringA = Str(!"\r\n")

Const MEMORYPAGE_SIZE As Integer = 4096

Const RAWBUFFER_MEMORYPAGE_COUNT As Integer = 4

#if __FB_DEBUG__
Const RAWBUFFER_CAPACITY As Integer = (RAWBUFFER_MEMORYPAGE_COUNT * MEMORYPAGE_SIZE) - (4 * SizeOf(Integer)) - SizeOf(ZString) * 16
#else
Const RAWBUFFER_CAPACITY As Integer = (RAWBUFFER_MEMORYPAGE_COUNT * MEMORYPAGE_SIZE) - (4 * SizeOf(Integer))
#endif

Type ClientRequestBuffer
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	cbLength As Integer
	EndOfHeaders As Integer
	StartLine As Integer
	Padding1 As Integer
	Bytes(0 To RAWBUFFER_CAPACITY - 1) As UByte
End Type

Type HttpReader
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IHttpAsyncReaderVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pIStream As IBaseAsyncStream Ptr
	pClientBuffer As ClientRequestBuffer Ptr
	SkippedBytes As LongInt
	IsAllBytesReaded As Boolean
End Type

Private Sub InitializeClientRequestBuffer( _
		ByVal self As ClientRequestBuffer Ptr _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@self->RttiClassName(0), _
			@Str(RTTI_ID_CLIENTREQUESTBUFFER), _
			UBound(self->RttiClassName) - LBound(self->RttiClassName) + 1 _
		)
	#endif
	self->cbLength = 0
	self->EndOfHeaders = 0

	' No Need ZeroMemory StartLine
	' No Need ZeroMemory self.Bytes

End Sub

Private Function ClientRequestBufferGetFreeSpaceLength( _
		ByVal self As ClientRequestBuffer Ptr _
	)As Integer

	Dim FreeSpace As Integer = RAWBUFFER_CAPACITY - self->cbLength

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

Private Function ClientRequestBufferFindDoubleCrLfIndexA( _
		ByVal self As ClientRequestBuffer Ptr, _
		ByVal pFindIndex As Integer Ptr _
	)As Boolean

	Dim pDoubleCrLf As UByte Ptr = FindStringA( _
		@self->Bytes(0), _
		self->cbLength, _
		@DoubleNewLineStringA, _
		Len(DoubleNewLineStringA) _
	)
	If pDoubleCrLf = NULL Then
		*pFindIndex = 0
		Return False
	End If

	Dim FindIndex As Integer = pDoubleCrLf - @self->Bytes(0)
	*pFindIndex = FindIndex

	Return True

End Function

Private Function ClientRequestBufferFindCrLfIndexA( _
		ByVal self As ClientRequestBuffer Ptr, _
		ByVal pFindIndex As Integer Ptr _
	)As Boolean

	Dim pCrLf As UByte Ptr = FindStringA( _
		@self->Bytes(self->StartLine), _
		self->EndOfHeaders, _
		@NewLineStringA, _
		Len(NewLineStringA) _
	)
	If pCrLf = NULL Then
		*pFindIndex = 0
		Return False
	End If

	Dim FindIndex As Integer = pCrLf - @self->Bytes(self->StartLine)
	*pFindIndex = FindIndex

	Return True

End Function

Private Function ClientRequestBufferGetLine( _
		ByVal self As ClientRequestBuffer Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As HeapBSTR

	Dim CrLfIndex As Integer = Any
	Dim Finded As Boolean = ClientRequestBufferFindCrLfIndexA( _
		self, _
		@CrLfIndex _
	)
	If Finded = False Then
		Return NULL
	End If

	' TODO Проверить, начинается ли строка за CrLf с пробела
	' Если начинается — объединить обе строки

	Dim LineLength As Integer = CrLfIndex
	Dim StartLineIndex As Integer = self->StartLine

	Dim bstrLine As HeapBSTR = CreateHeapZStringLen( _
		pIMemoryAllocator, _
		@self->Bytes(StartLineIndex), _
		LineLength _
	)
	If bstrLine = NULL Then
		Return NULL
	End If

	Dim NewStartIndex As Integer = StartLineIndex + LineLength + Len(NewLineStringA)
	self->StartLine = NewStartIndex

	Return bstrLine

End Function

Private Sub ClientRequestBufferClear( _
		ByVal self As ClientRequestBuffer Ptr _
	)

	self->cbLength = 0
	self->EndOfHeaders = 0

End Sub

Private Function GetPreloadedBytesLength( _
		ByVal pClientBuffer As ClientRequestBuffer Ptr _
	)As Integer

	Dim cbPreloadedBytes As Integer = pClientBuffer->cbLength - pClientBuffer->EndOfHeaders

	Return cbPreloadedBytes

End Function

Private Sub InitializeHttpReader( _
		ByVal self As HttpReader Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pClientBuffer As ClientRequestBuffer Ptr _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@self->RttiClassName(0), _
			@Str(RTTI_ID_HTTPREADER), _
			UBound(self->RttiClassName) - LBound(self->RttiClassName) + 1 _
		)
	#endif
	self->lpVtbl = @GlobalHttpReaderVirtualTable
	self->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	self->pIMemoryAllocator = pIMemoryAllocator
	self->pIStream = NULL
	InitializeClientRequestBuffer(pClientBuffer)
	self->pClientBuffer = pClientBuffer
	self->SkippedBytes = 0
	self->IsAllBytesReaded = False

End Sub

Private Sub UnInitializeHttpReader( _
		ByVal self As HttpReader Ptr _
	)

	If self->pIStream Then
		IBaseAsyncStream_Release(self->pIStream)
	End If

	IMalloc_Free(self->pIMemoryAllocator, self->pClientBuffer)

End Sub

Private Sub HttpReaderCreated( _
		ByVal self As HttpReader Ptr _
	)

End Sub

Private Sub HttpReaderDestroyed( _
		ByVal self As HttpReader Ptr _
	)

End Sub

Private Sub DestroyHttpReader( _
		ByVal self As HttpReader Ptr _
	)

	Dim pIMemoryAllocator As IMalloc Ptr = self->pIMemoryAllocator

	UnInitializeHttpReader(self)

	IMalloc_Free(pIMemoryAllocator, self)

	HttpReaderDestroyed(self)

	IMalloc_Release(pIMemoryAllocator)

End Sub

Private Function HttpReaderAddRef( _
		ByVal self As HttpReader Ptr _
	)As ULONG

	self->ReferenceCounter += 1

	Return 1

End Function

Private Function HttpReaderRelease( _
		ByVal self As HttpReader Ptr _
	)As ULONG

	self->ReferenceCounter -= 1

	If self->ReferenceCounter Then
		Return 1
	End If

	DestroyHttpReader(self)

	Return 0

End Function

Private Function HttpReaderQueryInterface( _
		ByVal self As HttpReader Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_IHttpAsyncReader, riid) Then
		*ppv = @self->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @self->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If

	HttpReaderAddRef(self)

	Return S_OK

End Function

Public Function CreateHttpReader( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	Dim self As HttpReader Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(HttpReader) _
	)

	If self Then
		Dim pClientBuffer As ClientRequestBuffer Ptr = IMalloc_Alloc( _
			pIMemoryAllocator, _
			SizeOf(ClientRequestBuffer) _
		)

		If pClientBuffer Then
			InitializeHttpReader(self, pIMemoryAllocator, pClientBuffer)
			HttpReaderCreated(self)

			Dim hrQueryInterface As HRESULT = HttpReaderQueryInterface( _
				self, _
				riid, _
				ppv _
			)
			If FAILED(hrQueryInterface) Then
				DestroyHttpReader(self)
			End If

			Return hrQueryInterface
		End If

		IMalloc_Free(pIMemoryAllocator, self)
	End If

	*ppv = NULL
	Return E_OUTOFMEMORY

End Function

Private Function HttpReaderReadLine( _
		ByVal self As HttpReader Ptr, _
		ByVal ppLine As HeapBSTR Ptr _
	)As HRESULT

	If self->IsAllBytesReaded = False Then
		*ppLine = NULL
		Return E_FAIL
	End If

	Dim bstrLine As HeapBSTR = ClientRequestBufferGetLine( _
		self->pClientBuffer, _
		self->pIMemoryAllocator _
	)
	If bstrLine = NULL Then
		*ppLine = NULL
		Return E_OUTOFMEMORY
	End If

	*ppLine = bstrLine
	Return S_OK

End Function

Private Function HttpReaderBeginReadLine( _
		ByVal self As HttpReader Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	If self->IsAllBytesReaded = False Then

		Dim cbFreeSpace As Integer = ClientRequestBufferGetFreeSpaceLength( _
			self->pClientBuffer _
		)
		If cbFreeSpace = 0 Then
			*ppIAsyncResult = NULL
			Return HTTPREADER_E_INTERNALBUFFEROVERFLOW
		End If

		Dim FreeSpaceIndex As Integer = self->pClientBuffer->cbLength
		Dim lpFreeSpace As Any Ptr = @self->pClientBuffer->Bytes(FreeSpaceIndex)
		Dim hrBeginRead As HRESULT = IBaseAsyncStream_BeginRead( _
			self->pIStream, _
			lpFreeSpace, _
			cbFreeSpace, _
			pcb, _
			StateObject, _
			ppIAsyncResult _
		)
		If FAILED(hrBeginRead) Then
			Return hrBeginRead
		End If

	End If

	Return HTTPREADER_S_IO_PENDING

End Function

Private Sub HttpReaderPrintClientBuffer( _
		ByVal self As HttpReader Ptr _
	)

End Sub

Private Function HttpReaderEndReadLine( _
		ByVal self As HttpReader Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal ppLine As HeapBSTR Ptr _
	)As HRESULT

	Dim cbReceived As DWORD = Any

	Scope
		Dim hrRead As HRESULT = IBaseAsyncStream_EndRead( _
			self->pIStream, _
			pIAsyncResult, _
			@cbReceived _
		)
		If FAILED(hrRead) Then
			*ppLine = NULL
			Return hrRead
		End If

		If hrRead = S_FALSE Then
			*ppLine = NULL
			Return S_FALSE
		End If

	End Scope

	Dim SkippedBytes As LongInt = min(self->SkippedBytes, CLngInt(cbReceived))

	If self->SkippedBytes Then
		Dim cbMovedBytes As Integer = RAWBUFFER_CAPACITY - CInt(SkippedBytes)
		If cbMovedBytes Then
			memmove( _
				@self->pClientBuffer->Bytes(0), _
				@self->pClientBuffer->Bytes(SkippedBytes), _
				cbMovedBytes _
			)
		End If

		self->SkippedBytes -= SkippedBytes

		If self->SkippedBytes Then
			*ppLine = NULL
			Return HTTPREADER_S_IO_PENDING
		End If
	End If

	Dim cbNewLength As Integer = self->pClientBuffer->cbLength + cbReceived - SkippedBytes

	If cbNewLength > RAWBUFFER_CAPACITY Then
		*ppLine = NULL
		Return HTTPREADER_E_INTERNALBUFFEROVERFLOW
	End If

	self->pClientBuffer->cbLength = cbNewLength

	Dim DoubleCrLfIndex As Integer = Any
	Dim Finded As Boolean = ClientRequestBufferFindDoubleCrLfIndexA( _
		self->pClientBuffer, _
		@DoubleCrLfIndex _
	)
	If Finded = False Then
		*ppLine = NULL
		Return HTTPREADER_S_IO_PENDING
	End If

	HttpReaderPrintClientBuffer(self)

	Dim NewEndOfHeaders As Integer = DoubleCrLfIndex + Len(DoubleNewLineStringA)
	self->pClientBuffer->EndOfHeaders = NewEndOfHeaders
	self->pClientBuffer->StartLine = 0
	self->IsAllBytesReaded = True

	Dim bstrLine As HeapBSTR = ClientRequestBufferGetLine( _
		self->pClientBuffer, _
		self->pIMemoryAllocator _
	)
	If bstrLine = NULL Then
		*ppLine = NULL
		Return E_OUTOFMEMORY
	End If

	*ppLine = bstrLine
	Return S_OK

End Function

Private Function HttpReaderClear( _
		ByVal self As HttpReader Ptr _
	)As HRESULT

	self->IsAllBytesReaded = False

	ClientRequestBufferClear(self->pClientBuffer)

	Return S_OK

End Function

Private Function HttpReaderSetBaseStream( _
		ByVal self As HttpReader Ptr, _
		ByVal pIStream As IBaseAsyncStream Ptr _
	)As HRESULT

	If self->pIStream Then
		IBaseAsyncStream_Release(self->pIStream)
	End If

	If pIStream Then
		IBaseAsyncStream_AddRef(pIStream)
	End If

	self->pIStream = pIStream

	Return S_OK

End Function

Private Function HttpReaderGetPreloadedBytes( _
		ByVal self As HttpReader Ptr, _
		ByVal pPreloadedBytesLength As Integer Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As HRESULT

	Dim cbPreloadedBytes As Integer = GetPreloadedBytesLength(self->pClientBuffer)
	Dim PreloadedIndex As Integer = self->pClientBuffer->EndOfHeaders
	Dim pBytes As UByte Ptr = @self->pClientBuffer->Bytes(PreloadedIndex)

	*pPreloadedBytesLength = cbPreloadedBytes
	*ppPreloadedBytes = pBytes

	Return S_OK

End Function

Private Function HttpReaderGetRequestedBytes( _
		ByVal self As HttpReader Ptr, _
		ByVal pRequestedBytesLength As Integer Ptr, _
		ByVal ppRequestedBytes As UByte Ptr Ptr _
	)As HRESULT

	Dim Length As Integer = self->pClientBuffer->cbLength
	Dim pBytes As UByte Ptr = @self->pClientBuffer->Bytes(0)

	*pRequestedBytesLength = Length
	*ppRequestedBytes = pBytes

	Return S_OK

End Function

Private Function HttpReaderSkipBytes( _
		ByVal self As HttpReader Ptr, _
		ByVal Length As LongInt _
	)As HRESULT

	Dim cbPreloadedBytes As Integer = GetPreloadedBytesLength(self->pClientBuffer)
	self->SkippedBytes = Length - CLngInt(cbPreloadedBytes)

	Return S_OK

End Function


Private Function IHttpAsyncReaderQueryInterface( _
		ByVal self As IHttpAsyncReader Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return HttpReaderQueryInterface(CONTAINING_RECORD(self, HttpReader, lpVtbl), riid, ppvObject)
End Function

Private Function IHttpAsyncReaderAddRef( _
		ByVal self As IHttpAsyncReader Ptr _
	)As ULONG
	Return HttpReaderAddRef(CONTAINING_RECORD(self, HttpReader, lpVtbl))
End Function

Private Function IHttpAsyncReaderRelease( _
		ByVal self As IHttpAsyncReader Ptr _
	)As ULONG
	Return HttpReaderRelease(CONTAINING_RECORD(self, HttpReader, lpVtbl))
End Function

Private Function IHttpAsyncReaderReadLine( _
		ByVal self As IHttpAsyncReader Ptr, _
		ByVal pLine As HeapBSTR Ptr _
	)As HRESULT
	Return HttpReaderReadLine(CONTAINING_RECORD(self, HttpReader, lpVtbl), pLine)
End Function

Private Function IHttpAsyncReaderBeginReadLine( _
		ByVal self As IHttpAsyncReader Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return HttpReaderBeginReadLine(CONTAINING_RECORD(self, HttpReader, lpVtbl), pcb, StateObject, ppIAsyncResult)
End Function

Private Function IHttpAsyncReaderEndReadLine( _
		ByVal self As IHttpAsyncReader Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal ppLine As HeapBSTR Ptr _
	)As HRESULT
	Return HttpReaderEndReadLine(CONTAINING_RECORD(self, HttpReader, lpVtbl), pIAsyncResult, ppLine)
End Function

Private Function IHttpAsyncReaderClear( _
		ByVal self As IHttpAsyncReader Ptr _
	)As HRESULT
	Return HttpReaderClear(CONTAINING_RECORD(self, HttpReader, lpVtbl))
End Function

Private Function IHttpAsyncReaderSetBaseStream( _
		ByVal self As IHttpAsyncReader Ptr, _
		ByVal pIStream As IBaseAsyncStream Ptr _
	)As HRESULT
	Return HttpReaderSetBaseStream(CONTAINING_RECORD(self, HttpReader, lpVtbl), pIStream)
End Function

Private Function IHttpAsyncReaderGetPreloadedBytes( _
		ByVal self As IHttpAsyncReader Ptr, _
		ByVal pPreloadedBytesLength As Integer Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As HRESULT
	Return HttpReaderGetPreloadedBytes(CONTAINING_RECORD(self, HttpReader, lpVtbl), pPreloadedBytesLength, ppPreloadedBytes)
End Function

Private Function IHttpAsyncReaderGetRequestedBytes( _
		ByVal self As IHttpAsyncReader Ptr, _
		ByVal pRequestedBytesLength As Integer Ptr, _
		ByVal ppRequestedBytes As UByte Ptr Ptr _
	)As HRESULT
	Return HttpReaderGetRequestedBytes(CONTAINING_RECORD(self, HttpReader, lpVtbl), pRequestedBytesLength, ppRequestedBytes)
End Function

Private Function IHttpAsyncReaderSkipBytes( _
		ByVal self As IHttpAsyncReader Ptr, _
		ByVal Length As LongInt _
	)As HRESULT
	Return HttpReaderSkipBytes(CONTAINING_RECORD(self, HttpReader, lpVtbl), Length)
End Function

Dim GlobalHttpReaderVirtualTable As Const IHttpAsyncReaderVirtualTable = Type( _
	@IHttpAsyncReaderQueryInterface, _
	@IHttpAsyncReaderAddRef, _
	@IHttpAsyncReaderRelease, _
	@IHttpAsyncReaderReadLine, _
	@IHttpAsyncReaderBeginReadLine, _
	@IHttpAsyncReaderEndReadLine, _
	@IHttpAsyncReaderClear, _
	@IHttpAsyncReaderSetBaseStream, _
	@IHttpAsyncReaderGetPreloadedBytes, _
	@IHttpAsyncReaderGetRequestedBytes, _
	@IHttpAsyncReaderSkipBytes _
)
