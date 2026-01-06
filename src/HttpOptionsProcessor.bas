#include once "HttpOptionsProcessor.bi"
#include once "HeapBSTR.bi"
#include once "MemoryAsyncStream.bi"

Extern GlobalHttpOptionsProcessorVirtualTable As Const IHttpOptionsAsyncProcessorVirtualTable

Const CompareResultEqual As Long = 0

Type HttpOptionsProcessor
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IHttpOptionsAsyncProcessorVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
End Type

Private Sub InitializeHttpOptionsProcessor( _
		ByVal self As HttpOptionsProcessor Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@self->RttiClassName(0), _
			@Str(RTTI_ID_HTTPOPTIONSPROCESSOR), _
			UBound(self->RttiClassName) - LBound(self->RttiClassName) + 1 _
		)
	#endif
	self->lpVtbl = @GlobalHttpOptionsProcessorVirtualTable
	self->ReferenceCounter = CUInt(-1)
	IMalloc_AddRef(pIMemoryAllocator)
	self->pIMemoryAllocator = pIMemoryAllocator

End Sub

Private Sub UnInitializeHttpOptionsProcessor( _
		ByVal self As HttpOptionsProcessor Ptr _
	)

End Sub

Private Sub DestroyHttpOptionsProcessor( _
		ByVal self As HttpOptionsProcessor Ptr _
	)

	Dim pIMemoryAllocator As IMalloc Ptr = self->pIMemoryAllocator

	UnInitializeHttpOptionsProcessor(self)

	IMalloc_Free(pIMemoryAllocator, self)

	IMalloc_Release(pIMemoryAllocator)

End Sub

Private Function HttpOptionsProcessorAddRef( _
		ByVal self As HttpOptionsProcessor Ptr _
	)As ULONG

	Return 1

End Function

Private Function HttpOptionsProcessorRelease( _
		ByVal self As HttpOptionsProcessor Ptr _
	)As ULONG

	Return 0

End Function

Private Function HttpOptionsProcessorQueryInterface( _
		ByVal self As HttpOptionsProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_IHttpOptionsAsyncProcessor, riid) Then
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

	HttpOptionsProcessorAddRef(self)

	Return S_OK

End Function

Public Function CreateHttpOptionsProcessor( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	Dim self As HttpOptionsProcessor Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(HttpOptionsProcessor) _
	)

	If self Then
		InitializeHttpOptionsProcessor(self, pIMemoryAllocator)

		Dim hrQueryInterface As HRESULT = HttpOptionsProcessorQueryInterface( _
			self, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyHttpOptionsProcessor(self)
		End If

		Return hrQueryInterface
	End If

	*ppv = NULL
	Return E_OUTOFMEMORY

End Function

Private Function AddHeaderAllow( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT

	Dim pHeaderAllow As WString Ptr = Any
	Dim HeaderAllowLength As Integer = Any

	Scope
		' TODO Get all methods from website
		Const AllServerMethods = WStr("GET, HEAD, OPTIONS, PUT, TRACE")
		Const AllServerMethodsForFile = WStr("GET, HEAD, OPTIONS, PUT, TRACE")
		Const AllServerMethodsForScript = WStr("GET, HEAD, OPTIONS, PUT, TRACE")

		Dim ClientURI As IClientUri Ptr = Any
		IClientRequest_GetUri(pIRequest, @ClientURI)

		Dim Path As HeapBSTR = Any
		IClientUri_GetPath(ClientURI, @Path)

		Dim CompareResult As Long = lstrcmpW(Path, WStr("*"))

		If CompareResult = CompareResultEqual Then
			pHeaderAllow = @AllServerMethods
			HeaderAllowLength = Len(AllServerMethods)
		Else
			Dim NeedProcessing As Boolean = Any
			IWebSite_NeedCgiProcessing( _
				pIWebSite, _
				Path, _
				@NeedProcessing _
			)

			If NeedProcessing Then
				pHeaderAllow = @AllServerMethodsForScript
				HeaderAllowLength = Len(AllServerMethodsForScript)
			Else
				pHeaderAllow = @AllServerMethodsForFile
				HeaderAllowLength = Len(AllServerMethodsForFile)
			End If

		End If

		HeapSysFreeString(Path)
		IClientUri_Release(ClientURI)
	End Scope

	Dim hrAddHeader As HRESULT = IServerResponse_AddKnownResponseHeaderWstrLen( _
		pIResponse, _
		HttpResponseHeaders.HeaderAllow, _
		pHeaderAllow, _
		HeaderAllowLength _
	)
	If FAILED(hrAddHeader) Then
		Return hrAddHeader
	End If

	Return S_OK

End Function

Private Function HttpOptionsProcessorPrepare( _
		ByVal self As HttpOptionsProcessor Ptr, _
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

	Dim hrAddHeaser As HRESULT = AddHeaderAllow( _
		pContext->pIRequest, _
		pContext->pIResponse, _
		pContext->pIWebSite _
	)
	If FAILED(hrAddHeaser) Then
		IMemoryStream_Release(pIBuffer)
		*ppIBuffer = NULL
		Return hrAddHeaser
	End If

	IMemoryStream_SetBuffer( _
		pIBuffer, _
		NULL, _
		0 _
	)

	IServerResponse_SetSendOnlyHeaders(pContext->pIResponse, True)
	IServerResponse_SetStatusCode(pContext->pIResponse, HttpStatusCodes.NoContent)

	Dim hrPrepareResponse As HRESULT = IHttpAsyncWriter_Prepare( _
		pContext->pIWriter, _
		pContext->pIResponse, _
		CLngInt(0), _
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

Private Function HttpOptionsProcessorBeginProcess( _
		ByVal self As HttpOptionsProcessor Ptr, _
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

Private Function HttpOptionsProcessorEndProcess( _
		ByVal self As HttpOptionsProcessor Ptr, _
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


Private Function IHttpOptionsProcessorQueryInterface( _
		ByVal self As IHttpOptionsAsyncProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return HttpOptionsProcessorQueryInterface(CONTAINING_RECORD(self, HttpOptionsProcessor, lpVtbl), riid, ppv)
End Function

Private Function IHttpOptionsProcessorAddRef( _
		ByVal self As IHttpOptionsAsyncProcessor Ptr _
	)As ULONG
	Return HttpOptionsProcessorAddRef(CONTAINING_RECORD(self, HttpOptionsProcessor, lpVtbl))
End Function

Private Function IHttpOptionsProcessorRelease( _
		ByVal self As IHttpOptionsAsyncProcessor Ptr _
	)As ULONG
	Return HttpOptionsProcessorRelease(CONTAINING_RECORD(self, HttpOptionsProcessor, lpVtbl))
End Function

Private Function IHttpOptionsProcessorPrepare( _
		ByVal self As IHttpOptionsAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal ppIBuffer As IAttributedAsyncStream Ptr Ptr _
	)As HRESULT
	Return HttpOptionsProcessorPrepare(CONTAINING_RECORD(self, HttpOptionsProcessor, lpVtbl), pContext, ppIBuffer)
End Function

Private Function IHttpOptionsProcessorBeginProcess( _
		ByVal self As IHttpOptionsAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return HttpOptionsProcessorBeginProcess(CONTAINING_RECORD(self, HttpOptionsProcessor, lpVtbl), pContext, pcb, StateObject, ppIAsyncResult)
End Function

Private Function IHttpOptionsProcessorEndProcess( _
		ByVal self As IHttpOptionsAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	Return HttpOptionsProcessorEndProcess(CONTAINING_RECORD(self, HttpOptionsProcessor, lpVtbl), pContext, pIAsyncResult)
End Function

Dim GlobalHttpOptionsProcessorVirtualTable As Const IHttpOptionsAsyncProcessorVirtualTable = Type( _
	@IHttpOptionsProcessorQueryInterface, _
	@IHttpOptionsProcessorAddRef, _
	@IHttpOptionsProcessorRelease, _
	@IHttpOptionsProcessorPrepare, _
	@IHttpOptionsProcessorBeginProcess, _
	@IHttpOptionsProcessorEndProcess _
)
