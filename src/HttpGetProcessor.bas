#include once "HttpGetProcessor.bi"
#include once "ArrayStringWriter.bi"
#include once "CharacterConstants.bi"
#include once "ContainerOf.bi"
#include once "HeapBSTR.bi"
#include once "WebUtils.bi"

Extern GlobalHttpGetProcessorVirtualTable As Const IHttpGetAsyncProcessorVirtualTable

Const GZipString = WStr("gzip")
Const DeflateString = WStr("deflate")
Const BytesStringWithSpace = WStr("bytes ")
Const CompareResultEqual As Long = 0
Const DefaultCacheControl = WStr("max-age=180")

Type HttpGetProcessor
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IHttpGetAsyncProcessorVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
End Type

Private Function AddResponseCacheHeaders( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pDateLastFileModified As FILETIME Ptr, _
		ByVal ETag As HeapBSTR _
	)As HRESULT
	
	Dim IsFileModified As Boolean = True
	
	Scope
		Dim LastModifiedHttpDate As HeapBSTR = Any
		
		Scope
			Dim dFileLastModified As SYSTEMTIME = Any
			FileTimeToSystemTime(pDateLastFileModified, @dFileLastModified)
			
			LastModifiedHttpDate = ConvertSystemDateToHttpDate( _
				pIMemoryAllocator, _
				@dFileLastModified _
			)
			If LastModifiedHttpDate = NULL Then
				Return E_OUTOFMEMORY
			End If
			
			IServerResponse_AddKnownResponseHeader( _
				pIResponse, _
				HttpResponseHeaders.HeaderLastModified, _
				LastModifiedHttpDate _
			)
		End Scope
		
		Scope
			Dim pHeaderIfModifiedSince As HeapBSTR = Any
			IClientRequest_GetHttpHeader( _
				pIRequest, _
				HttpRequestHeaders.HeaderIfModifiedSince, _
				@pHeaderIfModifiedSince _
			)
			
			Dim Length As Integer = SysStringLen(pHeaderIfModifiedSince)
			
			If Length Then
				Dim resCompare As Long = lstrcmpiW( _
					LastModifiedHttpDate, _
					pHeaderIfModifiedSince _
				)
				If resCompare = CompareResultEqual Then
					IsFileModified = False
				End If
			End If
			
			HeapSysFreeString(pHeaderIfModifiedSince)
		End Scope
		
		Scope
			Dim pHeaderIfUnModifiedSince As HeapBSTR = Any
			IClientRequest_GetHttpHeader( _
				pIRequest, _
				HttpRequestHeaders.HeaderIfUnModifiedSince, _
				@pHeaderIfUnModifiedSince _
			)
			
			Dim Length As Integer = SysStringLen(pHeaderIfUnModifiedSince)
			
			If Length Then
				Dim resCompare As Long = lstrcmpiW( _
					LastModifiedHttpDate, _
					pHeaderIfUnModifiedSince _
				)
				If resCompare = CompareResultEqual Then
					IsFileModified = True
				End If
			End If
			
			HeapSysFreeString(pHeaderIfUnModifiedSince)
		End Scope
		
		HeapSysFreeString(LastModifiedHttpDate)
	End Scope
	
	Scope
		IServerResponse_AddKnownResponseHeader( _
			pIResponse, _
			HttpResponseHeaders.HeaderETag, _
			ETag _
		)
		
		If IsFileModified Then
			Dim HeaderIfNoneMatch As HeapBSTR = Any
			IClientRequest_GetHttpHeader( _
				pIRequest, _
				HttpRequestHeaders.HeaderIfNoneMatch, _
				@HeaderIfNoneMatch _
			)
			
			Dim Length As Integer = SysStringLen(HeaderIfNoneMatch)
			
			If Length Then
				Dim CompareResult As Long = lstrcmpiW(HeaderIfNoneMatch, ETag)
				If CompareResult = CompareResultEqual Then
					IsFileModified = False
				End If
			End If
			
			HeapSysFreeString(HeaderIfNoneMatch)
		End If
		
		If IsFileModified = False Then
			Dim HeaderIfMatch As HeapBSTR = Any
			IClientRequest_GetHttpHeader( _
				pIRequest, _
				HttpRequestHeaders.HeaderIfMatch, _
				@HeaderIfMatch _
			)
			
			Dim Length As Integer = SysStringLen(HeaderIfMatch)
			
			If Length Then
				Dim CompareResult As Long = lstrcmpiW(HeaderIfMatch, ETag)
				If CompareResult = CompareResultEqual Then
					IsFileModified = True
				End If
			End If
			
			HeapSysFreeString(HeaderIfMatch)
		End If
	End Scope
	
	Dim hrAddHeader As HRESULT = IServerResponse_AddKnownResponseHeaderWstrLen( _
		pIResponse, _
		HttpResponseHeaders.HeaderCacheControl, _
		@DefaultCacheControl, _
		Len(DefaultCacheControl) _
	)
	If FAILED(hrAddHeader) Then
		Return E_OUTOFMEMORY
	End If
	
	Dim SendOnlyHeaders As Boolean = Any
	IServerResponse_GetSendOnlyHeaders(pIResponse, @SendOnlyHeaders)
	
	Dim CurrentSendOnlyHeaders As Boolean = SendOnlyHeaders OrElse (Not IsFileModified)
	
	IServerResponse_SetSendOnlyHeaders(pIResponse, CurrentSendOnlyHeaders)
	
	If IsFileModified = False Then
		IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.NotModified)
	End If
	
	Return S_OK
	
End Function

Private Sub MakeContentRangeHeader( _
		ByRef Writer As ArrayStringWriter, _
		ByVal FirstBytePosition As LongInt, _
		ByVal LastBytePosition As LongInt, _
		ByVal TotalLength As LongInt _
	)
	
	' Example:
	' Content-Range: bytes 88080384-160993791/160993792
	
	Writer.WriteLengthString(@BytesStringWithSpace, Len(BytesStringWithSpace))
	
	Writer.WriteUInt64(FirstBytePosition)
	Writer.WriteChar(Characters.HyphenMinus)
	
	Writer.WriteUInt64(LastBytePosition)
	Writer.WriteChar(Characters.Solidus)
	
	Writer.WriteUInt64(TotalLength)
	
End Sub

Private Sub InitializeHttpGetProcessor( _
		ByVal this As HttpGetProcessor Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->RttiClassName(0), _
			@Str(RTTI_ID_HTTPGETPROCESSOR), _
			UBound(this->RttiClassName) - LBound(this->RttiClassName) + 1 _
		)
	#endif
	this->lpVtbl = @GlobalHttpGetProcessorVirtualTable
	this->ReferenceCounter = CUInt(-1)
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	
End Sub

Private Sub UnInitializeHttpGetProcessor( _
		ByVal this As HttpGetProcessor Ptr _
	)
	
End Sub

Private Sub HttpGetProcessorCreated( _
		ByVal this As HttpGetProcessor Ptr _
	)
	
End Sub

Private Sub HttpGetProcessorDestroyed( _
		ByVal this As HttpGetProcessor Ptr _
	)
	
End Sub

Private Sub DestroyHttpGetProcessor( _
		ByVal this As HttpGetProcessor Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeHttpGetProcessor(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	HttpGetProcessorDestroyed(this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Private Function HttpGetProcessorAddRef( _
		ByVal this As HttpGetProcessor Ptr _
	)As ULONG
	
	Return 1
	
End Function

Private Function HttpGetProcessorRelease( _
		ByVal this As HttpGetProcessor Ptr _
	)As ULONG
	
	Return 0
	
End Function

Private Function HttpGetProcessorQueryInterface( _
		ByVal this As HttpGetProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IHttpGetAsyncProcessor, riid) Then
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
	
	HttpGetProcessorAddRef(this)
	
	Return S_OK
	
End Function

Public Function CreateHttpGetProcessor( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Dim this As HttpGetProcessor Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(HttpGetProcessor) _
	)
	
	If this Then
		InitializeHttpGetProcessor(this, pIMemoryAllocator)
		HttpGetProcessorCreated(this)
		
		Dim hrQueryInterface As HRESULT = HttpGetProcessorQueryInterface( _
			this, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyHttpGetProcessor(this)
		End If
		
		Return hrQueryInterface
	End If
	
	*ppv = NULL
	Return E_OUTOFMEMORY
	
End Function

Private Function HttpGetProcessorPrepare( _
		ByVal this As HttpGetProcessor Ptr, _
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
		FileAccess.ReadAccess, _
		@pIBuffer _
	)
	If FAILED(hrGetBuffer) Then
		*ppIBuffer = NULL
		Return hrGetBuffer
	End If
	
	Scope
		Dim HttpMethod As HeapBSTR = Any
		IClientRequest_GetHttpMethod(pContext->pIRequest, @HttpMethod)
		
		Dim CompareResult As Long = lstrcmpW(HttpMethod, WStr("HEAD"))
		If CompareResult = CompareResultEqual Then
			IServerResponse_SetSendOnlyHeaders(pContext->pIResponse, True)
		End If
		
		HeapSysFreeString(HttpMethod)
	End Scope
	
	Scope
		Dim Language As HeapBSTR = Any
		IAttributedStream_GetLanguage(pIBuffer, @Language)
		
		IServerResponse_AddKnownResponseHeader( _
			pContext->pIResponse, _
			HttpResponseHeaders.HeaderContentLanguage, _
			Language _
		)
		
		HeapSysFreeString(Language)
	End Scope
	
	Scope
		Dim Mime As MimeType = Any
		IAttributedStream_GetContentType(pIBuffer, @Mime)
		
		IServerResponse_SetMimeType(pContext->pIResponse, @Mime)
		
		Dim DateLastFileModified As FILETIME = Any
		IAttributedStream_GetLastFileModifiedDate(pIBuffer, @DateLastFileModified)
		
		Dim ETag As HeapBSTR = Any
		IAttributedStream_GetETag(pIBuffer, @ETag)
		
		AddResponseCacheHeaders( _
			pContext->pIMemoryAllocator, _
			pContext->pIRequest, _
			pContext->pIResponse, _
			@DateLastFileModified, _
			ETag _
		)
		
		HeapSysFreeString(ETag)
	End Scope
	
	Scope
		Dim ZipMode As ZipModes = Any
		IAttributedStream_GetEncoding(pIBuffer, @ZipMode)
		
		Select Case ZipMode
			
			Case ZipModes.GZip
				IServerResponse_AddKnownResponseHeaderWstrLen( _
					pContext->pIResponse, _
					HttpResponseHeaders.HeaderContentEncoding, _
					@GZipString, _
					Len(GZipString) _
				)
				
			Case ZipModes.Deflate
				IServerResponse_AddKnownResponseHeaderWstrLen( _
					pContext->pIResponse, _
					HttpResponseHeaders.HeaderContentEncoding, _
					@DeflateString, _
					Len(DeflateString) _
				)
				
		End Select
	End Scope
	
	Scope
		Const AcceptEncoding = WStr("Accept-Encoding")
		If Flags And ContentNegotiationFlags.AcceptEncoding Then
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				pContext->pIResponse, _
				HttpResponseHeaders.HeaderVary, _
				AcceptEncoding, _
				Len(AcceptEncoding) _
			)
		End If
	End Scope
	
	Dim RequestedByteRange As ByteRange = Any
	IClientRequest_GetByteRange(pContext->pIRequest, @RequestedByteRange)
	
	Dim ContentLength As LongInt = Any
	
	If RequestedByteRange.IsSet = ByteRangeIsSet.NotSet Then
		IAttributedStream_GetLength(pIBuffer, @ContentLength)
	Else
		Dim FileBytesOffset As LongInt = Any
		Dim Writer As ArrayStringWriter = Any
		InitializeArrayStringWriter(@Writer)
		
		Const ContentRangeMaximumBufferLength As Integer = 512 - 1
		Dim wContentRange As WString * (ContentRangeMaximumBufferLength + 1) = Any
		
		Writer.SetBuffer( _
			@wContentRange, _
			ContentRangeMaximumBufferLength _
		)
		
		Dim VirtualFileLength As LongInt = Any
		IAttributedStream_GetLength(pIBuffer, @VirtualFileLength)
		
		Select Case RequestedByteRange.IsSet
			
			Case ByteRangeIsSet.FirstBytePositionIsSet
				' �� X ����� � �� �����: bytes=9500-
				If RequestedByteRange.FirstBytePosition >= VirtualFileLength Then
					' ������ � ���������?
					Dim FirstBytePosition As LongInt = 0
					Dim LastBytePosition As LongInt = VirtualFileLength - 1
					
					MakeContentRangeHeader( _
						Writer, _
						FirstBytePosition, _
						LastBytePosition, _
						VirtualFileLength _
					)
					
					IServerResponse_AddKnownResponseHeaderWstr( _
						pContext->pIResponse, _
						HttpResponseHeaders.HeaderContentRange, _
						@wContentRange _
					)
					
					IAttributedStream_Release(pIBuffer)
					*ppIBuffer = NULL
					
					Return HTTPPROCESSOR_E_RANGENOTSATISFIABLE
				End If
				
				FileBytesOffset = RequestedByteRange.FirstBytePosition
				ContentLength = VirtualFileLength - RequestedByteRange.FirstBytePosition
				
				IServerResponse_SetByteRange( _
					pContext->pIResponse, _
					FileBytesOffset, _
					ContentLength _
				)
				
				Dim FirstBytePosition As LongInt = RequestedByteRange.FirstBytePosition
				Dim LastBytePosition As LongInt = VirtualFileLength - 1
				
				MakeContentRangeHeader( _
					Writer, _
					FirstBytePosition, _
					LastBytePosition, _
					VirtualFileLength _
				)
				
				IServerResponse_AddKnownResponseHeaderWstr( _
					pContext->pIResponse, _
					HttpResponseHeaders.HeaderContentRange, _
					@wContentRange _
				)
				IServerResponse_SetStatusCode( _
					pContext->pIResponse, _
					HttpStatusCodes.PartialContent _
				)
				
			Case ByteRangeIsSet.LastBytePositionIsSet
				' ������������� 500 ���� : bytes=-500
				' ���� ������� ������ ��� ����� �����
				' �� ������������ ��� ����� �����
				If RequestedByteRange.LastBytePosition = 0 Then
					' ������ � ���������?
					Dim FirstBytePosition As LongInt = 0
					Dim LastBytePosition As LongInt = VirtualFileLength - 1
					
					MakeContentRangeHeader( _
						Writer, _
						FirstBytePosition, _
						LastBytePosition, _
						VirtualFileLength _
					)
					
					IServerResponse_AddKnownResponseHeaderWstr( _
						pContext->pIResponse, _
						HttpResponseHeaders.HeaderContentRange, _
						@wContentRange _
					)
					
					IAttributedStream_Release(pIBuffer)
					*ppIBuffer = NULL
					
					Return HTTPPROCESSOR_E_RANGENOTSATISFIABLE
				End If
				
				ContentLength = min(VirtualFileLength, RequestedByteRange.LastBytePosition)
				FileBytesOffset = VirtualFileLength - ContentLength
				
				IServerResponse_SetByteRange( _
					pContext->pIResponse, _
					FileBytesOffset, _
					ContentLength _
				)
				
				Dim FirstBytePosition As LongInt = VirtualFileLength - ContentLength
				Dim LastBytePosition As LongInt = VirtualFileLength - 1
				
				MakeContentRangeHeader( _
					Writer, _
					FirstBytePosition, _
					LastBytePosition, _
					VirtualFileLength _
				)
				
				IServerResponse_AddKnownResponseHeaderWstr( _
					pContext->pIResponse, _
					HttpResponseHeaders.HeaderContentRange, _
					@wContentRange _
				)
				IServerResponse_SetStatusCode( _
					pContext->pIResponse, _
					HttpStatusCodes.PartialContent _
				)
				
			Case Else ' ByteRangeIsSet.FirstAndLastPositionIsSet
				' ������ 500 ������ (�������� �������� 0-499 ������������): bytes=0-499
				' ������ 500 ������ (�������� �������� 500-999 ������������): bytes=500-999
				If (RequestedByteRange.LastBytePosition < RequestedByteRange.FirstBytePosition) OrElse (RequestedByteRange.LastBytePosition >= VirtualFileLength) Then
					Dim FirstBytePosition As LongInt = 0
					Dim LastBytePosition As LongInt = VirtualFileLength - 1
					
					MakeContentRangeHeader( _
						Writer, _
						FirstBytePosition, _
						LastBytePosition, _
						VirtualFileLength _
					)
					
					IServerResponse_AddKnownResponseHeaderWstr( _
						pContext->pIResponse, _
						HttpResponseHeaders.HeaderContentRange, _
						@wContentRange _
					)
					
					IAttributedStream_Release(pIBuffer)
					*ppIBuffer = NULL
					
					Return HTTPPROCESSOR_E_RANGENOTSATISFIABLE
				End If
				
				ContentLength = min(RequestedByteRange.LastBytePosition - RequestedByteRange.FirstBytePosition + 1, VirtualFileLength)
				FileBytesOffset = RequestedByteRange.FirstBytePosition
				
				IServerResponse_SetByteRange( _
					pContext->pIResponse, _
					FileBytesOffset, _
					ContentLength _
				)
				
				Dim FirstBytePosition As LongInt = RequestedByteRange.FirstBytePosition
				Dim LastBytePosition As LongInt = min(RequestedByteRange.LastBytePosition, VirtualFileLength - 1)
				
				MakeContentRangeHeader( _
					Writer, _
					FirstBytePosition, _
					LastBytePosition, _
					VirtualFileLength _
				)
				
				IServerResponse_AddKnownResponseHeaderWstr( _
					pContext->pIResponse, _
					HttpResponseHeaders.HeaderContentRange, _
					@wContentRange _
				)
				IServerResponse_SetStatusCode( _
					pContext->pIResponse, _
					HttpStatusCodes.PartialContent _
				)
				
		End Select
		
	End If
	
	Dim hrPrepareResponse As HRESULT = IHttpWriter_Prepare( _
		pContext->pIWriter, _
		pContext->pIResponse, _
		ContentLength, _
		FileAccess.ReadAccess _
	)
	If FAILED(hrPrepareResponse) Then
		IAttributedStream_Release(pIBuffer)
		*ppIBuffer = NULL
		Return hrPrepareResponse
	End If
	
	*ppIBuffer = pIBuffer
	
	Return S_OK
	
End Function

Private Function HttpGetProcessorBeginProcess( _
		ByVal this As HttpGetProcessor Ptr, _
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

Private Function HttpGetProcessorEndProcess( _
		ByVal this As HttpGetProcessor Ptr, _
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


Private Function IHttpGetProcessorQueryInterface( _
		ByVal this As IHttpGetAsyncProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return HttpGetProcessorQueryInterface(ContainerOf(this, HttpGetProcessor, lpVtbl), riid, ppv)
End Function

Private Function IHttpGetProcessorAddRef( _
		ByVal this As IHttpGetAsyncProcessor Ptr _
	)As ULONG
	Return HttpGetProcessorAddRef(ContainerOf(this, HttpGetProcessor, lpVtbl))
End Function

Private Function IHttpGetProcessorRelease( _
		ByVal this As IHttpGetAsyncProcessor Ptr _
	)As ULONG
	Return HttpGetProcessorRelease(ContainerOf(this, HttpGetProcessor, lpVtbl))
End Function

Private Function IHttpGetProcessorPrepare( _
		ByVal this As IHttpGetAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal ppIBuffer As IAttributedStream Ptr Ptr _
	)As HRESULT
	Return HttpGetProcessorPrepare(ContainerOf(this, HttpGetProcessor, lpVtbl), pContext, ppIBuffer)
End Function

Private Function IHttpGetProcessorBeginProcess( _
		ByVal this As IHttpGetAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return HttpGetProcessorBeginProcess(ContainerOf(this, HttpGetProcessor, lpVtbl), pContext, StateObject, ppIAsyncResult)
End Function

Private Function IHttpGetProcessorEndProcess( _
		ByVal this As IHttpGetAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	Return HttpGetProcessorEndProcess(ContainerOf(this, HttpGetProcessor, lpVtbl), pContext, pIAsyncResult)
End Function

Dim GlobalHttpGetProcessorVirtualTable As Const IHttpGetAsyncProcessorVirtualTable = Type( _
	@IHttpGetProcessorQueryInterface, _
	@IHttpGetProcessorAddRef, _
	@IHttpGetProcessorRelease, _
	@IHttpGetProcessorPrepare, _
	@IHttpGetProcessorBeginProcess, _
	@IHttpGetProcessorEndProcess _
)
