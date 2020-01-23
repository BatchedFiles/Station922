#include "ProcessGetHeadRequest.bi"
#include "HttpConst.bi"
#include "WriteHttpError.bi"
#include "Mime.bi"
#include "WebUtils.bi"
#include "CharacterConstants.bi"
#include "StringConstants.bi"
#include "ProcessCgiRequest.bi"
#include "ProcessDllRequest.bi"
#include "ProcessWebSocketRequest.bi"
#include "SafeHandle.bi"
#include "ArrayStringWriter.bi"
#include "win\Mswsock.bi"
#include "win\shlwapi.bi"

Const MaxTransmitSize As DWORD = 536870912
Const ContentRangeMaximumBufferLength As Integer = 512 - 1

Declare Function GetFileBytesStartingIndex( _
	ByVal mt As MimeType Ptr, _
	ByVal hRequestedFile As HANDLE, _
	ByVal hZipFile As HANDLE _
)As LongInt

Declare Sub AddExtendedHeaders( _
	ByVal pIResponse As IServerResponse Ptr, _
	ByVal pIRequestedFile As IRequestedFile Ptr _
)

Function ProcessGetHeadRequest( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pINetworkStream As INetworkStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr, _
		ByVal pIClientReader As IHttpReader Ptr, _
		ByVal pIRequestedFile As IRequestedFile Ptr _
	)As Boolean
	
	Dim PathTranslated As WString Ptr = Any
	IRequestedFile_GetPathTranslated(pIRequestedFile, @PathTranslated)
	
	Dim FileHandle As HANDLE = Any
	IRequestedFile_GetFileHandle(pIRequestedFile, @FileHandle)
	
	Dim FileExists As RequestedFileState = Any
	IRequestedFile_FileExists(pIRequestedFile, @FileExists)
	
	Select Case FileExists
		
		Case RequestedFileState.NotFound
			WriteHttpFileNotFound(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), pIWebSite)
			Return False
			
		Case RequestedFileState.Gone
			WriteHttpFileGone(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), pIWebSite)
			Return False
			
	End Select
	
	Scope
		
		Dim pHeaderConnection As WString Ptr = Any
		IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderConnection, @pHeaderConnection)
		
		If lstrcmpi(pHeaderConnection, @UpgradeString) = 0 Then
			Dim pHeaderUpgrade As WString Ptr = Any
			IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderUpgrade, @pHeaderUpgrade)
			
			If lstrcmpi(pHeaderUpgrade, @WebSocketString) = 0 Then
				Dim pHeaderSecWebSocketVersion As WString Ptr = Any
				IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderSecWebSocketVersion, @pHeaderSecWebSocketVersion)
				
				If lstrcmpi(pHeaderSecWebSocketVersion, @WebSocketVersionString) = 0 Then
					
					CloseHandle(FileHandle)
					Return ProcessWebSocketRequest(pIRequest, pIResponse, pINetworkStream, pIWebSite, pIClientReader, pIRequestedFile)
					
				End If 
			End If
		End If
		
		Dim ClientUri As Station922Uri = Any
		IClientRequest_GetUri(pIRequest, @ClientUri)
		
		Dim NeedProcessing As Boolean = Any
		
		IWebSite_NeedCgiProcessing(pIWebSite, ClientUri.Path, @NeedProcessing)
		
		If NeedProcessing Then
			CloseHandle(FileHandle)
			Return ProcessCGIRequest(pIRequest, pIResponse, pINetworkStream, pIWebSite, pIClientReader, pIRequestedFile)
		End If
		
		IWebSite_NeedDllProcessing(pIWebSite, ClientUri.Path, @NeedProcessing)
		
		If NeedProcessing Then
			CloseHandle(FileHandle)
			Return ProcessDllCgiRequest(pIRequest, pIResponse, pINetworkStream, pIWebSite, pIClientReader, pIRequestedFile)
		End If
		
	End Scope
	
	Dim objRequestedFile As SafeHandle = Type<SafeHandle>(FileHandle)
	
	' Проверка запрещённого MIME
	Dim Mime As MimeType = Any
	Dim GetMimeOfFileExtensionResult As Boolean = GetMimeOfFileExtension(@Mime, PathFindExtension(PathTranslated))
	
	If GetMimeOfFileExtensionResult = False Then
		WriteHttpForbidden(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), pIWebSite)
		Return False
	End If
	
	' TODO Проверить идентификацию для запароленных ресурсов
	
	' Заголовки сжатия
	Dim hZipFile As Handle = Any
	Dim IsAcceptEncoding As Boolean = Any
	
	If Mime.IsTextFormat Then
		hZipFile = SetResponseCompression(pIRequest, pIResponse, PathTranslated, @IsAcceptEncoding)
	Else
		hZipFile = INVALID_HANDLE_VALUE
		IsAcceptEncoding = False
	End If
	
	Dim objHZipFile As SafeHandle = Type<SafeHandle>(hZipFile)
	
	Dim FileSize As LARGE_INTEGER = Any
	Dim GetFileSizeExResult As Integer = Any
	If hZipFile = INVALID_HANDLE_VALUE Then
		GetFileSizeExResult = GetFileSizeEx(FileHandle, @FileSize)
	Else
		GetFileSizeExResult = GetFileSizeEx(hZipFile, @FileSize)
	End If
	
	If GetFileSizeExResult = 0 Then
		' TODO Оработать код ошибки через GetLastError()
		WriteHttpInternalServerError(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), pIWebSite)
		Return False
	End If
	
	Dim FileBytesStartingIndex As LongInt = GetFileBytesStartingIndex( _
		@Mime, _
		FileHandle, _
		hZipFile _
	)
	
	IServerResponse_SetMimeType(pIResponse, @Mime)
	
	AddResponseCacheHeaders(pIRequest, pIResponse, FileHandle)
	
	AddExtendedHeaders(pIResponse, pIRequestedFile)
	
	' В основном анализируются заголовки
	' Accept: text/css, */*
	' Accept-Charset: utf-8
	' Accept-Encoding: gzip, deflate
	' Accept-Language: ru-RU
	' User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36 Edge/15.15063
	' Серверу следует включать в ответ заголовок Vary
	
	' TODO вместо перезаписывания заголовка его нужно добавить
	If IsAcceptEncoding Then
		IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderVary, @"Accept-Encoding")
	End If
	
	Dim ResponseZipEnable As Boolean = Any
	IServerResponse_GetZipEnabled(pIResponse, @ResponseZipEnable)
	
	If ResponseZipEnable Then
		
		Dim ResponseZipMode As ZipModes = Any
		IServerResponse_GetZipMode(pIResponse, @ResponseZipMode)
		
		Select Case ResponseZipMode
			
			Case ZipModes.GZip
				IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderContentEncoding, @GZipString)
				
			Case ZipModes.Deflate
				IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderContentEncoding, @DeflateString)
				
		End Select
		
	End If
	
	Dim BodyLength As ULongInt = FileSize.QuadPart - FileBytesStartingIndex
	
	Dim HeadersWriter As ArrayStringWriter = Any
	Dim pIWriter As IArrayStringWriter Ptr = InitializeArrayStringWriterOfIArrayStringWriter(@HeadersWriter)
	
	Dim wContentRange As WString * (ContentRangeMaximumBufferLength + 1) = Any
	ArrayStringWriter_NonVirtualSetBuffer(pIWriter, @wContentRange, ContentRangeMaximumBufferLength)
	
	Dim RequestedByteRange As ByteRange = Any
	IClientRequest_GetByteRange(pIRequest, @RequestedByteRange)
	
	Select Case RequestedByteRange.IsSet
		
		Case ByteRangeIsSet.FirstBytePositionIsSet
			' Окончательные 500 байт (байтовые смещения 9500-9999, включительно): bytes=9500-
			If RequestedByteRange.FirstBytePosition <= BodyLength Then
				Dim TotalBodyLength As ULongInt = BodyLength
				
				If RequestedByteRange.FirstBytePosition > 0 Then
					BodyLength -= RequestedByteRange.FirstBytePosition
					
					Dim liDistanceToMove As LARGE_INTEGER = Any
					liDistanceToMove.QuadPart = RequestedByteRange.FirstBytePosition
					If SetFilePointerEx(FileHandle, liDistanceToMove, NULL, FILE_CURRENT) = 0 Then
						#if __FB_DEBUG__ <> 0
							Dim dwError As DWORD = GetLastError()
							Print "Ошибка SetFilePointerEx", dwError
						#endif
					End If
				End If
				
				IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.PartialContent)

				MakeContentRangeHeader( _
					CPtr(ITextWriter Ptr, pIWriter), _
					RequestedByteRange.FirstBytePosition, _
					TotalBodyLength - 1, _
					TotalBodyLength _
				)
				
				IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderContentRange, @wContentRange)
			Else
				' Ошибка в диапазоне?
			End If
			
		Case ByteRangeIsSet.LastBytePositionIsSet
			' Окончательные 500 байт (байтовые смещения 9500-9999, включительно): bytes=-500
			' Только последние байты (9999): bytes=-1
			If RequestedByteRange.LastBytePosition > 0 Then
				Dim TotalBodyLength As ULongInt = BodyLength
				BodyLength = Minimum(RequestedByteRange.LastBytePosition, TotalBodyLength)
				
				If RequestedByteRange.LastBytePosition < TotalBodyLength Then
					Dim liDistanceToMove As LARGE_INTEGER = Any
					liDistanceToMove.QuadPart = -BodyLength
					If SetFilePointerEx(FileHandle, liDistanceToMove, NULL, FILE_END) = 0 Then
						#if __FB_DEBUG__ <> 0
							Dim dwError As DWORD = GetLastError()
							Print "Ошибка SetFilePointerEx", dwError
						#endif
					End If
				End If
				
				IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.PartialContent)
				
				MakeContentRangeHeader( _
					CPtr(ITextWriter Ptr, pIWriter), _
					TotalBodyLength - BodyLength, _
					TotalBodyLength - 1, _
					TotalBodyLength _
				)
				
				IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderContentRange, @wContentRange)
			Else
				' Ошибка в диапазоне?
			End If
			
		Case ByteRangeIsSet.FirstAndLastPositionIsSet
			' Первые 500 байтов (байтовые смещения 0-499 включительно): bytes=0-499
			' Второй 500 байтов (байтовые смещения 500-999 включительно): bytes=500-999
			If RequestedByteRange.FirstBytePosition <= RequestedByteRange.LastBytePosition Then
				Dim TotalBodyLength As ULongInt = BodyLength
				
				If RequestedByteRange.FirstBytePosition < TotalBodyLength Then
					BodyLength = Minimum(RequestedByteRange.LastBytePosition - RequestedByteRange.FirstBytePosition + 1, BodyLength)
					
					If RequestedByteRange.FirstBytePosition > 0 Then
						Dim liDistanceToMove As LARGE_INTEGER = Any
						liDistanceToMove.QuadPart = RequestedByteRange.FirstBytePosition
						If SetFilePointerEx(FileHandle, liDistanceToMove, NULL, FILE_CURRENT) = 0 Then
							#if __FB_DEBUG__ <> 0
								Dim dwError As DWORD = GetLastError()
								Print "Ошибка SetFilePointerEx", dwError
							#endif
						End If
					End If
					
					IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.PartialContent)
					
					MakeContentRangeHeader( _
						CPtr(ITextWriter Ptr, pIWriter), _
						RequestedByteRange.FirstBytePosition, _
						RequestedByteRange.FirstBytePosition + BodyLength - 1, _
						TotalBodyLength _
					)
					
					IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderContentRange, @wContentRange)
				Else
					' Ошибка в диапазоне?
				End If
			Else
				' Ошибка в диапазоне?
			End If
			
	End Select
	
	ArrayStringWriter_NonVirtualRelease(pIWriter)
	
	Dim SendBuffer As ZString * (MaxResponseBufferLength + 1) = Any
	Dim HeadersLength As Integer = AllResponseHeadersToBytes(pIRequest, pIResponse, @SendBuffer, BodyLength)
	
	Dim TransmitHeader As TRANSMIT_FILE_BUFFERS = Any
	With TransmitHeader
		.Head = @SendBuffer
		.HeadLength = Cast(DWORD, HeadersLength)
		.Tail = NULL
		.TailLength = Cast(DWORD, 0)
	End With
	
	Dim SendOnlyHeaders As Boolean = Any
	IServerResponse_GetSendOnlyHeaders(pIResponse, @SendOnlyHeaders)
	
	Dim hTransmitFile As HANDLE = Any
	
	If SendOnlyHeaders Then
		hTransmitFile = NULL
	Else
		If hZipFile <> INVALID_HANDLE_VALUE Then
			hTransmitFile = hZipFile
		Else
			hTransmitFile = FileHandle
		End If
	End If
	
	Dim ClientSocket As SOCKET = Any
	INetworkStream_GetSocket(pINetworkStream, @ClientSocket)
	
	If TransmitFile(ClientSocket, hTransmitFile, Cast(DWORD, Minimum(MaxTransmitSize, BodyLength)), 0, NULL, @TransmitHeader, 0) = 0 Then
		#if __FB_DEBUG__ <> 0
			Dim intError As Integer = WSAGetLastError()
			Print "Ошибка отправки файла", intError
		#endif
		Return False
	End If
	
	If hTransmitFile <> NULL Then
		
		Dim i As ULongInt = 1
		
		Do While BodyLength > Cast(ULongInt, MaxTransmitSize)
			BodyLength -= Cast(ULongInt, MaxTransmitSize)
			
			Dim NewPointer As LARGE_INTEGER = Any
			NewPointer.QuadPart = i * Cast(LongInt, MaxTransmitSize)
			SetFilePointerEx(hTransmitFile, NewPointer, NULL, FILE_BEGIN)
			
			If BodyLength <> 0 Then
				If TransmitFile(ClientSocket, hTransmitFile, Cast(DWORD, Minimum(MaxTransmitSize, BodyLength)), 0, NULL, NULL, 0) = 0 Then
					#if __FB_DEBUG__ <> 0
						Dim intError As Integer = WSAGetLastError()
						Print "Ошибка отправки файла", intError
					#endif
					Return False
				End If
			End If
			
			i += 1
		Loop
		
	End If
	
	Return True
	
End Function

Function GetFileBytesStartingIndex( _
		ByVal mt As MimeType Ptr, _
		ByVal hRequestedFile As HANDLE, _
		ByVal hZipFile As HANDLE _
	)As LongInt
	
	If mt->IsTextFormat Then
		Const MaxBytesRead As DWORD = 16 - 1
		
		Dim FileBytes As ZString * (MaxBytesRead + 1) = Any
		Dim BytesReaded As DWORD = Any
		
		If ReadFile(hRequestedFile, @FileBytes, MaxBytesRead, @BytesReaded, 0) <> 0 Then
			
			mt->Charset = GetDocumentCharset(@FileBytes)
			
			Dim FileBytesStartIndex As LongInt = Any
			
			If hZipFile = INVALID_HANDLE_VALUE Then
				
				Select Case mt->Charset
					
					Case DocumentCharsets.Utf8BOM
						FileBytesStartIndex = 3
						
					Case DocumentCharsets.Utf16LE
						FileBytesStartIndex = 0
						
					Case DocumentCharsets.Utf16BE
						FileBytesStartIndex = 2
						
					Case Else
						FileBytesStartIndex = 0
						
				End Select
			Else
				FileBytesStartIndex = 0
				
			End If
			
			Dim liDistanceToMove As LARGE_INTEGER = Any
			liDistanceToMove.QuadPart = FileBytesStartIndex
			SetFilePointerEx(hRequestedFile, liDistanceToMove, NULL, FILE_BEGIN)
			
			Return FileBytesStartIndex
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
	lstrcpy(@wExtHeadersFile, PathTranslated)
	lstrcat(@wExtHeadersFile, @HeadersExtensionString)
	
	Dim hExtHeadersFile As HANDLE = CreateFile( _
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
						Dim wColon As WString Ptr = StrChr(w, Characters.Colon)
						
						w = StrStr(w, NewLineString)
						
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
						
					Loop While lstrlen(w) > 0
					
				End If
			End If
		End If
		
		CloseHandle(hExtHeadersFile)
	End If
	
End Sub
