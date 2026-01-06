#include once "ServerResponse.bi"
#include once "ArrayStringWriter.bi"
#include once "CharacterConstants.bi"
#include once "HeapBSTR.bi"
#include once "Resources.RH"
#include once "WebUtils.bi"

Extern GlobalServerResponseVirtualTable As Const IServerResponseVirtualTable

Const NosniffString = WStr("nosniff")
Const BytesString = WStr("bytes")
Const CloseString = WStr("Close")
Const KeepAliveString = WStr("Keep-Alive")
Const MaxResponseBufferLength As Integer = 1 * 4096 - 1
Const ColonWithSpaceString = WStr(": ")
Const CompareResultEqual As Long = 0

Type ResponseHeaderNode
	pHeader As WString Ptr
	HeaderLength As Integer
	HeaderIndex As HttpResponseHeaders
End Type

Type ServerResponse
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IServerResponseVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	ResponseHeaderLine As ZString Ptr
	ResponseHeaderLineLength As Integer
	HttpVersion As HttpVersions
	StatusCode As HttpStatusCodes
	StatusDescription As HeapBSTR
	ByteRangeOffset As LongInt
	ByteRangeLength As LongInt
	ResponseZipMode As ZipModes
	Mime As MimeType
	ResponseHeaders(HttpResponseHeadersSize - 1) As HeapBSTR
	ResponseZipEnable As Boolean
	SendOnlyHeaders As Boolean
	KeepAlive As Boolean
End Type

Dim Shared ResponseHeaderNodesVector(1 To HttpResponseHeadersSize) As ResponseHeaderNode = { _
	Type<ResponseHeaderNode>(@HeaderCacheControlString,         Len(HeaderCacheControlString),         HttpResponseHeaders.HeaderCacheControl), _
	Type<ResponseHeaderNode>(@HeaderConnectionString,           Len(HeaderConnectionString),           HttpResponseHeaders.HeaderConnection), _
	Type<ResponseHeaderNode>(@HeaderDateString,                 Len(HeaderDateString),                 HttpResponseHeaders.HeaderDate), _
	Type<ResponseHeaderNode>(@HeaderPragmaString,               Len(HeaderPragmaString),               HttpResponseHeaders.HeaderPragma), _
	Type<ResponseHeaderNode>(@HeaderTrailerString,              Len(HeaderTrailerString),              HttpResponseHeaders.HeaderTrailer), _
	Type<ResponseHeaderNode>(@HeaderTransferEncodingString,     Len(HeaderTransferEncodingString),     HttpResponseHeaders.HeaderTransferEncoding), _
	Type<ResponseHeaderNode>(@HeaderUpgradeString,              Len(HeaderUpgradeString),              HttpResponseHeaders.HeaderUpgrade), _
	Type<ResponseHeaderNode>(@HeaderViaString,                  Len(HeaderViaString),                  HttpResponseHeaders.HeaderVia), _
	Type<ResponseHeaderNode>(@HeaderWarningString,              Len(HeaderWarningString),              HttpResponseHeaders.HeaderWarning), _
	Type<ResponseHeaderNode>(@HeaderAcceptRangesString,         Len(HeaderAcceptRangesString),         HttpResponseHeaders.HeaderAcceptRanges), _
	Type<ResponseHeaderNode>(@HeaderAgeString,                  Len(HeaderAgeString),                  HttpResponseHeaders.HeaderAge), _
	Type<ResponseHeaderNode>(@HeaderETagString,                 Len(HeaderETagString),                 HttpResponseHeaders.HeaderETag), _
	Type<ResponseHeaderNode>(@HeaderLocationString,             Len(HeaderLocationString),             HttpResponseHeaders.HeaderLocation), _
	Type<ResponseHeaderNode>(@HeaderProxyAuthenticateString,    Len(HeaderProxyAuthenticateString),    HttpResponseHeaders.HeaderProxyAuthenticate), _
	Type<ResponseHeaderNode>(@HeaderRetryAfterString,           Len(HeaderRetryAfterString),           HttpResponseHeaders.HeaderRetryAfter), _
	Type<ResponseHeaderNode>(@HeaderSetCookieString,            Len(HeaderSetCookieString),            HttpResponseHeaders.HeaderSetCookie), _
	Type<ResponseHeaderNode>(@HeaderServerString,               Len(HeaderServerString),               HttpResponseHeaders.HeaderServer), _
	Type<ResponseHeaderNode>(@HeaderVaryString,                 Len(HeaderVaryString),                 HttpResponseHeaders.HeaderVary), _
	Type<ResponseHeaderNode>(@HeaderWWWAuthenticateString,      Len(HeaderWWWAuthenticateString),      HttpResponseHeaders.HeaderWwwAuthenticate), _
	Type<ResponseHeaderNode>(@HeaderXContentTypeOptionsString,  Len(HeaderXContentTypeOptionsString),  HttpResponseHeaders.HeaderXContentTypeOptions), _
	Type<ResponseHeaderNode>(@HeaderKeepAliveString,            Len(HeaderKeepAliveString),            HttpResponseHeaders.HeaderKeepAlive), _
	Type<ResponseHeaderNode>(@HeaderSecWebSocketAcceptString,   Len(HeaderSecWebSocketAcceptString),   HttpResponseHeaders.HeaderSecWebSocketAccept), _
	Type<ResponseHeaderNode>(@HeaderSecWebSocketLocationString, Len(HeaderSecWebSocketLocationString), HttpResponseHeaders.HeaderSecWebSocketLocation), _
	Type<ResponseHeaderNode>(@HeaderSecWebSocketOriginString,   Len(HeaderSecWebSocketOriginString),   HttpResponseHeaders.HeaderSecWebSocketOrigin), _
	Type<ResponseHeaderNode>(@HeaderSecWebSocketProtocolString, Len(HeaderSecWebSocketProtocolString), HttpResponseHeaders.HeaderSecWebSocketProtocol), _
	Type<ResponseHeaderNode>(@HeaderWebSocketLocationString,    Len(HeaderWebSocketLocationString),    HttpResponseHeaders.HeaderWebSocketLocation), _
	Type<ResponseHeaderNode>(@HeaderWebSocketOriginString,      Len(HeaderWebSocketOriginString),      HttpResponseHeaders.HeaderWebSocketOrigin), _
	Type<ResponseHeaderNode>(@HeaderWebSocketProtocolString,    Len(HeaderWebSocketProtocolString),    HttpResponseHeaders.HeaderWebSocketProtocol), _
	Type<ResponseHeaderNode>(@HeaderAllowString,                Len(HeaderAllowString),                HttpResponseHeaders.HeaderAllow), _
	Type<ResponseHeaderNode>(@HeaderContentEncodingString,      Len(HeaderContentEncodingString),      HttpResponseHeaders.HeaderContentEncoding), _
	Type<ResponseHeaderNode>(@HeaderContentLanguageString,      Len(HeaderContentLanguageString),      HttpResponseHeaders.HeaderContentLanguage), _
	Type<ResponseHeaderNode>(@HeaderContentLengthString,        Len(HeaderContentLengthString),        HttpResponseHeaders.HeaderContentLength), _
	Type<ResponseHeaderNode>(@HeaderContentLocationString,      Len(HeaderContentLocationString),      HttpResponseHeaders.HeaderContentLocation), _
	Type<ResponseHeaderNode>(@HeaderContentMd5String,           Len(HeaderContentMd5String),           HttpResponseHeaders.HeaderContentMd5), _
	Type<ResponseHeaderNode>(@HeaderContentRangeString,         Len(HeaderContentRangeString),         HttpResponseHeaders.HeaderContentRange), _
	Type<ResponseHeaderNode>(@HeaderContentTypeString,          Len(HeaderContentTypeString),          HttpResponseHeaders.HeaderContentType), _
	Type<ResponseHeaderNode>(@HeaderExpiresString,              Len(HeaderExpiresString),              HttpResponseHeaders.HeaderExpires), _
	Type<ResponseHeaderNode>(@HeaderLastModifiedString,         Len(HeaderLastModifiedString),         HttpResponseHeaders.HeaderLastModified) _
}

Private Function KnownResponseHeaderToString( _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal pHeaderLength As Integer Ptr _
	)As WString Ptr

	Dim pHeader As WString Ptr = NULL
	Dim HeaderLength As Integer = 0

	For i As Integer = 1 To HttpResponseHeadersSize
		If ResponseHeaderNodesVector(i).HeaderIndex = HeaderIndex Then
			HeaderLength = ResponseHeaderNodesVector(i).HeaderLength
			pHeader = ResponseHeaderNodesVector(i).pHeader
			Exit For
		End If
	Next

	If pHeaderLength Then
		*pHeaderLength = HeaderLength
	End If

	Return pHeader

End Function

Private Function HttpVersionToString( _
		ByVal v As HttpVersions, _
		ByVal pBufferLength As Integer Ptr _
	)As WString Ptr

	Dim intBufferLength As Integer = 0

	Select Case v

		Case HttpVersions.Http11
			intBufferLength = Len(HttpVersion11String)
			HttpVersionToString = @HttpVersion11String

		Case HttpVersions.Http10
			intBufferLength = Len(HttpVersion10String)
			HttpVersionToString = @HttpVersion10String

		Case Else
			intBufferLength = Len(HttpVersion11String)
			HttpVersionToString = @HttpVersion11String

	End Select

	If pBufferLength Then
		*pBufferLength = intBufferLength
	End If

End Function

Private Function GetKnownResponseHeaderIndex( _
		ByVal pHeader As WString Ptr, _
		ByVal pIndex As HttpResponseHeaders Ptr _
	)As Boolean

	For i As Integer = 1 To HttpResponseHeadersSize
		Dim CompareResult As Long = lstrcmpW( _
			ResponseHeaderNodesVector(i).pHeader, _
			pHeader _
		)
		If CompareResult = CompareResultEqual Then
			*pIndex = ResponseHeaderNodesVector(i).HeaderIndex
			Return True
		End If
	Next

	*pIndex = 0
	Return False

End Function

Private Sub InitializeServerResponse( _
		ByVal self As ServerResponse Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@self->RttiClassName(0), _
			@Str(RTTI_ID_SERVERRESPONSE), _
			UBound(self->RttiClassName) - LBound(self->RttiClassName) + 1 _
		)
	#endif
	self->lpVtbl = @GlobalServerResponseVirtualTable
	self->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	self->pIMemoryAllocator = pIMemoryAllocator
	ZeroMemory(@self->ResponseHeaders(0), HttpResponseHeadersSize * SizeOf(HeapBSTR))
	self->ResponseHeaderLine = NULL
	self->ResponseHeaderLineLength = 0
	self->HttpVersion = HttpVersions.Http11
	self->StatusCode = HttpStatusCodes.OK
	self->StatusDescription = NULL
	self->ByteRangeOffset = 0
	self->ByteRangeLength = 0
	self->SendOnlyHeaders = False
	self->KeepAlive = True
	self->ResponseZipEnable = False
	self->Mime.ContentType = ContentTypes.AnyAny
	self->Mime.Format = MimeFormats.Binary
	self->Mime.CharsetWeakPtr = NULL

End Sub

Private Sub UnInitializeServerResponse( _
		ByVal self As ServerResponse Ptr _
	)

	For i As Integer = 0 To HttpResponseHeadersSize - 1
		HeapSysFreeString(self->ResponseHeaders(i))
	Next

	HeapSysFreeString(self->StatusDescription)

	If self->ResponseHeaderLine Then
		IMalloc_Free( _
			self->pIMemoryAllocator, _
			self->ResponseHeaderLine _
		)
	End If

End Sub

Private Sub DestroyServerResponse( _
		ByVal self As ServerResponse Ptr _
	)

	Dim pIMemoryAllocator As IMalloc Ptr = self->pIMemoryAllocator

	UnInitializeServerResponse(self)

	IMalloc_Free(pIMemoryAllocator, self)

	IMalloc_Release(pIMemoryAllocator)

End Sub

Private Function ServerResponseAddRef( _
		ByVal self As ServerResponse Ptr _
	)As ULONG

	self->ReferenceCounter += 1

	Return 1

End Function

Private Function ServerResponseRelease( _
		ByVal self As ServerResponse Ptr _
	)As ULONG

	self->ReferenceCounter -= 1

	If self->ReferenceCounter Then
		Return 1
	End If

	DestroyServerResponse(self)

	Return 0

End Function

Private Function ServerResponseQueryInterface( _
		ByVal self As ServerResponse Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_IServerResponse, riid) Then
		*ppv = @self->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @self->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If

	ServerResponseAddRef(self)

	Return S_OK

End Function

Public Function CreateServerResponse( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	Dim self As ServerResponse Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(ServerResponse) _
	)

	If self Then
		InitializeServerResponse(self, pIMemoryAllocator)

		Dim hrQueryInterface As HRESULT = ServerResponseQueryInterface( _
			self, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyServerResponse(self)
		End If

		Return hrQueryInterface
	End If

	*ppv = NULL
	Return E_OUTOFMEMORY

End Function

Private Function ServerResponseGetHttpVersion( _
		ByVal self As ServerResponse Ptr, _
		ByVal pHttpVersion As HttpVersions Ptr _
	)As HRESULT

	*pHttpVersion = self->HttpVersion

	Return S_OK

End Function

Private Function ServerResponseSetHttpVersion( _
		ByVal self As ServerResponse Ptr, _
		ByVal HttpVersion As HttpVersions _
	)As HRESULT

	self->HttpVersion = HttpVersion

	Return S_OK

End Function

Private Function ServerResponseGetStatusCode( _
		ByVal self As ServerResponse Ptr, _
		ByVal pStatusCode As HttpStatusCodes Ptr _
	)As HRESULT

	*pStatusCode = self->StatusCode

	Return S_OK

End Function

Private Function ServerResponseSetStatusCode( _
		ByVal self As ServerResponse Ptr, _
		ByVal StatusCode As HttpStatusCodes _
	)As HRESULT

	self->StatusCode = StatusCode

	Return S_OK

End Function

Private Function ServerResponseGetStatusDescription( _
		ByVal self As ServerResponse Ptr, _
		ByVal ppStatusDescription As HeapBSTR Ptr _
	)As HRESULT

	*ppStatusDescription = self->StatusDescription

	Return S_OK

End Function

Private Function ServerResponseSetStatusDescription( _
		ByVal self As ServerResponse Ptr, _
		ByVal pStatusDescription As HeapBSTR _
	)As HRESULT

	self->StatusDescription = pStatusDescription

	Return S_OK

End Function

Private Function ServerResponseGetKeepAlive( _
		ByVal self As ServerResponse Ptr, _
		ByVal pKeepAlive As Boolean Ptr _
	)As HRESULT

	*pKeepAlive = self->KeepAlive

	Return S_OK

End Function

Private Function ServerResponseSetKeepAlive( _
		ByVal self As ServerResponse Ptr, _
		ByVal KeepAlive As Boolean _
	)As HRESULT

	self->KeepAlive = KeepAlive

	Return S_OK

End Function

Private Function ServerResponseGetSendOnlyHeaders( _
		ByVal self As ServerResponse Ptr, _
		ByVal pSendOnlyHeaders As Boolean Ptr _
	)As HRESULT

	*pSendOnlyHeaders = self->SendOnlyHeaders

	Return S_OK

End Function

Private Function ServerResponseSetSendOnlyHeaders( _
		ByVal self As ServerResponse Ptr, _
		ByVal SendOnlyHeaders As Boolean _
	)As HRESULT

	self->SendOnlyHeaders = SendOnlyHeaders

	Return S_OK

End Function

Private Function ServerResponseGetMimeType( _
		ByVal self As ServerResponse Ptr, _
		ByVal pMimeType As MimeType Ptr _
	)As HRESULT

	*pMimeType = self->Mime

	Return S_OK

End Function

Private Function ServerResponseSetMimeType( _
		ByVal self As ServerResponse Ptr, _
		ByVal pMimeType As MimeType Ptr _
	)As HRESULT

	self->Mime = *pMimeType

	Return S_OK

End Function

Private Function ServerResponseGetHttpHeader( _
		ByVal self As ServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal ppHeader As HeapBSTR Ptr _
	)As HRESULT

	*ppHeader = self->ResponseHeaders(HeaderIndex)

	Return S_OK

End Function

Private Function ServerResponseSetHttpHeader( _
		ByVal self As ServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal pHeader As HeapBSTR _
	)As HRESULT

	self->ResponseHeaders(HeaderIndex) = pHeader

	Return S_OK

End Function

Private Function ServerResponseGetZipEnabled( _
		ByVal self As ServerResponse Ptr, _
		ByVal pZipEnabled As Boolean Ptr _
	)As HRESULT

	*pZipEnabled = self->ResponseZipEnable

	Return S_OK

End Function

Private Function ServerResponseSetZipEnabled( _
		ByVal self As ServerResponse Ptr, _
		ByVal ZipEnabled As Boolean _
	)As HRESULT

	self->ResponseZipEnable = ZipEnabled

	Return S_OK

End Function

Private Function ServerResponseGetZipMode( _
		ByVal self As ServerResponse Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT

	*pZipMode = self->ResponseZipMode

	Return S_OK

End Function

Private Function ServerResponseSetZipMode( _
		ByVal self As ServerResponse Ptr, _
		ByVal ZipMode As ZipModes _
	)As HRESULT

	self->ResponseZipMode = ZipMode

	Return S_OK

End Function

Private Function ServerResponseAddKnownResponseHeader( _
		ByVal self As ServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As HeapBSTR _
	)As HRESULT

	LET_HEAPSYSSTRING(self->ResponseHeaders(HeaderIndex), Value)

	Return S_OK

End Function

Private Function ServerResponseAddResponseHeader( _
		ByVal self As ServerResponse Ptr, _
		ByVal HeaderName As HeapBSTR, _
		ByVal Value As HeapBSTR _
	)As HRESULT

	Dim HeaderIndex As HttpResponseHeaders = Any
	Dim Finded As Boolean = GetKnownResponseHeaderIndex(HeaderName, @HeaderIndex)
	If Finded Then
		Dim hrAddHeader As HRESULT = ServerResponseAddKnownResponseHeader( _
			self, _
			HeaderIndex, _
			Value _
		)
		Return hrAddHeader
	End If

	Return S_FALSE

End Function

Private Function ServerResponseAddKnownResponseHeaderWstrLen( _
		ByVal self As ServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As WString Ptr, _
		ByVal Length As Integer _
	)As HRESULT

	Dim hBstr As HeapBSTR = CreateHeapStringLen( _
		self->pIMemoryAllocator, _
		Value, _
		Length _
	)
	If hBstr = NULL Then
		Return E_OUTOFMEMORY
	End If

	Dim hr As HRESULT = ServerResponseAddKnownResponseHeader( _
		self, _
		HeaderIndex, _
		hBstr _
	)

	HeapSysFreeString(hBstr)

	Return hr

End Function

Private Function ServerResponseAddKnownResponseHeaderWstr( _
		ByVal self As ServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As WString Ptr _
	)As HRESULT

	Dim Length As Integer = lstrlenW(Value)

	Dim hr As HRESULT = ServerResponseAddKnownResponseHeaderWstrLen( _
		self, _
		HeaderIndex, _
		Value, _
		Length _
	)

	Return hr

End Function

Private Function ServerResponseGetByteRange( _
		ByVal self As ServerResponse Ptr, _
		ByVal pOffset As LongInt Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT

	*pOffset = self->ByteRangeOffset
	*pLength = self->ByteRangeLength

	Return S_OK

End Function

Private Function ServerResponseSetByteRange( _
		ByVal self As ServerResponse Ptr, _
		ByVal Offset As LongInt, _
		ByVal Length As LongInt _
	)As HRESULT

	self->ByteRangeOffset = Offset
	self->ByteRangeLength = Length

	Return S_OK

End Function

Private Sub ServerResponsePrintServerHeaders( _
		ByVal self As ServerResponse Ptr _
	)

End Sub

Private Function ServerResponseAllHeadersToZString( _
		ByVal self As ServerResponse Ptr, _
		ByVal ContentLength As LongInt, _
		ByVal ppHeaders As ZString Ptr Ptr, _
		ByVal pHeadersLength As LongInt Ptr _
	)As HRESULT

	Scope
		Dim hrAddHeader As HRESULT = ServerResponseAddKnownResponseHeaderWstrLen( _
			self, _
			HttpResponseHeaders.HeaderAcceptRanges, _
			@BytesString, _
			Len(BytesString) _
		)
		If FAILED(hrAddHeader) Then
			Return hrAddHeader
		End If
	End Scope

	Scope
		Dim hrAddHeader As HRESULT = ServerResponseAddKnownResponseHeaderWstrLen( _
			self, _
			HttpResponseHeaders.HeaderXContentTypeOptions, _
			@NosniffString, _
			Len(NosniffString) _
		)
		If FAILED(hrAddHeader) Then
			Return hrAddHeader
		End If
	End Scope

	Scope
		Const BufSize As Integer = 256
		Const FormatString = WStr(!"Station922/%s")

		Dim ServerVersionString As WString * BufSize = Any
		Dim Length As Long = wsprintfW( _
			@ServerVersionString, _
			@FormatString, _
			@WStr(VER_PRODUCTVERSION_STR) _
		)

		Dim hrAddHeader As HRESULT = ServerResponseAddKnownResponseHeaderWstrLen( _
			self, _
			HttpResponseHeaders.HeaderServer, _
			@ServerVersionString, _
			CInt(Length) _
		)
		If FAILED(hrAddHeader) Then
			Return hrAddHeader
		End If
	End Scope

	If self->KeepAlive Then
		Dim hrAddHeader As HRESULT = ServerResponseAddKnownResponseHeaderWstrLen( _
			self, _
			HttpResponseHeaders.HeaderConnection, _
			@KeepAliveString, _
			Len(KeepAliveString) _
		)
		If FAILED(hrAddHeader) Then
			Return hrAddHeader
		End If
	Else
		Dim hrAddHeader As HRESULT = ServerResponseAddKnownResponseHeaderWstrLen( _
			self, _
			HttpResponseHeaders.HeaderConnection, _
			@CloseString, _
			Len(CloseString) _
		)
		If FAILED(hrAddHeader) Then
			Return hrAddHeader
		End If
	End If

	Select Case self->StatusCode

		Case HttpStatusCodes.CodeContinue, _
			HttpStatusCodes.SwitchingProtocols, _
			HttpStatusCodes.Processing, _
			HttpStatusCodes.NoContent

			ServerResponseAddKnownResponseHeader( _
				self, _
				HttpResponseHeaders.HeaderContentLength, _
				NULL _
			)

		Case Else
			Dim strContentLength As WString * (64) = Any
			_i64tow(ContentLength, @strContentLength, 10)

			ServerResponseAddKnownResponseHeaderWstr( _
				self, _
				HttpResponseHeaders.HeaderContentLength, _
				@strContentLength _
			)

	End Select

	Scope
		If self->Mime.ContentType <> ContentTypes.AnyAny Then
			Dim wContentType As WString * (MaxContentTypeLength + 1) = Any
			GetContentTypeOfMimeType(@wContentType, @self->Mime)

			ServerResponseAddKnownResponseHeaderWstr( _
				self, _
				HttpResponseHeaders.HeaderContentType, _
				@wContentType _
			)
		End If
	End Scope

	Dim pHeadersBuffer As WString Ptr = IMalloc_Alloc( _
		self->pIMemoryAllocator, _
		SizeOf(WString) * (MaxResponseBufferLength + 1) _
	)
	If pHeadersBuffer = NULL Then
		*ppHeaders = NULL
		*pHeadersLength = 0
		Return E_OUTOFMEMORY
	End If

	Scope
		Dim Writer As ArrayStringWriter = Any
		InitializeArrayStringWriter(@Writer)

		Writer.SetBuffer( _
			pHeadersBuffer, _
			MaxResponseBufferLength _
		)

		Scope
			Dim HttpVersionLength As Integer = Any
			Dim pwHttpVersion As WString Ptr = HttpVersionToString( _
				self->HttpVersion, _
				@HttpVersionLength _
			)

			Writer.WriteLengthString(pwHttpVersion, HttpVersionLength)
			Writer.WriteChar(Characters.WhiteSpace)

			Writer.WriteInt32(self->StatusCode)
			Writer.WriteChar(Characters.WhiteSpace)

			If self->StatusDescription = NULL Then
				Dim BufferLength As Integer = Any
				Dim wBuffer As WString Ptr = GetStatusDescription(self->StatusCode, @BufferLength)
				Writer.WriteLengthStringLine(wBuffer, BufferLength)
			Else
				Writer.WriteStringLine(self->StatusDescription)
			End If
		End Scope

		Scope
			Dim datNowF As FILETIME = Any
			GetSystemTimeAsFileTime(@datNowF)

			Dim datNowS As SYSTEMTIME = Any
			FileTimeToSystemTime(@datNowF, @datNowS)

			Dim HttpDate As HeapBSTR = ConvertSystemDateToHttpDate( _
				self->pIMemoryAllocator, _
				@datNowS _
			)
			If HttpDate = NULL Then
				IMalloc_Free(self->pIMemoryAllocator, pHeadersBuffer)
				*ppHeaders = NULL
				*pHeadersLength = 0
				Return E_OUTOFMEMORY
			End If

			ServerResponseAddKnownResponseHeader( _
				self, _
				HttpResponseHeaders.HeaderDate, _
				HttpDate _
			)

			HeapSysFreeString(HttpDate)
		End Scope

		For i As Integer = 0 To HttpResponseHeadersSize - 1

			Dim HeaderIndex As HttpResponseHeaders = Cast(HttpResponseHeaders, i)

			If self->ResponseHeaders(HeaderIndex) Then

				Dim BufferLength As Integer = Any
				Dim wBuffer As WString Ptr = KnownResponseHeaderToString( _
					HeaderIndex, _
					@BufferLength _
				)

				Writer.WriteLengthString(wBuffer, BufferLength)
				Writer.WriteLengthString(@ColonWithSpaceString, Len(ColonWithSpaceString))
				Writer.WriteStringLine(self->ResponseHeaders(HeaderIndex))
			End If

		Next

		Writer.WriteNewLine()

		self->ResponseHeaderLineLength = Writer.GetLength()

	End Scope

	self->ResponseHeaderLine = IMalloc_Alloc( _
		self->pIMemoryAllocator, _
		self->ResponseHeaderLineLength _
	)
	If self->ResponseHeaderLine = NULL Then
		IMalloc_Free(self->pIMemoryAllocator, pHeadersBuffer)
		*ppHeaders = NULL
		*pHeadersLength = 0
		Return E_OUTOFMEMORY
	End If

	WideCharToMultiByte( _
		CP_ACP, _
		0, _
		pHeadersBuffer, _
		self->ResponseHeaderLineLength, _
		self->ResponseHeaderLine, _
		self->ResponseHeaderLineLength, _
		0, _
		0 _
	)

	ServerResponsePrintServerHeaders(self)

	*ppHeaders = self->ResponseHeaderLine
	*pHeadersLength = self->ResponseHeaderLineLength

	IMalloc_Free(self->pIMemoryAllocator, pHeadersBuffer)

	Return S_OK

End Function


Private Function IServerResponseQueryInterface( _
		ByVal self As IServerResponse Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return ServerResponseQueryInterface(CONTAINING_RECORD(self, ServerResponse, lpVtbl), riid, ppvObject)
End Function

Private Function IServerResponseAddRef( _
		ByVal self As IServerResponse Ptr _
	)As ULONG
	Return ServerResponseAddRef(CONTAINING_RECORD(self, ServerResponse, lpVtbl))
End Function

Private Function IServerResponseRelease( _
		ByVal self As IServerResponse Ptr _
	)As ULONG
	Return ServerResponseRelease(CONTAINING_RECORD(self, ServerResponse, lpVtbl))
End Function

Private Function IServerResponseGetHttpVersion( _
		ByVal self As IServerResponse Ptr, _
		ByVal pHttpVersion As HttpVersions Ptr _
	)As HRESULT
	Return ServerResponseGetHttpVersion(CONTAINING_RECORD(self, ServerResponse, lpVtbl), pHttpVersion)
End Function

Private Function IServerResponseSetHttpVersion( _
		ByVal self As IServerResponse Ptr, _
		ByVal HttpVersion As HttpVersions _
	)As HRESULT
	Return ServerResponseSetHttpVersion(CONTAINING_RECORD(self, ServerResponse, lpVtbl), HttpVersion)
End Function

Private Function IServerResponseGetStatusCode( _
		ByVal self As IServerResponse Ptr, _
		ByVal pStatusCode As HttpStatusCodes Ptr _
	)As HRESULT
	Return ServerResponseGetStatusCode(CONTAINING_RECORD(self, ServerResponse, lpVtbl), pStatusCode)
End Function

Private Function IServerResponseSetStatusCode( _
		ByVal self As IServerResponse Ptr, _
		ByVal StatusCode As HttpStatusCodes _
	)As HRESULT
	Return ServerResponseSetStatusCode(CONTAINING_RECORD(self, ServerResponse, lpVtbl), StatusCode)
End Function

Private Function IServerResponseGetStatusDescription( _
		ByVal self As IServerResponse Ptr, _
		ByVal ppStatusDescription As HeapBSTR Ptr _
	)As HRESULT
	Return ServerResponseGetStatusDescription(CONTAINING_RECORD(self, ServerResponse, lpVtbl), ppStatusDescription)
End Function

Private Function IServerResponseSetStatusDescription( _
		ByVal self As IServerResponse Ptr, _
		ByVal pStatusDescription As HeapBSTR _
	)As HRESULT
	Return ServerResponseSetStatusDescription(CONTAINING_RECORD(self, ServerResponse, lpVtbl), pStatusDescription)
End Function

Private Function IServerResponseGetKeepAlive( _
		ByVal self As IServerResponse Ptr, _
		ByVal pKeepAlive As Boolean Ptr _
	)As HRESULT
	Return ServerResponseGetKeepAlive(CONTAINING_RECORD(self, ServerResponse, lpVtbl), pKeepAlive)
End Function

Private Function IServerResponseSetKeepAlive( _
		ByVal self As IServerResponse Ptr, _
		ByVal KeepAlive As Boolean _
	)As HRESULT
	Return ServerResponseSetKeepAlive(CONTAINING_RECORD(self, ServerResponse, lpVtbl), KeepAlive)
End Function

Private Function IServerResponseGetSendOnlyHeaders( _
		ByVal self As IServerResponse Ptr, _
		ByVal pSendOnlyHeaders As Boolean Ptr _
	)As HRESULT
	Return ServerResponseGetSendOnlyHeaders(CONTAINING_RECORD(self, ServerResponse, lpVtbl), pSendOnlyHeaders)
End Function

Private Function IServerResponseSetSendOnlyHeaders( _
		ByVal self As IServerResponse Ptr, _
		ByVal SendOnlyHeaders As Boolean _
	)As HRESULT
	Return ServerResponseSetSendOnlyHeaders(CONTAINING_RECORD(self, ServerResponse, lpVtbl), SendOnlyHeaders)
End Function

Private Function IServerResponseGetMimeType( _
		ByVal self As IServerResponse Ptr, _
		ByVal pMimeType As MimeType Ptr _
	)As HRESULT
	Return ServerResponseGetMimeType(CONTAINING_RECORD(self, ServerResponse, lpVtbl), pMimeType)
End Function

Private Function IServerResponseSetMimeType( _
		ByVal self As IServerResponse Ptr, _
		ByVal pMimeType As MimeType Ptr _
	)As HRESULT
	Return ServerResponseSetMimeType(CONTAINING_RECORD(self, ServerResponse, lpVtbl), pMimeType)
End Function

Private Function IServerResponseGetHttpHeader( _
		ByVal self As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal ppHeader As HeapBSTR Ptr _
	)As HRESULT
	Return ServerResponseGetHttpHeader(CONTAINING_RECORD(self, ServerResponse, lpVtbl), HeaderIndex, ppHeader)
End Function

Private Function IServerResponseSetHttpHeader( _
		ByVal self As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal pHeader As HeapBSTR _
	)As HRESULT
	Return ServerResponseSetHttpHeader(CONTAINING_RECORD(self, ServerResponse, lpVtbl), HeaderIndex, pHeader)
End Function

Private Function IServerResponseGetZipEnabled( _
		ByVal self As IServerResponse Ptr, _
		ByVal pZipEnabled As Boolean Ptr _
	)As HRESULT
	Return ServerResponseGetZipEnabled(CONTAINING_RECORD(self, ServerResponse, lpVtbl), pZipEnabled)
End Function

Private Function IServerResponseSetZipEnabled( _
		ByVal self As IServerResponse Ptr, _
		ByVal ZipEnabled As Boolean _
	)As HRESULT
	Return ServerResponseSetZipEnabled(CONTAINING_RECORD(self, ServerResponse, lpVtbl), ZipEnabled)
End Function

Private Function IServerResponseGetZipMode( _
		ByVal self As IServerResponse Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	Return ServerResponseGetZipMode(CONTAINING_RECORD(self, ServerResponse, lpVtbl), pZipMode)
End Function

Private Function IServerResponseSetZipMode( _
		ByVal self As IServerResponse Ptr, _
		ByVal ZipMode As ZipModes _
	)As HRESULT
	Return ServerResponseSetZipMode(CONTAINING_RECORD(self, ServerResponse, lpVtbl), ZipMode)
End Function

Private Function IServerResponseAddResponseHeader( _
		ByVal self As IServerResponse Ptr, _
		ByVal HeaderName As HeapBSTR, _
		ByVal Value As HeapBSTR _
	)As HRESULT
	Return ServerResponseAddResponseHeader(CONTAINING_RECORD(self, ServerResponse, lpVtbl), HeaderName, Value)
End Function

Private Function IServerResponseAddKnownResponseHeader( _
		ByVal self As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As HeapBSTR _
	)As HRESULT
	Return ServerResponseAddKnownResponseHeader(CONTAINING_RECORD(self, ServerResponse, lpVtbl), HeaderIndex, Value)
End Function

Private Function IServerResponseAddKnownResponseHeaderWstr( _
		ByVal self As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As HeapBSTR _
	)As HRESULT
	Return ServerResponseAddKnownResponseHeaderWstr(CONTAINING_RECORD(self, ServerResponse, lpVtbl), HeaderIndex, Value)
End Function

Private Function IServerResponseGetByteRange( _
		ByVal self As IServerResponse Ptr, _
		ByVal pOffset As LongInt Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT
	Return ServerResponseGetByteRange(CONTAINING_RECORD(self, ServerResponse, lpVtbl), pOffset, pLength)
End Function

Private Function IServerResponseSetByteRange( _
		ByVal self As IServerResponse Ptr, _
		ByVal Offset As LongInt, _
		ByVal Length As LongInt _
	)As HRESULT
	Return ServerResponseSetByteRange(CONTAINING_RECORD(self, ServerResponse, lpVtbl), Offset, Length)
End Function

Private Function IServerResponseAddKnownResponseHeaderWstrLen( _
		ByVal self As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As HeapBSTR, _
		ByVal Length As Integer _
	)As HRESULT
	Return ServerResponseAddKnownResponseHeaderWstrLen(CONTAINING_RECORD(self, ServerResponse, lpVtbl), HeaderIndex, Value, Length)
End Function

Private Function IServerResponseAllHeadersToZString( _
		ByVal self As IServerResponse Ptr, _
		ByVal ContentLength As LongInt, _
		ByVal ppHeaders As ZString Ptr Ptr, _
		ByVal pHeadersLength As LongInt Ptr _
	)As HRESULT
	Return ServerResponseAllHeadersToZString(CONTAINING_RECORD(self, ServerResponse, lpVtbl), ContentLength, ppHeaders, pHeadersLength)
End Function

Dim GlobalServerResponseVirtualTable As Const IServerResponseVirtualTable = Type( _
	@IServerResponseQueryInterface, _
	@IServerResponseAddRef, _
	@IServerResponseRelease, _
	@IServerResponseGetHttpVersion, _
	@IServerResponseSetHttpVersion, _
	@IServerResponseGetStatusCode, _
	@IServerResponseSetStatusCode, _
	@IServerResponseGetStatusDescription, _
	@IServerResponseSetStatusDescription, _
	@IServerResponseGetKeepAlive, _
	@IServerResponseSetKeepAlive, _
	@IServerResponseGetSendOnlyHeaders, _
	@IServerResponseSetSendOnlyHeaders, _
	@IServerResponseGetMimeType, _
	@IServerResponseSetMimeType, _
	@IServerResponseGetHttpHeader, _
	@IServerResponseSetHttpHeader, _
	@IServerResponseGetZipEnabled, _
	@IServerResponseSetZipEnabled, _
	@IServerResponseGetZipMode, _
	@IServerResponseSetZipMode, _
	@IServerResponseAddResponseHeader, _
	@IServerResponseAddKnownResponseHeader, _
	@IServerResponseAddKnownResponseHeaderWstr, _
	@IServerResponseAddKnownResponseHeaderWstrLen, _
	@IServerResponseGetByteRange, _
	@IServerResponseSetByteRange, _
	@IServerResponseAllHeadersToZString _
)
