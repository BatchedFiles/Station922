#include once "HttpGetProcessor.bi"
#include once "win\shlwapi.bi"
#include once "win\mswsock.bi"
#include once "ArrayStringWriter.bi"
#include once "CharacterConstants.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "HeapBSTR.bi"
#include once "Logger.bi"
#include once "StringConstants.bi"
#include once "WebUtils.bi"

Extern GlobalHttpGetProcessorVirtualTable As Const IHttpGetAsyncProcessorVirtualTable

Const GzipString = WStr("gzip")
Const DeflateString = WStr("deflate")
Const BytesStringWithSpace = WStr("bytes ")

Type _HttpGetProcessor
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IHttpGetAsyncProcessorVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
End Type

Sub MakeContentRangeHeader( _
		ByVal pIWriter As IArrayStringWriter Ptr, _
		ByVal FirstBytePosition As LongInt, _
		ByVal LastBytePosition As LongInt, _
		ByVal TotalLength As LongInt _
	)
	
	' Example:
	' Content-Range: bytes 88080384-160993791/160993792
	
	IArrayStringWriter_WriteLengthString(pIWriter, @BytesStringWithSpace, Len(BytesStringWithSpace))
	
	IArrayStringWriter_WriteUInt64(pIWriter, FirstBytePosition)
	IArrayStringWriter_WriteChar(pIWriter, Characters.HyphenMinus)
	
	IArrayStringWriter_WriteUInt64(pIWriter, LastBytePosition)
	IArrayStringWriter_WriteChar(pIWriter, Characters.Solidus)
	
	IArrayStringWriter_WriteUInt64(pIWriter, TotalLength)
	
End Sub

Sub InitializeHttpGetProcessor( _
		ByVal this As HttpGetProcessor Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_HTTPGETPROCESSOR), _
			Len(HttpGetProcessor.IdString) _
		)
	#endif
	this->lpVtbl = @GlobalHttpGetProcessorVirtualTable
	this->ReferenceCounter = CUInt(-1)
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	
End Sub

Sub UnInitializeHttpGetProcessor( _
		ByVal this As HttpGetProcessor Ptr _
	)
	
End Sub

Function CreatePermanentHttpGetProcessor( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As HttpGetProcessor Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(HttpGetProcessor)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"HttpGetProcessor creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim this As HttpGetProcessor Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(HttpGetProcessor) _
	)
	
	If this <> NULL Then
		
		InitializeHttpGetProcessor( _
			this, _
			pIMemoryAllocator _
		)
		
		#if __FB_DEBUG__
		Scope
			Dim vtEmpty As VARIANT = Any
			VariantInit(@vtEmpty)
			LogWriteEntry( _
				LogEntryType.Debug, _
				WStr("HttpGetProcessor created"), _
				@vtEmpty _
			)
		End Scope
		#endif
		
		Return this
	End If
	
	Return NULL
	
End Function

Sub DestroyHttpGetProcessor( _
		ByVal this As HttpGetProcessor Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("HttpGetProcessor destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeHttpGetProcessor(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("HttpGetProcessor destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function HttpGetProcessorQueryInterface( _
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

Function HttpGetProcessorAddRef( _
		ByVal this As HttpGetProcessor Ptr _
	)As ULONG
	
	Return 1
	
End Function

Function HttpGetProcessorRelease( _
		ByVal this As HttpGetProcessor Ptr _
	)As ULONG
	
	Return 0
	
End Function

Function HttpGetProcessorPrepare( _
		ByVal this As HttpGetProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal ppIBuffer As IBuffer Ptr Ptr _
	)As HRESULT
	
	Dim Flags As ContentNegotiationFlags = Any
	Dim pIBuffer As IBuffer Ptr = Any
	Dim hrGetBuffer As HRESULT = IWebSite_GetBuffer( _
		pContext->pIWebSite, _
		pContext->pIMemoryAllocator, _
		FileAccess.ReadAccess, _
		pContext->pIRequest, _
		0, _
		@Flags, _
		@pIBuffer _
	)
	If FAILED(hrGetBuffer) Then
		*ppIBuffer = NULL
		Return hrGetBuffer
	End If
	
	Scope
		Dim HttpMethod As HeapBSTR = Any
		IClientRequest_GetHttpMethod(pContext->pIRequest, @HttpMethod)
		
		If lstrcmp(HttpMethod, WStr("HEAD")) = 0 Then
			IServerResponse_SetSendOnlyHeaders(pContext->pIResponse, True)
		End If
		
		HeapSysFreeString(HttpMethod)
	End Scope
	
	Scope
		Dim Language As HeapBSTR = Any
		IBuffer_GetLanguage(pIBuffer, @Language)
		
		IServerResponse_AddKnownResponseHeader( _
			pContext->pIResponse, _
			HttpResponseHeaders.HeaderContentLanguage, _
			Language _
		)
		
		HeapSysFreeString(Language)
	End Scope
	
	Scope
		Dim Mime As MimeType = Any
		IBuffer_GetContentType(pIBuffer, @Mime)
		
		IServerResponse_SetMimeType(pContext->pIResponse, @Mime)
		
		Dim DateLastFileModified As FILETIME = Any
		IBuffer_GetLastFileModifiedDate(pIBuffer, @DateLastFileModified)
		
		Dim ETag As HeapBSTR = Any
		IBuffer_GetETag(pIBuffer, @ETag)
		
		AddResponseCacheHeaders( _
			pContext->pIRequest, _
			pContext->pIResponse, _
			@DateLastFileModified, _
			ETag _
		)
		
		HeapSysFreeString(ETag)
	End Scope
	
	Scope
		Dim ZipMode As ZipModes = Any
		IBuffer_GetEncoding(pIBuffer, @ZipMode)
		
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
		If Flags And ContentNegotiationFlags.ContentNegotiationAcceptEncoding Then
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				pContext->pIResponse, _
				HttpResponseHeaders.HeaderVary, _
				WStr("Accept-Encoding"), _
				Len(WSTR("Accept-Encoding")) _
			)
		End If
	End Scope
	
	Dim RequestedByteRange As ByteRange = Any
	IClientRequest_GetByteRange(pContext->pIRequest, @RequestedByteRange)
	
	Dim ContentLength As LongInt = Any
	Dim FileBytesOffset As LongInt = Any
	
	If RequestedByteRange.IsSet = ByteRangeIsSet.NotSet Then
		IBuffer_GetLength(pIBuffer, @ContentLength)
		FileBytesOffset = 0
	Else
		Dim pIWriter As IArrayStringWriter Ptr = Any
		Dim hrCreateWriter As HRESULT = CreateInstance( _
			pContext->pIMemoryAllocator, _
			@CLSID_ARRAYSTRINGWRITER, _
			@IID_IArrayStringWriter, _
			@pIWriter _
		)
		If FAILED(hrCreateWriter) Then
			IBuffer_Release(pIBuffer)
			*ppIBuffer = NULL
			Return hrCreateWriter
		End If
		
		Const ContentRangeMaximumBufferLength As Integer = 512 - 1
		Dim wContentRange As WString * (ContentRangeMaximumBufferLength + 1) = Any
		
		IArrayStringWriter_SetBuffer( _
			pIWriter, _
			@wContentRange, _
			ContentRangeMaximumBufferLength _
		)
		
		Dim VirtualFileLength As LongInt = Any
		IBuffer_GetLength(pIBuffer, @VirtualFileLength)
		
		Select Case RequestedByteRange.IsSet
			
			Case ByteRangeIsSet.FirstBytePositionIsSet
				' От X байта и до конца: bytes=9500-
				If RequestedByteRange.FirstBytePosition >= VirtualFileLength Then
					' Ошибка в диапазоне?
					Dim FirstBytePosition As LongInt = 0
					Dim LastBytePosition As LongInt = VirtualFileLength - 1
					
					MakeContentRangeHeader( _
						pIWriter, _
						FirstBytePosition, _
						LastBytePosition, _
						VirtualFileLength _
					)
					
					IServerResponse_AddKnownResponseHeaderWstr( _
						pContext->pIResponse, _
						HttpResponseHeaders.HeaderContentRange, _
						@wContentRange _
					)
					
					IArrayStringWriter_Release(pIWriter)
					IBuffer_Release(pIBuffer)
					*ppIBuffer = NULL
					
					Return HTTPASYNCPROCESSOR_E_RANGENOTSATISFIABLE
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
					pIWriter, _
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
				' Окончательные 500 байт : bytes=-500
				' Если указано больше чем длина файла
				' то возвращаются все байты файла
				If RequestedByteRange.LastBytePosition = 0 Then
					' Ошибка в диапазоне?
					Dim FirstBytePosition As LongInt = 0
					Dim LastBytePosition As LongInt = VirtualFileLength - 1
					
					MakeContentRangeHeader( _
						pIWriter, _
						FirstBytePosition, _
						LastBytePosition, _
						VirtualFileLength _
					)
					
					IServerResponse_AddKnownResponseHeaderWstr( _
						pContext->pIResponse, _
						HttpResponseHeaders.HeaderContentRange, _
						@wContentRange _
					)
					
					IArrayStringWriter_Release(pIWriter)
					IBuffer_Release(pIBuffer)
					*ppIBuffer = NULL
					
					Return HTTPASYNCPROCESSOR_E_RANGENOTSATISFIABLE
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
					pIWriter, _
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
				' Первые 500 байтов (байтовые смещения 0-499 включительно): bytes=0-499
				' Второй 500 байтов (байтовые смещения 500-999 включительно): bytes=500-999
				If (RequestedByteRange.LastBytePosition < RequestedByteRange.FirstBytePosition) OrElse (RequestedByteRange.LastBytePosition >= VirtualFileLength) Then
					Dim FirstBytePosition As LongInt = 0
					Dim LastBytePosition As LongInt = VirtualFileLength - 1
					
					MakeContentRangeHeader( _
						pIWriter, _
						FirstBytePosition, _
						LastBytePosition, _
						VirtualFileLength _
					)
					
					IServerResponse_AddKnownResponseHeaderWstr( _
						pContext->pIResponse, _
						HttpResponseHeaders.HeaderContentRange, _
						@wContentRange _
					)
					
					IArrayStringWriter_Release(pIWriter)
					IBuffer_Release(pIBuffer)
					*ppIBuffer = NULL
					
					Return HTTPASYNCPROCESSOR_E_RANGENOTSATISFIABLE
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
					pIWriter, _
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
		
		IArrayStringWriter_Release(pIWriter)
	End If
	
	Dim hrPrepareResponse As HRESULT = IHttpWriter_Prepare( _
		pContext->pIWriter, _
		pContext->pIResponse, _
		ContentLength _
	)
	If FAILED(hrPrepareResponse) Then
		IBuffer_Release(pIBuffer)
		*ppIBuffer = NULL
		Return hrPrepareResponse
	End If
	
	*ppIBuffer = pIBuffer
	
	Return S_OK
	
End Function

Function HttpGetProcessorBeginProcess( _
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

Function HttpGetProcessorEndProcess( _
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
	
End Function


Function IHttpGetProcessorQueryInterface( _
		ByVal this As IHttpGetAsyncProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return HttpGetProcessorQueryInterface(ContainerOf(this, HttpGetProcessor, lpVtbl), riid, ppv)
End Function

Function IHttpGetProcessorAddRef( _
		ByVal this As IHttpGetAsyncProcessor Ptr _
	)As ULONG
	Return HttpGetProcessorAddRef(ContainerOf(this, HttpGetProcessor, lpVtbl))
End Function

Function IHttpGetProcessorRelease( _
		ByVal this As IHttpGetAsyncProcessor Ptr _
	)As ULONG
	Return HttpGetProcessorRelease(ContainerOf(this, HttpGetProcessor, lpVtbl))
End Function

Function IHttpGetProcessorPrepare( _
		ByVal this As IHttpGetAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal ppIBuffer As IBuffer Ptr Ptr _
	)As HRESULT
	Return HttpGetProcessorPrepare(ContainerOf(this, HttpGetProcessor, lpVtbl), pContext, ppIBuffer)
End Function

Function IHttpGetProcessorBeginProcess( _
		ByVal this As IHttpGetAsyncProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return HttpGetProcessorBeginProcess(ContainerOf(this, HttpGetProcessor, lpVtbl), pContext, StateObject, ppIAsyncResult)
End Function

Function IHttpGetProcessorEndProcess( _
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
