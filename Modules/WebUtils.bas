#include once "WebUtils.bi"
#include once "win\shlwapi.bi"
#include once "win\wincrypt.bi"
#include once "IStringable.bi"
#include once "IWebServerConfiguration.bi"
#include once "CharacterConstants.bi"
#include once "CreateInstance.bi"
#include once "HttpConst.bi"
#include once "Mime.bi"
#include once "StringConstants.bi"
#include once "Station922Uri.bi"
#include once "WriteHttpError.bi"

Extern CLSID_WEBSERVERINICONFIGURATION Alias "CLSID_WEBSERVERINICONFIGURATION" As Const CLSID

Const DateFormatString = WStr("ddd, dd MMM yyyy ")
Const TimeFormatString = WStr("HH:mm:ss GMT")
Const DefaultCacheControl = WStr("max-age=2678400")

Declare Function GetBase64Sha1( _
	ByVal pDestination As WString Ptr, _
	ByVal pSource As WString Ptr _
)As Boolean

Function GetHtmlSafeString( _
		ByVal Buffer As WString Ptr, _
		ByVal BufferLength As Integer, _
		ByVal HtmlSafe As WString Ptr, _
		ByVal pHtmlSafeLength As Integer Ptr _
	)As Boolean
	
	Const MaxQuotationMarkSafeStringLength As Integer = 6
	Const MaxAmpersandSafeStringLength As Integer = 5
	Const MaxApostropheSafeStringLength As Integer = 6
	Const MaxLessThanSignSafeStringLength As Integer = 4
	Const MaxGreaterThanSignSafeStringLength As Integer = 4
	
	Dim SafeLength As Integer = Any
	
	' Посчитать размер буфера
	Scope
		
		Dim cbNeedenBufferLength As Integer = 0
		
		Dim i As Integer = 0
		
		Do While HtmlSafe[i] <> 0
			Dim Number As Integer = HtmlSafe[i]
			
			Select Case Number
				
				Case Characters.QuotationMark
					cbNeedenBufferLength += MaxQuotationMarkSafeStringLength
					
				Case Characters.Ampersand
					cbNeedenBufferLength += MaxAmpersandSafeStringLength
					
				Case Characters.Apostrophe
					cbNeedenBufferLength += MaxApostropheSafeStringLength
					
				Case Characters.LessThanSign
					cbNeedenBufferLength += MaxLessThanSignSafeStringLength
					
				Case Characters.GreaterThanSign
					cbNeedenBufferLength += MaxGreaterThanSignSafeStringLength
					
				Case Else
					cbNeedenBufferLength += 1
					
			End Select
			
			i += 1
			
		Loop
		
		SafeLength = i
		
		*pHtmlSafeLength = cbNeedenBufferLength
		
		If Buffer = 0 Then
			SetLastError(ERROR_SUCCESS)
			Return True
		End If
		
		If BufferLength < cbNeedenBufferLength Then
			SetLastError(ERROR_INSUFFICIENT_BUFFER)
			Return False
		End If
		
	End Scope
	
	Scope
		
		Dim BufferIndex As Integer = 0
		
		For OriginalIndex As Integer = 0 To SafeLength - 1
			
			Dim Number As Integer = HtmlSafe[OriginalIndex]
			
			Select Case Number
				
				Case Is < 32
					' Пропустить непробельные символы
					
				Case Characters.QuotationMark
					' Заменить на &quot;
					Buffer[BufferIndex + 0] = Characters.Ampersand
					Buffer[BufferIndex + 1] = &h71  ' q
					Buffer[BufferIndex + 2] = &h75  ' u
					Buffer[BufferIndex + 3] = &h6f  ' o
					Buffer[BufferIndex + 4] = &h74  ' t
					Buffer[BufferIndex + 5] = Characters.Semicolon
					BufferIndex += MaxQuotationMarkSafeStringLength
					
				Case Characters.Ampersand
					' Заменить на &amp;
					Buffer[BufferIndex + 0] = Characters.Ampersand
					Buffer[BufferIndex + 1] = &h61  ' a
					Buffer[BufferIndex + 2] = &h6d  ' m
					Buffer[BufferIndex + 3] = &h70  ' p
					Buffer[BufferIndex + 4] = Characters.Semicolon
					BufferIndex += MaxAmpersandSafeStringLength
					
				Case Characters.Apostrophe
					' Заменить на &apos;
					Buffer[BufferIndex + 0] = Characters.Ampersand
					Buffer[BufferIndex + 1] = &h61  ' a
					Buffer[BufferIndex + 2] = &h70  ' p
					Buffer[BufferIndex + 3] = &h6f  ' o
					Buffer[BufferIndex + 4] = &h73  ' s
					Buffer[BufferIndex + 5] = Characters.Semicolon
					BufferIndex += MaxApostropheSafeStringLength
					
				Case Characters.LessThanSign
					' Заменить на &lt;
					Buffer[BufferIndex + 0] = Characters.Ampersand
					Buffer[BufferIndex + 1] = &h6c  ' l
					Buffer[BufferIndex + 2] = &h74  ' t
					Buffer[BufferIndex + 3] = Characters.Semicolon
					BufferIndex += MaxLessThanSignSafeStringLength
					
				Case Characters.GreaterThanSign
					' Заменить на &gt;
					Buffer[BufferIndex + 0] = Characters.Ampersand
					Buffer[BufferIndex + 1] = &h67  ' g
					Buffer[BufferIndex + 2] = &h74  ' t
					Buffer[BufferIndex + 3] = Characters.Semicolon
					BufferIndex += MaxGreaterThanSignSafeStringLength
					
				Case Else
					Buffer[BufferIndex] = Number
					BufferIndex += 1
					
			End Select
			
		Next
		
		' Завершающий нулевой символ
		Buffer[BufferIndex] = 0
		SetLastError(ERROR_SUCCESS)
		
		Return True
		
	End Scope
	
End Function

Sub GetHttpDate( _
		ByVal Buffer As WString Ptr, _
		ByVal dt As SYSTEMTIME Ptr _
	)
	
	' Tue, 15 Nov 1994 12:45:26 GMT
	Dim dtBufferLength As Integer = GetDateFormatW(LOCALE_INVARIANT, 0, dt, @DateFormatString, Buffer, 31) - 1
	GetTimeFormatW(LOCALE_INVARIANT, 0, dt, @TimeFormatString, @Buffer[dtBufferLength], 31 - dtBufferLength)
	
End Sub

Sub GetHttpDate(ByVal Buffer As WString Ptr)
	
	Dim dt As SYSTEMTIME = Any
	GetSystemTime(@dt)
	GetHttpDate(Buffer, @dt)
	
End Sub

/'
Function HttpAuthUtil( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr,  _
		ByVal ProxyAuthorization As Boolean _
	)As Boolean
	
	Dim pHeaderAuthorization As WString Ptr = Any
	
	If ProxyAuthorization Then
		IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderProxyAuthorization, @pHeaderAuthorization)
		
		If lstrlenW(pHeaderAuthorization) = 0 Then
			IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderAuthorization, @pHeaderAuthorization)
		End If
	Else
		IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderAuthorization, @pHeaderAuthorization)
	End If
	
	If lstrlenW(pHeaderAuthorization) = 0 Then
		' WriteHttpNeedAuthenticate(pIRequest, pIResponse, pStream, pIWebSite)
		Return False
	End If
	
	Dim pSpace As WString Ptr = StrChrW(pHeaderAuthorization, Characters.WhiteSpace)
	If pSpace = 0 Then
		' WriteHttpBadAuthenticateParam(pIRequest, pIResponse, pStream, pIWebSite)
		Return False
	End If
	
	pSpace[0] = 0
	
	If lstrcmpW(pHeaderAuthorization, @BasicAuthorization) <> 0 Then
		' WriteHttpNeedBasicAuthenticate(pIRequest, pIResponse, pStream, pIWebSite)
		Return False
	End If
	
	Dim UsernamePasswordUtf8 As ZString * (MaxRequestBufferLength + 1) = Any
	Dim dwUsernamePasswordUtf8Length As DWORD = Cast(DWORD, MaxRequestBufferLength)
	
	CryptStringToBinaryW( _
		@pSpace[1], _
		0, _
		CRYPT_STRING_BASE64, _
		@UsernamePasswordUtf8, _
		@dwUsernamePasswordUtf8Length, _
		0, _
		0 _
	)
	
	UsernamePasswordUtf8[dwUsernamePasswordUtf8Length] = 0
	
	' Из массива байт в строку
	' Преобразуем utf8 в WString
	' -1 — значит, длина строки будет проверяться самой функцией по завершающему нулю
	Dim UsernamePasswordKey As WString * (MaxRequestBufferLength + 1) = Any
	MultiByteToWideChar( _
		CP_UTF8, _
		0, _
		@UsernamePasswordUtf8, _
		-1, _
		@UsernamePasswordKey, _
		MaxRequestBufferLength _
	)
	
	' Теперь pSpace хранит в себе указатель на разделитель-двоеточие
	pSpace = StrChrW(@UsernamePasswordKey, Characters.Colon)
	If pSpace = 0 Then
		' WriteHttpEmptyPassword(pIRequest, pIResponse, pStream, pIWebSite)
		Return False
	End If
	
	' Убрали двоеточие
	pSpace[0] = 0
	
	Dim pIMemoryAllocator As IMalloc Ptr = Any
	Scope
		Dim hr As HRESULT = CoGetMalloc(1, @pIMemoryAllocator)
		If FAILED(hr) Then
			Return False
		End If
	End Scope
	
	Dim pILogger As ILogger Ptr = Any
	Dim hrCreateLogger As HRESULT = CreateLoggerInstance( _
		pIMemoryAllocator, _
		@CLSID_CONSOLELOGGER, _
		@IID_ILogger, _
		@pILogger _
	)
	If FAILED(hrCreateLogger) Then
		IMalloc_Release(pIMemoryAllocator)
		Return False
	End If
	
	Dim pIConfig As IWebServerConfiguration Ptr = Any
	Scope
		Dim hr As HRESULT = CreateInstance( _
			pILogger, _
			pIMemoryAllocator, _
			@CLSID_WEBSERVERINICONFIGURATION, _
			@IID_IWebServerConfiguration, _
			@pIConfig _
		)
		If FAILED(hr) Then
			ILogger_Release(pILogger)
			IMalloc_Release(pIMemoryAllocator)
			Return False
		End If
	End Scope
	
	Dim IsPasswordValid As Boolean = Any
	Scope
		Dim hr As HRESULT = IWebServerConfiguration_GetIsPasswordValid( _
			pIConfig, _
			@UsernamePasswordKey, _
			pSpace + 1, _
			@IsPasswordValid _
		)
		If FAILED(hr) Then
			IWebServerConfiguration_Release(pIConfig)
			ILogger_Release(pILogger)
			IMalloc_Release(pIMemoryAllocator)
			Return False
		End If
	End Scope
	
	IWebServerConfiguration_Release(pIConfig)
	ILogger_Release(pILogger)
	IMalloc_Release(pIMemoryAllocator)
	
	Return IsPasswordValid
	
End Function
'/

Sub GetETag( _
		ByVal wETag As WString Ptr, _
		ByVal pDateLastFileModified As FILETIME Ptr, _
		ByVal ZipEnable As Boolean, _
		ByVal ResponseZipMode As ZipModes _
	)
	
	lstrcpyW(wETag, @QuoteString)
	
	Dim ul As ULARGE_INTEGER = Any
	With ul
		.LowPart = pDateLastFileModified->dwLowDateTime
		.HighPart = pDateLastFileModified->dwHighDateTime
	End With
	
	_ui64tow(ul.QuadPart, @wETag[1], 10)
	
	If ZipEnable Then
		Select Case ResponseZipMode
			
			Case ZipModes.GZip
				lstrcatW(wETag, @GzipString)
				
			Case ZipModes.Deflate
				lstrcatW(wETag, @DeflateString)
				
		End Select
	End If
	
	lstrcatW(wETag, @QuoteString)
	
End Sub

Function AllResponseHeadersToBytes( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal zBuffer As ZString Ptr, _
		ByVal ContentLength As ULongInt _
	)As Integer
	
	' TODO Найти способ откатывать изменения буфера заголовков ответа
	
	Dim StatusCode As HttpStatusCodes = Any
	IServerResponse_GetStatusCode(pIResponse, @StatusCode)
	
	If StatusCode <> HttpStatusCodes.PartialContent Then
		IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderAcceptRanges, @BytesString)
	End If
	
	' Dim KeepAlive As Boolean = Any
	' If pIRequest = NULL Then
		' KeepAlive = False
	' Else
		' IClientRequest_GetKeepAlive(pIRequest, @KeepAlive)
	' End If
	
	' If KeepAlive Then
		' Dim HttpVersion As HttpVersions = Any
		' If pIRequest = NULL Then
			' HttpVersion = HttpVersions.Http10
		' Else
			' IClientRequest_GetHttpVersion(pIRequest, @HttpVersion)
		' End If
		
	' Else
		' IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderConnection, @CloseString)
	' End If
	
	Select Case StatusCode
		
		Case HttpStatusCodes.CodeContinue, HttpStatusCodes.SwitchingProtocols, HttpStatusCodes.Processing, HttpStatusCodes.NoContent
			IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderContentLength, NULL)
			
		Case Else
			Dim strContentLength As WString * (64) = Any
			_ui64tow(ContentLength, @strContentLength, 10)
			IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderContentLength, @strContentLength)
			
	End Select
	
	Dim pIStringable As IStringable Ptr = Any
	IServerResponse_QueryInterface(pIResponse, @IID_IStringable, @pIStringable)
	
	Dim HeadersBufferLength As Integer = Any
	Dim pHeadersBuffer As WString Ptr = Any
	IStringable_ToString(pIStringable, @HeadersBufferLength, @pHeadersBuffer)
	
	Dim HeadersLength As Integer = WideCharToMultiByte( _
		CP_ACP, _
		0, _
		pHeadersBuffer, _
		HeadersBufferLength, _
		zBuffer, _
		MaxResponseBufferLength + 1, _
		0, _
		0 _
	)
	
	IStringable_Release(pIStringable)
	
	Return HeadersLength
	
End Function

Function SetResponseCompression( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal PathTranslated As WString Ptr, _
		ByVal pAcceptEncoding As Boolean Ptr _
	)As Handle
	
	Const GzipExtensionString = WStr(".gz")
	Const DeflateExtensionString = WStr(".deflate")
	
	*pAcceptEncoding = False
	
	Scope
		Dim GZipFileName As WString * (MAX_PATH + 1) = Any
		lstrcpyW(@GZipFileName, PathTranslated)
		lstrcatW(@GZipFileName, @GZipExtensionString)
		
		Dim hFile As HANDLE = CreateFileW( _
			@GZipFileName, _
			GENERIC_READ, _
			FILE_SHARE_READ, _
			NULL, _
			OPEN_EXISTING, _
			FILE_ATTRIBUTE_NORMAL Or FILE_FLAG_SEQUENTIAL_SCAN, _
			NULL _
		)
		
		If hFile <> INVALID_HANDLE_VALUE Then
			*pAcceptEncoding = True
			
			Dim IsGZip As Boolean = Any
			IClientRequest_GetZipMode(pIRequest, ZipModes.GZip, @IsGZip)
			
			If IsGZip Then
				IServerResponse_SetZipEnabled(pIResponse, True)
				IServerResponse_SetZipMode(pIResponse, ZipModes.GZip)
				Return hFile
			End If
			
			CloseHandle(hFile)
		End If
	End Scope
	
	Scope
		Dim DeflateFileName As WString * (MAX_PATH + 1) = Any
		lstrcpyW(@DeflateFileName, PathTranslated)
		lstrcatW(@DeflateFileName, @DeflateExtensionString)
		
		Dim hFile As HANDLE = CreateFileW( _
			@DeflateFileName, _
			GENERIC_READ, _
			FILE_SHARE_READ, _
			NULL, _
			OPEN_EXISTING, _
			FILE_ATTRIBUTE_NORMAL Or FILE_FLAG_SEQUENTIAL_SCAN, _
			NULL _
		)
		
		If hFile <> INVALID_HANDLE_VALUE Then
			*pAcceptEncoding = True
		
			Dim IsDeflate As Boolean = Any
			IClientRequest_GetZipMode(pIRequest, ZipModes.Deflate, @IsDeflate)
			
			If IsDeflate Then
				IServerResponse_SetZipEnabled(pIResponse, True)
				IServerResponse_SetZipMode(pIResponse, ZipModes.Deflate)
				Return hFile
			End If
			
			CloseHandle(hFile)
		End If
	End Scope
	
	Return INVALID_HANDLE_VALUE
	
End Function

Sub AddResponseCacheHeaders( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal hFile As HANDLE _
	)
	Dim IsFileModified As Boolean = True
	
	Dim DateLastFileModified As FILETIME = Any
	If GetFileTime(hFile, 0, 0, @DateLastFileModified) = 0 Then
		Exit Sub
	End If
	
	Scope
		' TODO Уметь распознавать все три HTTP-формата даты
		Dim dFileLastModified As SYSTEMTIME = Any
		FileTimeToSystemTime(@DateLastFileModified, @dFileLastModified)
		
		Dim strFileLastModifiedHttpDate As WString * 256 = Any
		GetHttpDate(@strFileLastModifiedHttpDate, @dFileLastModified)
		
		IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderLastModified, @strFileLastModifiedHttpDate)
		
		Dim pHeaderIfModifiedSince As WString Ptr = Any
		IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderIfModifiedSince, @pHeaderIfModifiedSince)
		
		If lstrlenW(pHeaderIfModifiedSince) <> 0 Then
			
			Dim wSeparator As WString Ptr = StrChrW(pHeaderIfModifiedSince, Characters.Semicolon)
			If wSeparator <> 0 Then
				wSeparator[0] = 0
			End If
			
			If lstrcmpiW(@strFileLastModifiedHttpDate, pHeaderIfModifiedSince) = 0 Then
				IsFileModified = False
			End If
		End If
		
		Dim pHeaderIfUnModifiedSince As WString Ptr = Any
		IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderIfUnModifiedSince, @pHeaderIfUnModifiedSince)
		
		If lstrlenW(pHeaderIfUnModifiedSince) <> 0 Then
			
			Dim wSeparator As WString Ptr = StrChrW(pHeaderIfUnModifiedSince, Characters.Semicolon)
			If wSeparator <> 0 Then
				wSeparator[0] = 0
			End If
			
			If lstrcmpiW(@strFileLastModifiedHttpDate, pHeaderIfUnModifiedSince) = 0 Then
				IsFileModified = True
			End If
		End If
	End Scope
	
	Scope
		Dim ResponseZipEnable As Boolean = Any
		IServerResponse_GetZipEnabled(pIResponse, @ResponseZipEnable)
		
		Dim ResponseZipMode As ZipModes = Any
		IServerResponse_GetZipMode(pIResponse, @ResponseZipMode)
		
		Dim strETag As WString * 256 = Any
		GetETag(@strETag, @DateLastFileModified, ResponseZipEnable, ResponseZipMode)
		
		IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderEtag, @strETag)
		
		If IsFileModified Then
			Dim pHeaderIfNoneMatch As WString Ptr = Any
			IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderIfNoneMatch, @pHeaderIfNoneMatch)
			
			If lstrlenW(pHeaderIfNoneMatch) <> 0 Then
				If lstrcmpiW(pHeaderIfNoneMatch, @strETag) = 0 Then
					IsFileModified = False
				End If
			End If
			
		End If
		
		If IsFileModified = False Then
			
			Dim pHeaderIfMatch As WString Ptr = Any
			IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderIfMatch, @pHeaderIfMatch)
			
			If lstrlenW(pHeaderIfMatch) <> 0 Then
				If lstrcmpiW(pHeaderIfMatch, @strETag) = 0 Then
					IsFileModified = True
				End If
			End If
			
		End If
		
	End Scope
	
	IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderCacheControl, @DefaultCacheControl)
	
	Dim SendOnlyHeaders As Boolean = Any
	IServerResponse_GetSendOnlyHeaders(pIResponse, @SendOnlyHeaders)
	
	SendOnlyHeaders = SendOnlyHeaders OrElse (Not IsFileModified)
	
	IServerResponse_SetSendOnlyHeaders(pIResponse, SendOnlyHeaders)
	
	If IsFileModified = False Then
		IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.NotModified)
	End If
	
End Sub

Function GetBase64Sha1( _
		ByVal pDestination As WString Ptr, _
		ByVal pSource As WString Ptr _
	)As Boolean
	
	Dim zBuffer As ZString * (127 + 1) = Any
	
	Dim dwBufferLength As DWORD = WideCharToMultiByte( _
		CP_UTF8, _
		0, _
		pSource, _
		-1, _
		@zBuffer, _
		127, _
		0, _
		0 _
	) - 1
	
	Dim hCryptProv As HCRYPTPROV = Any
	
	If CryptAcquireContext(@hCryptProv, NULL, NULL, PROV_RSA_FULL, 0) = 0 Then
		Return False
	End If
		
	Dim hHash As HCRYPTHASH = Any
	
	If CryptCreateHash(hCryptProv, CALG_SHA1, 0, 0, @hHash) = 0 Then
		CryptReleaseContext(hCryptProv, 0)
		Return False
	End If
	
	If CryptHashData(hHash, @zBuffer, dwBufferLength, 0) = 0 Then
		CryptDestroyHash(hHash)
		CryptReleaseContext(hCryptProv, 0)
		Return False
	End If
	
	Dim Sha1 As ZString * (127 + 1) = Any
	Dim Sha1Length As DWORD = 127
	
	If CryptGetHashParam(hHash, HP_HASHVAL, @Sha1, @Sha1Length, 0) = 0 Then
		CryptDestroyHash(hHash)
		CryptReleaseContext(hCryptProv, 0)
		Return False
	End If
	
	Dim Base64Length As DWORD = 127
	
	CryptBinaryToStringW( _
		@Sha1, _
		Sha1Length, _
		CRYPT_STRING_BASE64 Or CRYPT_STRING_NOCRLF, _
		pDestination, _
		@Base64Length _
	)
	
	pDestination[Base64Length] = 0
	
	CryptDestroyHash(hHash)
	CryptReleaseContext(hCryptProv, 0)
	
	Return True
	
End Function
