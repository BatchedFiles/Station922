#include once "HttpDeleteProcessor.bi"
#include once "CharacterConstants.bi"
#include once "ContainerOf.bi"
#include once "HeapBSTR.bi"
#include once "WebUtils.bi"

Extern GlobalHttpDeleteProcessorVirtualTable As Const IHttpDeleteAsyncProcessorVirtualTable

Const CompareResultEqual As Long = 0

Type _HttpDeleteProcessor
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IHttpDeleteAsyncProcessorVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
End Type

Private Sub InitializeHttpDeleteProcessor( _
		ByVal this As HttpDeleteProcessor Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->RttiClassName(0), _
			@Str(RTTI_ID_HTTPDELETEPROCESSOR), _
			UBound(this->RttiClassName) - LBound(this->RttiClassName) + 1 _
		)
	#endif
	this->lpVtbl = @GlobalHttpDeleteProcessorVirtualTable
	this->ReferenceCounter = CUInt(-1)
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	
End Sub

Private Sub UnInitializeHttpDeleteProcessor( _
		ByVal this As HttpDeleteProcessor Ptr _
	)
	
End Sub

Private Sub HttpDeleteProcessorCreated( _
		ByVal this As HttpDeleteProcessor Ptr _
	)
	
End Sub

Private Sub HttpDeleteProcessorDestroyed( _
		ByVal this As HttpDeleteProcessor Ptr _
	)
	
End Sub

Private Sub DestroyHttpDeleteProcessor( _
		ByVal this As HttpDeleteProcessor Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeHttpDeleteProcessor(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	HttpDeleteProcessorDestroyed(this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Private Function HttpDeleteProcessorAddRef( _
		ByVal this As HttpDeleteProcessor Ptr _
	)As ULONG
	
	Return 1
	
End Function

Private Function HttpDeleteProcessorRelease( _
		ByVal this As HttpDeleteProcessor Ptr _
	)As ULONG
	
	Return 0
	
End Function

Private Function HttpDeleteProcessorQueryInterface( _
		ByVal this As HttpDeleteProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IHttpDeleteAsyncProcessor, riid) Then
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
	
	HttpDeleteProcessorAddRef(this)
	
	Return S_OK
	
End Function

Function CreateHttpDeleteProcessor( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Dim this As HttpDeleteProcessor Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(HttpDeleteProcessor) _
	)
	
	If this Then
		InitializeHttpDeleteProcessor(this, pIMemoryAllocator)
		HttpDeleteProcessorCreated(this)
		
		Dim hrQueryInterface As HRESULT = HttpDeleteProcessorQueryInterface( _
			this, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyHttpDeleteProcessor(this)
		End If
		
		Return hrQueryInterface
	End If
	
	*ppv = NULL
	Return E_OUTOFMEMORY
	
End Function

Private Function HttpDeleteProcessorPrepare( _
		ByVal this As HttpDeleteProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal ppIBuffer As IAttributedStream Ptr Ptr _
	)As HRESULT
	
	Dim Flags As ContentNegotiationFlags = Any
	Dim pIBuffer As IAttributedStream Ptr = Any
	Dim hrGetBuffer As HRESULT = IWebSite_GetBuffer( _
		pContext->pIWebSite, _
		pContext->pIMemoryAllocator, _
		pContext->pIRequest, _
		pContext->pIReader, _
		0, _
		@Flags, _
		FileAccess.DeleteAccess, _
		@pIBuffer _
	)
	If FAILED(hrGetBuffer) Then
		*ppIBuffer = NULL
		Return hrGetBuffer
	End If
	
	IServerResponse_SetStatusCode( _
		pContext->pIResponse, _
		HttpStatusCodes.NoContent _
	)
	
	IServerResponse_SetSendOnlyHeaders( _
		pContext->pIResponse, _
		True _
	)
	
	Dim hrPrepareResponse As HRESULT = IHttpWriter_Prepare( _
		pContext->pIWriter, _
		pContext->pIResponse, _
		0, _
		FileAccess.DeleteAccess _
	)
	If FAILED(hrPrepareResponse) Then
		IAttributedStream_Release(pIBuffer)
		*ppIBuffer = NULL
		Return hrPrepareResponse
	End If
	
	*ppIBuffer = pIBuffer
	
	Return S_OK
	
End Function

Private Function HttpDeleteProcessorBeginProcess( _
		ByVal this As HttpDeleteProcessor Ptr, _
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

Private Function HttpDeleteProcessorEndProcess( _
		ByVal this As HttpDeleteProcessor Ptr, _
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


Private Function IHttpDeleteProcessorQueryInterface( _
		ByVal this As IHttpDeleteAsyncProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return HttpDeleteProcessorQueryInterface(ContainerOf(this, HttpDeleteProcessor, lpVtbl), riid, ppv)
End Function

Private Function IHttpDeleteProcessorAddRef( _
		ByVal this As IHttpDeleteAsyncProcessor Ptr _
	)As ULONG
	Return HttpDeleteProcessorAddRef(ContainerOf(this, HttpDeleteProcessor, lpVtbl))
End Function

Private Function IHttpDeleteProcessorRelease( _
		ByVal this As IHttpDeleteAsyncProcessor Ptr _
	)As ULONG
	Return HttpDeleteProcessorRelease(ContainerOf(this, HttpDeleteProcessor, lpVtbl))
End Function

Private Function IHttpDeleteProcessorPrepare( _
		ByVal this As IHttpDeleteAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal ppIBuffer As IAttributedStream Ptr Ptr _
	)As HRESULT
	Return HttpDeleteProcessorPrepare(ContainerOf(this, HttpDeleteProcessor, lpVtbl), pContext, ppIBuffer)
End Function

Private Function IHttpDeleteProcessorBeginProcess( _
		ByVal this As IHttpDeleteAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return HttpDeleteProcessorBeginProcess(ContainerOf(this, HttpDeleteProcessor, lpVtbl), pContext, StateObject, ppIAsyncResult)
End Function

Private Function IHttpDeleteProcessorEndProcess( _
		ByVal this As IHttpDeleteAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	Return HttpDeleteProcessorEndProcess(ContainerOf(this, HttpDeleteProcessor, lpVtbl), pContext, pIAsyncResult)
End Function

Dim GlobalHttpDeleteProcessorVirtualTable As Const IHttpDeleteAsyncProcessorVirtualTable = Type( _
	@IHttpDeleteProcessorQueryInterface, _
	@IHttpDeleteProcessorAddRef, _
	@IHttpDeleteProcessorRelease, _
	@IHttpDeleteProcessorPrepare, _
	@IHttpDeleteProcessorBeginProcess, _
	@IHttpDeleteProcessorEndProcess _
)
