#include once "ServerResponse.bi"
#include once "ArrayStringWriter.bi"
#include once "CharacterConstants.bi"
#include once "ContainerOf.bi"
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

Type _ServerResponse
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
		ByVal this As ServerResponse Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->RttiClassName(0), _
			@Str(RTTI_ID_SERVERRESPONSE), _
			UBound(this->RttiClassName) - LBound(this->RttiClassName) + 1 _
		)
	#endif
	this->lpVtbl = @GlobalServerResponseVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	ZeroMemory(@this->ResponseHeaders(0), HttpResponseHeadersSize * SizeOf(HeapBSTR))
	this->ResponseHeaderLine = NULL
	this->ResponseHeaderLineLength = 0
	this->HttpVersion = HttpVersions.Http11
	this->StatusCode = HttpStatusCodes.OK
	this->StatusDescription = NULL
	this->ByteRangeOffset = 0
	this->ByteRangeLength = 0
	this->SendOnlyHeaders = False
	this->KeepAlive = True
	this->ResponseZipEnable = False
	this->Mime.ContentType = ContentTypes.AnyAny
	this->Mime.Format = MimeFormats.Binary
	this->Mime.CharsetWeakPtr = NULL
	
End Sub

Private Sub UnInitializeServerResponse( _
		ByVal this As ServerResponse Ptr _
	)
	
	For i As Integer = 0 To HttpResponseHeadersSize - 1
		HeapSysFreeString(this->ResponseHeaders(i))
	Next
	
	HeapSysFreeString(this->StatusDescription)
	
	If this->ResponseHeaderLine Then
		IMalloc_Free( _
			this->pIMemoryAllocator, _
			this->ResponseHeaderLine _
		)
	End If
	
End Sub

Private Sub ServerResponseCreated( _
		ByVal this As ServerResponse Ptr _
	)
	
End Sub

Private Sub ServerResponseDestroyed( _
		ByVal this As ServerResponse Ptr _
	)
	
End Sub

Private Sub DestroyServerResponse( _
		ByVal this As ServerResponse Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeServerResponse(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	ServerResponseDestroyed(this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Private Function ServerResponseAddRef( _
		ByVal this As ServerResponse Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return 1
	
End Function

Private Function ServerResponseRelease( _
		ByVal this As ServerResponse Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyServerResponse(this)
	
	Return 0
	
End Function

Private Function ServerResponseQueryInterface( _
		ByVal this As ServerResponse Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IServerResponse, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	ServerResponseAddRef(this)
	
	Return S_OK
	
End Function

Public Function CreateServerResponse( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Dim this As ServerResponse Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(ServerResponse) _
	)
	
	If this Then
		InitializeServerResponse(this, pIMemoryAllocator)
		ServerResponseCreated(this)
		
		Dim hrQueryInterface As HRESULT = ServerResponseQueryInterface( _
			this, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyServerResponse(this)
		End If
		
		Return hrQueryInterface
	End If
	
	*ppv = NULL
	Return E_OUTOFMEMORY
	
End Function

Private Function ServerResponseGetHttpVersion( _
		ByVal this As ServerResponse Ptr, _
		ByVal pHttpVersion As HttpVersions Ptr _
	)As HRESULT
	
	*pHttpVersion = this->HttpVersion
	
	Return S_OK
	
End Function

Private Function ServerResponseSetHttpVersion( _
		ByVal this As ServerResponse Ptr, _
		ByVal HttpVersion As HttpVersions _
	)As HRESULT
	
	this->HttpVersion = HttpVersion
	
	Return S_OK
	
End Function

Private Function ServerResponseGetStatusCode( _
		ByVal this As ServerResponse Ptr, _
		ByVal pStatusCode As HttpStatusCodes Ptr _
	)As HRESULT
	
	*pStatusCode = this->StatusCode
	
	Return S_OK
	
End Function

Private Function ServerResponseSetStatusCode( _
		ByVal this As ServerResponse Ptr, _
		ByVal StatusCode As HttpStatusCodes _
	)As HRESULT
	
	this->StatusCode = StatusCode
	
	Return S_OK
	
End Function

Private Function ServerResponseGetStatusDescription( _
		ByVal this As ServerResponse Ptr, _
		ByVal ppStatusDescription As HeapBSTR Ptr _
	)As HRESULT
	
	*ppStatusDescription = this->StatusDescription
	
	Return S_OK
	
End Function

Private Function ServerResponseSetStatusDescription( _
		ByVal this As ServerResponse Ptr, _
		ByVal pStatusDescription As HeapBSTR _
	)As HRESULT
	
	this->StatusDescription = pStatusDescription
	
	Return S_OK
	
End Function

Private Function ServerResponseGetKeepAlive( _
		ByVal this As ServerResponse Ptr, _
		ByVal pKeepAlive As Boolean Ptr _
	)As HRESULT
	
	*pKeepAlive = this->KeepAlive
	
	Return S_OK
	
End Function

Private Function ServerResponseSetKeepAlive( _
		ByVal this As ServerResponse Ptr, _
		ByVal KeepAlive As Boolean _
	)As HRESULT
	
	this->KeepAlive = KeepAlive
	
	Return S_OK
	
End Function

Private Function ServerResponseGetSendOnlyHeaders( _
		ByVal this As ServerResponse Ptr, _
		ByVal pSendOnlyHeaders As Boolean Ptr _
	)As HRESULT
	
	*pSendOnlyHeaders = this->SendOnlyHeaders
	
	Return S_OK
	
End Function

Private Function ServerResponseSetSendOnlyHeaders( _
		ByVal this As ServerResponse Ptr, _
		ByVal SendOnlyHeaders As Boolean _
	)As HRESULT
	
	this->SendOnlyHeaders = SendOnlyHeaders
	
	Return S_OK
	
End Function

Private Function ServerResponseGetMimeType( _
		ByVal this As ServerResponse Ptr, _
		ByVal pMimeType As MimeType Ptr _
	)As HRESULT
	
	*pMimeType = this->Mime
	
	Return S_OK
	
End Function

Private Function ServerResponseSetMimeType( _
		ByVal this As ServerResponse Ptr, _
		ByVal pMimeType As MimeType Ptr _
	)As HRESULT
	
	this->Mime = *pMimeType
	
	Return S_OK
	
End Function

Private Function ServerResponseGetHttpHeader( _
		ByVal this As ServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal ppHeader As HeapBSTR Ptr _
	)As HRESULT
	
	*ppHeader = this->ResponseHeaders(HeaderIndex)
	
	Return S_OK
	
End Function

Private Function ServerResponseSetHttpHeader( _
		ByVal this As ServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal pHeader As HeapBSTR _
	)As HRESULT
	
	this->ResponseHeaders(HeaderIndex) = pHeader
	
	Return S_OK
	
End Function

Private Function ServerResponseGetZipEnabled( _
		ByVal this As ServerResponse Ptr, _
		ByVal pZipEnabled As Boolean Ptr _
	)As HRESULT
	
	*pZipEnabled = this->ResponseZipEnable
	
	Return S_OK
	
End Function

Private Function ServerResponseSetZipEnabled( _
		ByVal this As ServerResponse Ptr, _
		ByVal ZipEnabled As Boolean _
	)As HRESULT
	
	this->ResponseZipEnable = ZipEnabled
	
	Return S_OK
	
End Function

Private Function ServerResponseGetZipMode( _
		ByVal this As ServerResponse Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	
	*pZipMode = this->ResponseZipMode
	
	Return S_OK
	
End Function

Private Function ServerResponseSetZipMode( _
		ByVal this As ServerResponse Ptr, _
		ByVal ZipMode As ZipModes _
	)As HRESULT
	
	this->ResponseZipMode = ZipMode
	
	Return S_OK
	
End Function

Private Function ServerResponseAddKnownResponseHeader( _
		ByVal this As ServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->ResponseHeaders(HeaderIndex), Value)
	
	Return S_OK
	
End Function

Private Function ServerResponseAddResponseHeader( _
		ByVal this As ServerResponse Ptr, _
		ByVal HeaderName As HeapBSTR, _
		ByVal Value As HeapBSTR _
	)As HRESULT
	
	Dim HeaderIndex As HttpResponseHeaders = Any
	Dim Finded As Boolean = GetKnownResponseHeaderIndex(HeaderName, @HeaderIndex)
	If Finded Then
		Dim hrAddHeader As HRESULT = ServerResponseAddKnownResponseHeader( _
			this, _
			HeaderIndex, _
			Value _
		)
		Return hrAddHeader
	End If
	
	Return S_FALSE
	
End Function

Private Function ServerResponseAddKnownResponseHeaderWstrLen( _
		ByVal this As ServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As WString Ptr, _
		ByVal Length As Integer _
	)As HRESULT
	
	Dim hBstr As HeapBSTR = CreateHeapStringLen( _
		this->pIMemoryAllocator, _
		Value, _
		Length _
	)
	If hBstr = NULL Then
		Return E_OUTOFMEMORY
	End If
	
	Dim hr As HRESULT = ServerResponseAddKnownResponseHeader( _
		this, _
		HeaderIndex, _
		hBstr _
	)
	
	HeapSysFreeString(hBstr)
	
	Return hr
	
End Function

Private Function ServerResponseAddKnownResponseHeaderWstr( _
		ByVal this As ServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As WString Ptr _
	)As HRESULT
	
	Dim Length As Integer = lstrlenW(Value)
	
	Dim hr As HRESULT = ServerResponseAddKnownResponseHeaderWstrLen( _
		this, _
		HeaderIndex, _
		Value, _
		Length _
	)
	
	Return hr
	
End Function

Private Function ServerResponseGetByteRange( _
		ByVal this As ServerResponse Ptr, _
		ByVal pOffset As LongInt Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT
	
	*pOffset = this->ByteRangeOffset
	*pLength = this->ByteRangeLength
	
	Return S_OK
	
End Function

Private Function ServerResponseSetByteRange( _
		ByVal this As ServerResponse Ptr, _
		ByVal Offset As LongInt, _
		ByVal Length As LongInt _
	)As HRESULT
	
	this->ByteRangeOffset = Offset
	this->ByteRangeLength = Length
	
	Return S_OK
	
End Function

Private Sub ServerResponsePrintServerHeaders( _
		ByVal this As ServerResponse Ptr _
	)
	
End Sub

Private Function ServerResponseAllHeadersToZString( _
		ByVal this As ServerResponse Ptr, _
		ByVal ContentLength As LongInt, _
		ByVal ppHeaders As ZString Ptr Ptr, _
		ByVal pHeadersLength As LongInt Ptr _
	)As HRESULT
	
	Scope
		Dim hrAddHeader As HRESULT = ServerResponseAddKnownResponseHeaderWstrLen( _
			this, _
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
			this, _
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
			this, _
			HttpResponseHeaders.HeaderServer, _
			@ServerVersionString, _
			CInt(Length) _
		)
		If FAILED(hrAddHeader) Then
			Return hrAddHeader
		End If
	End Scope
	
	If this->KeepAlive Then
		Dim hrAddHeader As HRESULT = ServerResponseAddKnownResponseHeaderWstrLen( _
			this, _
			HttpResponseHeaders.HeaderConnection, _
			@KeepAliveString, _
			Len(KeepAliveString) _
		)
		If FAILED(hrAddHeader) Then
			Return hrAddHeader
		End If
	Else
		Dim hrAddHeader As HRESULT = ServerResponseAddKnownResponseHeaderWstrLen( _
			this, _
			HttpResponseHeaders.HeaderConnection, _
			@CloseString, _
			Len(CloseString) _
		)
		If FAILED(hrAddHeader) Then
			Return hrAddHeader
		End If
	End If
	
	Select Case this->StatusCode
		
		Case HttpStatusCodes.CodeContinue, _
			HttpStatusCodes.SwitchingProtocols, _
			HttpStatusCodes.Processing, _
			HttpStatusCodes.NoContent
			
			ServerResponseAddKnownResponseHeader( _
				this, _
				HttpResponseHeaders.HeaderContentLength, _
				NULL _
			)
			
		Case Else
			Dim strContentLength As WString * (64) = Any
			_i64tow(ContentLength, @strContentLength, 10)
			
			ServerResponseAddKnownResponseHeaderWstr( _
				this, _
				HttpResponseHeaders.HeaderContentLength, _
				@strContentLength _
			)
			
	End Select
	
	Scope
		If this->Mime.ContentType <> ContentTypes.AnyAny Then
			Dim wContentType As WString * (MaxContentTypeLength + 1) = Any
			GetContentTypeOfMimeType(@wContentType, @this->Mime)
			
			ServerResponseAddKnownResponseHeaderWstr( _
				this, _
				HttpResponseHeaders.HeaderContentType, _
				@wContentType _
			)
		End If
	End Scope
	
	Dim pHeadersBuffer As WString Ptr = IMalloc_Alloc( _
		this->pIMemoryAllocator, _
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
				this->HttpVersion, _
				@HttpVersionLength _
			)
			
			Writer.WriteLengthString(pwHttpVersion, HttpVersionLength)
			Writer.WriteChar(Characters.WhiteSpace)
			
			Writer.WriteInt32(this->StatusCode)
			Writer.WriteChar(Characters.WhiteSpace)
			
			If this->StatusDescription = NULL Then
				Dim BufferLength As Integer = Any
				Dim wBuffer As WString Ptr = GetStatusDescription(this->StatusCode, @BufferLength)
				Writer.WriteLengthStringLine(wBuffer, BufferLength)
			Else
				Writer.WriteStringLine(this->StatusDescription)
			End If
		End Scope
		
		Scope
			Dim datNowF As FILETIME = Any
			GetSystemTimeAsFileTime(@datNowF)
			
			Dim datNowS As SYSTEMTIME = Any
			FileTimeToSystemTime(@datNowF, @datNowS)
			
			Dim HttpDate As HeapBSTR = ConvertSystemDateToHttpDate( _
				this->pIMemoryAllocator, _
				@datNowS _
			)
			If HttpDate = NULL Then
				IMalloc_Free(this->pIMemoryAllocator, pHeadersBuffer)
				*ppHeaders = NULL
				*pHeadersLength = 0
				Return E_OUTOFMEMORY
			End If
			
			ServerResponseAddKnownResponseHeader( _
				this, _
				HttpResponseHeaders.HeaderDate, _
				HttpDate _
			)
			
			HeapSysFreeString(HttpDate)
		End Scope
		
		For i As Integer = 0 To HttpResponseHeadersSize - 1
			
			Dim HeaderIndex As HttpResponseHeaders = Cast(HttpResponseHeaders, i)
			
			If this->ResponseHeaders(HeaderIndex) Then
				
				Dim BufferLength As Integer = Any
				Dim wBuffer As WString Ptr = KnownResponseHeaderToString( _
					HeaderIndex, _
					@BufferLength _
				)
				
				Writer.WriteLengthString(wBuffer, BufferLength)
				Writer.WriteLengthString(@ColonWithSpaceString, Len(ColonWithSpaceString))
				Writer.WriteStringLine(this->ResponseHeaders(HeaderIndex))
			End If
			
		Next
		
		Writer.WriteNewLine()
		
		this->ResponseHeaderLineLength = Writer.GetLength()
		
	End Scope
	
	this->ResponseHeaderLine = IMalloc_Alloc( _
		this->pIMemoryAllocator, _
		this->ResponseHeaderLineLength _
	)
	If this->ResponseHeaderLine = NULL Then
		IMalloc_Free(this->pIMemoryAllocator, pHeadersBuffer)
		*ppHeaders = NULL
		*pHeadersLength = 0
		Return E_OUTOFMEMORY
	End If
	
	WideCharToMultiByte( _
		CP_ACP, _
		0, _
		pHeadersBuffer, _
		this->ResponseHeaderLineLength, _
		this->ResponseHeaderLine, _
		this->ResponseHeaderLineLength, _
		0, _
		0 _
	)
	
	ServerResponsePrintServerHeaders(this)
	
	*ppHeaders = this->ResponseHeaderLine
	*pHeadersLength = this->ResponseHeaderLineLength
	
	IMalloc_Free(this->pIMemoryAllocator, pHeadersBuffer)
	
	Return S_OK
	
End Function


Private Function IServerResponseQueryInterface( _
		ByVal this As IServerResponse Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return ServerResponseQueryInterface(ContainerOf(this, ServerResponse, lpVtbl), riid, ppvObject)
End Function

Private Function IServerResponseAddRef( _
		ByVal this As IServerResponse Ptr _
	)As ULONG
	Return ServerResponseAddRef(ContainerOf(this, ServerResponse, lpVtbl))
End Function

Private Function IServerResponseRelease( _
		ByVal this As IServerResponse Ptr _
	)As ULONG
	Return ServerResponseRelease(ContainerOf(this, ServerResponse, lpVtbl))
End Function

Private Function IServerResponseGetHttpVersion( _
		ByVal this As IServerResponse Ptr, _
		ByVal pHttpVersion As HttpVersions Ptr _
	)As HRESULT
	Return ServerResponseGetHttpVersion(ContainerOf(this, ServerResponse, lpVtbl), pHttpVersion)
End Function

Private Function IServerResponseSetHttpVersion( _
		ByVal this As IServerResponse Ptr, _
		ByVal HttpVersion As HttpVersions _
	)As HRESULT
	Return ServerResponseSetHttpVersion(ContainerOf(this, ServerResponse, lpVtbl), HttpVersion)
End Function

Private Function IServerResponseGetStatusCode( _
		ByVal this As IServerResponse Ptr, _
		ByVal pStatusCode As HttpStatusCodes Ptr _
	)As HRESULT
	Return ServerResponseGetStatusCode(ContainerOf(this, ServerResponse, lpVtbl), pStatusCode)
End Function

Private Function IServerResponseSetStatusCode( _
		ByVal this As IServerResponse Ptr, _
		ByVal StatusCode As HttpStatusCodes _
	)As HRESULT
	Return ServerResponseSetStatusCode(ContainerOf(this, ServerResponse, lpVtbl), StatusCode)
End Function

Private Function IServerResponseGetStatusDescription( _
		ByVal this As IServerResponse Ptr, _
		ByVal ppStatusDescription As HeapBSTR Ptr _
	)As HRESULT
	Return ServerResponseGetStatusDescription(ContainerOf(this, ServerResponse, lpVtbl), ppStatusDescription)
End Function

Private Function IServerResponseSetStatusDescription( _
		ByVal this As IServerResponse Ptr, _
		ByVal pStatusDescription As HeapBSTR _
	)As HRESULT
	Return ServerResponseSetStatusDescription(ContainerOf(this, ServerResponse, lpVtbl), pStatusDescription)
End Function

Private Function IServerResponseGetKeepAlive( _
		ByVal this As IServerResponse Ptr, _
		ByVal pKeepAlive As Boolean Ptr _
	)As HRESULT
	Return ServerResponseGetKeepAlive(ContainerOf(this, ServerResponse, lpVtbl), pKeepAlive)
End Function

Private Function IServerResponseSetKeepAlive( _
		ByVal this As IServerResponse Ptr, _
		ByVal KeepAlive As Boolean _
	)As HRESULT
	Return ServerResponseSetKeepAlive(ContainerOf(this, ServerResponse, lpVtbl), KeepAlive)
End Function

Private Function IServerResponseGetSendOnlyHeaders( _
		ByVal this As IServerResponse Ptr, _
		ByVal pSendOnlyHeaders As Boolean Ptr _
	)As HRESULT
	Return ServerResponseGetSendOnlyHeaders(ContainerOf(this, ServerResponse, lpVtbl), pSendOnlyHeaders)
End Function

Private Function IServerResponseSetSendOnlyHeaders( _
		ByVal this As IServerResponse Ptr, _
		ByVal SendOnlyHeaders As Boolean _
	)As HRESULT
	Return ServerResponseSetSendOnlyHeaders(ContainerOf(this, ServerResponse, lpVtbl), SendOnlyHeaders)
End Function

Private Function IServerResponseGetMimeType( _
		ByVal this As IServerResponse Ptr, _
		ByVal pMimeType As MimeType Ptr _
	)As HRESULT
	Return ServerResponseGetMimeType(ContainerOf(this, ServerResponse, lpVtbl), pMimeType)
End Function

Private Function IServerResponseSetMimeType( _
		ByVal this As IServerResponse Ptr, _
		ByVal pMimeType As MimeType Ptr _
	)As HRESULT
	Return ServerResponseSetMimeType(ContainerOf(this, ServerResponse, lpVtbl), pMimeType)
End Function

Private Function IServerResponseGetHttpHeader( _
		ByVal this As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal ppHeader As HeapBSTR Ptr _
	)As HRESULT
	Return ServerResponseGetHttpHeader(ContainerOf(this, ServerResponse, lpVtbl), HeaderIndex, ppHeader)
End Function

Private Function IServerResponseSetHttpHeader( _
		ByVal this As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal pHeader As HeapBSTR _
	)As HRESULT
	Return ServerResponseSetHttpHeader(ContainerOf(this, ServerResponse, lpVtbl), HeaderIndex, pHeader)
End Function

Private Function IServerResponseGetZipEnabled( _
		ByVal this As IServerResponse Ptr, _
		ByVal pZipEnabled As Boolean Ptr _
	)As HRESULT
	Return ServerResponseGetZipEnabled(ContainerOf(this, ServerResponse, lpVtbl), pZipEnabled)
End Function

Private Function IServerResponseSetZipEnabled( _
		ByVal this As IServerResponse Ptr, _
		ByVal ZipEnabled As Boolean _
	)As HRESULT
	Return ServerResponseSetZipEnabled(ContainerOf(this, ServerResponse, lpVtbl), ZipEnabled)
End Function

Private Function IServerResponseGetZipMode( _
		ByVal this As IServerResponse Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	Return ServerResponseGetZipMode(ContainerOf(this, ServerResponse, lpVtbl), pZipMode)
End Function

Private Function IServerResponseSetZipMode( _
		ByVal this As IServerResponse Ptr, _
		ByVal ZipMode As ZipModes _
	)As HRESULT
	Return ServerResponseSetZipMode(ContainerOf(this, ServerResponse, lpVtbl), ZipMode)
End Function

Private Function IServerResponseAddResponseHeader( _
		ByVal this As IServerResponse Ptr, _
		ByVal HeaderName As HeapBSTR, _
		ByVal Value As HeapBSTR _
	)As HRESULT
	Return ServerResponseAddResponseHeader(ContainerOf(this, ServerResponse, lpVtbl), HeaderName, Value)
End Function

Private Function IServerResponseAddKnownResponseHeader( _
		ByVal this As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As HeapBSTR _
	)As HRESULT
	Return ServerResponseAddKnownResponseHeader(ContainerOf(this, ServerResponse, lpVtbl), HeaderIndex, Value)
End Function

Private Function IServerResponseAddKnownResponseHeaderWstr( _
		ByVal this As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As HeapBSTR _
	)As HRESULT
	Return ServerResponseAddKnownResponseHeaderWstr(ContainerOf(this, ServerResponse, lpVtbl), HeaderIndex, Value)
End Function

Private Function IServerResponseGetByteRange( _
		ByVal this As IServerResponse Ptr, _
		ByVal pOffset As LongInt Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT
	Return ServerResponseGetByteRange(ContainerOf(this, ServerResponse, lpVtbl), pOffset, pLength)
End Function

Private Function IServerResponseSetByteRange( _
		ByVal this As IServerResponse Ptr, _
		ByVal Offset As LongInt, _
		ByVal Length As LongInt _
	)As HRESULT
	Return ServerResponseSetByteRange(ContainerOf(this, ServerResponse, lpVtbl), Offset, Length)
End Function

Private Function IServerResponseAddKnownResponseHeaderWstrLen( _
		ByVal this As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As HeapBSTR, _
		ByVal Length As Integer _
	)As HRESULT
	Return ServerResponseAddKnownResponseHeaderWstrLen(ContainerOf(this, ServerResponse, lpVtbl), HeaderIndex, Value, Length)
End Function

Private Function IServerResponseAllHeadersToZString( _
		ByVal this As IServerResponse Ptr, _
		ByVal ContentLength As LongInt, _
		ByVal ppHeaders As ZString Ptr Ptr, _
		ByVal pHeadersLength As LongInt Ptr _
	)As HRESULT
	Return ServerResponseAllHeadersToZString(ContainerOf(this, ServerResponse, lpVtbl), ContentLength, ppHeaders, pHeadersLength)
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
