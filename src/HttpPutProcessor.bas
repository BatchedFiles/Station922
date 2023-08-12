#include once "HttpPutProcessor.bi"
#include once "ArrayStringWriter.bi"
#include once "CharacterConstants.bi"
#include once "ContainerOf.bi"
#include once "HeapBSTR.bi"
#include once "WebUtils.bi"

Extern GlobalHttpPutProcessorVirtualTable As Const IHttpPutAsyncProcessorVirtualTable

Const CompareResultEqual As Long = 0

Type _HttpPutProcessor
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IHttpPutAsyncProcessorVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
End Type

Private Sub InitializeHttpPutProcessor( _
		ByVal this As HttpPutProcessor Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->RttiClassName(0), _
			@Str(RTTI_ID_HTTPPUTPROCESSOR), _
			UBound(this->RttiClassName) - LBound(this->RttiClassName) + 1 _
		)
	#endif
	this->lpVtbl = @GlobalHttpPutProcessorVirtualTable
	this->ReferenceCounter = CUInt(-1)
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	
End Sub

Private Sub UnInitializeHttpPutProcessor( _
		ByVal this As HttpPutProcessor Ptr _
	)
	
End Sub

Private Sub HttpPutProcessorCreated( _
		ByVal this As HttpPutProcessor Ptr _
	)
	
End Sub

Private Sub HttpPutProcessorDestroyed( _
		ByVal this As HttpPutProcessor Ptr _
	)
	
End Sub

Private Sub DestroyHttpPutProcessor( _
		ByVal this As HttpPutProcessor Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeHttpPutProcessor(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	HttpPutProcessorDestroyed(this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Private Function HttpPutProcessorAddRef( _
		ByVal this As HttpPutProcessor Ptr _
	)As ULONG
	
	Return 1
	
End Function

Private Function HttpPutProcessorRelease( _
		ByVal this As HttpPutProcessor Ptr _
	)As ULONG
	
	Return 0
	
End Function

Private Function HttpPutProcessorQueryInterface( _
		ByVal this As HttpPutProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IHttpPutAsyncProcessor, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IHttpAsyncProcessor, riid) Then
			*ppv = @this->lpVtbl
		Else
			If IsEqualIID(@IID_IUnknown, riid) Then
				*ppv = @this->lpVtbl
			Else
				*ppv = NULL
				Return E_NOINTERFACE
			End If
		End If
	End If
	
	HttpPutProcessorAddRef(this)
	
	Return S_OK
	
End Function

Function CreateHttpPutProcessor( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Dim this As HttpPutProcessor Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(HttpPutProcessor) _
	)
	
	If this Then
		InitializeHttpPutProcessor(this, pIMemoryAllocator)
		HttpPutProcessorCreated(this)
		
		Dim hrQueryInterface As HRESULT = HttpPutProcessorQueryInterface( _
			this, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyHttpPutProcessor(this)
		End If
		
		Return hrQueryInterface
	End If
	
	*ppv = NULL
	Return E_OUTOFMEMORY
	
End Function

Private Function HttpPutProcessorPrepare( _
		ByVal this As HttpPutProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal ppIBuffer As IAttributedStream Ptr Ptr _
	)As HRESULT
	
	Dim ContentLength As LongInt = Any
	IClientRequest_GetContentLength(pContext->pIRequest, @ContentLength)
	
	If ContentLength <= 0 Then
		*ppIBuffer = NULL
		Return HTTPPROCESSOR_E_LENGTHREQUIRED
	End If
	
	Dim Flags As ContentNegotiationFlags = Any
	Dim pIBuffer As IAttributedStream Ptr = Any
	Dim hrGetBuffer As HRESULT = IWebSite_GetBuffer( _
		pContext->pIWebSite, _
		pContext->pIMemoryAllocator, _
		FileAccess.CreateAccess, _
		pContext->pIRequest, _
		pContext->pIReader, _
		ContentLength, _
		@Flags, _
		@pIBuffer _
	)
	If FAILED(hrGetBuffer) Then
		IHttpReader_SkipBytes(pContext->pIReader, ContentLength)
		*ppIBuffer = NULL
		Return hrGetBuffer
	End If
	
	Select Case hrGetBuffer
		
		Case WEBSITE_S_CREATE_NEW
			IServerResponse_SetStatusCode( _
				pContext->pIResponse, _
				HttpStatusCodes.Created _
			)
			
		Case WEBSITE_S_ALREADY_EXISTS
			IServerResponse_SetStatusCode( _
				pContext->pIResponse, _
				HttpStatusCodes.OK _
			)
			
	End Select
	
	Scope
		Dim NeedWrite100Continue As Boolean = Any
		IClientRequest_GetExpect100Continue( _
			pContext->pIRequest, _
			@NeedWrite100Continue _
		)
		IHttpWriter_SetNeedWrite100Continue( _
			pContext->pIWriter, _
			NeedWrite100Continue _
		)
	End Scope
	
	Dim hrPrepareResponse As HRESULT = IHttpWriter_Prepare( _
		pContext->pIWriter, _
		pContext->pIResponse, _
		ContentLength, _
		FileAccess.CreateAccess _
	)
	If FAILED(hrPrepareResponse) Then
		IAttributedStream_Release(pIBuffer)
		*ppIBuffer = NULL
		Return hrPrepareResponse
	End If
	
	*ppIBuffer = pIBuffer
	
	Return S_OK
	
End Function

Private Function HttpPutProcessorBeginProcess( _
		ByVal this As HttpPutProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Dim hrBeginWrite As HRESULT = IHttpWriter_BeginWrite( _
		pContext->pIWriter, _
		StateObject, _
		ppIAsyncResult _
	)
	If FAILED(hrBeginWrite) Then
		Return hrBeginWrite
	End If
	
	Return HTTPASYNCPROCESSOR_S_IO_PENDING
	
End Function

Private Function HttpPutProcessorEndProcess( _
		ByVal this As HttpPutProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	
	Dim hrEndWrite As HRESULT = IHttpWriter_EndWrite( _
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


Private Function IHttpPutProcessorQueryInterface( _
		ByVal this As IHttpPutAsyncProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return HttpPutProcessorQueryInterface(ContainerOf(this, HttpPutProcessor, lpVtbl), riid, ppv)
End Function

Private Function IHttpPutProcessorAddRef( _
		ByVal this As IHttpPutAsyncProcessor Ptr _
	)As ULONG
	Return HttpPutProcessorAddRef(ContainerOf(this, HttpPutProcessor, lpVtbl))
End Function

Private Function IHttpPutProcessorRelease( _
		ByVal this As IHttpPutAsyncProcessor Ptr _
	)As ULONG
	Return HttpPutProcessorRelease(ContainerOf(this, HttpPutProcessor, lpVtbl))
End Function

Private Function IHttpPutProcessorPrepare( _
		ByVal this As IHttpPutAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal ppIBuffer As IAttributedStream Ptr Ptr _
	)As HRESULT
	Return HttpPutProcessorPrepare(ContainerOf(this, HttpPutProcessor, lpVtbl), pContext, ppIBuffer)
End Function

Private Function IHttpPutProcessorBeginProcess( _
		ByVal this As IHttpPutAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return HttpPutProcessorBeginProcess(ContainerOf(this, HttpPutProcessor, lpVtbl), pContext, StateObject, ppIAsyncResult)
End Function

Private Function IHttpPutProcessorEndProcess( _
		ByVal this As IHttpPutAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	Return HttpPutProcessorEndProcess(ContainerOf(this, HttpPutProcessor, lpVtbl), pContext, pIAsyncResult)
End Function

Dim GlobalHttpPutProcessorVirtualTable As Const IHttpPutAsyncProcessorVirtualTable = Type( _
	@IHttpPutProcessorQueryInterface, _
	@IHttpPutProcessorAddRef, _
	@IHttpPutProcessorRelease, _
	@IHttpPutProcessorPrepare, _
	@IHttpPutProcessorBeginProcess, _
	@IHttpPutProcessorEndProcess _
)
