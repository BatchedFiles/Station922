#include once "Http.bi"
#include once "windows.bi"

Const CompareResultEqual As Long = 0

Type StatusCodeNode
	pDescription As WString Ptr
	DescriptionLength As Integer
	StatusCodeIndex As HttpStatusCodes
End Type

Type CgiHeaderNode
	pHeader As WString Ptr
	HeaderLength As Integer
	HeaderIndex As HttpRequestHeaders
End Type

Dim Shared StatusCodeNodesVector(1 To HttpStatusCodesSize) As StatusCodeNode = { _
	Type<StatusCodeNode>(@HttpStatusCodeString100, Len(HttpStatusCodeString100), HttpStatusCodes.CodeContinue), _
	Type<StatusCodeNode>(@HttpStatusCodeString101, Len(HttpStatusCodeString101), HttpStatusCodes.SwitchingProtocols), _
	Type<StatusCodeNode>(@HttpStatusCodeString102, Len(HttpStatusCodeString102), HttpStatusCodes.Processing), _
	Type<StatusCodeNode>(@HttpStatusCodeString200, Len(HttpStatusCodeString200), HttpStatusCodes.OK), _
	Type<StatusCodeNode>(@HttpStatusCodeString201, Len(HttpStatusCodeString201), HttpStatusCodes.Created), _
	Type<StatusCodeNode>(@HttpStatusCodeString202, Len(HttpStatusCodeString202), HttpStatusCodes.Accepted), _
	Type<StatusCodeNode>(@HttpStatusCodeString203, Len(HttpStatusCodeString203), HttpStatusCodes.NonAuthoritativeInformation), _
	Type<StatusCodeNode>(@HttpStatusCodeString204, Len(HttpStatusCodeString204), HttpStatusCodes.NoContent), _
	Type<StatusCodeNode>(@HttpStatusCodeString205, Len(HttpStatusCodeString205), HttpStatusCodes.ResetContent), _
	Type<StatusCodeNode>(@HttpStatusCodeString206, Len(HttpStatusCodeString206), HttpStatusCodes.PartialContent), _
	Type<StatusCodeNode>(@HttpStatusCodeString207, Len(HttpStatusCodeString207), HttpStatusCodes.MultiStatus), _
	Type<StatusCodeNode>(@HttpStatusCodeString226, Len(HttpStatusCodeString226), HttpStatusCodes.IAmUsed), _
	Type<StatusCodeNode>(@HttpStatusCodeString300, Len(HttpStatusCodeString300), HttpStatusCodes.MultipleChoices), _
	Type<StatusCodeNode>(@HttpStatusCodeString301, Len(HttpStatusCodeString301), HttpStatusCodes.MovedPermanently), _
	Type<StatusCodeNode>(@HttpStatusCodeString302, Len(HttpStatusCodeString302), HttpStatusCodes.Found), _
	Type<StatusCodeNode>(@HttpStatusCodeString303, Len(HttpStatusCodeString303), HttpStatusCodes.SeeOther), _
	Type<StatusCodeNode>(@HttpStatusCodeString304, Len(HttpStatusCodeString304), HttpStatusCodes.NotModified), _
	Type<StatusCodeNode>(@HttpStatusCodeString305, Len(HttpStatusCodeString305), HttpStatusCodes.UseProxy), _
	Type<StatusCodeNode>(@HttpStatusCodeString307, Len(HttpStatusCodeString307), HttpStatusCodes.TemporaryRedirect), _
	Type<StatusCodeNode>(@HttpStatusCodeString400, Len(HttpStatusCodeString400), HttpStatusCodes.BadRequest), _
	Type<StatusCodeNode>(@HttpStatusCodeString401, Len(HttpStatusCodeString401), HttpStatusCodes.Unauthorized), _
	Type<StatusCodeNode>(@HttpStatusCodeString402, Len(HttpStatusCodeString402), HttpStatusCodes.PaymentRequired), _
	Type<StatusCodeNode>(@HttpStatusCodeString403, Len(HttpStatusCodeString403), HttpStatusCodes.Forbidden), _
	Type<StatusCodeNode>(@HttpStatusCodeString404, Len(HttpStatusCodeString404), HttpStatusCodes.NotFound), _
	Type<StatusCodeNode>(@HttpStatusCodeString405, Len(HttpStatusCodeString405), HttpStatusCodes.MethodNotAllowed), _
	Type<StatusCodeNode>(@HttpStatusCodeString406, Len(HttpStatusCodeString406), HttpStatusCodes.NotAcceptable), _
	Type<StatusCodeNode>(@HttpStatusCodeString407, Len(HttpStatusCodeString407), HttpStatusCodes.ProxyAuthenticationRequired), _
	Type<StatusCodeNode>(@HttpStatusCodeString408, Len(HttpStatusCodeString408), HttpStatusCodes.RequestTimeout), _
	Type<StatusCodeNode>(@HttpStatusCodeString409, Len(HttpStatusCodeString409), HttpStatusCodes.Conflict), _
	Type<StatusCodeNode>(@HttpStatusCodeString410, Len(HttpStatusCodeString410), HttpStatusCodes.Gone), _
	Type<StatusCodeNode>(@HttpStatusCodeString411, Len(HttpStatusCodeString411), HttpStatusCodes.LengthRequired), _
	Type<StatusCodeNode>(@HttpStatusCodeString412, Len(HttpStatusCodeString412), HttpStatusCodes.PreconditionFailed), _
	Type<StatusCodeNode>(@HttpStatusCodeString413, Len(HttpStatusCodeString413), HttpStatusCodes.RequestEntityTooLarge), _
	Type<StatusCodeNode>(@HttpStatusCodeString414, Len(HttpStatusCodeString414), HttpStatusCodes.RequestURITooLarge), _
	Type<StatusCodeNode>(@HttpStatusCodeString415, Len(HttpStatusCodeString415), HttpStatusCodes.UnsupportedMediaType), _
	Type<StatusCodeNode>(@HttpStatusCodeString416, Len(HttpStatusCodeString416), HttpStatusCodes.RangeNotSatisfiable), _
	Type<StatusCodeNode>(@HttpStatusCodeString417, Len(HttpStatusCodeString417), HttpStatusCodes.ExpectationFailed), _
	Type<StatusCodeNode>(@HttpStatusCodeString418, Len(HttpStatusCodeString418), HttpStatusCodes.IAmTeapot), _
	Type<StatusCodeNode>(@HttpStatusCodeString422, Len(HttpStatusCodeString422), HttpStatusCodes.UnprocessableEntity), _
	Type<StatusCodeNode>(@HttpStatusCodeString423, Len(HttpStatusCodeString423), HttpStatusCodes.Locked), _
	Type<StatusCodeNode>(@HttpStatusCodeString424, Len(HttpStatusCodeString424), HttpStatusCodes.FailedDependency), _
	Type<StatusCodeNode>(@HttpStatusCodeString425, Len(HttpStatusCodeString425), HttpStatusCodes.UnorderedCollection), _
	Type<StatusCodeNode>(@HttpStatusCodeString426, Len(HttpStatusCodeString426), HttpStatusCodes.UpgradeRequired), _
	Type<StatusCodeNode>(@HttpStatusCodeString428, Len(HttpStatusCodeString428), HttpStatusCodes.PreconditionRequired), _
	Type<StatusCodeNode>(@HttpStatusCodeString429, Len(HttpStatusCodeString429), HttpStatusCodes.TooManyRequests), _
	Type<StatusCodeNode>(@HttpStatusCodeString431, Len(HttpStatusCodeString431), HttpStatusCodes.RequestHeaderFieldsTooLarge), _
	Type<StatusCodeNode>(@HttpStatusCodeString449, Len(HttpStatusCodeString449), HttpStatusCodes.RetryWith), _
	Type<StatusCodeNode>(@HttpStatusCodeString451, Len(HttpStatusCodeString451), HttpStatusCodes.UnavailableForLegalReasons), _
	Type<StatusCodeNode>(@HttpStatusCodeString500, Len(HttpStatusCodeString500), HttpStatusCodes.InternalServerError), _
	Type<StatusCodeNode>(@HttpStatusCodeString501, Len(HttpStatusCodeString501), HttpStatusCodes.NotImplemented), _
	Type<StatusCodeNode>(@HttpStatusCodeString502, Len(HttpStatusCodeString502), HttpStatusCodes.BadGateway), _
	Type<StatusCodeNode>(@HttpStatusCodeString503, Len(HttpStatusCodeString503), HttpStatusCodes.ServiceUnavailable), _
	Type<StatusCodeNode>(@HttpStatusCodeString504, Len(HttpStatusCodeString504), HttpStatusCodes.GatewayTimeout), _
	Type<StatusCodeNode>(@HttpStatusCodeString505, Len(HttpStatusCodeString505), HttpStatusCodes.HTTPVersionNotSupported), _
	Type<StatusCodeNode>(@HttpStatusCodeString506, Len(HttpStatusCodeString506), HttpStatusCodes.VariantAlsoNegotiates), _
	Type<StatusCodeNode>(@HttpStatusCodeString507, Len(HttpStatusCodeString507), HttpStatusCodes.InsufficientStorage), _
	Type<StatusCodeNode>(@HttpStatusCodeString508, Len(HttpStatusCodeString508), HttpStatusCodes.LoopDetected), _
	Type<StatusCodeNode>(@HttpStatusCodeString509, Len(HttpStatusCodeString509), HttpStatusCodes.BandwidthLimitExceeded), _
	Type<StatusCodeNode>(@HttpStatusCodeString510, Len(HttpStatusCodeString510), HttpStatusCodes.NotExtended), _
	Type<StatusCodeNode>(@HttpStatusCodeString511, Len(HttpStatusCodeString511), HttpStatusCodes.NetworkAuthenticationRequired) _
}

Dim Shared CgiHeaderNodesVector(1 To HttpRequestHeadersSize) As CgiHeaderNode = { _
	Type<CgiHeaderNode>(@WStr("HTTP_ACCEPT"),                    11, HttpRequestHeaders.HeaderAccept), _
	Type<CgiHeaderNode>(@WStr("HTTP_ACCEPT_CHARSET"),            19, HttpRequestHeaders.HeaderAcceptCharset), _
	Type<CgiHeaderNode>(@WStr("HTTP_ACCEPT_ENCODING"),           20, HttpRequestHeaders.HeaderAcceptEncoding), _
	Type<CgiHeaderNode>(@WStr("HTTP_ACCEPT_LANGUAGE"),           20, HttpRequestHeaders.HeaderAcceptLanguage), _
	Type<CgiHeaderNode>(@WStr("AUTH_TYPE"),                      9,  HttpRequestHeaders.HeaderAuthorization), _
	Type<CgiHeaderNode>(@WStr("HTTP_CACHE_CONTROL"),             18, HttpRequestHeaders.HeaderCacheControl), _
	Type<CgiHeaderNode>(@WStr("HTTP_CONNECTION"),                15, HttpRequestHeaders.HeaderConnection), _
	Type<CgiHeaderNode>(@WStr("HTTP_CONTENT_ENCODING"),          21, HttpRequestHeaders.HeaderContentEncoding), _
	Type<CgiHeaderNode>(@WStr("HTTP_CONTENT_LANGUAGE"),          21, HttpRequestHeaders.HeaderContentLanguage), _
	Type<CgiHeaderNode>(@WStr("CONTENT_LENGTH"),                 14, HttpRequestHeaders.HeaderContentLength), _
	Type<CgiHeaderNode>(@WStr("HTTP_CONTENT_MD5"),               16, HttpRequestHeaders.HeaderContentMd5), _
	Type<CgiHeaderNode>(@WStr("HTTP_CONTENT_RANGE"),             18, HttpRequestHeaders.HeaderContentRange), _
	Type<CgiHeaderNode>(@WStr("CONTENT_TYPE"),                   12, HttpRequestHeaders.HeaderContentType), _
	Type<CgiHeaderNode>(@WStr("HTTP_COOKIE"),                    11, HttpRequestHeaders.HeaderCookie), _
	Type<CgiHeaderNode>(@WStr("HTTP_DNT"),                       8,  HttpRequestHeaders.HeaderDNT), _
	Type<CgiHeaderNode>(@WStr("HTTP_EXPECT"),                    11, HttpRequestHeaders.HeaderExpect), _
	Type<CgiHeaderNode>(@WStr("HTTP_FROM"),                      9,  HttpRequestHeaders.HeaderFrom), _
	Type<CgiHeaderNode>(@WStr("HTTP_HOST"),                      9,  HttpRequestHeaders.HeaderHost), _
	Type<CgiHeaderNode>(@WStr("HTTP_IF_MATCH"),                  13, HttpRequestHeaders.HeaderIfMatch), _
	Type<CgiHeaderNode>(@WStr("HTTP_IF_MODIFIED_SINCE"),         22, HttpRequestHeaders.HeaderIfModifiedSince), _
	Type<CgiHeaderNode>(@WStr("HTTP_IF_NONE_MATCH"),             18, HttpRequestHeaders.HeaderIfNoneMatch), _
	Type<CgiHeaderNode>(@WStr("HTTP_IF_RANGE"),                  13, HttpRequestHeaders.HeaderIfRange), _
	Type<CgiHeaderNode>(@WStr("HTTP_IF_UNMODIFIED_SINCE"),       24, HttpRequestHeaders.HeaderIfUnModifiedSince), _
	Type<CgiHeaderNode>(@WStr("HTTP_KEEP_ALIVE"),                15, HttpRequestHeaders.HeaderKeepAlive), _
	Type<CgiHeaderNode>(@WStr("HTTP_MAX_FORWARDS"),              17, HttpRequestHeaders.HeaderMaxForwards), _
	Type<CgiHeaderNode>(@WStr("HTTP_ORIGIN"),                    11, HttpRequestHeaders.HeaderOrigin), _
	Type<CgiHeaderNode>(@WStr("HTTP_PRAGMA"),                    11, HttpRequestHeaders.HeaderPragma), _
	Type<CgiHeaderNode>(@WStr("HTTP_PROXY_AUTHORIZATION"),       24, HttpRequestHeaders.HeaderProxyAuthorization), _
	Type<CgiHeaderNode>(@WStr("HTTP_RANGE"),                     10, HttpRequestHeaders.HeaderRange), _
	Type<CgiHeaderNode>(@WStr("HTTP_REFERER"),                   12, HttpRequestHeaders.HeaderReferer), _
	Type<CgiHeaderNode>(@WStr("HTTP_SEC_WEBSOCKET_KEY"),         22, HttpRequestHeaders.HeaderSecWebSocketKey), _
	Type<CgiHeaderNode>(@WStr("HTTP_SEC_WEBSOCKET_KEY1"),        23, HttpRequestHeaders.HeaderSecWebSocketKey1), _
	Type<CgiHeaderNode>(@WStr("HTTP_SEC_WEBSOCKET_KEY2"),        23, HttpRequestHeaders.HeaderSecWebSocketKey2), _
	Type<CgiHeaderNode>(@WStr("HTTP_SEC_WEBSOCKET_VERSION"),     26, HttpRequestHeaders.HeaderSecWebSocketVersion), _
	Type<CgiHeaderNode>(@WStr("HTTP_TE"),                        7,  HttpRequestHeaders.HeaderTe), _
	Type<CgiHeaderNode>(@WStr("HTTP_TRAILER"),                   12, HttpRequestHeaders.HeaderTrailer), _
	Type<CgiHeaderNode>(@WStr("HTTP_TRANSFER_ENCODING"),         22, HttpRequestHeaders.HeaderTransferEncoding), _
	Type<CgiHeaderNode>(@WStr("HTTP_UPGRADE"),                   12, HttpRequestHeaders.HeaderUpgrade), _
	Type<CgiHeaderNode>(@WStr("HTTP_UPGRADE_INSECURE_REQUESTS"), 30, HttpRequestHeaders.HeaderUpgradeInsecureRequests), _
	Type<CgiHeaderNode>(@WStr("HTTP_USER_AGENT"),                15, HttpRequestHeaders.HeaderUserAgent), _
	Type<CgiHeaderNode>(@WStr("HTTP_VIA"),                       8,  HttpRequestHeaders.HeaderVia), _
	Type<CgiHeaderNode>(@WStr("HTTP_WARNING"),                   12, HttpRequestHeaders.HeaderWarning), _
	Type<CgiHeaderNode>(@WStr("HTTP_WEBSOCKET_PROTOCOL"),        23, HttpRequestHeaders.HeaderWebSocketProtocol) _
}

Function GetStatusDescription( _
		ByVal StatusCode As HttpStatusCodes, _
		ByVal pDescriptionLength As Integer Ptr _
	)As WString Ptr
	
	Dim pDescription As WString Ptr = NULL
	Dim DescriptionLength As Integer = 0
	
	For i As Integer = 1 To HttpStatusCodesSize
		If StatusCodeNodesVector(i).StatusCodeIndex = StatusCode Then
			DescriptionLength = StatusCodeNodesVector(i).DescriptionLength
			pDescription = StatusCodeNodesVector(i).pDescription
			Exit For
		End If
	Next
	
	If pDescriptionLength Then
		*pDescriptionLength = DescriptionLength
	End If
	
	Return pDescription
	
End Function

Function KnownRequestCgiHeaderToString( _
		ByVal HeaderIndex As HttpRequestHeaders, _
		ByVal pHeaderLength As Integer Ptr _
	)As WString Ptr
	
	Dim pHeader As WString Ptr = NULL
	Dim HeaderLength As Integer = 0
	
	For i As Integer = 1 To HttpRequestHeadersSize
		If CgiHeaderNodesVector(i).HeaderIndex = HeaderIndex Then
			HeaderLength = CgiHeaderNodesVector(i).HeaderLength
			pHeader = CgiHeaderNodesVector(i).pHeader
			Exit For
		End If
	Next
	
	If pHeaderLength Then
		*pHeaderLength = HeaderLength
	End If
	
	Return pHeader
	
End Function
