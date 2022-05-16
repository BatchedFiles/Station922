#include once "HttpWriter.bi"
#include once "ContainerOf.bi"
#include once "Logger.bi"

Extern GlobalHttpWriterVirtualTable As Const IHttpWriterVirtualTable

Const TRANSMIT_CHUNK_SIZE As DWORD = 265 * (1024 * 1024)

Type HeadersBodyBuffer
	Buf(1) As BaseStreamBuffer
End Type

Type _HttpWriter
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IHttpWriterVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	pIStream As IBaseStream Ptr
	pIBuffer As IBuffer Ptr
	Padding As Integer
	WriterStartIndex As LongInt
	HeadersSended As Boolean
	BodySended As Boolean
End Type

Sub InitializeHttpWriter( _
		ByVal this As HttpWriter Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory(@this->IdString, @Str("Http______Writer"), 16)
	#endif
	this->lpVtbl = @GlobalHttpWriterVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIStream = NULL
	this->pIBuffer = NULL
	' this->Padding = 0
	this->WriterStartIndex = 0
	this->HeadersSended = False
	this->BodySended = False
	
End Sub

Sub UnInitializeHttpWriter( _
		ByVal this As HttpWriter Ptr _
	)
	
	If this->pIStream <> NULL Then
		IBaseStream_Release(this->pIStream)
	End If
	
	If this->pIBuffer <> NULL Then
		IBuffer_Release(this->pIBuffer)
	End If
	
	IMalloc_Release(this->pIMemoryAllocator)
	
End Sub

Function CreateHttpWriter( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As HttpWriter Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(HttpWriter)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"HttpWriter creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim this As HttpWriter Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(HttpWriter) _
	)
	
	If this <> NULL Then
		
		InitializeHttpWriter( _
			this, _
			pIMemoryAllocator _
		)
		
		#if __FB_DEBUG__
		Scope
			Dim vtEmpty As VARIANT = Any
			VariantInit(@vtEmpty)
			LogWriteEntry( _
				LogEntryType.Debug, _
				WStr("HttpWriter created"), _
				@vtEmpty _
			)
		End Scope
		#endif
		
		Return this
	End If
	
	Return NULL
	
End Function

Sub DestroyHttpWriter( _
		ByVal this As HttpWriter Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("HttpWriter destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeHttpWriter(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("HttpWriter destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function HttpWriterQueryInterface( _
		ByVal this As HttpWriter Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IHttpWriter, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	HttpWriterAddRef(this)
	
	Return S_OK
	
End Function

Function HttpWriterAddRef( _
		ByVal this As HttpWriter Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		InterlockedIncrement64(@this->ReferenceCounter)
	#else
		InterlockedIncrement(@this->ReferenceCounter)
	#endif
	
	Return 1
	
End Function

Function HttpWriterRelease( _
		ByVal this As HttpWriter Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		If InterlockedDecrement64(@this->ReferenceCounter) Then
			Return 1
		End If
	#else
		If InterlockedDecrement(@this->ReferenceCounter) Then
			Return 1
		End If
	#endif
	
	DestroyHttpWriter(this)
	
	Return 0
	
End Function

Function HttpWriterGetBaseStream( _
		ByVal this As HttpWriter Ptr, _
		ByVal ppResult As IBaseStream Ptr Ptr _
	)As HRESULT
	
	If this->pIStream <> NULL Then
		IBaseStream_AddRef(this->pIStream)
	End If
	
	*ppResult = this->pIStream
	
	Return S_OK
	
End Function

Function HttpWriterSetBaseStream( _
		ByVal this As HttpWriter Ptr, _
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

Function HttpWriterGetBuffer( _
		ByVal this As HttpWriter Ptr, _
		ByVal ppResult As IBuffer Ptr Ptr _
	)As HRESULT
	
	If this->pIBuffer <> NULL Then
		IBuffer_AddRef(this->pIBuffer)
	End If
	
	*ppResult = this->pIBuffer
	
	Return S_OK
	
End Function

Function HttpWriterSetBuffer( _
		ByVal this As HttpWriter Ptr, _
		ByVal pIBuffer As IBuffer Ptr _
	)As HRESULT
	
	If this->pIBuffer <> NULL Then
		IBuffer_Release(this->pIBuffer)
	End If
	
	If pIBuffer <> NULL Then
		IBuffer_AddRef(pIBuffer)
	End If
	
	this->pIBuffer = pIBuffer
	
	Return S_OK
	
End Function

	/'
	*ppIAsyncResult = NULL
	
	Dim pINewAsyncResult As IMutableAsyncResult Ptr = Any
	Dim hr As HRESULT = CreateInstance( _
		this->pIMemoryAllocator, _
		@CLSID_ASYNCRESULT, _
		@IID_IMutableAsyncResult, _
		@pINewAsyncResult _
	)
	If FAILED(hr) Then
		Return E_OUTOFMEMORY
	End If
	
	Dim lpRecvOverlapped As ASYNCRESULTOVERLAPPED Ptr = Any
	IMutableAsyncResult_GetWsaOverlapped(pINewAsyncResult, @lpRecvOverlapped)
	' TODO Запросить интерфейс вместо конвертирования указателя
	lpRecvOverlapped->pIAsync = CPtr(IAsyncResult Ptr, pINewAsyncResult)
	IMutableAsyncResult_SetAsyncState(pINewAsyncResult, StateObject)
	IMutableAsyncResult_SetAsyncCallback(pINewAsyncResult, NULL)
	
	Dim FileOffsetPointer As LARGE_INTEGER = Any
	FileOffsetPointer.QuadPart = this->CurrentChunkIndex * Cast(LongInt, TRANSMIT_CHUNK_SIZE)
	
	Dim dwCurrentChunkSize As DWORD = Cast(DWORD, _
		min( _
			this->ContentBodyLength - FileOffsetPointer.QuadPart, _
			Cast(LongInt, TRANSMIT_CHUNK_SIZE) _
		) _
	)
	
	Dim pTransmitHeader As TRANSMIT_FILE_BUFFERS Ptr = Any
	If this->CurrentChunkIndex = 0 Then
		this->TransmitHeader.Head = this->pSendBuffer
		this->TransmitHeader.HeadLength = Cast(DWORD, this->HeadersLength)
		this->TransmitHeader.Tail = NULL
		this->TransmitHeader.TailLength = Cast(DWORD, 0)
		pTransmitHeader = @this->TransmitHeader
	Else
		pTransmitHeader = NULL
	End If
	
	Dim SendOnlyHeaders As Boolean = Any
	IServerResponse_GetSendOnlyHeaders(pc->pIResponse, @SendOnlyHeaders)
	
	If SendOnlyHeaders Then
		this->hTransmitFile = NULL
	Else
		If this->ZipFileHandle <> INVALID_HANDLE_VALUE Then
			this->hTransmitFile = this->ZipFileHandle
		Else
			this->hTransmitFile = this->FileHandle
		End If
	End If
	
	Dim ClientSocket As SOCKET = Any
	INetworkStream_GetSocket(pc->pINetworkStream, @ClientSocket)
	
	If this->hTransmitFile <> NULL Then
		Dim CurrentOffsetPointer As LARGE_INTEGER = Any
		CurrentOffsetPointer.QuadPart = FileOffsetPointer.QuadPart + this->FileBytesOffset
		
		Dim OffsetResult As Integer = SetFilePointerEx( _
			this->hTransmitFile, _
			CurrentOffsetPointer, _
			NULL, _
			FILE_BEGIN _
		)
		If OffsetResult = 0 Then
			Dim dwError As DWORD = GetLastError()
			IMutableAsyncResult_Release(pINewAsyncResult)
			Return HRESULT_FROM_WIN32(dwError)
		End If
	End If
	
	Const Reserved As DWORD = 0
	Const NumberOfBytesPerSendDefault As DWORD = 0
	
	Dim TransmitFileResult As Integer = TransmitFile( _
		ClientSocket, _
		this->hTransmitFile, _
		dwCurrentChunkSize, _
		NumberOfBytesPerSendDefault, _
		CPtr(OVERLAPPED Ptr, lpRecvOverlapped), _
		pTransmitHeader, _
		Reserved _
	)
	If TransmitFileResult = 0 Then
		
		Dim intError As Long = WSAGetLastError()
		If intError = ERROR_IO_PENDING OrElse intError = WSA_IO_PENDING Then
			' TODO Запросить интерфейс вместо конвертирования указателя
			*ppIAsyncResult = CPtr(IAsyncResult Ptr, pINewAsyncResult)
			Return HTTPASYNCPROCESSOR_S_IO_PENDING
		End If
		
		IMutableAsyncResult_Release(pINewAsyncResult)
		Return HRESULT_FROM_WIN32(intError)
		
	End If
	
	' TODO Запросить интерфейс вместо конвертирования указателя
	*ppIAsyncResult = CPtr(IAsyncResult Ptr, pINewAsyncResult)
	'/


	/'
	' TODO Приём и отправка данных через какой-нибудь объект
	
	If this->hTransmitFile = NULL Then
		If this->FileHandle <> INVALID_HANDLE_VALUE Then
			' If CloseHandle(this->FileHandle) = 0 Then
				' Dim dwError As DWORD = GetLastError()
			' End If
			CloseHandle(this->FileHandle)
			this->FileHandle = INVALID_HANDLE_VALUE
		End If
		
		If this->ZipFileHandle <> INVALID_HANDLE_VALUE Then
			' If CloseHandle(this->ZipFileHandle) = 0 Then
				' Dim dwError As DWORD = GetLastError()
			' End If
			CloseHandle(this->ZipFileHandle)
			this->ZipFileHandle = INVALID_HANDLE_VALUE
		End If
		
		Return S_OK
	End If
	
	Dim FileOffsetPointer As LARGE_INTEGER = Any
	FileOffsetPointer.QuadPart = this->CurrentChunkIndex * Cast(LongInt, TRANSMIT_CHUNK_SIZE)
	
	Dim dwCurrentChunkSize As DWORD = Cast(DWORD, _
		min( _
			this->ContentBodyLength - FileOffsetPointer.QuadPart, _
			Cast(LongInt, TRANSMIT_CHUNK_SIZE) _
		) _
	)
	
	If dwCurrentChunkSize <= TRANSMIT_CHUNK_SIZE Then
		
		If this->FileHandle <> INVALID_HANDLE_VALUE Then
			' If CloseHandle(this->FileHandle) = 0 Then
				' Dim dwError As DWORD = GetLastError()
			' End If
			CloseHandle(this->FileHandle)
			this->FileHandle = INVALID_HANDLE_VALUE
		End If
		
		If this->ZipFileHandle <> INVALID_HANDLE_VALUE Then
			' If CloseHandle(this->ZipFileHandle) = 0 Then
				' Dim dwError As DWORD = GetLastError()
			' End If
			CloseHandle(this->ZipFileHandle)
			this->ZipFileHandle = INVALID_HANDLE_VALUE
		End If
		
		Return S_OK
	End If
	
	this->CurrentChunkIndex += 1
	'/

Function HttpWriterBeginWrite( _
		ByVal this As HttpWriter Ptr, _
		ByVal Headers As LPVOID, _
		ByVal HeadersLength As DWORD, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Dim Slice As BufferSlice = Any
	Dim hrGetSlice As HRESULT = IBuffer_GetSlice( _
		this->pIBuffer, _
		this->WriterStartIndex, _
		TRANSMIT_CHUNK_SIZE, _
		@Slice _
	)
	
	If FAILED(hrGetSlice) Then
		Return hrGetSlice
	End If
	
	Dim StreamBuffer As HeadersBodyBuffer = Any
	Dim StreamBufferLength As Integer = Any
	
	If this->HeadersSended Then
		StreamBufferLength = 1
		StreamBuffer.Buf(0).Buffer = Slice.pSlice
		StreamBuffer.Buf(0).Length = Slice.Length
	Else
		StreamBuffer.Buf(0).Buffer = Headers
		StreamBuffer.Buf(0).Length = HeadersLength
		
		If Slice.Length > 0 Then
			StreamBufferLength = 2
			StreamBuffer.Buf(1).Buffer = Slice.pSlice
			StreamBuffer.Buf(1).Length = Slice.Length
		Else
			StreamBufferLength = 1
		End If
		
		this->WriterStartIndex = this->WriterStartIndex - HeadersLength
	End If
	
	If hrGetSlice = S_FALSE OrElse Slice.Length = 0 Then
		this->BodySended = True
	End If
	
	Dim hrBeginWrite As HRESULT = IBaseStream_BeginWriteGather( _
		this->pIStream, _
		@StreamBuffer.Buf(0), _
		StreamBufferLength, _
		NULL, _
		StateObject, _
		ppIAsyncResult _
	)
	If FAILED(hrBeginWrite) Then
		Return hrBeginWrite
	End If
	
	Return S_OK
	
End Function

Function HttpWriterEndWrite( _
		ByVal this As HttpWriter Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	
	Dim WritedBytes As DWORD = Any
	Dim hrEndWrite As HRESULT = IBaseStream_EndWrite( _
		this->pIStream, _
		pIAsyncResult, _
		@WritedBytes _
	)
	If FAILED(hrEndWrite) Then
		Return hrEndWrite
	End If
	
	this->HeadersSended = True
	this->WriterStartIndex = this->WriterStartIndex + WritedBytes
	
	Select Case hrEndWrite
		
		Case S_OK
			If this->BodySended Then
				Return S_OK
			End If
			
		Case S_FALSE
			Return S_FALSE
			
		Case BASESTREAM_S_IO_PENDING
			Return HTTPWRITER_S_IO_PENDING
			
	End Select
	
	Return HTTPWRITER_S_IO_PENDING
	
End Function


Function IHttpWriterQueryInterface( _
		ByVal this As IHttpWriter Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return HttpWriterQueryInterface(ContainerOf(this, HttpWriter, lpVtbl), riid, ppvObject)
End Function

Function IHttpWriterAddRef( _
		ByVal this As IHttpWriter Ptr _
	)As ULONG
	Return HttpWriterAddRef(ContainerOf(this, HttpWriter, lpVtbl))
End Function

Function IHttpWriterRelease( _
		ByVal this As IHttpWriter Ptr _
	)As ULONG
	Return HttpWriterRelease(ContainerOf(this, HttpWriter, lpVtbl))
End Function

Function IHttpWriterGetBaseStream( _
		ByVal this As IHttpWriter Ptr, _
		ByVal ppResult As IBaseStream Ptr Ptr _
	)As HRESULT
	Return HttpWriterGetBaseStream(ContainerOf(this, HttpWriter, lpVtbl), ppResult)
End Function

Function IHttpWriterSetBaseStream( _
		ByVal this As IHttpWriter Ptr, _
		ByVal pIStream As IBaseStream Ptr _
	)As HRESULT
	Return HttpWriterSetBaseStream(ContainerOf(this, HttpWriter, lpVtbl), pIStream)
End Function

Function IHttpWriterGetBuffer( _
		ByVal this As IHttpWriter Ptr, _
		ByVal ppResult As IBuffer Ptr Ptr _
	)As HRESULT
	Return HttpWriterGetBuffer(ContainerOf(this, HttpWriter, lpVtbl), ppResult)
End Function

Function IHttpWriterSetBuffer( _
		ByVal this As IHttpWriter Ptr, _
		ByVal pIBuffer As IBuffer Ptr _
	)As HRESULT
	Return HttpWriterSetBuffer(ContainerOf(this, HttpWriter, lpVtbl), pIBuffer)
End Function

Function IHttpWriterBeginWrite( _
		ByVal this As IHttpWriter Ptr, _
		ByVal Headers As LPVOID, _
		ByVal HeadersLength As DWORD, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return HttpWriterBeginWrite(ContainerOf(this, HttpWriter, lpVtbl), Headers, HeadersLength, StateObject, ppIAsyncResult)
End Function

Function IHttpWriterEndWrite( _
		ByVal this As IHttpWriter Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	Return HttpWriterEndWrite(ContainerOf(this, HttpWriter, lpVtbl), pIAsyncResult)
End Function

Dim GlobalHttpWriterVirtualTable As Const IHttpWriterVirtualTable = Type( _
	@IHttpWriterQueryInterface, _
	@IHttpWriterAddRef, _
	@IHttpWriterRelease, _
	@IHttpWriterGetBaseStream, _
	@IHttpWriterSetBaseStream, _
	@IHttpWriterGetBuffer, _
	@IHttpWriterSetBuffer, _
	@IHttpWriterBeginWrite, _
	@IHttpWriterEndWrite _
)
