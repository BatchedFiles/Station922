#include once "HttpTraceProcessor.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "Logger.bi"
#include once "MemoryBuffer.bi"

Extern GlobalHttpTraceProcessorVirtualTable As Const IHttpTraceAsyncProcessorVirtualTable

Type _HttpTraceProcessor
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IHttpTraceAsyncProcessorVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
End Type

Sub InitializeHttpTraceProcessor( _
		ByVal this As HttpTraceProcessor Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_HTTPTRACEPROCESSOR), _
			Len(HttpTraceProcessor.IdString) _
		)
	#endif
	this->lpVtbl = @GlobalHttpTraceProcessorVirtualTable
	this->ReferenceCounter = CUInt(-1)
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	
End Sub

Sub UnInitializeHttpTraceProcessor( _
		ByVal this As HttpTraceProcessor Ptr _
	)
	
End Sub

Function CreatePermanentHttpTraceProcessor( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As HttpTraceProcessor Ptr
	
	Dim this As HttpTraceProcessor Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(HttpTraceProcessor) _
	)
	
	If this Then
		
		InitializeHttpTraceProcessor( _
			this, _
			pIMemoryAllocator _
		)
		
		Return this
	End If
	
	Return NULL
	
End Function

Sub DestroyHttpTraceProcessor( _
		ByVal this As HttpTraceProcessor Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeHttpTraceProcessor(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function HttpTraceProcessorQueryInterface( _
		ByVal this As HttpTraceProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IHttpTraceAsyncProcessor, riid) Then
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
	
	HttpTraceProcessorAddRef(this)
	
	Return S_OK
	
End Function

Function HttpTraceProcessorAddRef( _
		ByVal this As HttpTraceProcessor Ptr _
	)As ULONG
	
	Return 1
	
End Function

Function HttpTraceProcessorRelease( _
		ByVal this As HttpTraceProcessor Ptr _
	)As ULONG
	
	Return 0
	
End Function

Function HttpTraceProcessorPrepare( _
		ByVal this As HttpTraceProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal ppIBuffer As IBuffer Ptr Ptr _
	)As HRESULT
	
	Dim pIBuffer As IMemoryBuffer Ptr = Any
	Dim hrCreateBuffer As HRESULT = CreateInstance( _
		this->pIMemoryAllocator, _
		@CLSID_MEMORYBUFFER, _
		@IID_IMemoryBuffer, _
		@pIBuffer _
	)
	If FAILED(hrCreateBuffer) Then
		*ppIBuffer = NULL
		Return hrCreateBuffer
	End If
	
	Dim RequestedBytesLength As Integer = Any
	Dim pRequestedBytes As UByte Ptr = Any
	IHttpReader_GetRequestedBytes( _
		pContext->pIReader, _
		@RequestedBytesLength, _
		@pRequestedBytes _
	)
	
	IMemoryBuffer_SetBuffer( _
		pIBuffer, _
		pRequestedBytes, _
		RequestedBytesLength _
	)
	
	Scope
		Dim Mime As MimeType = Any
		With Mime
			.ContentType = ContentTypes.MessageHttp
			.Charset = DocumentCharsets.ASCII
			.IsTextFormat = True
		End With
		
		IServerResponse_SetMimeType(pContext->pIResponse, @Mime)
	End Scope
	
	Dim hrPrepareResponse As HRESULT = IHttpWriter_Prepare( _
		pContext->pIWriter, _
		pContext->pIResponse, _
		CLngInt(RequestedBytesLength) _
	)
	If FAILED(hrPrepareResponse) Then
		IBuffer_Release(pIBuffer)
		*ppIBuffer = NULL
		Return hrPrepareResponse
	End If
	
	*ppIBuffer = CPtr(IBuffer Ptr, pIBuffer)
	
	Return S_OK
	
End Function

Function HttpTraceProcessorBeginProcess( _
		ByVal this As HttpTraceProcessor Ptr, _
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

Function HttpTraceProcessorEndProcess( _
		ByVal this As HttpTraceProcessor Ptr, _
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
	
End Function


Function IHttpTraceProcessorQueryInterface( _
		ByVal this As IHttpTraceAsyncProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return HttpTraceProcessorQueryInterface(ContainerOf(this, HttpTraceProcessor, lpVtbl), riid, ppv)
End Function

Function IHttpTraceProcessorAddRef( _
		ByVal this As IHttpTraceAsyncProcessor Ptr _
	)As ULONG
	Return HttpTraceProcessorAddRef(ContainerOf(this, HttpTraceProcessor, lpVtbl))
End Function

Function IHttpTraceProcessorRelease( _
		ByVal this As IHttpTraceAsyncProcessor Ptr _
	)As ULONG
	Return HttpTraceProcessorRelease(ContainerOf(this, HttpTraceProcessor, lpVtbl))
End Function

Function IHttpTraceProcessorPrepare( _
		ByVal this As IHttpTraceAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal ppIBuffer As IBuffer Ptr Ptr _
	)As HRESULT
	Return HttpTraceProcessorPrepare(ContainerOf(this, HttpTraceProcessor, lpVtbl), pContext, ppIBuffer)
End Function

Function IHttpTraceProcessorBeginProcess( _
		ByVal this As IHttpTraceAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return HttpTraceProcessorBeginProcess(ContainerOf(this, HttpTraceProcessor, lpVtbl), pContext, StateObject, ppIAsyncResult)
End Function

Function IHttpTraceProcessorEndProcess( _
		ByVal this As IHttpTraceAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	Return HttpTraceProcessorEndProcess(ContainerOf(this, HttpTraceProcessor, lpVtbl), pContext, pIAsyncResult)
End Function

Dim GlobalHttpTraceProcessorVirtualTable As Const IHttpTraceAsyncProcessorVirtualTable = Type( _
	@IHttpTraceProcessorQueryInterface, _
	@IHttpTraceProcessorAddRef, _
	@IHttpTraceProcessorRelease, _
	@IHttpTraceProcessorPrepare, _
	@IHttpTraceProcessorBeginProcess, _
	@IHttpTraceProcessorEndProcess _
)
