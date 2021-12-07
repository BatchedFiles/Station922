#include once "HttpGetProcessor.bi"
#include once "win\shlwapi.bi"
#include once "win\mswsock.bi"
#include once "IArrayStringWriter.bi"
#include once "IMutableAsyncResult.bi"
#include once "ContainerOf.bi"
#include once "CharacterConstants.bi"
#include once "CreateInstance.bi"
#include once "HttpConst.bi"
#include once "Logger.bi"
#include once "Mime.bi"
#include once "SafeHandle.bi"
#include once "StringConstants.bi"
#include once "WebUtils.bi"

Extern GlobalHttpGetProcessorVirtualTable As Const IRequestProcessorVirtualTable

Extern CLSID_ARRAYSTRINGWRITER Alias "CLSID_ARRAYSTRINGWRITER" As Const CLSID
Extern CLSID_ASYNCRESULT Alias "CLSID_ASYNCRESULT" As Const CLSID

Const TRANSMIT_CHUNK_SIZE As DWORD = 1024 * 1024 * 265
Const ContentRangeMaximumBufferLength As Integer = 512 - 1

Type _HttpGetProcessor
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IRequestProcessorVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	FileHandle As HANDLE
	ZipFileHandle As HANDLE
	pSendBuffer As ZString Ptr
	HeadersLength As Integer
	' BodyLength As LongInt
	ContentBodyLength As LongInt
	FileBytesOffset As LongInt
	hTransmitFile As HANDLE
	CurrentChunkIndex As LongInt
	TransmitHeader As TRANSMIT_FILE_BUFFERS
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

' Определяет кодировку документа (массива байт)
Function GetDocumentCharset( _
		ByVal bytes As ZString Ptr _
	)As DocumentCharsets
	
	Dim byte1 As UByte = bytes[0]
	
	Select Case byte1
		
		Case 239
			Dim byte2 As UByte = bytes[1]
			If byte2 = 187 Then
				Dim byte3 As UByte = bytes[2]
				If byte3 = 191 Then
					Return DocumentCharsets.Utf8BOM
				End If
			End If
			
		Case 254
			Dim byte2 As UByte = bytes[1]
			If byte2 = 255 Then
				Return DocumentCharsets.Utf16BE
			End If
			
		Case 255
			Dim byte2 As UByte = bytes[1]
			If byte2 = 254 Then
				Return DocumentCharsets.Utf16LE
			End If
			
	End Select
	
	Return DocumentCharsets.ASCII
	
End Function

Function GetFileBytesOffset( _
		ByVal mt As MimeType Ptr, _
		ByVal hRequestedFile As HANDLE, _
		ByVal hZipFile As HANDLE _
	)As LongInt
	
	If mt->IsTextFormat Then
		Const MaxBytesRead As DWORD = 16 - 1
		
		Dim FileBytes As ZString * (MaxBytesRead + 1) = Any
		Dim BytesReaded As DWORD = Any
		
		Dim ReadResult As Integer = ReadFile( _
			hRequestedFile, _
			@FileBytes, _
			MaxBytesRead, _
			@BytesReaded, _
			0 _
		)
		If ReadResult <> 0 Then
			
			mt->Charset = GetDocumentCharset(@FileBytes)
			
			Dim offset As LongInt = Any
			
			If hZipFile = INVALID_HANDLE_VALUE Then
				
				Select Case mt->Charset
					
					Case DocumentCharsets.Utf8BOM
						offset = 3
						
					Case DocumentCharsets.Utf16LE
						offset = 0
						
					Case DocumentCharsets.Utf16BE
						offset = 2
						
					Case Else
						offset = 0
						
				End Select
			Else
				offset = 0
				
			End If
			
			Return offset
			
		End If
		
	End If
	
	Return 0
	
End Function

Sub AddExtendedHeaders( _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pIRequestedFile As IRequestedFile Ptr _
	)
	' TODO Убрать переполнение буфера при слишком длинных заголовках
	
	Dim PathTranslated As WString Ptr = Any
	IRequestedFile_GetPathTranslated(pIRequestedFile, @PathTranslated)
	
	Dim wExtHeadersFile As WString * (MAX_PATH + 1) = Any
	lstrcpyW(@wExtHeadersFile, PathTranslated)
	lstrcatW(@wExtHeadersFile, @HeadersExtensionString)
	
	Dim hExtHeadersFile As HANDLE = CreateFileW( _
		@wExtHeadersFile, _
		GENERIC_READ, _
		FILE_SHARE_READ, _
		NULL, _
		OPEN_EXISTING, _
		FILE_ATTRIBUTE_NORMAL Or FILE_FLAG_SEQUENTIAL_SCAN, _
		NULL _
	)
	
	If hExtHeadersFile <> INVALID_HANDLE_VALUE Then
		Dim zExtHeaders As ZString * (MaxResponseBufferLength + 1) = Any
		Dim wExtHeaders As WString * (MaxResponseBufferLength + 1) = Any
		
		Dim BytesReaded As DWORD = Any
		If ReadFile(hExtHeadersFile, @zExtHeaders, MaxResponseBufferLength, @BytesReaded, 0) <> 0 Then
			
			If BytesReaded > 2 Then
				zExtHeaders[BytesReaded] = 0
				
				If MultiByteToWideChar(CP_UTF8, 0, @zExtHeaders, -1, @wExtHeaders, MaxResponseBufferLength) > 0 Then
					Dim w As WString Ptr = @wExtHeaders
					
					Do
						Dim wName As WString Ptr = w
						Dim wColon As WString Ptr = StrChrW(w, Characters.Colon)
						
						w = StrStrW(w, NewLineString)
						
						If w <> 0 Then
							w[0] = Characters.NullChar ' и ещё w[1] = 0
							' Указываем на следующий символ после vbCrLf, если это ноль — то это конец
							w += 2
						End If
						
						If wColon > 0 Then
							wColon[0] = Characters.NullChar
							Do
								wColon += 1
							Loop While wColon[0] = Characters.WhiteSpace
							
							IServerResponse_AddResponseHeader(pIResponse, wName, wColon)
						End If
						
					Loop While lstrlenW(w) > 0
					
				End If
			End If
		End If
		
		CloseHandle(hExtHeadersFile)
	End If
	
End Sub

Sub InitializeHttpGetProcessor( _
		ByVal this As HttpGetProcessor Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pSendBuffer As ZString Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory(@this->IdString, @Str("HttpGetProcessor"), 16)
	#endif
	this->lpVtbl = @GlobalHttpGetProcessorVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->FileHandle = INVALID_HANDLE_VALUE
	this->ZipFileHandle = INVALID_HANDLE_VALUE
	this->pSendBuffer = pSendBuffer
	this->HeadersLength = 0
	
End Sub

Sub UnInitializeHttpGetProcessor( _
		ByVal this As HttpGetProcessor Ptr _
	)
	
	IMalloc_Free(this->pIMemoryAllocator, this->pSendBuffer)
	
	If this->FileHandle <> INVALID_HANDLE_VALUE Then
		CloseHandle(this->FileHandle)
	End If
	
	If this->ZipFileHandle <> INVALID_HANDLE_VALUE Then
		CloseHandle(this->ZipFileHandle)
	End If
	
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
	
	Dim pSendBuffer As ZString Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(ZString) * (MaxResponseBufferLength + 1) _
	)
	
	If pSendBuffer <> NULL Then
		
		Dim this As HttpGetProcessor Ptr = IMalloc_Alloc( _
			pIMemoryAllocator, _
			SizeOf(HttpGetProcessor) _
		)
		
		If this <> NULL Then
			
			InitializeHttpGetProcessor( _
				this, _
				pIMemoryAllocator, _
				pSendBuffer _
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
		
		IMalloc_Free(pIMemoryAllocator, pSendBuffer)
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
	
	If IsEqualIID(@IID_IRequestProcessor, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
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
		ByVal pc As ProcessorContext Ptr _
	)As HRESULT
	
	Dim PathTranslated As WString Ptr = Any
	IRequestedFile_GetPathTranslated(pc->pIRequestedFile, @PathTranslated)
	
	IRequestedFile_GetFileHandle(pc->pIRequestedFile, @this->FileHandle)
	
	Dim FileState As RequestedFileState = Any
	IRequestedFile_FileExists(pc->pIRequestedFile, @FileState)
	
	Select Case FileState
		
		Case RequestedFileState.NotFound
			Return REQUESTPROCESSOR_E_FILENOTFOUND
			
		Case RequestedFileState.Gone
			Return REQUESTPROCESSOR_E_FILEGONE
			
	End Select
	
	' Scope
		
		' Dim pHeaderConnection As WString Ptr = Any
		' IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderConnection, @pHeaderConnection)
		
		' If lstrcmpi(pHeaderConnection, @UpgradeString) = 0 Then
			' Dim pHeaderUpgrade As WString Ptr = Any
			' IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderUpgrade, @pHeaderUpgrade)
			
			' If lstrcmpi(pHeaderUpgrade, @WebSocketString) = 0 Then
				' Dim pHeaderSecWebSocketVersion As WString Ptr = Any
				' IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderSecWebSocketVersion, @pHeaderSecWebSocketVersion)
				
				' If lstrcmpi(pHeaderSecWebSocketVersion, @WebSocketVersionString) = 0 Then
					
					' CloseHandle(FileHandle)
					' Return ProcessWebSocketRequest(pIRequest, pIResponse, pINetworkStream, pIWebSite, pIClientReader, pIRequestedFile)
					
				' End If 
			' End If
		' End If
		
		' Dim ClientUri As Station922Uri = Any
		' IClientRequest_GetUri(pIRequest, @ClientUri)
		
		' Dim NeedProcessing As Boolean = Any
		
		' IWebSite_NeedCgiProcessing(pIWebSite, ClientUri.Path, @NeedProcessing)
		
		' If NeedProcessing Then
			' CloseHandle(FileHandle)
			' Return ProcessCGIRequest(pIRequest, pIResponse, pINetworkStream, pIWebSite, pIClientReader, pIRequestedFile)
		' End If
		
		' TODO ProcessDllCgiRequest
		' IWebSite_NeedDllProcessing(pIWebSite, ClientUri.Path, @NeedProcessing)
		
		' If NeedProcessing Then
			' CloseHandle(FileHandle)
			' Return ProcessDllCgiRequest(pIRequest, pIResponse, pINetworkStream, pIWebSite, pIClientReader, pIRequestedFile)
		' End If
		
	' End Scope
	
	' Проверка запрещённого MIME
	Dim Mime As MimeType = Any
	Dim GetMimeOfFileExtensionResult As Boolean = GetMimeOfFileExtension( _
		@Mime, _
		PathFindExtensionW(PathTranslated) _
	)
	If GetMimeOfFileExtensionResult = False Then
		Return REQUESTPROCESSOR_E_FORBIDDEN
	End If
	
	' TODO Проверить идентификацию для запароленных ресурсов
	
	' Заголовки сжатия
	Dim IsAcceptEncoding As Boolean = Any
	
	If Mime.IsTextFormat Then
		this->ZipFileHandle = SetResponseCompression( _
			pc->pIRequest, _
			pc->pIResponse, _
			PathTranslated, _
			@IsAcceptEncoding _
		)
	Else
		this->ZipFileHandle = INVALID_HANDLE_VALUE
		IsAcceptEncoding = False
	End If
	
	Dim FileSize As LARGE_INTEGER = Any
	Dim GetFileSizeExResult As Integer = Any
	If this->ZipFileHandle = INVALID_HANDLE_VALUE Then
		GetFileSizeExResult = GetFileSizeEx(this->FileHandle, @FileSize)
	Else
		GetFileSizeExResult = GetFileSizeEx(this->ZipFileHandle, @FileSize)
	End If
	
	If GetFileSizeExResult = 0 Then
		Dim dwError As DWORD = GetLastError()
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Dim EncodingFileOffset As LongInt = GetFileBytesOffset( _
		@Mime, _
		this->FileHandle, _
		this->ZipFileHandle _
	)
	
	IServerResponse_SetMimeType(pc->pIResponse, @Mime)
	
	AddResponseCacheHeaders(pc->pIRequest, pc->pIResponse, this->FileHandle)
	
	AddExtendedHeaders(pc->pIResponse, pc->pIRequestedFile)
	
	' В основном анализируются заголовки
	' Accept: text/css, */*
	' Accept-Charset: utf-8
	' Accept-Encoding: gzip, deflate
	' Accept-Language: ru-RU
	' User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36 Edge/15.15063
	' Серверу следует включать в ответ заголовок Vary
	
	' TODO вместо перезаписывания заголовка его нужно добавить
	If IsAcceptEncoding Then
		IServerResponse_AddKnownResponseHeader(pc->pIResponse, HttpResponseHeaders.HeaderVary, WStr("Accept-Encoding"))
	End If
	
	Dim ResponseZipEnable As Boolean = Any
	IServerResponse_GetZipEnabled(pc->pIResponse, @ResponseZipEnable)
	
	If ResponseZipEnable Then
		
		Dim ResponseZipMode As ZipModes = Any
		IServerResponse_GetZipMode(pc->pIResponse, @ResponseZipMode)
		
		Select Case ResponseZipMode
			
			Case ZipModes.GZip
				IServerResponse_AddKnownResponseHeader(pc->pIResponse, HttpResponseHeaders.HeaderContentEncoding, @GZipString)
				
			Case ZipModes.Deflate
				IServerResponse_AddKnownResponseHeader(pc->pIResponse, HttpResponseHeaders.HeaderContentEncoding, @DeflateString)
				
		End Select
		
	End If
	
	Dim EncodingFileSize As LongInt = FileSize.QuadPart - EncodingFileOffset
	
	Dim RequestedByteRange As ByteRange = Any
	IClientRequest_GetByteRange(pc->pIRequest, @RequestedByteRange)
	
	If RequestedByteRange.IsSet = ByteRangeIsSet.NotSet Then
		this->FileBytesOffset = EncodingFileOffset
		this->ContentBodyLength = EncodingFileSize
	Else
		
		Dim pIWriter As IArrayStringWriter Ptr = Any
		Dim hr As HRESULT = CreateInstance( _
			pc->pIMemoryAllocator, _
			@CLSID_ARRAYSTRINGWRITER, _
			@IID_IArrayStringWriter, _
			@pIWriter _
		)
		If FAILED(hr) Then
			Return hr
		End If
		
		Dim wContentRange As WString * (ContentRangeMaximumBufferLength + 1) = Any
		IArrayStringWriter_SetBuffer(pIWriter, @wContentRange, ContentRangeMaximumBufferLength)
		
		Select Case RequestedByteRange.IsSet
			
			Case ByteRangeIsSet.FirstBytePositionIsSet
				' От X байта и до конца: bytes=9500-
				If RequestedByteRange.FirstBytePosition > EncodingFileSize Then
					' Ошибка в диапазоне?
					Dim FirstBytePosition As LongInt = 0
					Dim LastBytePosition As LongInt = EncodingFileSize - 1
					
					MakeContentRangeHeader( _
						pIWriter, _
						FirstBytePosition, _
						LastBytePosition, _
						EncodingFileSize _
					)
					
					IServerResponse_AddKnownResponseHeader(pc->pIResponse, HttpResponseHeaders.HeaderContentRange, @wContentRange)
					
					IArrayStringWriter_Release(pIWriter)
					
					Return REQUESTPROCESSOR_E_RANGENOTSATISFIABLE
				End If
				
				this->FileBytesOffset = EncodingFileOffset + RequestedByteRange.FirstBytePosition
				this->ContentBodyLength = EncodingFileSize - RequestedByteRange.FirstBytePosition
				Dim LastBytePosition As LongInt = this->ContentBodyLength - 1
				
				IServerResponse_SetStatusCode(pc->pIResponse, HttpStatusCodes.PartialContent)
				
				MakeContentRangeHeader( _
					pIWriter, _
					RequestedByteRange.FirstBytePosition, _
					LastBytePosition, _
					EncodingFileSize _
				)
				
				IServerResponse_AddKnownResponseHeader(pc->pIResponse, HttpResponseHeaders.HeaderContentRange, @wContentRange)
				
			Case ByteRangeIsSet.LastBytePositionIsSet
				' Окончательные 500 байт (байтовые смещения 9500-9999, включительно): bytes=-500
				' Только последний байты (9999): bytes=-1
				' Если указано больше чем длина файла
				' то возвращаются все байты файла
				If RequestedByteRange.LastBytePosition = 0 Then
					' Ошибка в диапазоне?
					Dim FirstBytePosition As LongInt = 0
					Dim LastBytePosition As LongInt = EncodingFileSize - 1
					
					MakeContentRangeHeader( _
						pIWriter, _
						FirstBytePosition, _
						LastBytePosition, _
						EncodingFileSize _
					)
					
					IServerResponse_AddKnownResponseHeader(pc->pIResponse, HttpResponseHeaders.HeaderContentRange, @wContentRange)
					
					IArrayStringWriter_Release(pIWriter)
					
					Return REQUESTPROCESSOR_E_RANGENOTSATISFIABLE
				End If
				
				this->ContentBodyLength = min(EncodingFileSize, RequestedByteRange.LastBytePosition)
				this->FileBytesOffset = EncodingFileOffset + EncodingFileSize - this->ContentBodyLength
				Dim FirstBytePosition As LongInt = EncodingFileSize - this->ContentBodyLength
				Dim LastBytePosition As LongInt = FirstBytePosition + this->ContentBodyLength - 1
				
				IServerResponse_SetStatusCode(pc->pIResponse, HttpStatusCodes.PartialContent)
				
				MakeContentRangeHeader( _
					pIWriter, _
					FirstBytePosition, _
					LastBytePosition, _
					EncodingFileSize _
				)
				
				IServerResponse_AddKnownResponseHeader(pc->pIResponse, HttpResponseHeaders.HeaderContentRange, @wContentRange)
				
			Case ByteRangeIsSet.FirstAndLastPositionIsSet
				' Первые 500 байтов (байтовые смещения 0-499 включительно): bytes=0-499
				' Второй 500 байтов (байтовые смещения 500-999 включительно): bytes=500-999
				If RequestedByteRange.LastBytePosition < RequestedByteRange.FirstBytePosition OrElse RequestedByteRange.FirstBytePosition >= EncodingFileSize Then
					Dim FirstBytePosition As LongInt = 0
					Dim LastBytePosition As LongInt = EncodingFileSize - 1
					
					MakeContentRangeHeader( _
						pIWriter, _
						FirstBytePosition, _
						LastBytePosition, _
						EncodingFileSize _
					)
					
					IServerResponse_AddKnownResponseHeader(pc->pIResponse, HttpResponseHeaders.HeaderContentRange, @wContentRange)
					
					IArrayStringWriter_Release(pIWriter)
					
					Return REQUESTPROCESSOR_E_RANGENOTSATISFIABLE
				End If
				
				this->ContentBodyLength = min(RequestedByteRange.LastBytePosition - RequestedByteRange.FirstBytePosition + 1, EncodingFileSize)
				this->FileBytesOffset = EncodingFileOffset + RequestedByteRange.FirstBytePosition
				Dim FirstBytePosition As LongInt = RequestedByteRange.FirstBytePosition
				Dim LastBytePosition As LongInt = min(RequestedByteRange.LastBytePosition, EncodingFileSize - 1)
				
				IServerResponse_SetStatusCode(pc->pIResponse, HttpStatusCodes.PartialContent)
				
				MakeContentRangeHeader( _
					pIWriter, _
					FirstBytePosition, _
					LastBytePosition, _
					EncodingFileSize _
				)
				
				IServerResponse_AddKnownResponseHeader(pc->pIResponse, HttpResponseHeaders.HeaderContentRange, @wContentRange)
				
		End Select
		
		IArrayStringWriter_Release(pIWriter)
	End If
	
	this->HeadersLength = AllResponseHeadersToBytes( _
		pc->pIRequest, _
		pc->pIResponse, _
		this->pSendBuffer, _
		this->ContentBodyLength _
	)
	
	this->CurrentChunkIndex = 0
	
	IRequestedFile_SetFileHandle(pc->pIRequestedFile, INVALID_HANDLE_VALUE)
	
	Return S_OK
	
End Function

Function HttpGetProcessorBeginProcess( _
		ByVal this As HttpGetProcessor Ptr, _
		ByVal pc As ProcessorContext Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	*ppIAsyncResult = NULL
	
	Dim pINewAsyncResult As IMutableAsyncResult Ptr = Any
	Dim hr As HRESULT = CreateInstance( _
		this->pIMemoryAllocator, _
		@CLSID_ASYNCRESULT, _
		@IID_IMutableAsyncResult, _
		@pINewAsyncResult _
	)
	If FAILED(hr) Then
		Return E_OUTOFMEMORY
	End If
	
	Dim lpRecvOverlapped As ASYNCRESULTOVERLAPPED Ptr = Any
	IMutableAsyncResult_GetWsaOverlapped(pINewAsyncResult, @lpRecvOverlapped)
	' TODO Запросить интерфейс вместо конвертирования указателя
	lpRecvOverlapped->pIAsync = CPtr(IAsyncResult Ptr, pINewAsyncResult)
	IMutableAsyncResult_SetAsyncState(pINewAsyncResult, StateObject)
	IMutableAsyncResult_SetAsyncCallback(pINewAsyncResult, NULL)
	
	Dim FileOffsetPointer As LARGE_INTEGER = Any
	FileOffsetPointer.QuadPart = this->CurrentChunkIndex * Cast(LongInt, TRANSMIT_CHUNK_SIZE)
	
	Dim dwCurrentChunkSize As DWORD = Cast(DWORD, _
		min( _
			this->ContentBodyLength - FileOffsetPointer.QuadPart, _
			Cast(LongInt, TRANSMIT_CHUNK_SIZE) _
		) _
	)
	
	Dim pTransmitHeader As TRANSMIT_FILE_BUFFERS Ptr = Any
	If this->CurrentChunkIndex = 0 Then
		this->TransmitHeader.Head = this->pSendBuffer
		this->TransmitHeader.HeadLength = Cast(DWORD, this->HeadersLength)
		this->TransmitHeader.Tail = NULL
		this->TransmitHeader.TailLength = Cast(DWORD, 0)
		pTransmitHeader = @this->TransmitHeader
	Else
		pTransmitHeader = NULL
	End If
	
	Dim SendOnlyHeaders As Boolean = Any
	IServerResponse_GetSendOnlyHeaders(pc->pIResponse, @SendOnlyHeaders)
	
	If SendOnlyHeaders Then
		this->hTransmitFile = NULL
	Else
		If this->ZipFileHandle <> INVALID_HANDLE_VALUE Then
			this->hTransmitFile = this->ZipFileHandle
		Else
			this->hTransmitFile = this->FileHandle
		End If
	End If
	
	Dim ClientSocket As SOCKET = Any
	INetworkStream_GetSocket(pc->pINetworkStream, @ClientSocket)
	
	If this->hTransmitFile <> NULL Then
		Dim CurrentOffsetPointer As LARGE_INTEGER = Any
		CurrentOffsetPointer.QuadPart = FileOffsetPointer.QuadPart + this->FileBytesOffset
		
		Dim OffsetResult As Integer = SetFilePointerEx( _
			this->hTransmitFile, _
			CurrentOffsetPointer, _
			NULL, _
			FILE_BEGIN _
		)
		If OffsetResult = 0 Then
			Dim dwError As DWORD = GetLastError()
			IMutableAsyncResult_Release(pINewAsyncResult)
			Return HRESULT_FROM_WIN32(dwError)
		End If
	End If
	
	Const Reserved As DWORD = 0
	Const NumberOfBytesPerSendDefault As DWORD = 0
	
	Dim TransmitFileResult As Integer = TransmitFile( _
		ClientSocket, _
		this->hTransmitFile, _
		dwCurrentChunkSize, _
		NumberOfBytesPerSendDefault, _
		CPtr(OVERLAPPED Ptr, lpRecvOverlapped), _
		pTransmitHeader, _
		Reserved _
	)
	If TransmitFileResult = 0 Then
		
		Dim intError As Long = WSAGetLastError()
		If intError = ERROR_IO_PENDING OrElse intError = WSA_IO_PENDING Then
			' TODO Запросить интерфейс вместо конвертирования указателя
			*ppIAsyncResult = CPtr(IAsyncResult Ptr, pINewAsyncResult)
			Return REQUESTPROCESSOR_S_IO_PENDING
		End If
		
		IMutableAsyncResult_Release(pINewAsyncResult)
		Return HRESULT_FROM_WIN32(intError)
		
	End If
	
	' TODO Запросить интерфейс вместо конвертирования указателя
	*ppIAsyncResult = CPtr(IAsyncResult Ptr, pINewAsyncResult)
	
	Return S_OK
	
End Function

Function HttpGetProcessorEndProcess( _
		ByVal this As HttpGetProcessor Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	
	' TODO Приём и отправка данных через какой-нибудь объект
	
	If this->hTransmitFile = NULL Then
		If this->FileHandle <> INVALID_HANDLE_VALUE Then
			' If CloseHandle(this->FileHandle) = 0 Then
				' Dim dwError As DWORD = GetLastError()
			' End If
			CloseHandle(this->FileHandle)
			this->FileHandle = INVALID_HANDLE_VALUE
		End If
		
		If this->ZipFileHandle <> INVALID_HANDLE_VALUE Then
			' If CloseHandle(this->ZipFileHandle) = 0 Then
				' Dim dwError As DWORD = GetLastError()
			' End If
			CloseHandle(this->ZipFileHandle)
			this->ZipFileHandle = INVALID_HANDLE_VALUE
		End If
		
		Return S_OK
	End If
	
	Dim FileOffsetPointer As LARGE_INTEGER = Any
	FileOffsetPointer.QuadPart = this->CurrentChunkIndex * Cast(LongInt, TRANSMIT_CHUNK_SIZE)
	
	Dim dwCurrentChunkSize As DWORD = Cast(DWORD, _
		min( _
			this->ContentBodyLength - FileOffsetPointer.QuadPart, _
			Cast(LongInt, TRANSMIT_CHUNK_SIZE) _
		) _
	)
	
	If dwCurrentChunkSize <= TRANSMIT_CHUNK_SIZE Then
		
		If this->FileHandle <> INVALID_HANDLE_VALUE Then
			' If CloseHandle(this->FileHandle) = 0 Then
				' Dim dwError As DWORD = GetLastError()
			' End If
			CloseHandle(this->FileHandle)
			this->FileHandle = INVALID_HANDLE_VALUE
		End If
		
		If this->ZipFileHandle <> INVALID_HANDLE_VALUE Then
			' If CloseHandle(this->ZipFileHandle) = 0 Then
				' Dim dwError As DWORD = GetLastError()
			' End If
			CloseHandle(this->ZipFileHandle)
			this->ZipFileHandle = INVALID_HANDLE_VALUE
		End If
		
		Return S_OK
	End If
	
	this->CurrentChunkIndex += 1
	
	Return REQUESTPROCESSOR_S_IO_PENDING
	
End Function


Function IHttpGetProcessorQueryInterface( _
		ByVal this As IRequestProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return HttpGetProcessorQueryInterface(ContainerOf(this, HttpGetProcessor, lpVtbl), riid, ppv)
End Function

Function IHttpGetProcessorAddRef( _
		ByVal this As IRequestProcessor Ptr _
	)As ULONG
	Return HttpGetProcessorAddRef(ContainerOf(this, HttpGetProcessor, lpVtbl))
End Function

Function IHttpGetProcessorRelease( _
		ByVal this As IRequestProcessor Ptr _
	)As ULONG
	Return HttpGetProcessorRelease(ContainerOf(this, HttpGetProcessor, lpVtbl))
End Function

Function IHttpGetProcessorPrepare( _
		ByVal this As IRequestProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr _
	)As HRESULT
	Return HttpGetProcessorPrepare(ContainerOf(this, HttpGetProcessor, lpVtbl), pContext)
End Function

Function IHttpGetProcessorBeginProcess( _
		ByVal this As IRequestProcessor Ptr, _
		ByVal pContext As ProcessorContext Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return HttpGetProcessorBeginProcess(ContainerOf(this, HttpGetProcessor, lpVtbl), pContext, StateObject, ppIAsyncResult)
End Function

Function IHttpGetProcessorEndProcess( _
		ByVal this As IRequestProcessor Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	Return HttpGetProcessorEndProcess(ContainerOf(this, HttpGetProcessor, lpVtbl), pIAsyncResult)
End Function

Dim GlobalHttpGetProcessorVirtualTable As Const IRequestProcessorVirtualTable = Type( _
	@IHttpGetProcessorQueryInterface, _
	@IHttpGetProcessorAddRef, _
	@IHttpGetProcessorRelease, _
	@IHttpGetProcessorPrepare, _
	NULL, _ /' @IHttpGetProcessorProcess '/
	@IHttpGetProcessorBeginProcess, _
	@IHttpGetProcessorEndProcess _
)
