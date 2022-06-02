#include once "WebUtils.bi"
#include once "win\shlwapi.bi"
#include once "win\wincrypt.bi"
#include once "IWebServerConfiguration.bi"
#include once "CharacterConstants.bi"
#include once "CreateInstance.bi"
#include once "HeapBSTR.bi"
#include once "Mime.bi"
#include once "StringConstants.bi"

Extern CLSID_WEBSERVERINICONFIGURATION Alias "CLSID_WEBSERVERINICONFIGURATION" As Const CLSID

Const DateFormatString = WStr("ddd, dd MMM yyyy ")
Const TimeFormatString = WStr("HH:mm:ss GMT")
Const DefaultCacheControl = WStr("max-age=2678400")
Const BasicAuthorization = WStr("Basic")

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

Sub AddResponseCacheHeaders( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pDateLastFileModified As FILETIME Ptr, _
		ByVal ETag As HeapBSTR _
	)
	
	Dim IsFileModified As Boolean = True
	
	Scope
		' TODO Уметь распознавать все три HTTP-формата даты
		Dim dFileLastModified As SYSTEMTIME = Any
		FileTimeToSystemTime(pDateLastFileModified, @dFileLastModified)
		
		Dim strFileLastModifiedHttpDate As WString * 256 = Any
		GetHttpDate(@strFileLastModifiedHttpDate, @dFileLastModified)
		
		IServerResponse_AddKnownResponseHeaderWstr( _
			pIResponse, _
			HttpResponseHeaders.HeaderLastModified, _
			@strFileLastModifiedHttpDate _
		)
		
		Dim pHeaderIfModifiedSince As HeapBSTR = Any
		IClientRequest_GetHttpHeader( _
			pIRequest, _
			HttpRequestHeaders.HeaderIfModifiedSince, _
			@pHeaderIfModifiedSince _
		)
		
		If SysStringLen(pHeaderIfModifiedSince) <> 0 Then
			
			Dim resCompare As Long = lstrcmpiW( _
				@strFileLastModifiedHttpDate, _
				pHeaderIfModifiedSince _
			)
			If resCompare = 0 Then
				IsFileModified = False
			End If
		End If
		
		HeapSysFreeString(pHeaderIfModifiedSince)
		
		Dim pHeaderIfUnModifiedSince As HeapBSTR = Any
		IClientRequest_GetHttpHeader( _
			pIRequest, _
			HttpRequestHeaders.HeaderIfUnModifiedSince, _
			@pHeaderIfUnModifiedSince _
		)
		
		If SysStringLen(pHeaderIfUnModifiedSince) <> 0 Then
			
			Dim resCompare As Long = lstrcmpiW( _
				@strFileLastModifiedHttpDate, _
				pHeaderIfUnModifiedSince _
			)
			If resCompare = 0 Then
				IsFileModified = True
			End If
		End If
		
		HeapSysFreeString(pHeaderIfUnModifiedSince)
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
			
			If SysStringLen(HeaderIfNoneMatch) Then
				If lstrcmpiW(HeaderIfNoneMatch, ETag) = 0 Then
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
			
			If SysStringLen(HeaderIfMatch) Then
				If lstrcmpiW(HeaderIfMatch, ETag) = 0 Then
					IsFileModified = True
				End If
			End If
			
			HeapSysFreeString(HeaderIfMatch)
		End If
		
	End Scope
	
	IServerResponse_AddKnownResponseHeaderWstrLen( _
		pIResponse, _
		HttpResponseHeaders.HeaderCacheControl, _
		@DefaultCacheControl, _
		Len(DefaultCacheControl) _
	)
	
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

Function FindWebSite( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT
	
	/'
	If HttpMethod = HttpMethods.HttpConnect Then
		IWebSiteCollection_Item( _
			pIWebSites, _
			NULL, _
			ppIWebSite _
		)
		Return S_OK
	End If
	'/
	
	Dim HeaderHost As HeapBSTR = Any
	IClientRequest_GetHttpHeader( _
		pIRequest, _
		HttpRequestHeaders.HeaderHost, _
		@HeaderHost _
	)
	
	Dim hrFindSite As HRESULT = IWebSiteCollection_Item( _
		pIWebSites, _
		HeaderHost, _
		ppIWebSite _
	)
	
	HeapSysFreeString(HeaderHost)
	
	Return hrFindSite
	
End Function

Function Integer64Division( _
		ByVal Dividend As LongInt, _
		ByVal Divisor As LongInt _
	)As LongInt
	
	Dim varLeft As VARIANT = Any
	varLeft.vt = VT_I8
	varLeft.llVal = Dividend
	
	Dim varRight As VARIANT = Any
	varRight.vt = VT_I8
	varRight.llVal = Divisor
	
	Dim varResult As VARIANT = Any
	VariantInit(@varResult)
	
	Dim hr As HRESULT = VarIdiv( _
		@varLeft, _
		@varRight, _
		@varResult _
	)
	If FAILED(hr) Then
		Return 0
	End If
	
	Return varResult.llVal
	
End Function
