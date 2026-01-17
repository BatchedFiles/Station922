#include once "Http.bi"

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
	Type<CgiHeaderNode>(@CgiHeaderAcceptString,                  Len(CgiHeaderAcceptString), HttpRequestHeaders.HeaderAccept), _
	Type<CgiHeaderNode>(@CgiHeaderAcceptCharsetString,           Len(CgiHeaderAcceptCharsetString), HttpRequestHeaders.HeaderAcceptCharset), _
	Type<CgiHeaderNode>(@CgiHeaderAcceptEncodingString,          Len(CgiHeaderAcceptEncodingString), HttpRequestHeaders.HeaderAcceptEncoding), _
	Type<CgiHeaderNode>(@CgiHeaderAcceptLanguageString,          Len(CgiHeaderAcceptLanguageString), HttpRequestHeaders.HeaderAcceptLanguage), _
	Type<CgiHeaderNode>(@CgiHeaderAuthorizationString,           Len(CgiHeaderAuthorizationString), HttpRequestHeaders.HeaderAuthorization), _
	Type<CgiHeaderNode>(@CgiHeaderCacheControlString,            Len(CgiHeaderCacheControlString), HttpRequestHeaders.HeaderCacheControl), _
	Type<CgiHeaderNode>(@CgiHeaderConnectionString,              Len(CgiHeaderConnectionString), HttpRequestHeaders.HeaderConnection), _
	Type<CgiHeaderNode>(@CgiHeaderContentEncodingString,         Len(CgiHeaderContentEncodingString), HttpRequestHeaders.HeaderContentEncoding), _
	Type<CgiHeaderNode>(@CgiHeaderContentLanguageString,         Len(CgiHeaderContentLanguageString), HttpRequestHeaders.HeaderContentLanguage), _
	Type<CgiHeaderNode>(@CgiHeaderContentLengthString,           Len(CgiHeaderContentLengthString), HttpRequestHeaders.HeaderContentLength), _
	Type<CgiHeaderNode>(@CgiHeaderContentMd5String,              Len(CgiHeaderContentMd5String), HttpRequestHeaders.HeaderContentMd5), _
	Type<CgiHeaderNode>(@CgiHeaderContentRangeString,            Len(CgiHeaderContentRangeString), HttpRequestHeaders.HeaderContentRange), _
	Type<CgiHeaderNode>(@CgiHeaderContentTypeString,             Len(CgiHeaderContentTypeString), HttpRequestHeaders.HeaderContentType), _
	Type<CgiHeaderNode>(@CgiHeaderCookieString,                  Len(CgiHeaderCookieString), HttpRequestHeaders.HeaderCookie), _
	Type<CgiHeaderNode>(@CgiHeaderDNTString,                     Len(CgiHeaderDNTString), HttpRequestHeaders.HeaderDNT), _
	Type<CgiHeaderNode>(@CgiHeaderExpectString,                  Len(CgiHeaderExpectString), HttpRequestHeaders.HeaderExpect), _
	Type<CgiHeaderNode>(@CgiHeaderFromString,                    Len(CgiHeaderFromString), HttpRequestHeaders.HeaderFrom), _
	Type<CgiHeaderNode>(@CgiHeaderHostString,                    Len(CgiHeaderHostString), HttpRequestHeaders.HeaderHost), _
	Type<CgiHeaderNode>(@CgiHeaderIfMatchString,                 Len(CgiHeaderIfMatchString), HttpRequestHeaders.HeaderIfMatch), _
	Type<CgiHeaderNode>(@CgiHeaderIfModifiedSinceString,         Len(CgiHeaderIfModifiedSinceString), HttpRequestHeaders.HeaderIfModifiedSince), _
	Type<CgiHeaderNode>(@CgiHeaderIfNoneMatchString,             Len(CgiHeaderIfNoneMatchString), HttpRequestHeaders.HeaderIfNoneMatch), _
	Type<CgiHeaderNode>(@CgiHeaderIfRangeString,                 Len(CgiHeaderIfRangeString), HttpRequestHeaders.HeaderIfRange), _
	Type<CgiHeaderNode>(@CgiHeaderIfUnmodifiedSinceString,       Len(CgiHeaderIfUnmodifiedSinceString), HttpRequestHeaders.HeaderIfUnModifiedSince), _
	Type<CgiHeaderNode>(@CgiHeaderKeepAliveString,               Len(CgiHeaderKeepAliveString), HttpRequestHeaders.HeaderKeepAlive), _
	Type<CgiHeaderNode>(@CgiHeaderMaxForwardsString,             Len(CgiHeaderMaxForwardsString), HttpRequestHeaders.HeaderMaxForwards), _
	Type<CgiHeaderNode>(@CgiHeaderOriginString,                  Len(CgiHeaderOriginString), HttpRequestHeaders.HeaderOrigin), _
	Type<CgiHeaderNode>(@CgiHeaderPragmaString,                  Len(CgiHeaderPragmaString), HttpRequestHeaders.HeaderPragma), _
	Type<CgiHeaderNode>(@CgiHeaderProxyAuthorizationString,      Len(CgiHeaderProxyAuthorizationString), HttpRequestHeaders.HeaderProxyAuthorization), _
	Type<CgiHeaderNode>(@CgiHeaderRangeString,                   Len(CgiHeaderRangeString), HttpRequestHeaders.HeaderRange), _
	Type<CgiHeaderNode>(@CgiHeaderRefererString,                 Len(CgiHeaderRefererString), HttpRequestHeaders.HeaderReferer), _
	Type<CgiHeaderNode>(@CgiHeaderSecWebSocketKeyString,         Len(CgiHeaderSecWebSocketKeyString), HttpRequestHeaders.HeaderSecWebSocketKey), _
	Type<CgiHeaderNode>(@CgiHeaderSecWebSocketKey1String,        Len(CgiHeaderSecWebSocketKey1String), HttpRequestHeaders.HeaderSecWebSocketKey1), _
	Type<CgiHeaderNode>(@CgiHeaderSecWebSocketKey2String,        Len(CgiHeaderSecWebSocketKey2String), HttpRequestHeaders.HeaderSecWebSocketKey2), _
	Type<CgiHeaderNode>(@CgiHeaderSecWebSocketVersionString,     Len(CgiHeaderSecWebSocketVersionString), HttpRequestHeaders.HeaderSecWebSocketVersion), _
	Type<CgiHeaderNode>(@CgiHeaderTeString,                      Len(CgiHeaderTeString), HttpRequestHeaders.HeaderTe), _
	Type<CgiHeaderNode>(@CgiHeaderTrailerString,                 Len(CgiHeaderTrailerString), HttpRequestHeaders.HeaderTrailer), _
	Type<CgiHeaderNode>(@CgiHeaderTransferEncodingString,        Len(CgiHeaderTransferEncodingString), HttpRequestHeaders.HeaderTransferEncoding), _
	Type<CgiHeaderNode>(@CgiHeaderUpgradeString,                 Len(CgiHeaderUpgradeString), HttpRequestHeaders.HeaderUpgrade), _
	Type<CgiHeaderNode>(@CgiHeaderUpgradeInsecureRequestsString, Len(CgiHeaderUpgradeInsecureRequestsString), HttpRequestHeaders.HeaderUpgradeInsecureRequests), _
	Type<CgiHeaderNode>(@CgiHeaderUserAgentString,               Len(CgiHeaderUserAgentString), HttpRequestHeaders.HeaderUserAgent), _
	Type<CgiHeaderNode>(@CgiHeaderViaString,                     Len(CgiHeaderViaString), HttpRequestHeaders.HeaderVia), _
	Type<CgiHeaderNode>(@CgiHeaderWarningString,                 Len(CgiHeaderWarningString), HttpRequestHeaders.HeaderWarning), _
	Type<CgiHeaderNode>(@CgiHeaderWebSocketProtocolString,       Len(CgiHeaderWebSocketProtocolString), HttpRequestHeaders.HeaderWebSocketProtocol) _
}

Public Function GetStatusDescription( _
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

Public Function KnownRequestCgiHeaderToString( _
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
