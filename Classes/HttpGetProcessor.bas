#include once "HttpGetProcessor.bi"
#include once "win\shlwapi.bi"
#include once "win\mswsock.bi"
#include once "ArrayStringWriter.bi"
#include once "CharacterConstants.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "HeapBSTR.bi"
#include once "HttpConst.bi"
#include once "IMutableAsyncResult.bi"
#include once "Logger.bi"
#include once "SafeHandle.bi"
#include once "StringConstants.bi"
#include once "WebUtils.bi"

Extern GlobalHttpGetProcessorVirtualTable As Const IHttpGetAsyncProcessorVirtualTable

Type _HttpGetProcessor
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IHttpGetAsyncProcessorVirtualTable Ptr
	ReferenceCounter As Integer
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
	
	IArrayStringWriter_WriteLengthString(pIWriter, @BytesStringWithSpace, BytesStringWithSpaceLength)
	
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
		CopyMemory(@this->IdString, @Str("HttpGetProcessor"), 16)
	#endif
	this->lpVtbl = @GlobalHttpGetProcessorVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	
End Sub

Sub UnInitializeHttpGetProcessor( _
		ByVal this As HttpGetProcessor Ptr _
	)
	
	IMalloc_Release(this->pIMemoryAllocator)
	
End Sub

Function CreateHttpGetProcessor( _
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
	
	IMalloc_AddRef(this->pIMemoryAllocator)
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
	
	#ifdef __FB_64BIT__
		InterlockedIncrement64(@this->ReferenceCounter)
	#else
		InterlockedIncrement(@this->ReferenceCounter)
	#endif
	
	Return 1
	
End Function

Function HttpGetProcessorRelease( _
		ByVal this As HttpGetProcessor Ptr _
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
	
	DestroyHttpGetProcessor(this)
	
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
		Return E_FAIL
	End If
	
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
		If Flags And ContentNegotiationFlags.ContentNegotiationAcceptEncoding Then
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				pContext->pIResponse, _
				HttpResponseHeaders.HeaderVary, _
				WStr("Accept-Encoding"), _
				Len(WSTR("Accept-Encoding")) _
			)
		End If
	End Scope
	
	Scope
		Dim RequestedByteRange As ByteRange = Any
		IClientRequest_GetByteRange(pContext->pIRequest, @RequestedByteRange)
		
		If RequestedByteRange.IsSet <> ByteRangeIsSet.NotSet Then
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
			
			IArrayStringWriter_SetBuffer(pIWriter, @wContentRange, ContentRangeMaximumBufferLength)
			
			Dim VirtualFileLength As LongInt = Any 'EncodingFileSize
			IBuffer_GetLength(pIBuffer, @VirtualFileLength)
			
			Select Case RequestedByteRange.IsSet
				
				Case ByteRangeIsSet.FirstBytePositionIsSet
					' �� X ����� � �� �����: bytes=9500-
					If RequestedByteRange.FirstBytePosition > VirtualFileLength Then
						' ������ � ���������?
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
					
					Dim FileBytesOffset As LongInt = RequestedByteRange.FirstBytePosition
					Dim ContentBodyLength As LongInt = VirtualFileLength - RequestedByteRange.FirstBytePosition
					IBuffer_SetByteRange(pIBuffer, FileBytesOffset, ContentBodyLength)
					
					Dim FirstBytePosition As LongInt = RequestedByteRange.FirstBytePosition
					Dim LastBytePosition As LongInt = ContentBodyLength - 1
					
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
					' ������������� 500 ���� (�������� �������� 9500-9999, ������������): bytes=-500
					' ������ ��������� ����� (9999): bytes=-1
					' ���� ������� ������ ��� ����� �����
					' �� ������������ ��� ����� �����
					If RequestedByteRange.LastBytePosition = 0 Then
						' ������ � ���������?
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
					
					Dim ContentBodyLength As LongInt = min(VirtualFileLength, RequestedByteRange.LastBytePosition)
					Dim FileBytesOffset As LongInt = VirtualFileLength - ContentBodyLength
					IBuffer_SetByteRange(pIBuffer, FileBytesOffset, ContentBodyLength)
					
					Dim FirstBytePosition As LongInt = VirtualFileLength - ContentBodyLength
					Dim LastBytePosition As LongInt = FirstBytePosition + ContentBodyLength - 1
					
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
					
				Case ByteRangeIsSet.FirstAndLastPositionIsSet
					' ������ 500 ������ (�������� �������� 0-499 ������������): bytes=0-499
					' ������ 500 ������ (�������� �������� 500-999 ������������): bytes=500-999
					If RequestedByteRange.LastBytePosition < RequestedByteRange.FirstBytePosition OrElse RequestedByteRange.FirstBytePosition >= VirtualFileLength Then
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
					
					Dim ContentBodyLength As LongInt = min(RequestedByteRange.LastBytePosition - RequestedByteRange.FirstBytePosition + 1, VirtualFileLength)
					Dim FileBytesOffset As LongInt = RequestedByteRange.FirstBytePosition
					IBuffer_SetByteRange(pIBuffer, FileBytesOffset, ContentBodyLength)
					
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
	End Scope
	
	*ppIBuffer = pIBuffer
	
	Return S_OK
	
End Function

Function HttpGetProcessorBeginProcess( _
		ByVal this As HttpGetProcessor Ptr, _
		ByVal pc As ProcessorContext Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	*ppIAsyncResult = NULL
	
	Return E_UNEXPECTED
	
End Function

Function HttpGetProcessorEndProcess( _
		ByVal this As HttpGetProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	
	Return E_UNEXPECTED
	
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
