#include once "HttpOptionsProcessor.bi"
#include once "ContainerOf.bi"
#include once "HeapBSTR.bi"
#include once "MemoryStream.bi"

Extern GlobalHttpOptionsProcessorVirtualTable As Const IHttpOptionsAsyncProcessorVirtualTable

Const CompareResultEqual As Long = 0

Type _HttpOptionsProcessor
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IHttpOptionsAsyncProcessorVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
End Type

Sub InitializeHttpOptionsProcessor( _
		ByVal this As HttpOptionsProcessor Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_HTTPOPTIONSPROCESSOR), _
			Len(HttpOptionsProcessor.IdString) _
		)
	#endif
	this->lpVtbl = @GlobalHttpOptionsProcessorVirtualTable
	this->ReferenceCounter = CUInt(-1)
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	
End Sub

Sub UnInitializeHttpOptionsProcessor( _
		ByVal this As HttpOptionsProcessor Ptr _
	)
	
End Sub

Sub HttpOptionsProcessorCreated( _
		ByVal this As HttpOptionsProcessor Ptr _
	)
	
End Sub

Function CreateHttpOptionsProcessor( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Dim this As HttpOptionsProcessor Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(HttpOptionsProcessor) _
	)
	
	If this Then
		InitializeHttpOptionsProcessor(this, pIMemoryAllocator)
		HttpOptionsProcessorCreated(this)
		
		Dim hrQueryInterface As HRESULT = HttpOptionsProcessorQueryInterface( _
			this, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyHttpOptionsProcessor(this)
		End If
		
		Return hrQueryInterface
	End If
	
	*ppv = NULL
	Return E_OUTOFMEMORY
	
End Function

Sub HttpOptionsProcessorDestroyed( _
		ByVal this As HttpOptionsProcessor Ptr _
	)
	
End Sub

Sub DestroyHttpOptionsProcessor( _
		ByVal this As HttpOptionsProcessor Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeHttpOptionsProcessor(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	HttpOptionsProcessorDestroyed(this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function HttpOptionsProcessorQueryInterface( _
		ByVal this As HttpOptionsProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IHttpOptionsAsyncProcessor, riid) Then
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
	
	HttpOptionsProcessorAddRef(this)
	
	Return S_OK
	
End Function

Function HttpOptionsProcessorAddRef( _
		ByVal this As HttpOptionsProcessor Ptr _
	)As ULONG
	
	Return 1
	
End Function

Function HttpOptionsProcessorRelease( _
		ByVal this As HttpOptionsProcessor Ptr _
	)As ULONG
	
	Return 0
	
End Function

Function HttpOptionsProcessorPrepare( _
		ByVal this As HttpOptionsProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal ppIBuffer As IAttributedStream Ptr Ptr _
	)As HRESULT
	
	Dim pIBuffer As IMemoryStream Ptr = Any
	Dim hrCreateBuffer As HRESULT = CreateMemoryStream( _
		this->pIMemoryAllocator, _
		@IID_IMemoryStream, _
		@pIBuffer _
	)
	If FAILED(hrCreateBuffer) Then
		*ppIBuffer = NULL
		Return hrCreateBuffer
	End If
	
	Dim ClientURI As IClientUri Ptr = Any
	IClientRequest_GetUri(pContext->pIRequest, @ClientURI)
	
	Dim Path As HeapBSTR = Any
	IClientUri_GetPath(ClientURI, @Path)
	
	Const AllServerMethods = WStr("GET, HEAD, OPTIONS, TRACE")
	Const AllServerMethodsForFile = WStr("GET, HEAD, OPTIONS, TRACE")
	Const AllServerMethodsForScript = WStr("GET, HEAD, OPTIONS, TRACE")
	
	Dim CompareResult As Long = lstrcmpW(Path, WStr("*"))
	If CompareResult = CompareResultEqual Then
		IServerResponse_AddKnownResponseHeaderWstrLen( _
			pContext->pIResponse, _
			HttpResponseHeaders.HeaderAllow, _
			@AllServerMethods, _
			Len(AllServerMethods) _
		)
	Else
		Dim NeedProcessing As Boolean = Any
		IWebSite_NeedCgiProcessing( _
			pContext->pIWebSite, _
			Path, _
			@NeedProcessing _
		)
		
		If NeedProcessing Then
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				pContext->pIResponse, _
				HttpResponseHeaders.HeaderAllow, _
				@AllServerMethodsForScript, _
				Len(AllServerMethodsForScript) _
			)
		Else
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				pContext->pIResponse, _
				HttpResponseHeaders.HeaderAllow, _
				@AllServerMethodsForFile, _
				Len(AllServerMethodsForFile) _
			)
		End If
	End If
	
	HeapSysFreeString(Path)
	IClientUri_Release(ClientURI)
	
	IMemoryStream_SetBuffer( _
		pIBuffer, _
		NULL, _
		0 _
	)
	
	IServerResponse_SetSendOnlyHeaders(pContext->pIResponse, True)
	IServerResponse_SetStatusCode(pContext->pIResponse, HttpStatusCodes.NoContent)
	
	Dim hrPrepareResponse As HRESULT = IHttpWriter_Prepare( _
		pContext->pIWriter, _
		pContext->pIResponse, _
		CLngInt(0) _
	)
	If FAILED(hrPrepareResponse) Then
		IMemoryStream_Release(pIBuffer)
		*ppIBuffer = NULL
		Return hrPrepareResponse
	End If
	
	*ppIBuffer = CPtr(IAttributedStream Ptr, pIBuffer)
	
	Return S_OK
	
End Function

Function HttpOptionsProcessorBeginProcess( _
		ByVal this As HttpOptionsProcessor Ptr, _
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

Function HttpOptionsProcessorEndProcess( _
		ByVal this As HttpOptionsProcessor Ptr, _
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


Function IHttpOptionsProcessorQueryInterface( _
		ByVal this As IHttpOptionsAsyncProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return HttpOptionsProcessorQueryInterface(ContainerOf(this, HttpOptionsProcessor, lpVtbl), riid, ppv)
End Function

Function IHttpOptionsProcessorAddRef( _
		ByVal this As IHttpOptionsAsyncProcessor Ptr _
	)As ULONG
	Return HttpOptionsProcessorAddRef(ContainerOf(this, HttpOptionsProcessor, lpVtbl))
End Function

Function IHttpOptionsProcessorRelease( _
		ByVal this As IHttpOptionsAsyncProcessor Ptr _
	)As ULONG
	Return HttpOptionsProcessorRelease(ContainerOf(this, HttpOptionsProcessor, lpVtbl))
End Function

Function IHttpOptionsProcessorPrepare( _
		ByVal this As IHttpOptionsAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal ppIBuffer As IAttributedStream Ptr Ptr _
	)As HRESULT
	Return HttpOptionsProcessorPrepare(ContainerOf(this, HttpOptionsProcessor, lpVtbl), pContext, ppIBuffer)
End Function

Function IHttpOptionsProcessorBeginProcess( _
		ByVal this As IHttpOptionsAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return HttpOptionsProcessorBeginProcess(ContainerOf(this, HttpOptionsProcessor, lpVtbl), pContext, StateObject, ppIAsyncResult)
End Function

Function IHttpOptionsProcessorEndProcess( _
		ByVal this As IHttpOptionsAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	Return HttpOptionsProcessorEndProcess(ContainerOf(this, HttpOptionsProcessor, lpVtbl), pContext, pIAsyncResult)
End Function

Dim GlobalHttpOptionsProcessorVirtualTable As Const IHttpOptionsAsyncProcessorVirtualTable = Type( _
	@IHttpOptionsProcessorQueryInterface, _
	@IHttpOptionsProcessorAddRef, _
	@IHttpOptionsProcessorRelease, _
	@IHttpOptionsProcessorPrepare, _
	@IHttpOptionsProcessorBeginProcess, _
	@IHttpOptionsProcessorEndProcess _
)
