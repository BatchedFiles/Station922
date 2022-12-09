#include once "HttpWriter.bi"
#include once "ContainerOf.bi"
#include once "Logger.bi"

Extern GlobalHttpWriterVirtualTable As Const IHttpWriterVirtualTable

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
	pIBuffer As IAttributedStream Ptr
	Headers As ZString Ptr
	HeadersOffset As LongInt
	HeadersLength As LongInt
	HeadersEndIndex As LongInt
	BodyOffset As LongInt
	BodyContentLength As LongInt
	BodyEndIndex As LongInt
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
	this->BodyOffset = 0
	this->BodyContentLength = 0
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
	
End Sub

Function CreateHttpWriter( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As HttpWriter Ptr
	
	Dim this As HttpWriter Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(HttpWriter) _
	)
	
	If this Then
		
		InitializeHttpWriter( _
			this, _
			pIMemoryAllocator _
		)
		
		Return this
	End If
	
	Return NULL
	
End Function

Sub DestroyHttpWriter( _
		ByVal this As HttpWriter Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeHttpWriter(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
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

Function HttpWriterPrepare( _
		ByVal this As HttpWriter Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal ContentLength As LongInt _
	)As HRESULT
	
	Dim hrHeadersToString As HRESULT = IServerResponse_AllHeadersToZString( _
		pIResponse, _
		ContentLength, _
		@this->Headers, _
		@this->HeadersLength _
	)
	If FAILED(hrHeadersToString) Then
		Return hrHeadersToString
	End If
	
	this->HeadersOffset = 0
	
	IServerResponse_GetSendOnlyHeaders(pIResponse, @this->SendOnlyHeaders)
	
	If this->SendOnlyHeaders Then
		this->BodySended = True
	Else
		this->BodySended = False
	End If
	
	this->HeadersSended = False
	
	Dim ByteRangeLength As LongInt = Any
	IServerResponse_GetByteRange( _
		pIResponse, _
		@this->BodyOffset, _
		@ByteRangeLength _
	)
	
	If ByteRangeLength = 0 Then
		this->BodyContentLength = ContentLength
	Else
		this->BodyContentLength = ByteRangeLength
	End If
	
	this->HeadersEndIndex = this->HeadersOffset + this->HeadersLength
	this->BodyEndIndex = this->BodyOffset + this->BodyContentLength
	
	Return S_OK
	
End Function

Function HttpWriterBeginWrite( _
		ByVal this As HttpWriter Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Dim StreamBuffer As HeadersBodyBuffer = Any
	Dim StreamBufferLength As Integer = Any
	
	If this->BodySended Then
		If this->HeadersSended Then
			Return S_FALSE
		End If
		
		StreamBufferLength = 1
		
		StreamBuffer.Buf(0).Buffer = @this->Headers[this->HeadersOffset]
		StreamBuffer.Buf(0).Length = this->HeadersLength - this->HeadersOffset
	Else
		Dim DesiredSliceLength As LongInt = min(BUFFERSLICECHUNK_SIZE, this->BodyEndIndex - this->BodyOffset)
		
		Dim Slice As BufferSlice = Any
		Dim hrGetSlice As HRESULT = IAttributedStream_GetSlice( _
			this->pIBuffer, _
			this->BodyOffset, _
			Cast(DWORD, DesiredSliceLength), _
			@Slice _
		)
		If FAILED(hrGetSlice) Then
			Return hrGetSlice
		End If
		
		If this->HeadersSended Then
			StreamBufferLength = 1
			
			StreamBuffer.Buf(0).Buffer = Slice.pSlice
			StreamBuffer.Buf(0).Length = Slice.Length
		Else
			StreamBufferLength = 2
			
			StreamBuffer.Buf(0).Buffer = @this->Headers[this->HeadersOffset]
			StreamBuffer.Buf(0).Length = this->HeadersLength - this->HeadersOffset
			
			StreamBuffer.Buf(1).Buffer = Slice.pSlice
			StreamBuffer.Buf(1).Length = Slice.Length
		End If
	End If
	
	Dim hrBeginWrite As HRESULT = Any
	
	If this->KeepAlive Then
		hrBeginWrite = IBaseStream_BeginWriteGather( _
			this->pIStream, _
			@StreamBuffer.Buf(0), _
			StreamBufferLength, _
			NULL, _
			StateObject, _
			ppIAsyncResult _
		)
	Else
		hrBeginWrite = IBaseStream_BeginWriteGatherAndShutdown( _
			this->pIStream, _
			@StreamBuffer.Buf(0), _
			StreamBufferLength, _
			NULL, _
			StateObject, _
			ppIAsyncResult _
		)
	End If
	
	If FAILED(hrBeginWrite) Then
		Return hrBeginWrite
	End If
	
	Return HTTPWRITER_S_IO_PENDING
	
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
	
	If this->HeadersSended Then
		this->BodyOffset += CLngInt(WritedBytes)
	Else
		Dim HeadersSize As LongInt = this->HeadersLength - this->HeadersOffset
		Dim HeadersWritedBytes As LongInt = min(CLngInt(WritedBytes), HeadersSize)
		
		this->HeadersOffset += HeadersWritedBytes
		
		If this->HeadersOffset >= this->HeadersEndIndex Then
			this->HeadersSended = True
		End If
		
		Dim BodyWritedBytes As LongInt = CLngInt(WritedBytes) - HeadersWritedBytes
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
		ByVal ContentLength As LongInt _
	)As HRESULT
	Return HttpWriterPrepare(ContainerOf(this, HttpWriter, lpVtbl), pIResponse, ContentLength)
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
