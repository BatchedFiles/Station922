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

Function HttpWriterBeginWrite( _
		ByVal this As HttpWriter Ptr, _
		ByVal Headers As LPVOID, _
		ByVal HeadersLength As DWORD, _
		ByVal SendOnlyHeaders As Boolean, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Dim Slice As BufferSlice = Any
	Dim hrGetSlice As HRESULT = IBuffer_GetSlice( _
		this->pIBuffer, _
		this->WriterStartIndex, _
		BUFFERSLICECHUNK_SIZE, _
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
			If SendOnlyHeaders Then
				StreamBufferLength = 1
			Else
				StreamBufferLength = 2
				StreamBuffer.Buf(1).Buffer = Slice.pSlice
				StreamBuffer.Buf(1).Length = Slice.Length
			End If
		Else
			StreamBufferLength = 1
		End If
		
		this->WriterStartIndex = this->WriterStartIndex - HeadersLength
	End If
	
	If hrGetSlice = S_FALSE OrElse Slice.Length = 0 Then
		this->BodySended = True
	End If
	
	If SendOnlyHeaders Then
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
		ByVal SendOnlyHeaders As Boolean, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return HttpWriterBeginWrite(ContainerOf(this, HttpWriter, lpVtbl), Headers, HeadersLength, SendOnlyHeaders, StateObject, ppIAsyncResult)
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
