#include once "HttpTraceProcessor.bi"
#include once "MemoryAsyncStream.bi"

Extern GlobalHttpTraceProcessorVirtualTable As Const IHttpTraceAsyncProcessorVirtualTable

Type HttpTraceProcessor
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IHttpTraceAsyncProcessorVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
End Type

Private Sub InitializeHttpTraceProcessor( _
		ByVal self As HttpTraceProcessor Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@self->RttiClassName(0), _
			@Str(RTTI_ID_HTTPTRACEPROCESSOR), _
			UBound(self->RttiClassName) - LBound(self->RttiClassName) + 1 _
		)
	#endif
	self->lpVtbl = @GlobalHttpTraceProcessorVirtualTable
	self->ReferenceCounter = CUInt(-1)
	IMalloc_AddRef(pIMemoryAllocator)
	self->pIMemoryAllocator = pIMemoryAllocator

End Sub

Private Sub UnInitializeHttpTraceProcessor( _
		ByVal self As HttpTraceProcessor Ptr _
	)

End Sub

Private Sub DestroyHttpTraceProcessor( _
		ByVal self As HttpTraceProcessor Ptr _
	)

	Dim pIMemoryAllocator As IMalloc Ptr = self->pIMemoryAllocator

	UnInitializeHttpTraceProcessor(self)

	IMalloc_Free(pIMemoryAllocator, self)

	IMalloc_Release(pIMemoryAllocator)

End Sub

Private Function HttpTraceProcessorAddRef( _
		ByVal self As HttpTraceProcessor Ptr _
	)As ULONG

	Return 1

End Function

Private Function HttpTraceProcessorRelease( _
		ByVal self As HttpTraceProcessor Ptr _
	)As ULONG

	Return 0

End Function

Private Function HttpTraceProcessorQueryInterface( _
		ByVal self As HttpTraceProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_IHttpTraceAsyncProcessor, riid) Then
		*ppv = @self->lpVtbl
	Else
		If IsEqualIID(@IID_IHttpAsyncProcessor, riid) Then
			*ppv = @self->lpVtbl
		Else
			If IsEqualIID(@IID_IUnknown, riid) Then
				*ppv = @self->lpVtbl
			Else
				*ppv = NULL
				Return E_NOINTERFACE
			End If
		End If
	End If

	HttpTraceProcessorAddRef(self)

	Return S_OK

End Function

Public Function CreateHttpTraceProcessor( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	Dim self As HttpTraceProcessor Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(HttpTraceProcessor) _
	)

	If self Then
		InitializeHttpTraceProcessor(self, pIMemoryAllocator)

		Dim hrQueryInterface As HRESULT = HttpTraceProcessorQueryInterface( _
			self, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyHttpTraceProcessor(self)
		End If

		Return hrQueryInterface
	End If

	*ppv = NULL
	Return E_OUTOFMEMORY

End Function

Private Function HttpTraceProcessorPrepare( _
		ByVal self As HttpTraceProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal ppIBuffer As IAttributedAsyncStream Ptr Ptr _
	)As HRESULT

	Dim pIBuffer As IMemoryStream Ptr = Any
	Dim hrCreateBuffer As HRESULT = CreateMemoryStream( _
		self->pIMemoryAllocator, _
		@IID_IMemoryStream, _
		@pIBuffer _
	)
	If FAILED(hrCreateBuffer) Then
		*ppIBuffer = NULL
		Return hrCreateBuffer
	End If

	Dim RequestedBytesLength As Integer = Any
	Dim pRequestedBytes As UByte Ptr = Any
	IHttpAsyncReader_GetRequestedBytes( _
		pContext->pIReader, _
		@RequestedBytesLength, _
		@pRequestedBytes _
	)

	IMemoryStream_SetBuffer( _
		pIBuffer, _
		pRequestedBytes, _
		RequestedBytesLength _
	)

	Scope
		Dim Mime As MimeType = Any
		With Mime
			.ContentType = ContentTypes.MessageHttp
			.CharsetWeakPtr = NULL
			.Format = MimeFormats.Text
		End With

		IServerResponse_SetMimeType(pContext->pIResponse, @Mime)
	End Scope

	Dim hrPrepareResponse As HRESULT = IHttpAsyncWriter_Prepare( _
		pContext->pIWriter, _
		pContext->pIResponse, _
		CLngInt(RequestedBytesLength), _
		FileAccess.ReadAccess _
	)
	If FAILED(hrPrepareResponse) Then
		IMemoryStream_Release(pIBuffer)
		*ppIBuffer = NULL
		Return hrPrepareResponse
	End If

	*ppIBuffer = CPtr(IAttributedAsyncStream Ptr, pIBuffer)

	Return S_OK

End Function

Private Function HttpTraceProcessorBeginProcess( _
		ByVal self As HttpTraceProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	Dim hrBeginWrite As HRESULT = IHttpAsyncWriter_BeginWrite( _
		pContext->pIWriter, _
		pcb, _
		StateObject, _
		ppIAsyncResult _
	)
	If FAILED(hrBeginWrite) Then
		Return hrBeginWrite
	End If

	Return HTTPASYNCPROCESSOR_S_IO_PENDING

End Function

Private Function HttpTraceProcessorEndProcess( _
		ByVal self As HttpTraceProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT

	Dim hrEndWrite As HRESULT = IHttpAsyncWriter_EndWrite( _
		pContext->pIWriter, _
		pIAsyncResult _
	)
	If FAILED(hrEndWrite) Then
		Return hrEndWrite
	End If

	Select Case hrEndWrite

		Case S_OK
			Return S_OK

		Case S_FALSE
			Return S_FALSE

		Case HTTPWRITER_S_IO_PENDING
			Return HTTPASYNCPROCESSOR_S_IO_PENDING

	End Select

	Return S_OK

End Function


Private Function IHttpTraceProcessorQueryInterface( _
		ByVal self As IHttpTraceAsyncProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return HttpTraceProcessorQueryInterface(CONTAINING_RECORD(self, HttpTraceProcessor, lpVtbl), riid, ppv)
End Function

Private Function IHttpTraceProcessorAddRef( _
		ByVal self As IHttpTraceAsyncProcessor Ptr _
	)As ULONG
	Return HttpTraceProcessorAddRef(CONTAINING_RECORD(self, HttpTraceProcessor, lpVtbl))
End Function

Private Function IHttpTraceProcessorRelease( _
		ByVal self As IHttpTraceAsyncProcessor Ptr _
	)As ULONG
	Return HttpTraceProcessorRelease(CONTAINING_RECORD(self, HttpTraceProcessor, lpVtbl))
End Function

Private Function IHttpTraceProcessorPrepare( _
		ByVal self As IHttpTraceAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal ppIBuffer As IAttributedAsyncStream Ptr Ptr _
	)As HRESULT
	Return HttpTraceProcessorPrepare(CONTAINING_RECORD(self, HttpTraceProcessor, lpVtbl), pContext, ppIBuffer)
End Function

Private Function IHttpTraceProcessorBeginProcess( _
		ByVal self As IHttpTraceAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return HttpTraceProcessorBeginProcess(CONTAINING_RECORD(self, HttpTraceProcessor, lpVtbl), pContext, pcb, StateObject, ppIAsyncResult)
End Function

Private Function IHttpTraceProcessorEndProcess( _
		ByVal self As IHttpTraceAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	Return HttpTraceProcessorEndProcess(CONTAINING_RECORD(self, HttpTraceProcessor, lpVtbl), pContext, pIAsyncResult)
End Function

Dim GlobalHttpTraceProcessorVirtualTable As Const IHttpTraceAsyncProcessorVirtualTable = Type( _
	@IHttpTraceProcessorQueryInterface, _
	@IHttpTraceProcessorAddRef, _
	@IHttpTraceProcessorRelease, _
	@IHttpTraceProcessorPrepare, _
	@IHttpTraceProcessorBeginProcess, _
	@IHttpTraceProcessorEndProcess _
)
