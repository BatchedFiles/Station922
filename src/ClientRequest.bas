#include once "ClientRequest.bi"
#include once "win\shlwapi.bi"
#include once "CharacterConstants.bi"
#include once "ClientUri.bi"
#include once "HeapBSTR.bi"

Extern GlobalClientRequestVirtualTable As Const IClientRequestVirtualTable

Const GzipString = WStr("gzip")
Const DeflateString = WStr("deflate")
Const BytesString = WStr("bytes")
Const CloseString = WStr("Close")
Const KeepAliveString = WStr("Keep-Alive")
Const CompareResultEqual As Long = 0

Type RequestHeaderNode
	pHeader As WString Ptr
	HeaderLength As Integer
	HeaderIndex As HttpRequestHeaders
End Type

Type ClientRequest
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IClientRequestVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pClientURI As IClientUri Ptr
	pHttpMethod As HeapBSTR
	HttpVersion As HttpVersions
	ContentLength As LongInt
	RequestByteRange As ByteRange
	RequestHeaders(0 To HttpRequestHeadersSize - 1) As HeapBSTR
	RequestZipModes(0 To ZipModesSize - 1) As Boolean
	KeepAlive As Boolean
	Expect100Continue As Boolean
End Type

Dim Shared RequestHeaderNodesVector(1 To HttpRequestHeadersSize) As RequestHeaderNode = { _
	Type<RequestHeaderNode>(@HeaderCacheControlString,            Len(HeaderCacheControlString),            HttpRequestHeaders.HeaderCacheControl), _
	Type<RequestHeaderNode>(@HeaderConnectionString,              Len(HeaderConnectionString),              HttpRequestHeaders.HeaderConnection), _
	Type<RequestHeaderNode>(@HeaderPragmaString,                  Len(HeaderPragmaString),                  HttpRequestHeaders.HeaderPragma), _
	Type<RequestHeaderNode>(@HeaderTrailerString,                 Len(HeaderTrailerString),                 HttpRequestHeaders.HeaderTrailer), _
	Type<RequestHeaderNode>(@HeaderTransferEncodingString,        Len(HeaderTransferEncodingString),        HttpRequestHeaders.HeaderTransferEncoding), _
	Type<RequestHeaderNode>(@HeaderUpgradeString,                 Len(HeaderUpgradeString),                 HttpRequestHeaders.HeaderUpgrade), _
	Type<RequestHeaderNode>(@HeaderViaString,                     Len(HeaderViaString),                     HttpRequestHeaders.HeaderVia), _
	Type<RequestHeaderNode>(@HeaderWarningString,                 Len(HeaderWarningString),                 HttpRequestHeaders.HeaderWarning), _
	Type<RequestHeaderNode>(@HeaderAcceptString,                  Len(HeaderAcceptString),                  HttpRequestHeaders.HeaderAccept), _
	Type<RequestHeaderNode>(@HeaderAcceptCharsetString,           Len(HeaderAcceptCharsetString),           HttpRequestHeaders.HeaderAcceptCharset), _
	Type<RequestHeaderNode>(@HeaderAcceptEncodingString,          Len(HeaderAcceptEncodingString),          HttpRequestHeaders.HeaderAcceptEncoding), _
	Type<RequestHeaderNode>(@HeaderAcceptLanguageString,          Len(HeaderAcceptLanguageString),          HttpRequestHeaders.HeaderAcceptLanguage), _
	Type<RequestHeaderNode>(@HeaderAuthorizationString,           Len(HeaderAuthorizationString),           HttpRequestHeaders.HeaderAuthorization), _
	Type<RequestHeaderNode>(@HeaderCookieString,                  Len(HeaderCookieString),                  HttpRequestHeaders.HeaderCookie), _
	Type<RequestHeaderNode>(@HeaderExpectString,                  Len(HeaderExpectString),                  HttpRequestHeaders.HeaderExpect), _
	Type<RequestHeaderNode>(@HeaderDNTString,                     Len(HeaderDNTString),                     HttpRequestHeaders.HeaderDNT), _
	Type<RequestHeaderNode>(@HeaderFromString,                    Len(HeaderFromString),                    HttpRequestHeaders.HeaderFrom), _
	Type<RequestHeaderNode>(@HeaderHostString,                    Len(HeaderHostString),                    HttpRequestHeaders.HeaderHost), _
	Type<RequestHeaderNode>(@HeaderIfMatchString,                 Len(HeaderIfMatchString),                 HttpRequestHeaders.HeaderIfMatch), _
	Type<RequestHeaderNode>(@HeaderIfModifiedSinceString,         Len(HeaderIfModifiedSinceString),         HttpRequestHeaders.HeaderIfModifiedSince), _
	Type<RequestHeaderNode>(@HeaderIfNoneMatchString,             Len(HeaderIfNoneMatchString),             HttpRequestHeaders.HeaderIfNoneMatch), _
	Type<RequestHeaderNode>(@HeaderIfRangeString,                 Len(HeaderIfRangeString),                 HttpRequestHeaders.HeaderIfRange), _
	Type<RequestHeaderNode>(@HeaderIfUnmodifiedSinceString,       Len(HeaderIfUnmodifiedSinceString),       HttpRequestHeaders.HeaderIfUnModifiedSince), _
	Type<RequestHeaderNode>(@HeaderMaxForwardsString,             Len(HeaderMaxForwardsString),             HttpRequestHeaders.HeaderMaxForwards), _
	Type<RequestHeaderNode>(@HeaderProxyAuthorizationString,      Len(HeaderProxyAuthorizationString),      HttpRequestHeaders.HeaderProxyAuthorization), _
	Type<RequestHeaderNode>(@HeaderRangeString,                   Len(HeaderRangeString),                   HttpRequestHeaders.HeaderRange), _
	Type<RequestHeaderNode>(@HeaderRefererString,                 Len(HeaderRefererString),                 HttpRequestHeaders.HeaderReferer), _
	Type<RequestHeaderNode>(@HeaderTeString,                      Len(HeaderTeString),                      HttpRequestHeaders.HeaderTe), _
	Type<RequestHeaderNode>(@HeaderUserAgentString,               Len(HeaderUserAgentString),               HttpRequestHeaders.HeaderUserAgent), _
	Type<RequestHeaderNode>(@HeaderKeepAliveString,               Len(HeaderKeepAliveString),               HttpRequestHeaders.HeaderKeepAlive), _
	Type<RequestHeaderNode>(@HeaderOriginString,                  Len(HeaderOriginString),                  HttpRequestHeaders.HeaderOrigin), _
	Type<RequestHeaderNode>(@HeaderPurposeString,                 Len(HeaderPurposeString),                 HttpRequestHeaders.HeaderPurpose), _
	Type<RequestHeaderNode>(@HeaderSecWebSocketKeyString,         Len(HeaderSecWebSocketKeyString),         HttpRequestHeaders.HeaderSecWebSocketKey), _
	Type<RequestHeaderNode>(@HeaderSecWebSocketKey1String,        Len(HeaderSecWebSocketKey1String),        HttpRequestHeaders.HeaderSecWebSocketKey1), _
	Type<RequestHeaderNode>(@HeaderSecWebSocketKey2String,        Len(HeaderSecWebSocketKey2String),        HttpRequestHeaders.HeaderSecWebSocketKey2), _
	Type<RequestHeaderNode>(@HeaderSecWebSocketVersionString,     Len(HeaderSecWebSocketVersionString),     HttpRequestHeaders.HeaderSecWebSocketVersion), _
	Type<RequestHeaderNode>(@HeaderUpgradeInsecureRequestsString, Len(HeaderUpgradeInsecureRequestsString), HttpRequestHeaders.HeaderUpgradeInsecureRequests), _
	Type<RequestHeaderNode>(@HeaderWebSocketProtocolString,       Len(HeaderWebSocketProtocolString),       HttpRequestHeaders.HeaderWebSocketProtocol), _
	Type<RequestHeaderNode>(@HeaderContentEncodingString,         Len(HeaderContentEncodingString),         HttpRequestHeaders.HeaderContentEncoding), _
	Type<RequestHeaderNode>(@HeaderContentLanguageString,         Len(HeaderContentLanguageString),         HttpRequestHeaders.HeaderContentLanguage), _
	Type<RequestHeaderNode>(@HeaderContentLengthString,           Len(HeaderContentLengthString),           HttpRequestHeaders.HeaderContentLength), _
	Type<RequestHeaderNode>(@HeaderContentMd5String,              Len(HeaderContentMd5String),              HttpRequestHeaders.HeaderContentMd5), _
	Type<RequestHeaderNode>(@HeaderContentRangeString,            Len(HeaderContentRangeString),            HttpRequestHeaders.HeaderContentRange), _
	Type<RequestHeaderNode>(@HeaderContentTypeString,             Len(HeaderContentTypeString),             HttpRequestHeaders.HeaderContentType) _
}

Private Function FindNotSpaceCharacter( _
		ByVal pwStr As WString Ptr _
	)As WString Ptr

	Dim Character As Integer = pwStr[0]

	If Character = Characters.WhiteSpace Then
		Dim pNext As WString Ptr = @pwStr[1]
		Return FindNotSpaceCharacter(pNext)
	End If

	Return pwStr

End Function

Private Function GetHttpVersionIndex( _
		ByVal s As WString Ptr, _
		ByVal pVersion As HttpVersions Ptr _
	)As Boolean

	If lstrlenW(s) = 0 Then
		*pVersion = HttpVersions.Http09
		Return True
	End If

	Scope
		Dim CompareResult As Long = lstrcmpW(s, @HttpVersion11String)
		If CompareResult = CompareResultEqual Then
			*pVersion = HttpVersions.Http11
			Return True
		End If
	End Scope

	Scope
		Dim CompareResult As Long = lstrcmpW(s, @HttpVersion10String)
		If CompareResult = CompareResultEqual Then
			*pVersion = HttpVersions.Http10
			Return True
		End If
	End Scope

	Return False

End Function

Private Function GetKnownRequestHeaderIndex( _
		ByVal pHeader As WString Ptr, _
		ByVal pIndex As HttpRequestHeaders Ptr _
	)As Boolean

	For i As Integer = 1 To HttpRequestHeadersSize
		Dim CompareResult As Long = lstrcmpiW( _
			RequestHeaderNodesVector(i).pHeader, _
			pHeader _
		)
		If CompareResult = CompareResultEqual Then
			*pIndex = RequestHeaderNodesVector(i).HeaderIndex
			Return True
		End If
	Next

	*pIndex = 0
	Return False

End Function

Private Function ClientRequestParseRequestedLine( _
		ByVal self As ClientRequest Ptr, _
		ByVal RequestedLine As HeapBSTR _
	)As HRESULT

	' Метод, запрошенный ресурс и версия протокола

	If SysStringLen(RequestedLine) = 0 Then
		Return CLIENTREQUEST_E_BADREQUEST
	End If

	Dim pFirstChar As WString Ptr = RequestedLine

	Dim FirstChar As Integer = pFirstChar[0]
	If FirstChar = Characters.WhiteSpace Then
		Return CLIENTREQUEST_E_BADREQUEST
	End If

	' Первый пробел
	Dim pSpace As WString Ptr = StrChrW( _
		pFirstChar, _
		Characters.WhiteSpace _
	)
	If pSpace = NULL Then
		Return CLIENTREQUEST_E_BADREQUEST
	End If

	' Verb
	Scope
		Dim pVerb As WString Ptr = pFirstChar

		Dim VerbLength As Integer = pSpace - pVerb
		self->pHttpMethod = CreateHeapStringLen( _
			self->pIMemoryAllocator, _
			pVerb, _
			VerbLength _
		)
		If self->pHttpMethod = NULL Then
			Return E_OUTOFMEMORY
		End If
	End Scope

	' Uri
	Scope
		Dim hrCreateUri As HRESULT = CreateClientUri( _
			self->pIMemoryAllocator, _
			@IID_IClientUri, _
			@self->pClientURI _
		)
		If FAILED(hrCreateUri) Then
			Return hrCreateUri
		End If

		' Найти начало непробела
		pSpace = FindNotSpaceCharacter(@pSpace[1])

		' Здесь начинается Url
		Dim pUri As WString Ptr = pSpace

		' Второй пробел
		pSpace = StrChrW( _
			pSpace, _
			Characters.WhiteSpace _
		)

		Dim bstrUri As HeapBSTR = Any
		If pSpace = NULL Then
			bstrUri = CreateHeapString( _
				self->pIMemoryAllocator, _
				pUri _
			)
		Else
			Dim UriLength As Integer = pSpace - pUri
			bstrUri = CreateHeapStringLen( _
				self->pIMemoryAllocator, _
				pUri, _
				UriLength _
			)
		End If

		If bstrUri = NULL Then
			Return E_OUTOFMEMORY
		End If

		Dim hrUriFromString As HRESULT = IClientUri_UriFromString( _
			self->pClientURI, _
			bstrUri _
		)

		HeapSysFreeString(bstrUri)

		If FAILED(hrUriFromString) Then
			Return hrUriFromString
		End If

	End Scope

	' Version
	Scope
		If pSpace = NULL Then
			self->HttpVersion = HttpVersions.Http09
		Else
			' Найти начало непробела
			pSpace = FindNotSpaceCharacter(@pSpace[1])

			Dim pVersion As WString Ptr = pSpace

			' Третий пробел
			pSpace = StrChrW( _
				pSpace, _
				Characters.WhiteSpace _
			)
			If pSpace Then
				' Слишком много пробелов
				Return CLIENTREQUEST_E_BADREQUEST
			End If

			Dim bstrVersion As HeapBSTR = CreateHeapString( _
				self->pIMemoryAllocator, _
				pVersion _
			)
			If bstrVersion = NULL Then
				Return E_OUTOFMEMORY
			End If

			Dim GetHttpVersionResult As Boolean = GetHttpVersionIndex( _
				bstrVersion, _
				@self->HttpVersion _
			)
			HeapSysFreeString(bstrVersion)

			If GetHttpVersionResult = False Then
				Return CLIENTREQUEST_E_HTTPVERSIONNOTSUPPORTED
			End If

			If self->HttpVersion = HttpVersions.Http11 Then
				' Для версии 1.1 это по умолчанию
				self->KeepAlive = True
			End If

		End If
	End Scope

	Return S_OK

End Function

Private Function ClientRequestAddHeader( _
		ByVal self As ClientRequest Ptr, _
		ByVal Header As WString Ptr, _
		ByVal Value As HeapBSTR _
	)As Boolean

	Dim HeaderIndex As HttpRequestHeaders = Any
	Dim Finded As Boolean = GetKnownRequestHeaderIndex( _
		Header, _
		@HeaderIndex _
	)
	If Finded = False Then
		' TODO Add item to collection of unrecognized request headers
		Return False
	End If

	LET_HEAPSYSSTRING(self->RequestHeaders(HeaderIndex), Value)

	Return True

End Function

Private Function ClientRequestAddRequestHeaders( _
		ByVal self As ClientRequest Ptr, _
		ByVal pIReader As IHttpAsyncReader Ptr _
	)As HRESULT

	Do
		Dim pLine As HeapBSTR = Any
		Dim hrReadLine As HRESULT = IHttpAsyncReader_ReadLine( _
			pIReader, _
			@pLine _
		)
		If FAILED(hrReadLine) Then
			Return hrReadLine
		End If

		Dim LineLength As Integer = SysStringLen(pLine)
		If LineLength = 0 Then
			HeapSysFreeString(pLine)
			Return S_OK
		End If

		Dim pColon As WString Ptr = StrChrW(pLine, Characters.Colon)

		If pColon Then
			pColon[0] = 0

			Dim pwszValue As WString Ptr = FindNotSpaceCharacter(@pColon[1])

			Dim pNullChar As WString Ptr = @pLine[LineLength]
			Dim ValueLength As Integer = pNullChar - pwszValue
			Dim Value As HeapBSTR = CreateHeapStringLen( _
				self->pIMemoryAllocator, _
				pwszValue, _
				ValueLength _
			)
			If Value = NULL Then
				HeapSysFreeString(pLine)
				Return E_OUTOFMEMORY
			End If

			ClientRequestAddHeader(self, pLine, Value)

			HeapSysFreeString(Value)

		End If

		HeapSysFreeString(pLine)
	Loop

End Function

Private Sub ReplaceUtcToGmt( _
		ByVal pSource As WString Ptr, _
		ByVal SourceLength As Integer _
	)

	Const UTC = WStr("UTC")
	Const GMT = WStr("GMT")

	Dim UtcLength As Integer = Len(UTC)
	Dim GmtLength As Integer = Len(GMT)

	Dim pUTC As WString Ptr = FindStringW( _
		pSource, _
		SourceLength, _
		@UTC, _
		UtcLength _
	)

	Dim GmtBytes As Integer = GmtLength * SizeOf(WString)
	If pUTC Then
		CopyMemory( _
			pUTC, _
			@GMT, _
			GmtBytes _
		)
	End If

End Sub

Private Sub ParseConnectionHeaderSink( _
		ByVal self As ClientRequest Ptr _
	)

	Dim pSource As WString Ptr = self->RequestHeaders(HttpRequestHeaders.HeaderConnection)
	If pSource Then
		Dim SourceLength As Integer = SysStringLen(self->RequestHeaders(HttpRequestHeaders.HeaderConnection))
		Dim pCloseString As WString Ptr = FindStringIW( _
			pSource, _
			SourceLength, _
			@CloseString, _
			Len(CloseString) _
		)
		If pCloseString Then
			self->KeepAlive = False
		Else
			Dim pKeepAliveString As WString Ptr = FindStringIW( _
				pSource, _
				SourceLength, _
				@KeepAliveString, _
				Len(KeepAliveString) _
			)
			If pKeepAliveString Then
				self->KeepAlive = True
			End If
		End If
	End If

	HeapSysFreeString(self->RequestHeaders(HttpRequestHeaders.HeaderConnection))
	self->RequestHeaders(HttpRequestHeaders.HeaderConnection) = NULL

End Sub

Private Sub ParseAcceptEncodingHeaderSink( _
		ByVal self As ClientRequest Ptr _
	)

	Dim pSource As WString Ptr = self->RequestHeaders(HttpRequestHeaders.HeaderAcceptEncoding)
	If pSource Then
		Dim SourceLength As Integer = SysStringLen(self->RequestHeaders(HttpRequestHeaders.HeaderAcceptEncoding))
		Dim pGzipString As PCWSTR = FindStringIW( _
			pSource, _
			SourceLength, _
			@GzipString, _
			Len(GzipString) _
		)
		If pGzipString Then
			self->RequestZipModes(ZipModes.GZip) = True
		End If

		Dim pDeflateString As PCWSTR = FindStringIW( _
			pSource, _
			SourceLength, _
			@DeflateString, _
			Len(DeflateString) _
		)
		If pDeflateString Then
			self->RequestZipModes(ZipModes.Deflate) = True
		End If
	End If

	HeapSysFreeString(self->RequestHeaders(HttpRequestHeaders.HeaderAcceptEncoding))
	self->RequestHeaders(HttpRequestHeaders.HeaderAcceptEncoding) = NULL

End Sub

Private Sub ParseIfModifiedSinceHeaderSink( _
		ByVal self As ClientRequest Ptr _
	)

	Scope
		Dim pSource As WString Ptr = self->RequestHeaders(HttpRequestHeaders.HeaderIfModifiedSince)
		If pSource Then
			Dim SourceLength As Integer = SysStringLen(self->RequestHeaders(HttpRequestHeaders.HeaderIfModifiedSince))
			ReplaceUtcToGmt(pSource, SourceLength)
		End If
	End Scope

	Scope
		Dim pSource As WString Ptr = self->RequestHeaders(HttpRequestHeaders.HeaderIfUnModifiedSince)
		If pSource Then
			Dim SourceLength As Integer = SysStringLen(self->RequestHeaders(HttpRequestHeaders.HeaderIfUnModifiedSince))
			ReplaceUtcToGmt(pSource, SourceLength)
		End If
	End Scope

	/'
	Dim wSeparator As WString Ptr = StrChrW( _
		pHeaderIfUnModifiedSince, _
		Characters.Semicolon _
	)
	If wSeparator Then
		wSeparator[0] = 0
	End If
	'/

End Sub

Private Sub ParseRangeHeaderSink( _
		ByVal self As ClientRequest Ptr _
	)

	Const BytesEqualString = WStr("bytes=")

	Dim pwszHeaderRange As WString Ptr = self->RequestHeaders(HttpRequestHeaders.HeaderRange)
	If pwszHeaderRange Then
		Dim HeaderRangeLength As Integer = SysStringLen( _
			self->RequestHeaders(HttpRequestHeaders.HeaderRange) _
		)

		' TODO Обрабатывать несколько байтовых диапазонов
		/'
		Dim pCommaChar As WString Ptr = StrChrW(pwszHeaderRange, Characters.Comma)
		If pCommaChar Then
			pCommaChar[0] = 0
		End If
		'/

		Dim pwszBytesString As WString Ptr = FindStringW( _
			pwszHeaderRange, _
			HeaderRangeLength, _
			@BytesEqualString, _
			Len(BytesEqualString) _
		)
		If pwszBytesString = pwszHeaderRange Then
			Dim wStartIntegerData As WString Ptr = @pwszHeaderRange[Len(BytesEqualString)]

			Dim wStartIndex As WString Ptr = wStartIntegerData

			Dim wHyphenMinusChar As WString Ptr = StrChrW( _
				wStartIndex, _
				Characters.HyphenMinus _
			)
			If wHyphenMinusChar Then
				wHyphenMinusChar[0] = 0

				Dim wEndIndex As WString Ptr = @wHyphenMinusChar[1]

				Dim FirstConverted As BOOL = StrToInt64ExW( _
					wStartIndex, _
					STIF_DEFAULT, _
					@self->RequestByteRange.FirstBytePosition _
				)
				If FirstConverted Then
					self->RequestByteRange.IsSet = ByteRangeIsSet.FirstBytePositionIsSet
				End If

				Dim LastConverted As BOOL = StrToInt64ExW( _
					wEndIndex, _
					STIF_DEFAULT, _
					@self->RequestByteRange.LastBytePosition _
				)
				If LastConverted Then
					If self->RequestByteRange.IsSet = ByteRangeIsSet.FirstBytePositionIsSet Then
						self->RequestByteRange.IsSet = ByteRangeIsSet.FirstAndLastPositionIsSet
					Else
						self->RequestByteRange.IsSet = ByteRangeIsSet.LastBytePositionIsSet
					End If
				End If

			End If

		End If

	End If

	HeapSysFreeString(self->RequestHeaders(HttpRequestHeaders.HeaderRange))
	self->RequestHeaders(HttpRequestHeaders.HeaderRange) = NULL

End Sub

Private Sub ParseContentLengthHeaderSink( _
		ByVal self As ClientRequest Ptr _
	)

	Dim pHeaderContentLength As WString Ptr = self->RequestHeaders(HttpRequestHeaders.HeaderContentLength)
	If pHeaderContentLength Then
		StrToInt64ExW( _
			self->RequestHeaders(HttpRequestHeaders.HeaderContentLength), _
			STIF_DEFAULT, _
			@self->ContentLength _
		)
	End If

	HeapSysFreeString(self->RequestHeaders(HttpRequestHeaders.HeaderContentLength))
	self->RequestHeaders(HttpRequestHeaders.HeaderContentLength) = NULL

End Sub

Private Sub ParseExpectHeaderSink( _
		ByVal self As ClientRequest Ptr _
	)

	Dim pHeaderExpect As WString Ptr = self->RequestHeaders(HttpRequestHeaders.HeaderExpect)
	If pHeaderExpect Then
		Const Expect100 = WStr("100-continue")
		Dim resCompare As Long = lstrcmpiW( _
			pHeaderExpect, _
			@Expect100 _
		)
		If resCompare = CompareResultEqual Then
			self->Expect100Continue = True
		Else
			self->Expect100Continue = False
		End If
	End If

	HeapSysFreeString(self->RequestHeaders(HttpRequestHeaders.HeaderExpect))
	self->RequestHeaders(HttpRequestHeaders.HeaderExpect) = NULL

End Sub

Private Function ParseHostHeaderSink( _
		ByVal self As ClientRequest Ptr _
	)As HRESULT

	/'
	' TODO Найти правильный заголовок Host в зависимости от версии 1.0 или 1.1
	Dim HeaderHost As HeapBSTR = Any
	If HttpMethod = HttpMethods.HttpConnect Then
		' HeaderHost = ClientURI.Authority.Host
		IClientUri_GetHost(ClientURI, HeaderHost)
	Else
		IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderHost, @HeaderHost)
	End If
	'/

	Dim HeaderHostLength As Integer = SysStringLen( _
		self->RequestHeaders(HttpRequestHeaders.HeaderHost) _
	)
	If HeaderHostLength = 0 Then
		If self->HttpVersion = HttpVersions.Http11 Then
			Return CLIENTREQUEST_E_BADHOST
		Else
			Dim pHost As HeapBSTR = Any
			IClientUri_GetHost(self->pClientURI, @pHost)
			Dim ClientUriHostLength As Integer = SysStringLen( _
				pHost _
			)
			If ClientUriHostLength = 0 Then
				Return CLIENTREQUEST_E_BADHOST
			End If

			LET_HEAPSYSSTRING( _
				self->RequestHeaders(HttpRequestHeaders.HeaderHost), _
				pHost _
			)
		End If
	End If

	Return S_OK

End Function

Private Function ClientRequestParseRequestHeaders( _
		ByVal self As ClientRequest Ptr _
	)As HRESULT

	ParseConnectionHeaderSink(self)

	ParseAcceptEncodingHeaderSink(self)

	ParseIfModifiedSinceHeaderSink(self)

	ParseRangeHeaderSink(self)

	ParseContentLengthHeaderSink(self)

	ParseExpectHeaderSink(self)

	Dim hrParseHost As HRESULT = ParseHostHeaderSink(self)
	If FAILED(hrParseHost) Then
		Return hrParseHost
	End If

	Return S_OK

End Function

Private Sub InitializeClientRequest( _
		ByVal self As ClientRequest Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@self->RttiClassName(0), _
			@Str(RTTI_ID_CLIENTREQUEST), _
			UBound(self->RttiClassName) - LBound(self->RttiClassName) + 1 _
		)
	#endif
	self->lpVtbl = @GlobalClientRequestVirtualTable
	self->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	self->pIMemoryAllocator = pIMemoryAllocator
	self->pClientURI = NULL

	self->pHttpMethod = NULL
	self->HttpVersion = HttpVersions.Http11
	self->ContentLength = 0

	self->RequestByteRange.FirstBytePosition = 0
	self->RequestByteRange.LastBytePosition = 0
	self->RequestByteRange.IsSet = ByteRangeIsSet.NotSet

	ZeroMemory(@self->RequestHeaders(0), HttpRequestHeadersSize * SizeOf(HeapBSTR))
	ZeroMemory(@self->RequestZipModes(0), ZipModesSize * SizeOf(Boolean))
	self->KeepAlive = False

End Sub

Private Sub UnInitializeClientRequest( _
		ByVal self As ClientRequest Ptr _
	)

	If self->pClientURI Then
		IClientUri_Release(self->pClientURI)
	End If

	HeapSysFreeString(self->pHttpMethod)

	For i As Integer = 0 To HttpRequestHeadersSize - 1
		HeapSysFreeString(self->RequestHeaders(i))
	Next

End Sub

Private Sub DestroyClientRequest( _
		ByVal self As ClientRequest Ptr _
	)

	Dim pIMemoryAllocator As IMalloc Ptr = self->pIMemoryAllocator

	UnInitializeClientRequest(self)

	IMalloc_Free(pIMemoryAllocator, self)

	IMalloc_Release(pIMemoryAllocator)

End Sub

Private Function ClientRequestAddRef( _
		ByVal self As ClientRequest Ptr _
	)As ULONG

	self->ReferenceCounter += 1

	Return 1

End Function

Private Function ClientRequestRelease( _
		ByVal self As ClientRequest Ptr _
	)As ULONG

	self->ReferenceCounter -= 1

	If self->ReferenceCounter Then
		Return 1
	End If

	DestroyClientRequest(self)

	Return 0

End Function

Private Function ClientRequestQueryInterface( _
		ByVal self As ClientRequest Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_IClientRequest, riid) Then
		*ppv = @self->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @self->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If

	ClientRequestAddRef(self)

	Return S_OK

End Function

Public Function CreateClientRequest( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	Dim self As ClientRequest Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(ClientRequest) _
	)

	If self Then
		InitializeClientRequest(self, pIMemoryAllocator)

		Dim hrQueryInterface As HRESULT = ClientRequestQueryInterface( _
			self, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyClientRequest(self)
		End If

		Return hrQueryInterface
	End If

	*ppv = NULL
	Return E_OUTOFMEMORY

End Function

Private Function ClientRequestParse( _
		ByVal self As ClientRequest Ptr, _
		ByVal pIReader As IHttpAsyncReader Ptr, _
		ByVal RequestedLine As HeapBSTR _
	)As HRESULT

	Dim hrParseRequestedLine As HRESULT = ClientRequestParseRequestedLine( _
		self, _
		RequestedLine _
	)
	If FAILED(hrParseRequestedLine) Then
		Return hrParseRequestedLine
	End If

	Dim hrAddHeaders As HRESULT = ClientRequestAddRequestHeaders( _
		self, _
		pIReader _
	)
	If FAILED(hrAddHeaders) Then
		Return hrAddHeaders
	End If

	Dim hrParseHeaders As HRESULT = ClientRequestParseRequestHeaders(self)
	If FAILED(hrParseHeaders) Then
		Return hrParseHeaders
	End If

	Return S_OK

End Function

Private Function ClientRequestGetHttpMethod( _
		ByVal self As ClientRequest Ptr, _
		ByVal ppHttpMethod As HeapBSTR Ptr _
	)As HRESULT

	HeapSysAddRefString( _
		self->pHttpMethod _
	)

	*ppHttpMethod = self->pHttpMethod

	Return S_OK

End Function

Private Function ClientRequestGetUri( _
		ByVal self As ClientRequest Ptr, _
		ByVal ppUri As IClientUri Ptr Ptr _
	)As HRESULT

	If self->pClientURI Then
		IClientUri_AddRef(self->pClientURI)
	End If

	*ppUri = self->pClientURI

	Return S_OK

End Function

Private Function ClientRequestGetHttpVersion( _
		ByVal self As ClientRequest Ptr, _
		ByVal pHttpVersion As HttpVersions Ptr _
	)As HRESULT

	*pHttpVersion = self->HttpVersion

	Return S_OK

End Function

Private Function ClientRequestGetHttpHeader( _
		ByVal self As ClientRequest Ptr, _
		ByVal HeaderIndex As HttpRequestHeaders, _
		ByVal ppHeader As HeapBSTR Ptr _
	)As HRESULT

	HeapSysAddRefString( _
		self->RequestHeaders(HeaderIndex) _
	)

	*ppHeader = self->RequestHeaders(HeaderIndex)

	Return S_OK

End Function

Private Function ClientRequestGetKeepAlive( _
		ByVal self As ClientRequest Ptr, _
		ByVal pKeepAlive As Boolean Ptr _
	)As HRESULT

	*pKeepAlive = self->KeepAlive

	Return S_OK

End Function

Private Function ClientRequestGetContentLength( _
		ByVal self As ClientRequest Ptr, _
		ByVal pContentLength As LongInt Ptr _
	)As HRESULT

	*pContentLength = self->ContentLength

	Return S_OK

End Function

Private Function ClientRequestGetByteRange( _
		ByVal self As ClientRequest Ptr, _
		ByVal pRange As ByteRange Ptr _
	)As HRESULT

	*pRange = self->RequestByteRange

	Return S_OK

End Function

Private Function ClientRequestGetZipMode( _
		ByVal self As ClientRequest Ptr, _
		ByVal ZipIndex As ZipModes, _
		ByVal pSupported As Boolean Ptr _
	)As HRESULT

	*pSupported = self->RequestZipModes(ZipIndex)

	Return S_OK

End Function

Private Function ClientRequestGetExpect100Continue( _
		ByVal self As ClientRequest Ptr, _
		ByVal pExpect As Boolean Ptr _
	)As HRESULT

	*pExpect = self->Expect100Continue

	Return S_OK

End Function


Private Function IClientRequestQueryInterface( _
		ByVal self As IClientRequest Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return ClientRequestQueryInterface(CONTAINING_RECORD(self, ClientRequest, lpVtbl), riid, ppvObject)
End Function

Private Function IClientRequestAddRef( _
		ByVal self As IClientRequest Ptr _
	)As ULONG
	Return ClientRequestAddRef(CONTAINING_RECORD(self, ClientRequest, lpVtbl))
End Function

Private Function IClientRequestRelease( _
		ByVal self As IClientRequest Ptr _
	)As ULONG
	Return ClientRequestRelease(CONTAINING_RECORD(self, ClientRequest, lpVtbl))
End Function

Private Function IClientRequestParse( _
		ByVal self As IClientRequest Ptr, _
		ByVal pIReader As IHttpAsyncReader Ptr, _
		ByVal RequestedLine As HeapBSTR _
	)As HRESULT
	Return ClientRequestParse(CONTAINING_RECORD(self, ClientRequest, lpVtbl), pIReader, RequestedLine)
End Function

Private Function IClientRequestGetHttpMethod( _
		ByVal self As IClientRequest Ptr, _
		ByVal ppHttpMethod As HeapBSTR Ptr _
	)As HRESULT
	Return ClientRequestGetHttpMethod(CONTAINING_RECORD(self, ClientRequest, lpVtbl), ppHttpMethod)
End Function

Private Function IClientRequestGetUri( _
		ByVal self As IClientRequest Ptr, _
		ByVal ppUri As IClientUri Ptr Ptr _
	)As HRESULT
	Return ClientRequestGetUri(CONTAINING_RECORD(self, ClientRequest, lpVtbl), ppUri)
End Function

Private Function IClientRequestGetHttpVersion( _
		ByVal self As IClientRequest Ptr, _
		ByVal pHttpVersions As HttpVersions Ptr _
	)As HRESULT
	Return ClientRequestGetHttpVersion(CONTAINING_RECORD(self, ClientRequest, lpVtbl), pHttpVersions)
End Function

Private Function IClientRequestGetHttpHeader( _
		ByVal self As IClientRequest Ptr, _
		ByVal HeaderIndex As HttpRequestHeaders, _
		ByVal ppHeader As HeapBSTR Ptr _
	)As HRESULT
	Return ClientRequestGetHttpHeader(CONTAINING_RECORD(self, ClientRequest, lpVtbl), HeaderIndex, ppHeader)
End Function

Private Function IClientRequestGetKeepAlive( _
		ByVal self As IClientRequest Ptr, _
		ByVal pKeepAlive As Boolean Ptr _
	)As HRESULT
	Return ClientRequestGetKeepAlive(CONTAINING_RECORD(self, ClientRequest, lpVtbl), pKeepAlive)
End Function

Private Function IClientRequestGetContentLength( _
		ByVal self As IClientRequest Ptr, _
		ByVal pContentLength As LongInt Ptr _
	)As HRESULT
	Return ClientRequestGetContentLength(CONTAINING_RECORD(self, ClientRequest, lpVtbl), pContentLength)
End Function

Private Function IClientRequestGetByteRange( _
		ByVal self As IClientRequest Ptr, _
		ByVal pRange As ByteRange Ptr _
	)As HRESULT
	Return ClientRequestGetByteRange(CONTAINING_RECORD(self, ClientRequest, lpVtbl), pRange)
End Function

Private Function IClientRequestGetZipMode( _
		ByVal self As IClientRequest Ptr, _
		ByVal ZipIndex As ZipModes, _
		ByVal pSupported As Boolean Ptr _
	)As HRESULT
	Return ClientRequestGetZipMode(CONTAINING_RECORD(self, ClientRequest, lpVtbl), ZipIndex, pSupported)
End Function

Private Function IClientRequestGetExpect100Continue( _
		ByVal self As IClientRequest Ptr, _
		ByVal pExpect As Boolean Ptr _
	)As HRESULT
	Return ClientRequestGetExpect100Continue(CONTAINING_RECORD(self, ClientRequest, lpVtbl), pExpect)
End Function

Dim GlobalClientRequestVirtualTable As Const IClientRequestVirtualTable = Type( _
	@IClientRequestQueryInterface, _
	@IClientRequestAddRef, _
	@IClientRequestRelease, _
	@IClientRequestParse, _
	@IClientRequestGetHttpMethod, _
	@IClientRequestGetUri, _
	@IClientRequestGetHttpVersion, _
	@IClientRequestGetHttpHeader, _
	@IClientRequestGetKeepAlive, _
	@IClientRequestGetContentLength, _
	@IClientRequestGetByteRange, _
	@IClientRequestGetZipMode, _
	@IClientRequestGetExpect100Continue _
)
