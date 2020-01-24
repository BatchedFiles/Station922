#include "WebUtils.bi"
#include "CharacterConstants.bi"
#include "CreateInstance.bi"
#include "HttpConst.bi"
#include "IConfiguration.bi"
#include "IniConst.bi"
#include "IntegerToWString.bi"
#include "IStringable.bi"
#include "PrintDebugInfo.bi"
#include "Resources.RH"
#include "StringConstants.bi"
#include "Station922Uri.bi"
#include "WriteHttpError.bi"
#include "win\shlwapi.bi"
#include "win\wincrypt.bi"

Const DateFormatString = "ddd, dd MMM yyyy "
Const TimeFormatString = "HH:mm:ss GMT"
Const DefaultCacheControl = "max-age=2678400"
Const BytesWithSpaceString = "bytes "
Const KeepAliveString = "Keep-Alive"

Extern CLSID_CONFIGURATION Alias "CLSID_CONFIGURATION" As Const CLSID

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

Function GetDocumentCharset( _
		ByVal bytes As ZString Ptr _
	)As DocumentCharsets
	
	If bytes[0] = 239 AndAlso bytes[1] = 187 AndAlso bytes[2] = 191 Then
		Return DocumentCharsets.Utf8BOM
	End If
	
	If bytes[0] = 255 AndAlso bytes[1] = 254 Then
		Return DocumentCharsets.Utf16LE
	End If
	
	If bytes[0] = 254 AndAlso bytes[1] = 255 Then
		Return DocumentCharsets.Utf16BE
	End If
	
	Return DocumentCharsets.ASCII
	
End Function

Sub GetHttpDate( _
		ByVal Buffer As WString Ptr, _
		ByVal dt As SYSTEMTIME Ptr _
	)
	
	' Tue, 15 Nov 1994 12:45:26 GMT
	Dim dtBufferLength As Integer = GetDateFormat(LOCALE_INVARIANT, 0, dt, @DateFormatString, Buffer, 31) - 1
	GetTimeFormat(LOCALE_INVARIANT, 0, dt, @TimeFormatString, @Buffer[dtBufferLength], 31 - dtBufferLength)
	
End Sub

Sub GetHttpDate(ByVal Buffer As WString Ptr)
	
	Dim dt As SYSTEMTIME = Any
	GetSystemTime(@dt)
	GetHttpDate(Buffer, @dt)
	
End Sub

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
		
		If lstrlen(pHeaderAuthorization) = 0 Then
			IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderAuthorization, @pHeaderAuthorization)
		End If
	Else
		IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderAuthorization, @pHeaderAuthorization)
	End If
	
	If lstrlen(pHeaderAuthorization) = 0 Then
		WriteHttpNeedAuthenticate(pIRequest, pIResponse, pStream, pIWebSite)
		Return False
	End If
	
	Dim pSpace As WString Ptr = StrChr(pHeaderAuthorization, Characters.WhiteSpace)
	If pSpace = 0 Then
		WriteHttpBadAuthenticateParam(pIRequest, pIResponse, pStream, pIWebSite)
		Return False
	End If
	
	pSpace[0] = 0
	
	If lstrcmp(pHeaderAuthorization, @BasicAuthorization) <> 0 Then
		WriteHttpNeedBasicAuthenticate(pIRequest, pIResponse, pStream, pIWebSite)
		Return False
	End If
	
	Dim UsernamePasswordUtf8 As ZString * (MaxRequestBufferLength + 1) = Any
	Dim dwUsernamePasswordUtf8Length As DWORD = Cast(DWORD, MaxRequestBufferLength)
	
	CryptStringToBinary(@pSpace[1], 0, CRYPT_STRING_BASE64, @UsernamePasswordUtf8, @dwUsernamePasswordUtf8Length, 0, 0)
	
	UsernamePasswordUtf8[dwUsernamePasswordUtf8Length] = 0
	
	' Из массива байт в строку
	' Преобразуем utf8 в WString
	' -1 — значит, длина строки будет проверяться самой функцией по завершающему нулю
	Dim UsernamePasswordKey As WString * (MaxRequestBufferLength + 1) = Any
	MultiByteToWideChar(CP_UTF8, 0, @UsernamePasswordUtf8, -1, @UsernamePasswordKey, MaxRequestBufferLength)
	
	' Теперь pSpace хранит в себе указатель на разделитель‐двоеточие
	pSpace = StrChr(@UsernamePasswordKey, Characters.Colon)
	If pSpace = 0 Then
		WriteHttpEmptyPassword(pIRequest, pIResponse, pStream, pIWebSite)
		Return False
	End If
	
	pSpace[0] = 0 ' Убрали двоеточие
	
	Dim SettingsFileName As WString * (MAX_PATH + 1) = Any
	
	IWebSite_MapPath(pIWebSite, @UsersIniFileString, @SettingsFileName)
	
	Dim pIConfig As IConfiguration Ptr = Any
	Dim hr As HRESULT = CreateInstance(GetProcessHeap(), @CLSID_CONFIGURATION, @IID_IConfiguration, @pIConfig)
	
	If FAILED(hr) Then
		Return False
	End If
	
	IConfiguration_SetIniFilename(pIConfig, @SettingsFileName)
	
	Dim PasswordBuffer As WString * (255 + 1) = Any
	
	Dim ValueLength As Integer = Any
	
	IConfiguration_GetStringValue(pIConfig, _
		@AdministratorsSectionString, _
		@UsernamePasswordKey, _
		@EmptyString, _
		255, _
		@PasswordBuffer, _
		@ValueLength _
	)
	
	IConfiguration_Release(pIConfig)
	
	If lstrlen(@PasswordBuffer) = 0 Then
		WriteHttpBadUserNamePassword(pIRequest, pIResponse, pStream, pIWebSite)
		Return False
	End If
	
	If lstrcmp(@PasswordBuffer, pSpace + 1) <> 0 Then
		WriteHttpBadUserNamePassword(pIRequest, pIResponse, pStream, pIWebSite)
		Return False
	End If
	
	Return True
End Function

Sub GetETag( _
		ByVal wETag As WString Ptr, _
		ByVal pDateLastFileModified As FILETIME Ptr, _
		ByVal ZipEnable As Boolean, _
		ByVal ResponseZipMode As ZipModes _
	)
	
	lstrcpy(wETag, @QuoteString)
	
	Dim ul As ULARGE_INTEGER = Any
	With ul
		.LowPart = pDateLastFileModified->dwLowDateTime
		.HighPart = pDateLastFileModified->dwHighDateTime
	End With
	
	ui64tow(ul.QuadPart, wETag[1], 10)
	
	If ZipEnable Then
		Select Case ResponseZipMode
			
			Case ZipModes.GZip
				lstrcat(wETag, @GzipString)
				
			Case ZipModes.Deflate
				lstrcat(wETag, @DeflateString)
				
		End Select
	End If
	
	lstrcat(wETag, @QuoteString)
	
End Sub

Sub MakeContentRangeHeader( _
		ByVal pIWriter As ITextWriter Ptr, _
		ByVal FirstBytePosition As ULongInt, _
		ByVal LastBytePosition As ULongInt, _
		ByVal TotalLength As ULongInt _
	)
	
	'Content-Range: bytes 88080384-160993791/160993792
	
	ITextWriter_WriteLengthString(pIWriter, @BytesStringWithSpace, BytesStringWithSpaceLength)
	
	ITextWriter_WriteUInt64(pIWriter, FirstBytePosition)
	ITextWriter_WriteChar(pIWriter, Characters.HyphenMinus)
	
	ITextWriter_WriteUInt64(pIWriter, LastBytePosition)
	ITextWriter_WriteChar(pIWriter, Characters.Solidus)
	
	ITextWriter_WriteUInt64(pIWriter, TotalLength)
	
End Sub

Function Minimum( _
		ByVal a As ULongInt, _
		ByVal b As ULongInt _
	)As ULongInt
	
	If a < b Then
		Return a
	End If
	
	Return b
	
End Function

Function AllResponseHeadersToBytes( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal zBuffer As ZString Ptr, _
		ByVal ContentLength As ULongInt _
	)As Integer
	
	' TODO Найти способ откатывать изменения буфера заголовков ответа
	
	IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderServer, @VER_HTTPSERVERVERSION_STR)
	
	Dim StatusCode As HttpStatusCodes = Any
	IServerResponse_GetStatusCode(pIResponse, @StatusCode)
	
	If StatusCode <> HttpStatusCodes.PartialContent Then
		IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderAcceptRanges, @BytesString)
	End If
	
	Dim KeepAlive As Boolean = Any
	If pIRequest = NULL Then
		KeepAlive = False
	Else
		IClientRequest_GetKeepAlive(pIRequest, @KeepAlive)
	End If
	
	If KeepAlive Then
		Dim HttpVersion As HttpVersions = Any
		If pIRequest = NULL Then
			HttpVersion = HttpVersions.Http10
		Else
			IClientRequest_GetHttpVersion(pIRequest, @HttpVersion)
		End If
		
		If HttpVersion = HttpVersions.Http10 Then
			IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderConnection, @KeepAliveString)
		End If
	Else
		IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderConnection, @CloseString)
	End If
	
	Select Case StatusCode
		
		Case HttpStatusCodes.CodeContinue, HttpStatusCodes.SwitchingProtocols, HttpStatusCodes.Processing, HttpStatusCodes.NoContent
			IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderContentLength, NULL)
			
		Case Else
			Dim strContentLength As WString * (64) = Any
			ui64tow(ContentLength, @strContentLength, 10)
			IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderContentLength, @strContentLength)
			
	End Select
	
	Dim wContentType As WString * (MaxContentTypeLength + 1) = Any
	
	Dim Mime As MimeType = Any
	IServerResponse_GetMimeType(pIResponse, @Mime)
	
	GetContentTypeOfMimeType(@wContentType, @Mime)
	IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderContentType, @wContentType)
	
	Dim datNowF As FILETIME = Any
	GetSystemTimeAsFileTime(@datNowF)
	
	Dim datNowS As SYSTEMTIME = Any
	FileTimeToSystemTime(@datNowF, @datNowS)
	
	Dim dtBuffer As WString * (32) = Any
	GetHttpDate(@dtBuffer, @datNowS)
	
	IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderDate, @dtBuffer)
	
	Dim pIStringable As IStringable Ptr = Any
	IServerResponse_QueryInterface(pIResponse, @IID_IStringable, @pIStringable)
	
	Dim wHeadersBuffer As WString Ptr = Any
	IStringable_ToString(pIStringable, @wHeadersBuffer)
	
#ifndef WINDOWS_SERVICE
		
		PrintResponseString(wHeadersBuffer, StatusCode)
		
#endif
	
	Dim HeadersLength As Integer = WideCharToMultiByte( _
		CP_UTF8, _
		0, _
		wHeadersBuffer, _
		-1, _
		zBuffer, _
		MaxResponseBufferLength + 1, _
		0, _
		0 _
	) - 1
	
	IStringable_Release(pIStringable)
	
	' TODO Запись в лог
	Return HeadersLength
	
End Function

Function SetResponseCompression( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal PathTranslated As WString Ptr, _
		ByVal pAcceptEncoding As Boolean Ptr _
	)As Handle
	
	Const GzipExtensionString = ".gz"
	Const DeflateExtensionString = ".deflate"
	
	*pAcceptEncoding = False
	
	Scope
		Dim GZipFileName As WString * (MAX_PATH + 1) = Any
		lstrcpy(@GZipFileName, PathTranslated)
		lstrcat(@GZipFileName, @GZipExtensionString)
		
		Dim hFile As HANDLE = CreateFile( _
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
		lstrcpy(@DeflateFileName, PathTranslated)
		lstrcat(@DeflateFileName, @DeflateExtensionString)
		
		Dim hFile As HANDLE = CreateFile( _
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
		' TODO Уметь распознавать все три HTTP‐формата даты
		Dim dFileLastModified As SYSTEMTIME = Any
		FileTimeToSystemTime(@DateLastFileModified, @dFileLastModified)
		
		Dim strFileLastModifiedHttpDate As WString * 256 = Any
		GetHttpDate(@strFileLastModifiedHttpDate, @dFileLastModified)
		
		IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderLastModified, @strFileLastModifiedHttpDate)
		
		Dim pHeaderIfModifiedSince As WString Ptr = Any
		IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderIfModifiedSince, @pHeaderIfModifiedSince)
		
		If lstrlen(pHeaderIfModifiedSince) <> 0 Then
			
			Dim wSeparator As WString Ptr = StrChr(pHeaderIfModifiedSince, Characters.Semicolon)
			If wSeparator <> 0 Then
				wSeparator[0] = 0
			End If
			
			If lstrcmpi(@strFileLastModifiedHttpDate, pHeaderIfModifiedSince) = 0 Then
				IsFileModified = False
			End If
		End If
		
		Dim pHeaderIfUnModifiedSince As WString Ptr = Any
		IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderIfUnModifiedSince, @pHeaderIfUnModifiedSince)
		
		If lstrlen(pHeaderIfUnModifiedSince) <> 0 Then
			
			Dim wSeparator As WString Ptr = StrChr(pHeaderIfUnModifiedSince, Characters.Semicolon)
			If wSeparator <> 0 Then
				wSeparator[0] = 0
			End If
			
			If lstrcmpi(@strFileLastModifiedHttpDate, pHeaderIfUnModifiedSince) = 0 Then
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
			
			If lstrlen(pHeaderIfNoneMatch) <> 0 Then
				If lstrcmpi(pHeaderIfNoneMatch, @strETag) = 0 Then
					IsFileModified = False
				End If
			End If
			
		End If
		
		If IsFileModified = False Then
			
			Dim pHeaderIfMatch As WString Ptr = Any
			IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderIfMatch, @pHeaderIfMatch)
			
			If lstrlen(pHeaderIfMatch) <> 0 Then
				If lstrcmpi(pHeaderIfMatch, @strETag) = 0 Then
					IsFileModified = True
				End If
			End If
			
		End If
		
	End Scope
	
	IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderCacheControl, @DefaultCacheControl)
	
	Dim SendOnlyHeaders As Boolean = Any
	IServerResponse_GetSendOnlyHeaders(pIResponse, @SendOnlyHeaders)
	
	SendOnlyHeaders OrElse= Not IsFileModified
	
	IServerResponse_SetSendOnlyHeaders(pIResponse, SendOnlyHeaders)
	
	If IsFileModified = False Then
		IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.NotModified)
	End If
	
End Sub

Function ContainsBadCharSequence( _
		ByVal Buffer As WString Ptr, _
		ByVal Length As Integer _
	)As HRESULT
	
	' TODO Звёздочка в пути допустима при методе OPTIONS
	
	If Length = 0 Then
		Return E_FAIL
	End If
	
	If Buffer[Length - 1] = Characters.FullStop Then
		Return E_FAIL
	End If
	
	For i As Integer = 0 To Length - 1
		
		Dim c As wchar_t = Buffer[i]
		
		Select Case c
			
			Case Is < Characters.WhiteSpace
				Return E_FAIL
				
			Case Characters.QuotationMark
				' Кавычки нельзя
				Return E_FAIL
				
			'Case Characters.DollarSign
				' Нельзя доллар, потому что могут открыть $MFT
				'Return E_FAIL
				
			'Case Characters.PercentSign
				' TODO Уточнить, почему нельзя использовать знак процента
				'Return E_FAIL
				
			'Case Characters.Ampersand
				' Объединение команд в одну
				'Return E_FAIL
				
			Case Characters.Asterisk
				' Нельзя звёздочку
				Return E_FAIL
				
			Case Characters.FullStop
				' Разрешены .. потому что могут встретиться в имени файла
				' Запрещены /.. потому что могут привести к смене каталога
				Dim NextChar As wchar_t = Buffer[i + 1]
				
				If NextChar = Characters.FullStop Then
					
					If i > 0 Then
						Dim PrevChar As wchar_t = Buffer[i - 1]
						
						If PrevChar = Characters.Solidus Then
							Return E_FAIL
						End If
						
					End If
					
				End If
				
			'Case Characters.Semicolon
				' Разделитель путей
				'Return E_FAIL
				
			Case Characters.LessThanSign
				' Защита от перенаправлений ввода‐вывода
				Return E_FAIL
				
			Case Characters.GreaterThanSign
				' Защита от перенаправлений ввода‐вывода
				Return E_FAIL
				
			Case Characters.QuestionMark
				' Подстановочный знак
				Return E_FAIL
				
			Case Characters.VerticalLine
				' Символ конвейера
				Return E_FAIL
				
		End Select
		
	Next
	
	Return S_OK
	
End Function

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
	
	CryptBinaryToString(@Sha1, Sha1Length, CRYPT_STRING_BASE64 Or CRYPT_STRING_NOCRLF, pDestination, @Base64Length)
	
	pDestination[Base64Length] = 0
	
	CryptDestroyHash(hHash)
	CryptReleaseContext(hCryptProv, 0)
	
	Return True
	
End Function
