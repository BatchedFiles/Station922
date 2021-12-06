#include once "Http.bi"
#include once "windows.bi"

Const HttpVersion10String = WStr("HTTP/1.0")
Const HttpVersion11String = WStr("HTTP/1.1")

Const HttpVersion10StringLength As Integer = 8
Const HttpVersion11StringLength As Integer = 8

Const HttpMethodCopy =     WStr("COPY")
Const HttpMethodConnect =  WStr("CONNECT")
Const HttpMethodDelete =   WStr("DELETE")
Const HttpMethodGet =      WStr("GET")
Const HttpMethodHead =     WStr("HEAD")
Const HttpMethodMove =     WStr("MOVE")
Const HttpMethodOptions =  WStr("OPTIONS")
Const HttpMethodPatch =    WStr("PATCH")
Const HttpMethodPost =     WStr("POST")
Const HttpMethodPropfind = WStr("PROPFIND")
Const HttpMethodPut =      WStr("PUT")
Const HttpMethodTrace =    WStr("TRACE")

Const HttpMethodCopyLength As Integer =     4
Const HttpMethodConnectLength As Integer =  7
Const HttpMethodDeleteLength As Integer =   6
Const HttpMethodGetLength As Integer =      3
Const HttpMethodHeadLength As Integer =     4
Const HttpMethodMoveLength As Integer =     4
Const HttpMethodOptionsLength As Integer =  7
Const HttpMethodPatchLength As Integer =    5
Const HttpMethodPostLength As Integer =     4
Const HttpMethodPropfindLength As Integer = 8
Const HttpMethodPutLength As Integer =      3
Const HttpMethodTraceLength As Integer =    5

Const HeaderAcceptString =             WStr("Accept")
Const HeaderAcceptCharsetString =      WStr("Accept-Charset")
Const HeaderAcceptEncodingString =     WStr("Accept-Encoding")
Const HeaderAcceptLanguageString =     WStr("Accept-Language")
Const HeaderAcceptRangesString =       WStr("Accept-Ranges")
Const HeaderAgeString =                WStr("Age")
Const HeaderAllowString =              WStr("Allow")
Const HeaderAuthorizationString =      WStr("Authorization")
Const HeaderCacheControlString =       WStr("Cache-Control")
Const HeaderConnectionString =         WStr("Connection")
Const HeaderContentEncodingString =    WStr("Content-Encoding")
Const HeaderContentLanguageString =    WStr("Content-Language")
Const HeaderContentLengthString =      WStr("Content-Length")
Const HeaderContentLocationString =    WStr("Content-Location")
Const HeaderContentMd5String =         WStr("Content-MD5")
Const HeaderContentTypeString =        WStr("Content-Type")
Const HeaderContentRangeString =       WStr("Content-Range")
Const HeaderCookieString =             WStr("Cookie")
Const HeaderDateString =               WStr("Date")
Const HeaderDNTString =                WStr("DNT")
Const HeaderETagString =               WStr("ETag")
Const HeaderExpectString =             WStr("Expect")
Const HeaderExpiresString =            WStr("Expires")
Const HeaderFromString =               WStr("From")
Const HeaderHostString =               WStr("Host")
Const HeaderIfMatchString =            WStr("If-Match")
Const HeaderIfModifiedSinceString =    WStr("If-Modified-Since")
Const HeaderIfNoneMatchString =        WStr("If-None-Match")
Const HeaderIfRangeString =            WStr("If-Range")
Const HeaderIfUnmodifiedSinceString =  WStr("If-Unmodified-Since")
Const HeaderKeepAliveString =          WStr("Keep-Alive")
Const HeaderLastModifiedString =       WStr("Last-Modified")
Const HeaderLocationString =           WStr("Location")
Const HeaderMaxForwardsString =        WStr("Max-Forwards")
Const HeaderOriginString =             WStr("Origin")
Const HeaderPragmaString =             WStr("Pragma")
Const HeaderProxyAuthenticateString =  WStr("Proxy-Authenticate")
Const HeaderProxyAuthorizationString = WStr("Proxy-Authorization")
Const HeaderRangeString =              WStr("Range")
Const HeaderRefererString =            WStr("Referer")
Const HeaderRetryAfterString =         WStr("Retry-After")
Const HeaderSecWebSocketAcceptString = WStr("Sec-WebSocket-Accept")
Const HeaderSecWebSocketKeyString =    WStr("Sec-WebSocket-Key")
Const HeaderSecWebSocketKey1String =   WStr("Sec-WebSocket-Key1")
Const HeaderSecWebSocketKey2String =   WStr("Sec-WebSocket-Key2")
Const HeaderSecWebSocketLocationString = WStr("Sec-WebSocket-Location")
Const HeaderSecWebSocketOriginString =   WStr("Sec-WebSocket-Origin")
Const HeaderSecWebSocketProtocolString = WStr("Sec-WebSocket-Protocol")
Const HeaderSecWebSocketVersionString = WStr("Sec-WebSocket-Version")
Const HeaderServerString =             WStr("Server")
Const HeaderSetCookieString =          WStr("Set-Cookie")
Const HeaderTeString =                 WStr("TE")
Const HeaderTrailerString =            WStr("Trailer")
Const HeaderTransferEncodingString =   WStr("Transfer-Encoding")
Const HeaderUpgradeString =            WStr("Upgrade")
Const HeaderUpgradeInsecureRequestsString = WStr("Upgrade-Insecure-Requests")
Const HeaderUserAgentString =          WStr("User-Agent")
Const HeaderVaryString =               WStr("Vary")
Const HeaderViaString =                WStr("Via")
Const HeaderWarningString =            WStr("Warning")
Const HeaderWebSocketLocationString =  WStr("WebSocket-Location")
Const HeaderWebSocketOriginString =    WStr("WebSocket-Origin")
Const HeaderWebSocketProtocolString =  WStr("WebSocket-Protocol")
Const HeaderWWWAuthenticateString =    WStr("WWW-Authenticate")

Const HttpStatusCodeString100 = WStr("Continue")
Const HttpStatusCodeString101 = WStr("Switching Protocols")
Const HttpStatusCodeString102 = WStr("Processing")

Const HttpStatusCodeString200 = WStr("OK")
Const HttpStatusCodeString201 = WStr("Created")
Const HttpStatusCodeString202 = WStr("Accepted")
Const HttpStatusCodeString203 = WStr("Non-Authoritative Information")
Const HttpStatusCodeString204 = WStr("No Content")
Const HttpStatusCodeString205 = WStr("Reset Content")
Const HttpStatusCodeString206 = WStr("Partial Content")
Const HttpStatusCodeString207 = WStr("Multi-Status")
Const HttpStatusCodeString226 = WStr("IM Used")

Const HttpStatusCodeString300 = WStr("Multiple Choices")
Const HttpStatusCodeString301 = WStr("Moved Permanently")
Const HttpStatusCodeString302 = WStr("Found")
Const HttpStatusCodeString303 = WStr("See Other")
Const HttpStatusCodeString304 = WStr("Not Modified")
Const HttpStatusCodeString305 = WStr("Use Proxy")
Const HttpStatusCodeString307 = WStr("Temporary Redirect")

Const HttpStatusCodeString400 = WStr("Bad Request")
Const HttpStatusCodeString401 = WStr("Unauthorized")
Const HttpStatusCodeString402 = WStr("Payment Required")
Const HttpStatusCodeString403 = WStr("Forbidden")
Const HttpStatusCodeString404 = WStr("Not Found")
Const HttpStatusCodeString405 = WStr("Method Not Allowed")
Const HttpStatusCodeString406 = WStr("Not Acceptable")
Const HttpStatusCodeString407 = WStr("Proxy Authentication Required")
Const HttpStatusCodeString408 = WStr("Request Timeout")
Const HttpStatusCodeString409 = WStr("Conflict")
Const HttpStatusCodeString410 = WStr("Gone")
Const HttpStatusCodeString411 = WStr("Length Required")
Const HttpStatusCodeString412 = WStr("Precondition Failed")
Const HttpStatusCodeString413 = WStr("Request Entity Too Large")
Const HttpStatusCodeString414 = WStr("Request-URI Too Large")
Const HttpStatusCodeString415 = WStr("Unsupported Media Type")
Const HttpStatusCodeString416 = WStr("Requested Range Not Satisfiable")
Const HttpStatusCodeString417 = WStr("Expectation Failed")
Const HttpStatusCodeString418 = WStr("I am a teapot")
Const HttpStatusCodeString422 = WStr("Unprocessable Entity")
Const HttpStatusCodeString423 = WStr("Locked")
Const HttpStatusCodeString424 = WStr("Failed Dependency")
Const HttpStatusCodeString425 = WStr("Unordered Collection")
Const HttpStatusCodeString426 = WStr("Upgrade Required")
Const HttpStatusCodeString428 = WStr("Precondition Required")
Const HttpStatusCodeString429 = WStr("Too Many Requests")
Const HttpStatusCodeString431 = WStr("Request Header Fields Too Large")
Const HttpStatusCodeString449 = WStr("Retry With")
Const HttpStatusCodeString451 = WStr("Unavailable For Legal Reasons")

Const HttpStatusCodeString500 = WStr("Internal Server Error")
Const HttpStatusCodeString501 = WStr("Not Implemented")
Const HttpStatusCodeString502 = WStr("Bad Gateway")
Const HttpStatusCodeString503 = WStr("Service Unavailable")
Const HttpStatusCodeString504 = WStr("Gateway Timeout")
Const HttpStatusCodeString505 = WStr("HTTP Version Not Supported")
Const HttpStatusCodeString506 = WStr("Variant Also Negotiates")
Const HttpStatusCodeString507 = WStr("Insufficient Storage")
Const HttpStatusCodeString508 = WStr("Loop Detected")
Const HttpStatusCodeString509 = WStr("Bandwidth Limit Exceeded")
Const HttpStatusCodeString510 = WStr("Not Extended")
Const HttpStatusCodeString511 = WStr("Network Authentication Required")

Type StatusCodeNode
	pDescription As WString Ptr
	DescriptionLength As Integer
	StatusCodeIndex As HttpStatusCodes
End Type

Type RequestHeaderNode
	pHeader As WString Ptr
	HeaderLength As Integer
	HeaderIndex As HttpRequestHeaders
End Type

Type ResponseHeaderNode
	pHeader As WString Ptr
	HeaderLength As Integer
	HeaderIndex As HttpResponseHeaders
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

Dim Shared RequestHeaderNodesVector(1 To HttpRequestHeadersSize) As RequestHeaderNode = { _
	Type<RequestHeaderNode>(@HeaderHostString,                    Len(HeaderHostString),                    HttpRequestHeaders.HeaderHost), _
	Type<RequestHeaderNode>(@HeaderAcceptLanguageString,          Len(HeaderAcceptLanguageString),          HttpRequestHeaders.HeaderAcceptLanguage), _
	Type<RequestHeaderNode>(@HeaderUserAgentString,               Len(HeaderUserAgentString),               HttpRequestHeaders.HeaderUserAgent), _
	Type<RequestHeaderNode>(@HeaderAcceptEncodingString,          Len(HeaderAcceptEncodingString),          HttpRequestHeaders.HeaderAcceptEncoding), _
	Type<RequestHeaderNode>(@HeaderAcceptString,                  Len(HeaderAcceptString),                  HttpRequestHeaders.HeaderAccept), _
	Type<RequestHeaderNode>(@HeaderConnectionString,              Len(HeaderConnectionString),              HttpRequestHeaders.HeaderConnection), _
	Type<RequestHeaderNode>(@HeaderCacheControlString,            Len(HeaderCacheControlString),            HttpRequestHeaders.HeaderCacheControl), _
	Type<RequestHeaderNode>(@HeaderIfModifiedSinceString,         Len(HeaderIfModifiedSinceString),         HttpRequestHeaders.HeaderIfModifiedSince), _
	Type<RequestHeaderNode>(@HeaderRefererString,                 Len(HeaderRefererString),                 HttpRequestHeaders.HeaderReferer), _
	Type<RequestHeaderNode>(@HeaderIfNoneMatchString,             Len(HeaderIfNoneMatchString),             HttpRequestHeaders.HeaderIfNoneMatch), _
	Type<RequestHeaderNode>(@HeaderDNTString,                     Len(HeaderDNTString),                     HttpRequestHeaders.HeaderDNT), _
	Type<RequestHeaderNode>(@HeaderUpgradeInsecureRequestsString, Len(HeaderUpgradeInsecureRequestsString), HttpRequestHeaders.HeaderUpgradeInsecureRequests), _
	Type<RequestHeaderNode>(@HeaderRangeString,                   Len(HeaderRangeString),                   HttpRequestHeaders.HeaderRange), _
	Type<RequestHeaderNode>(@HeaderAuthorizationString,           Len(HeaderAuthorizationString),           HttpRequestHeaders.HeaderAuthorization), _
	Type<RequestHeaderNode>(@HeaderContentLengthString,           Len(HeaderContentLengthString),           HttpRequestHeaders.HeaderContentLength), _
	Type<RequestHeaderNode>(@HeaderContentTypeString,             Len(HeaderContentTypeString),             HttpRequestHeaders.HeaderContentType), _
	Type<RequestHeaderNode>(@HeaderCookieString,                  Len(HeaderCookieString),                  HttpRequestHeaders.HeaderCookie), _
	Type<RequestHeaderNode>(@HeaderContentLanguageString,         Len(HeaderContentLanguageString),         HttpRequestHeaders.HeaderContentLanguage), _
	Type<RequestHeaderNode>(@HeaderAcceptCharsetString,           Len(HeaderAcceptCharsetString),           HttpRequestHeaders.HeaderAcceptCharset), _
	Type<RequestHeaderNode>(@HeaderContentEncodingString,         Len(HeaderContentEncodingString),         HttpRequestHeaders.HeaderContentEncoding), _
	Type<RequestHeaderNode>(@HeaderKeepAliveString,               Len(HeaderKeepAliveString),               HttpRequestHeaders.HeaderKeepAlive), _
	Type<RequestHeaderNode>(@HeaderExpectString,                  Len(HeaderExpectString),                  HttpRequestHeaders.HeaderExpect), _
	Type<RequestHeaderNode>(@HeaderContentMd5String,              Len(HeaderContentMd5String),              HttpRequestHeaders.HeaderContentMd5), _
	Type<RequestHeaderNode>(@HeaderContentRangeString,            Len(HeaderContentRangeString),            HttpRequestHeaders.HeaderContentRange), _
	Type<RequestHeaderNode>(@HeaderFromString,                    Len(HeaderFromString),                    HttpRequestHeaders.HeaderFrom), _
	Type<RequestHeaderNode>(@HeaderIfMatchString,                 Len(HeaderIfMatchString),                 HttpRequestHeaders.HeaderIfMatch), _
	Type<RequestHeaderNode>(@HeaderIfRangeString,                 Len(HeaderIfRangeString),                 HttpRequestHeaders.HeaderIfRange), _
	Type<RequestHeaderNode>(@HeaderIfUnmodifiedSinceString,       Len(HeaderIfUnmodifiedSinceString),       HttpRequestHeaders.HeaderIfUnmodifiedSince), _
	Type<RequestHeaderNode>(@HeaderMaxForwardsString,             Len(HeaderMaxForwardsString),             HttpRequestHeaders.HeaderMaxForwards), _
	Type<RequestHeaderNode>(@HeaderOriginString,                  Len(HeaderOriginString),                  HttpRequestHeaders.HeaderOrigin), _
	Type<RequestHeaderNode>(@HeaderPragmaString,                  Len(HeaderPragmaString),                  HttpRequestHeaders.HeaderPragma), _
	Type<RequestHeaderNode>(@HeaderProxyAuthorizationString,      Len(HeaderProxyAuthorizationString),      HttpRequestHeaders.HeaderProxyAuthorization), _
	Type<RequestHeaderNode>(@HeaderSecWebSocketKeyString,         Len(HeaderSecWebSocketKeyString),         HttpRequestHeaders.HeaderSecWebSocketKey), _
	Type<RequestHeaderNode>(@HeaderSecWebSocketKey1String,        Len(HeaderSecWebSocketKey1String),        HttpRequestHeaders.HeaderSecWebSocketKey1), _
	Type<RequestHeaderNode>(@HeaderSecWebSocketKey2String,        Len(HeaderSecWebSocketKey2String),        HttpRequestHeaders.HeaderSecWebSocketKey2), _
	Type<RequestHeaderNode>(@HeaderUpgradeString,                 Len(HeaderUpgradeString),                 HttpRequestHeaders.HeaderUpgrade), _
	Type<RequestHeaderNode>(@HeaderSecWebSocketVersionString,     Len(HeaderSecWebSocketVersionString),     HttpRequestHeaders.HeaderSecWebSocketVersion), _
	Type<RequestHeaderNode>(@HeaderTeString,                      Len(HeaderTeString),                      HttpRequestHeaders.HeaderTe), _
	Type<RequestHeaderNode>(@HeaderTrailerString,                 Len(HeaderTrailerString),                 HttpRequestHeaders.HeaderTrailer), _
	Type<RequestHeaderNode>(@HeaderTransferEncodingString,        Len(HeaderTransferEncodingString),        HttpRequestHeaders.HeaderTransferEncoding), _
	Type<RequestHeaderNode>(@HeaderViaString,                     Len(HeaderViaString),                     HttpRequestHeaders.HeaderVia), _
	Type<RequestHeaderNode>(@HeaderWarningString,                 Len(HeaderWarningString),                 HttpRequestHeaders.HeaderWarning), _
	Type<RequestHeaderNode>(@HeaderWebSocketProtocolString,       Len(HeaderWebSocketProtocolString),       HttpRequestHeaders.HeaderWebSocketProtocol) _
}

Dim Shared ResponseHeaderNodesVector(1 To HttpResponseHeadersSize) As ResponseHeaderNode = { _
	Type<ResponseHeaderNode>(@HeaderAcceptRangesString,         Len(HeaderAcceptRangesString),         HttpResponseHeaders.HeaderAcceptRanges), _
	Type<ResponseHeaderNode>(@HeaderAgeString,                  Len(HeaderAgeString),                  HttpResponseHeaders.HeaderAge), _
	Type<ResponseHeaderNode>(@HeaderAllowString,                Len(HeaderAllowString),                HttpResponseHeaders.HeaderAllow), _
	Type<ResponseHeaderNode>(@HeaderCacheControlString,         Len(HeaderCacheControlString),         HttpResponseHeaders.HeaderCacheControl), _
	Type<ResponseHeaderNode>(@HeaderConnectionString,           Len(HeaderConnectionString),           HttpResponseHeaders.HeaderConnection), _
	Type<ResponseHeaderNode>(@HeaderContentEncodingString,      Len(HeaderContentEncodingString),      HttpResponseHeaders.HeaderContentEncoding), _
	Type<ResponseHeaderNode>(@HeaderContentLanguageString,      Len(HeaderContentLanguageString),      HttpResponseHeaders.HeaderContentLanguage), _
	Type<ResponseHeaderNode>(@HeaderContentLengthString,        Len(HeaderContentLengthString),        HttpResponseHeaders.HeaderContentLength), _
	Type<ResponseHeaderNode>(@HeaderContentLocationString,      Len(HeaderContentLocationString),      HttpResponseHeaders.HeaderContentLocation), _
	Type<ResponseHeaderNode>(@HeaderContentMd5String,           Len(HeaderContentMd5String),           HttpResponseHeaders.HeaderContentMd5), _
	Type<ResponseHeaderNode>(@HeaderContentRangeString,         Len(HeaderContentRangeString),         HttpResponseHeaders.HeaderContentRange), _
	Type<ResponseHeaderNode>(@HeaderContentTypeString,          Len(HeaderContentTypeString),          HttpResponseHeaders.HeaderContentType), _
	Type<ResponseHeaderNode>(@HeaderDateString,                 Len(HeaderDateString),                 HttpResponseHeaders.HeaderDate), _
	Type<ResponseHeaderNode>(@HeaderETagString,                 Len(HeaderETagString),                 HttpResponseHeaders.HeaderETag), _
	Type<ResponseHeaderNode>(@HeaderExpiresString,              Len(HeaderExpiresString),              HttpResponseHeaders.HeaderExpires), _
	Type<ResponseHeaderNode>(@HeaderKeepAliveString,            Len(HeaderKeepAliveString),            HttpResponseHeaders.HeaderKeepAlive), _
	Type<ResponseHeaderNode>(@HeaderLastModifiedString,         Len(HeaderLastModifiedString),         HttpResponseHeaders.HeaderLastModified), _
	Type<ResponseHeaderNode>(@HeaderLocationString,             Len(HeaderLocationString),             HttpResponseHeaders.HeaderLocation), _
	Type<ResponseHeaderNode>(@HeaderPragmaString,               Len(HeaderPragmaString),               HttpResponseHeaders.HeaderPragma), _
	Type<ResponseHeaderNode>(@HeaderProxyAuthenticateString,    Len(HeaderProxyAuthenticateString),    HttpResponseHeaders.HeaderProxyAuthenticate), _
	Type<ResponseHeaderNode>(@HeaderRetryAfterString,           Len(HeaderRetryAfterString),           HttpResponseHeaders.HeaderRetryAfter), _
	Type<ResponseHeaderNode>(@HeaderSecWebSocketAcceptString,   Len(HeaderSecWebSocketAcceptString),   HttpResponseHeaders.HeaderSecWebSocketAccept), _
	Type<ResponseHeaderNode>(@HeaderSecWebSocketLocationString, Len(HeaderSecWebSocketLocationString), HttpResponseHeaders.HeaderSecWebSocketLocation), _
	Type<ResponseHeaderNode>(@HeaderSecWebSocketOriginString,   Len(HeaderSecWebSocketOriginString),   HttpResponseHeaders.HeaderSecWebSocketOrigin), _
	Type<ResponseHeaderNode>(@HeaderSecWebSocketProtocolString, Len(HeaderSecWebSocketProtocolString), HttpResponseHeaders.HeaderSecWebSocketProtocol), _
	Type<ResponseHeaderNode>(@HeaderServerString,               Len(HeaderServerString),               HttpResponseHeaders.HeaderServer), _
	Type<ResponseHeaderNode>(@HeaderSetCookieString,            Len(HeaderSetCookieString),            HttpResponseHeaders.HeaderSetCookie), _
	Type<ResponseHeaderNode>(@HeaderTrailerString,              Len(HeaderTrailerString),              HttpResponseHeaders.HeaderTrailer), _
	Type<ResponseHeaderNode>(@HeaderTransferEncodingString,     Len(HeaderTransferEncodingString),     HttpResponseHeaders.HeaderTransferEncoding), _
	Type<ResponseHeaderNode>(@HeaderUpgradeString,              Len(HeaderUpgradeString),              HttpResponseHeaders.HeaderUpgrade), _
	Type<ResponseHeaderNode>(@HeaderVaryString,                 Len(HeaderVaryString),                 HttpResponseHeaders.HeaderVary), _
	Type<ResponseHeaderNode>(@HeaderViaString,                  Len(HeaderViaString),                  HttpResponseHeaders.HeaderVia), _
	Type<ResponseHeaderNode>(@HeaderWarningString,              Len(HeaderWarningString),              HttpResponseHeaders.HeaderWarning), _
	Type<ResponseHeaderNode>(@HeaderWebSocketLocationString,    Len(HeaderWebSocketLocationString),    HttpResponseHeaders.HeaderWebSocketLocation), _
	Type<ResponseHeaderNode>(@HeaderWebSocketOriginString,      Len(HeaderWebSocketOriginString),      HttpResponseHeaders.HeaderWebSocketOrigin), _
	Type<ResponseHeaderNode>(@HeaderWebSocketProtocolString,    Len(HeaderWebSocketProtocolString),    HttpResponseHeaders.HeaderWebSocketProtocol), _
	Type<ResponseHeaderNode>(@HeaderWWWAuthenticateString,      Len(HeaderWWWAuthenticateString),      HttpResponseHeaders.HeaderWwwAuthenticate) _
}

Dim Shared CgiHeaderNodesVector(1 To HttpRequestHeadersSize) As CgiHeaderNode = { _
	Type<CgiHeaderNode>(@WStr("HTTP_ACCEPT"),                    11, HttpRequestHeaders.HeaderAccept), _
	Type<CgiHeaderNode>(@WStr("HTTP_ACCEPT_CHARSET"),            19, HttpRequestHeaders.HeaderAcceptCharset), _
	Type<CgiHeaderNode>(@WStr("HTTP_ACCEPT_ENCODING"),           20, HttpRequestHeaders.HeaderAcceptEncoding), _
	Type<CgiHeaderNode>(@WStr("HTTP_ACCEPT_LANGUAGE"),           20, HttpRequestHeaders.HeaderAcceptLanguage), _
	Type<CgiHeaderNode>(@WStr("AUTH_TYPE"),                      9, HttpRequestHeaders.HeaderAuthorization), _
	Type<CgiHeaderNode>(@WStr("HTTP_CACHE_CONTROL"),             18, HttpRequestHeaders.HeaderCacheControl), _
	Type<CgiHeaderNode>(@WStr("HTTP_CONNECTION"),                15, HttpRequestHeaders.HeaderConnection), _
	Type<CgiHeaderNode>(@WStr("HTTP_CONTENT_ENCODING"),          21, HttpRequestHeaders.HeaderContentEncoding), _
	Type<CgiHeaderNode>(@WStr("HTTP_CONTENT_LANGUAGE"),          21, HttpRequestHeaders.HeaderContentLanguage), _
	Type<CgiHeaderNode>(@WStr("CONTENT_LENGTH"),                 14, HttpRequestHeaders.HeaderContentLength), _
	Type<CgiHeaderNode>(@WStr("HTTP_CONTENT_MD5"),               16, HttpRequestHeaders.HeaderContentMd5), _
	Type<CgiHeaderNode>(@WStr("HTTP_CONTENT_RANGE"),             18, HttpRequestHeaders.HeaderContentRange), _
	Type<CgiHeaderNode>(@WStr("CONTENT_TYPE"),                   12, HttpRequestHeaders.HeaderContentType), _
	Type<CgiHeaderNode>(@WStr("HTTP_COOKIE"),                    11, HttpRequestHeaders.HeaderCookie), _
	Type<CgiHeaderNode>(@WStr("HTTP_DNT"),                       8, HttpRequestHeaders.HeaderDNT), _
	Type<CgiHeaderNode>(@WStr("HTTP_EXPECT"),                    11, HttpRequestHeaders.HeaderExpect), _
	Type<CgiHeaderNode>(@WStr("HTTP_FROM"),                      9, HttpRequestHeaders.HeaderFrom), _
	Type<CgiHeaderNode>(@WStr("HTTP_HOST"),                      9, HttpRequestHeaders.HeaderHost), _
	Type<CgiHeaderNode>(@WStr("HTTP_IF_MATCH"),                  13, HttpRequestHeaders.HeaderIfMatch), _
	Type<CgiHeaderNode>(@WStr("HTTP_IF_MODIFIED_SINCE"),         22, HttpRequestHeaders.HeaderIfModifiedSince), _
	Type<CgiHeaderNode>(@WStr("HTTP_IF_NONE_MATCH"),             18, HttpRequestHeaders.HeaderIfNoneMatch), _
	Type<CgiHeaderNode>(@WStr("HTTP_IF_RANGE"),                  13, HttpRequestHeaders.HeaderIfRange), _
	Type<CgiHeaderNode>(@WStr("HTTP_IF_UNMODIFIED_SINCE"),       24, HttpRequestHeaders.HeaderIfUnmodifiedSince), _
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
	Type<CgiHeaderNode>(@WStr("HTTP_TE"),                        7,                 HttpRequestHeaders.HeaderTe), _
	Type<CgiHeaderNode>(@WStr("HTTP_TRAILER"),                   12, HttpRequestHeaders.HeaderTrailer), _
	Type<CgiHeaderNode>(@WStr("HTTP_TRANSFER_ENCODING"),         22, HttpRequestHeaders.HeaderTransferEncoding), _
	Type<CgiHeaderNode>(@WStr("HTTP_UPGRADE"),                   12, HttpRequestHeaders.HeaderUpgrade), _
	Type<CgiHeaderNode>(@WStr("HTTP_UPGRADE_INSECURE_REQUESTS"), 30, HttpRequestHeaders.HeaderUpgradeInsecureRequests), _
	Type<CgiHeaderNode>(@WStr("HTTP_USER_AGENT"),                15, HttpRequestHeaders.HeaderUserAgent), _
	Type<CgiHeaderNode>(@WStr("HTTP_VIA"),                       8, HttpRequestHeaders.HeaderVia), _
	Type<CgiHeaderNode>(@WStr("HTTP_WARNING"),                   12, HttpRequestHeaders.HeaderWarning), _
	Type<CgiHeaderNode>(@WStr("HTTP_WEBSOCKET_PROTOCOL"),        23, HttpRequestHeaders.HeaderWebSocketProtocol) _
}

Function HttpMethodToString( _
		ByVal HttpMethod As HttpMethods, _
		ByVal pBufferLength As Integer Ptr _
	)As WString Ptr
	
	Dim intBufferLength As Integer = 0
	
	Select Case HttpMethod
		
		Case HttpMethods.HttpGet
			intBufferLength = HttpMethodGetLength
			HttpMethodToString = @HttpMethodGet
			
		Case HttpMethods.HttpHead
			intBufferLength = HttpMethodHeadLength
			HttpMethodToString = @HttpMethodHead
			
		Case HttpMethods.HttpPost
			intBufferLength = HttpMethodPostLength
			HttpMethodToString = @HttpMethodPost
			
		Case HttpMethods.HttpPut
			intBufferLength = HttpMethodPutLength
			HttpMethodToString = @HttpMethodPut
			
		Case HttpMethods.HttpDelete
			intBufferLength = HttpMethodDeleteLength
			HttpMethodToString = @HttpMethodDelete
			
		Case HttpMethods.HttpOptions
			intBufferLength = HttpMethodOptionsLength
			HttpMethodToString = @HttpMethodOptions
			
		Case HttpMethods.HttpTrace
			intBufferLength = HttpMethodTraceLength
			HttpMethodToString = @HttpMethodTrace
			
		Case HttpMethods.HttpConnect
			intBufferLength = HttpMethodConnectLength
			HttpMethodToString = @HttpMethodConnect
			
		Case Else
			intBufferLength = 0
			HttpMethodToString = 0
			
	End Select
	
	If pBufferLength <> 0 Then
		*pBufferLength = intBufferLength
	End If
	
End Function


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
	
	If pDescriptionLength <> NULL Then
		*pDescriptionLength = DescriptionLength
	End If
	
	Return pDescription
	
End Function


Function GetHttpVersionIndex( _
		ByVal s As WString Ptr, _
		ByVal pVersion As HttpVersions Ptr _
	)As Boolean
	
	If lstrlenW(s) = 0 Then
		*pVersion = HttpVersions.Http09
		Return True
	End If
	
	If lstrcmpW(s, @HttpVersion11String) = 0 Then
		*pVersion = HttpVersions.Http11
		Return True
	End If
	
	If lstrcmpW(s, @HttpVersion10String) = 0 Then
		*pVersion = HttpVersions.Http10
		Return True
	End If
	
	Return False
	
End Function

Function HttpVersionToString( _
		ByVal v As HttpVersions, _
		ByVal pBufferLength As Integer Ptr _
	)As WString Ptr
	
	Dim intBufferLength As Integer = 0
	
	Select Case v
		
		Case HttpVersions.Http11
			intBufferLength = HttpVersion11StringLength
			HttpVersionToString = @HttpVersion11String
			
		Case HttpVersions.Http10
			intBufferLength = HttpVersion10StringLength
			HttpVersionToString = @HttpVersion10String
			
		Case Else
			intBufferLength = HttpVersion11StringLength
			HttpVersionToString = @HttpVersion11String
			
	End Select
	
	If pBufferLength <> NULL Then
		*pBufferLength = intBufferLength
	End If
	
End Function


Function GetKnownRequestHeaderIndex( _
		ByVal pHeader As WString Ptr, _
		ByVal pIndex As HttpRequestHeaders Ptr _
	)As Boolean
	
	For i As Integer = 1 To HttpRequestHeadersSize
		Dim CompareResult As Long = memcmp( _
			RequestHeaderNodesVector(i).pHeader, _
			pHeader, _
			RequestHeaderNodesVector(i).HeaderLength * SizeOf(WString) _
		)
		If CompareResult = 0 Then
			*pIndex = RequestHeaderNodesVector(i).HeaderIndex
			Return True
		End If
	Next
	
	*pIndex = 0
	Return False
	
End Function

' Function KnownRequestHeaderToString( _
	' ByVal Header As HttpRequestHeaders, _
	' ByVal pBufferLength As Integer Ptr _
' )As WString Ptr


Function GetKnownResponseHeaderIndex( _
		ByVal pHeader As WString Ptr, _
		ByVal pIndex As HttpResponseHeaders Ptr _
	)As Boolean
	
	For i As Integer = 1 To HttpResponseHeadersSize
		Dim CompareResult As Long = memcmp( _
			ResponseHeaderNodesVector(i).pHeader, _
			pHeader, _
			ResponseHeaderNodesVector(i).HeaderLength * SizeOf(WString) _
		)
		If CompareResult = 0 Then
			*pIndex = ResponseHeaderNodesVector(i).HeaderIndex
			Return True
		End If
	Next
	
	*pIndex = 0
	Return False
	
End Function

Function KnownResponseHeaderToString( _
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
	
	If pHeaderLength <> NULL Then
		*pHeaderLength = HeaderLength
	End If
	
	Return pHeader
	
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
	
	If pHeaderLength <> NULL Then
		*pHeaderLength = HeaderLength
	End If
	
	Return pHeader
	
End Function
