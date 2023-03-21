#include once "AsyncResult.bi"
#include once "ContainerOf.bi"
#include once "HttpWriter.bi"
#include once "IFileStream.bi"
#include once "ThreadPool.bi"

Extern GlobalHttpWriterVirtualTable As Const IHttpWriterVirtualTable

Enum WriterTasks
	WritePreloadedBytesToNetwork
	ReadFileStream
	WriteNetworkData
	WritePreloadedBytesToFile
	ReadNetworkStream
	WriteFileData
End Enum

Type HeadersBodyBuffer
	Buf(1) As BaseStreamBuffer
End Type

Type _HttpWriter
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IHttpWriterVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pIStream As IBaseStream Ptr
	StreamBuffer As HeadersBodyBuffer
	pIBuffer As IAttributedStream Ptr
	pIResponse As IServerResponse Ptr
	CurrentTask As WriterTasks
	Headers As ZString Ptr
	HeadersOffset As LongInt
	HeadersLength As LongInt
	HeadersEndIndex As LongInt
	BodyOffset As LongInt
	BodyEndIndex As LongInt
	StreamBufferLength As Integer
	HeadersSended As Boolean
	BodySended As Boolean
	SendOnlyHeaders As Boolean
	KeepAlive As Boolean
End Type

Sub InitializeHttpWriter( _
		ByVal this As HttpWriter Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_HTTPWRITER), _
			Len(HttpWriter.IdString) _
		)
	#endif
	this->lpVtbl = @GlobalHttpWriterVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIStream = NULL
	this->pIBuffer = NULL
	this->pIResponse = NULL
	this->BodyOffset = 0
	this->KeepAlive = True
	
End Sub

Sub UnInitializeHttpWriter( _
		ByVal this As HttpWriter Ptr _
	)
	
	If this->pIStream Then
		IBaseStream_Release(this->pIStream)
	End If
	
	If this->pIBuffer Then
		IAttributedStream_Release(this->pIBuffer)
	End If
	
	If this->pIResponse Then
		IServerResponse_Release(this->pIResponse)
	End If
	
End Sub

Sub HttpWriterCreated( _
		ByVal this As HttpWriter Ptr _
	)
	
End Sub

Function CreateHttpWriter( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Dim this As HttpWriter Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(HttpWriter) _
	)
	
	If this Then
		InitializeHttpWriter(this, pIMemoryAllocator)
		HttpWriterCreated(this)
		
		Dim hrQueryInterface As HRESULT = HttpWriterQueryInterface( _
			this, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyHttpWriter(this)
		End If
		
		Return hrQueryInterface
	End If
	
	*ppv = NULL
	Return E_OUTOFMEMORY
	
End Function

Sub HttpWriterDestroyed( _
		ByVal this As HttpWriter Ptr _
	)
	
End Sub

Sub DestroyHttpWriter( _
		ByVal this As HttpWriter Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeHttpWriter(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	HttpWriterDestroyed(this)
	
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
	
	this->ReferenceCounter += 1
	
	Return 1
	
End Function

Function HttpWriterRelease( _
		ByVal this As HttpWriter Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyHttpWriter(this)
	
	Return 0
	
End Function

Function HttpWriterGetBaseStream( _
		ByVal this As HttpWriter Ptr, _
		ByVal ppResult As IBaseStream Ptr Ptr _
	)As HRESULT
	
	If this->pIStream Then
		IBaseStream_AddRef(this->pIStream)
	End If
	
	*ppResult = this->pIStream
	
	Return S_OK
	
End Function

Function HttpWriterSetBaseStream( _
		ByVal this As HttpWriter Ptr, _
		ByVal pIStream As IBaseStream Ptr _
	)As HRESULT
	
	If this->pIStream Then
		IBaseStream_Release(this->pIStream)
	End If
	
	If pIStream Then
		IBaseStream_AddRef(pIStream)
	End If
	
	this->pIStream = pIStream
	
	Return S_OK
	
End Function

Function HttpWriterGetBuffer( _
		ByVal this As HttpWriter Ptr, _
		ByVal ppResult As IAttributedStream Ptr Ptr _
	)As HRESULT
	
	If this->pIBuffer Then
		IAttributedStream_AddRef(this->pIBuffer)
	End If
	
	*ppResult = this->pIBuffer
	
	Return S_OK
	
End Function

Function HttpWriterSetBuffer( _
		ByVal this As HttpWriter Ptr, _
		ByVal pIBuffer As IAttributedStream Ptr _
	)As HRESULT
	
	If this->pIBuffer Then
		IAttributedStream_Release(this->pIBuffer)
	End If
	
	If pIBuffer Then
		IAttributedStream_AddRef(pIBuffer)
	End If
	
	this->pIBuffer = pIBuffer
	
	Return S_OK
	
End Function

Sub HttpWriterSinkResponse( _
		ByVal this As HttpWriter Ptr, _
		ByVal pIResponse As IServerResponse Ptr _
	)
	
	If this->pIResponse Then
		IServerResponse_Release(this->pIResponse)
	End If
	
	If pIResponse Then
		IServerResponse_AddRef(pIResponse)
	End If
	
	this->pIResponse = pIResponse
	
End Sub

Function HttpWriterPrepare( _
		ByVal this As HttpWriter Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal ContentLength As LongInt, _
		ByVal fFileAccess As FileAccess _
	)As HRESULT
	
	HttpWriterSinkResponse(this, pIResponse)
	
	this->HeadersOffset = 0
	this->HeadersSended = False
	
	Dim ResponseContentLength As LongInt = Any
	If fFileAccess = FileAccess.ReadAccess Then
		ResponseContentLength = ContentLength
	Else
		ResponseContentLength = 0
	End If
	
	Dim hrHeadersToString As HRESULT = IServerResponse_AllHeadersToZString( _
		pIResponse, _
		ResponseContentLength, _
		@this->Headers, _
		@this->HeadersLength _
	)
	If FAILED(hrHeadersToString) Then
		Return hrHeadersToString
	End If
	
	IServerResponse_GetSendOnlyHeaders(pIResponse, @this->SendOnlyHeaders)
	
	If this->SendOnlyHeaders Then
		this->BodySended = True
	Else
		this->BodySended = False
	End If
	
	Dim ByteRangeLength As LongInt = Any
	IServerResponse_GetByteRange( _
		pIResponse, _
		@this->BodyOffset, _
		@ByteRangeLength _
	)
	
	Dim BodyContentLength As LongInt = Any
	If ByteRangeLength Then
		BodyContentLength = ByteRangeLength
	Else
		BodyContentLength = ContentLength
	End If
	
	this->HeadersEndIndex = this->HeadersLength
	this->BodyEndIndex = this->BodyOffset + BodyContentLength
	
	Select Case fFileAccess
		
		Case FileAccess.ReadAccess
			this->CurrentTask = WriterTasks.ReadFileStream
			
		Case FileAccess.CreateAccess, FileAccess.UpdateAccess
			this->CurrentTask = WriterTasks.WritePreloadedBytesToFile
			
	End Select
	
	Return S_OK
	
End Function

Function HttpWriterBeginWrite( _
		ByVal this As HttpWriter Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Dim cTask As WriterTasks = this->CurrentTask
	
	Select Case cTask
		
		Case WriterTasks.WritePreloadedBytesToNetwork
			
		Case WriterTasks.ReadFileStream
			If this->BodySended Then
				If this->HeadersSended Then
					*ppIAsyncResult = NULL
					Return S_FALSE
				End If
				
				Dim pINewAsyncResult As IAsyncResult Ptr = Any
				Dim hrCreateAsyncResult As HRESULT = CreateAsyncResult( _
					this->pIMemoryAllocator, _
					@IID_IAsyncResult, _
					@pINewAsyncResult _
				)
				If FAILED(hrCreateAsyncResult) Then
					*ppIAsyncResult = NULL
					Return hrCreateAsyncResult
				End If
				
				Dim pOverlap As OVERLAPPED Ptr = Any
				IAsyncResult_GetWsaOverlapped(pINewAsyncResult, @pOverlap)
				
				IAsyncResult_SetAsyncStateWeakPtr(pINewAsyncResult, StateObject)
				
				*ppIAsyncResult = pINewAsyncResult
				
				Dim resStatus As BOOL = PostQueuedCompletionStatus( _
					ThreadPoolCompletionPort, _
					BUFFERSLICECHUNK_SIZE, _
					Cast(ULONG_PTR, StateObject), _
					pOverlap _
				)
				If resStatus = 0 Then
					Dim dwError As DWORD = GetLastError()
					IAsyncResult_Release(pINewAsyncResult)
					*ppIAsyncResult = NULL
					Return HRESULT_FROM_WIN32(dwError)
				End If
				
			Else
				Dim DesiredSliceLength As LongInt = min( _
					BUFFERSLICECHUNK_SIZE, _
					this->BodyEndIndex - this->BodyOffset _
				)
				
				Dim hrBeginGetSlice As HRESULT = IAttributedStream_BeginReadSlice( _
					this->pIBuffer, _
					this->BodyOffset, _
					DesiredSliceLength, _
					StateObject, _
					ppIAsyncResult _
				)
				If FAILED(hrBeginGetSlice) Then
					Return hrBeginGetSlice
				End If
				
			End If
			
		Case WriterTasks.WriteNetworkData
			Dim hrBeginWrite As HRESULT = Any
			
			If this->KeepAlive Then
				hrBeginWrite = IBaseStream_BeginWriteGather( _
					this->pIStream, _
					@this->StreamBuffer.Buf(0), _
					this->StreamBufferLength, _
					NULL, _
					StateObject, _
					ppIAsyncResult _
				)
			Else
				hrBeginWrite = IBaseStream_BeginWriteGatherAndShutdown( _
					this->pIStream, _
					@this->StreamBuffer.Buf(0), _
					this->StreamBufferLength, _
					NULL, _
					StateObject, _
					ppIAsyncResult _
				)
			End If
			
			If FAILED(hrBeginWrite) Then
				Return hrBeginWrite
			End If
			
		Case WriterTasks.WritePreloadedBytesToFile
			Dim pIFileStream As IFileStream Ptr = CPtr(IFileStream Ptr, this->pIBuffer)
			Dim PreloadedBytesLength As Integer = Any
			Dim pPreloadedBytes As UByte Ptr = Any
			IAttributedStream_GetPreloadedBytes( _
				this->pIBuffer, _
				@PreloadedBytesLength, _
				@pPreloadedBytes _
			)
			
			If PreloadedBytesLength Then
				Dim Slice As BufferSlice = Any
				With Slice
					.pSlice = pPreloadedBytes
					.Length = PreloadedBytesLength
				End With
				
				Dim hrBeginWrite As HRESULT = IFileStream_BeginWriteSlice( _
					pIFileStream, _
					@Slice, _
					this->BodyOffset, _
					StateObject, _
					ppIAsyncResult _
				)
				
				If FAILED(hrBeginWrite) Then
					Return hrBeginWrite
				End If
				
			Else
				this->CurrentTask = WriterTasks.ReadNetworkStream
				
				Dim ReservedBytesLength As Integer = Any
				Dim pReservedBytes As UByte Ptr = Any
				Dim hrGetReservedBytes As HRESULT = IFileStream_GetReservedBytes( _
					pIFileStream, _
					@ReservedBytesLength, _
					@pReservedBytes _
				)
				If FAILED(hrGetReservedBytes) Then
					Return hrGetReservedBytes
				End If
				
				Dim hrBeginRead As HRESULT = IBaseStream_BeginRead( _
					this->pIStream, _
					pReservedBytes, _
					ReservedBytesLength, _
					NULL, _
					StateObject, _
					ppIAsyncResult _
				)
				
				If FAILED(hrBeginRead) Then
					Return hrBeginRead
				End If
				
			End If
			
		Case WriterTasks.ReadNetworkStream
			
		Case WriterTasks.WriteFileData
			
	End Select
	
	Return HTTPWRITER_S_IO_PENDING
	
End Function

Function HttpWriterEndWrite( _
		ByVal this As HttpWriter Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	
	Dim cTask As WriterTasks = this->CurrentTask
	
	Select Case cTask
		
		Case WriterTasks.WritePreloadedBytesToNetwork
			
		Case WriterTasks.ReadFileStream
			If this->BodySended Then
				If this->HeadersSended Then
					Return S_FALSE
				End If
				
				this->StreamBufferLength = 1
				this->StreamBuffer.Buf(0).Buffer = @this->Headers[this->HeadersOffset]
				this->StreamBuffer.Buf(0).Length = this->HeadersLength - this->HeadersOffset
			Else
				
				Dim Slice As BufferSlice = Any
				Dim hrEndGetSlice As HRESULT = IAttributedStream_EndReadSlice( _
					this->pIBuffer, _
					pIAsyncResult, _
					@Slice _
				)
				If FAILED(hrEndGetSlice) Then
					Return hrEndGetSlice
				End If
				
				If this->HeadersSended Then
					this->StreamBufferLength = 1
					
					this->StreamBuffer.Buf(0).Buffer = Slice.pSlice
					this->StreamBuffer.Buf(0).Length = Slice.Length
				Else
					this->StreamBufferLength = 2
					
					this->StreamBuffer.Buf(0).Buffer = @this->Headers[this->HeadersOffset]
					this->StreamBuffer.Buf(0).Length = this->HeadersLength - this->HeadersOffset
					this->StreamBuffer.Buf(1).Buffer = Slice.pSlice
					this->StreamBuffer.Buf(1).Length = Slice.Length
				End If
				
			End If
			
			this->CurrentTask = WriterTasks.WriteNetworkData
			
		Case WriterTasks.WriteNetworkData
			Dim dwWritedBytes As DWORD = Any
			Dim hrEndWrite As HRESULT = IBaseStream_EndWrite( _
				this->pIStream, _
				pIAsyncResult, _
				@dwWritedBytes _
			)
			If FAILED(hrEndWrite) Then
				Return hrEndWrite
			End If
			
			If this->HeadersSended Then
				this->BodyOffset += CLngInt(dwWritedBytes)
			Else
				Dim HeadersSize As LongInt = this->HeadersLength - this->HeadersOffset
				Dim HeadersWritedBytes As LongInt = min(CLngInt(dwWritedBytes), HeadersSize)
				
				this->HeadersOffset += HeadersWritedBytes
				
				If this->HeadersOffset >= this->HeadersEndIndex Then
					this->HeadersSended = True
				End If
				
				Dim BodyWritedBytes As LongInt = CLngInt(dwWritedBytes) - HeadersWritedBytes
				this->BodyOffset += CLngInt(BodyWritedBytes)
				
			End If
			
			If this->BodyOffset >= this->BodyEndIndex Then
				this->BodySended = True
			End If
			
			If hrEndWrite = S_FALSE Then
				Return S_FALSE
			End If
			
			If this->BodySended Then
				Return S_OK
			End If
			
			this->CurrentTask = WriterTasks.ReadFileStream
			
		Case WriterTasks.WritePreloadedBytesToFile
			Dim pIFileStream As IFileStream Ptr = CPtr(IFileStream Ptr, this->pIBuffer)
			Dim WritedBytes As DWORD = Any
			Dim hrEndGetSlice As HRESULT = IFileStream_EndWriteSlice( _
				pIFileStream, _
				pIAsyncResult, _
				@WritedBytes _
			)
			If FAILED(hrEndGetSlice) Then
				Return hrEndGetSlice
			End If
			
			this->BodyOffset += CLngInt(WritedBytes)
			
			If hrEndGetSlice = S_FALSE Then
				Return S_FALSE
			End If
			
			If this->BodySended Then
				this->StreamBufferLength = 1
				this->StreamBuffer.Buf(0).Buffer = @this->Headers[this->HeadersOffset]
				this->StreamBuffer.Buf(0).Length = this->HeadersLength - this->HeadersOffset
				
				this->CurrentTask = WriterTasks.WriteNetworkData
			Else
				Dim PreloadedBytesLength As Integer = Any
				Dim pPreloadedBytes As UByte Ptr = Any
				IAttributedStream_GetPreloadedBytes( _
					this->pIBuffer, _
					@PreloadedBytesLength, _
					@pPreloadedBytes _
				)
				
				If PreloadedBytesLength >= this->BodyOffset Then
					this->CurrentTask = WriterTasks.ReadNetworkStream
				End If
			End If
			
		Case WriterTasks.ReadNetworkStream
			this->CurrentTask = WriterTasks.WriteFileData
			
		Case WriterTasks.WriteFileData
			this->CurrentTask = WriterTasks.ReadNetworkStream
			
	End Select
	
	Return HTTPWRITER_S_IO_PENDING
	
End Function

Function HttpWriterSetKeepAlive( _
		ByVal this As HttpWriter Ptr, _
		ByVal KeepAlive As Boolean _
	)As HRESULT
	
	this->KeepAlive = KeepAlive
	
	Return S_OK
	
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
		ByVal ppResult As IAttributedStream Ptr Ptr _
	)As HRESULT
	Return HttpWriterGetBuffer(ContainerOf(this, HttpWriter, lpVtbl), ppResult)
End Function

Function IHttpWriterSetBuffer( _
		ByVal this As IHttpWriter Ptr, _
		ByVal pIBuffer As IAttributedStream Ptr _
	)As HRESULT
	Return HttpWriterSetBuffer(ContainerOf(this, HttpWriter, lpVtbl), pIBuffer)
End Function

Function IHttpWriterPrepare( _
		ByVal this As IHttpWriter Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal ContentLength As LongInt, _
		ByVal fFileAccess As FileAccess _
	)As HRESULT
	Return HttpWriterPrepare(ContainerOf(this, HttpWriter, lpVtbl), pIResponse, ContentLength, fFileAccess)
End Function

Function IHttpWriterBeginWrite( _
		ByVal this As IHttpWriter Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return HttpWriterBeginWrite(ContainerOf(this, HttpWriter, lpVtbl), StateObject, ppIAsyncResult)
End Function

Function IHttpWriterEndWrite( _
		ByVal this As IHttpWriter Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	Return HttpWriterEndWrite(ContainerOf(this, HttpWriter, lpVtbl), pIAsyncResult)
End Function

Function IHttpWriterSetKeepAlive( _
		ByVal this As IHttpWriter Ptr, _
		ByVal KeepAlive As Boolean _
	)As HRESULT
	Return HttpWriterSetKeepAlive(ContainerOf(this, HttpWriter, lpVtbl), KeepAlive)
End Function

Dim GlobalHttpWriterVirtualTable As Const IHttpWriterVirtualTable = Type( _
	@IHttpWriterQueryInterface, _
	@IHttpWriterAddRef, _
	@IHttpWriterRelease, _
	@IHttpWriterGetBaseStream, _
	@IHttpWriterSetBaseStream, _
	@IHttpWriterGetBuffer, _
	@IHttpWriterSetBuffer, _
	@IHttpWriterPrepare, _
	@IHttpWriterBeginWrite, _
	@IHttpWriterEndWrite, _
	@IHttpWriterSetKeepAlive _
)
