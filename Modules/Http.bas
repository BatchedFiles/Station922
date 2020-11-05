#include "Http.bi"

#ifndef unicode
#define unicode
#endif
#include "windows.bi"

Const HttpVersion10String = "HTTP/1.0"
Const HttpVersion11String = "HTTP/1.1"

Const HttpVersion10StringLength As Integer = 8
Const HttpVersion11StringLength As Integer = 8

Const HttpMethodCopy =     "COPY"
Const HttpMethodConnect =  "CONNECT"
Const HttpMethodDelete =   "DELETE"
Const HttpMethodGet =      "GET"
Const HttpMethodHead =     "HEAD"
Const HttpMethodMove =     "MOVE"
Const HttpMethodOptions =  "OPTIONS"
Const HttpMethodPatch =    "PATCH"
Const HttpMethodPost =     "POST"
Const HttpMethodPropfind = "PROPFIND"
Const HttpMethodPut =      "PUT"
Const HttpMethodTrace =    "TRACE"

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

Const HeaderAcceptString =             "Accept"
Const HeaderAcceptCharsetString =      "Accept-Charset"
Const HeaderAcceptEncodingString =     "Accept-Encoding"
Const HeaderAcceptLanguageString =     "Accept-Language"
Const HeaderAcceptRangesString =       "Accept-Ranges"
Const HeaderAgeString =                "Age"
Const HeaderAllowString =              "Allow"
Const HeaderAuthorizationString =      "Authorization"
Const HeaderCacheControlString =       "Cache-Control"
Const HeaderConnectionString =         "Connection"
Const HeaderContentEncodingString =    "Content-Encoding"
Const HeaderContentLanguageString =    "Content-Language"
Const HeaderContentLengthString =      "Content-Length"
Const HeaderContentLocationString =    "Content-Location"
Const HeaderContentMd5String =         "Content-MD5"
Const HeaderContentTypeString =        "Content-Type"
Const HeaderContentRangeString =       "Content-Range"
Const HeaderCookieString =             "Cookie"
Const HeaderDateString =               "Date"
Const HeaderDNTString =                "DNT"
Const HeaderETagString =               "ETag"
Const HeaderExpectString =             "Expect"
Const HeaderExpiresString =            "Expires"
Const HeaderFromString =               "From"
Const HeaderHostString =               "Host"
Const HeaderIfMatchString =            "If-Match"
Const HeaderIfModifiedSinceString =    "If-Modified-Since"
Const HeaderIfNoneMatchString =        "If-None-Match"
Const HeaderIfRangeString =            "If-Range"
Const HeaderIfUnmodifiedSinceString =  "If-Unmodified-Since"
Const HeaderKeepAliveString =          "Keep-Alive"
Const HeaderLastModifiedString =       "Last-Modified"
Const HeaderLocationString =           "Location"
Const HeaderMaxForwardsString =        "Max-Forwards"
Const HeaderOriginString =             "Origin"
Const HeaderPragmaString =             "Pragma"
Const HeaderProxyAuthenticateString =  "Proxy-Authenticate"
Const HeaderProxyAuthorizationString = "Proxy-Authorization"
Const HeaderRangeString =              "Range"
Const HeaderRefererString =            "Referer"
Const HeaderRetryAfterString =         "Retry-After"
Const HeaderSecWebSocketAcceptString =             "Sec-WebSocket-Accept"
Const HeaderSecWebSocketKeyString =    "Sec-WebSocket-Key"
Const HeaderSecWebSocketKey1String =   "Sec-WebSocket-Key1"
Const HeaderSecWebSocketKey2String =   "Sec-WebSocket-Key2"
Const HeaderSecWebSocketLocationString =             "Sec-WebSocket-Location"
Const HeaderSecWebSocketOriginString =             "Sec-WebSocket-Origin"
Const HeaderSecWebSocketProtocolString =             "Sec-WebSocket-Protocol"
Const HeaderSecWebSocketVersionString = "Sec-WebSocket-Version"
Const HeaderServerString =             "Server"
Const HeaderSetCookieString =          "Set-Cookie"
Const HeaderTeString =                 "TE"
Const HeaderTrailerString =            "Trailer"
Const HeaderTransferEncodingString =   "Transfer-Encoding"
Const HeaderUpgradeString =            "Upgrade"
Const HeaderUpgradeInsecureRequestsString =            "Upgrade-Insecure-Requests"
Const HeaderUserAgentString =          "User-Agent"
Const HeaderVaryString =               "Vary"
Const HeaderViaString =                "Via"
Const HeaderWarningString =            "Warning"
Const HeaderWebSocketLocationString =  "WebSocket-Location"
Const HeaderWebSocketOriginString =    "WebSocket-Origin"
Const HeaderWebSocketProtocolString =  "WebSocket-Protocol"
Const HeaderWWWAuthenticateString =    "WWW-Authenticate"

Const HeaderAcceptStringLength As Integer =      6
Const HeaderAcceptCharsetStringLength As Integer = 14
Const HeaderAcceptEncodingStringLength As Integer = 15
Const HeaderAcceptLanguageStringLength As Integer = 15
Const HeaderAcceptRangesStringLength As Integer =      13
Const HeaderAgeStringLength As Integer =               3
Const HeaderAllowStringLength As Integer =             5
Const HeaderAuthorizationStringLength As Integer = 13
Const HeaderCacheControlStringLength As Integer =      13
Const HeaderConnectionStringLength As Integer =        10
Const HeaderContentEncodingStringLength As Integer =   16
Const HeaderContentLengthStringLength As Integer =     14
Const HeaderContentLanguageStringLength As Integer =   16
Const HeaderContentLocationStringLength As Integer =   16
Const HeaderContentMd5StringLength As Integer =        11
Const HeaderContentRangeStringLength As Integer =      13
Const HeaderContentTypeStringLength As Integer =       12
Const HeaderCookieStringLength As Integer = 6
Const HeaderDateStringLength As Integer =              4
Const HeaderDNTStringLength As Integer = 3
Const HeaderETagStringLength As Integer =              4
Const HeaderExpectStringLength As Integer = 6
Const HeaderExpiresStringLength As Integer =           7
Const HeaderFromStringLength As Integer = 4
Const HeaderHostStringLength As Integer = 4
Const HeaderIfMatchStringLength As Integer = 8
Const HeaderIfModifiedSinceStringLength As Integer = 17
Const HeaderIfNoneMatchStringLength As Integer = 13
Const HeaderIfRangeStringLength As Integer = 8
Const HeaderIfUnmodifiedSinceStringLength As Integer = 19
Const HeaderKeepAliveStringLength As Integer =         10
Const HeaderLastModifiedStringLength As Integer =      13
Const HeaderLocationStringLength As Integer =          8
Const HeaderMaxForwardsStringLength As Integer = 12
Const HeaderOriginStringLength As Integer = 6
Const HeaderPragmaStringLength As Integer =            6
Const HeaderProxyAuthenticateStringLength As Integer = 18
Const HeaderProxyAuthorizationStringLength As Integer = 19
Const HeaderRangeStringLength As Integer = 5
Const HeaderRefererStringLength As Integer = 7
Const HeaderRetryAfterStringLength As Integer =        11
Const HeaderSecWebSocketAcceptStringLength As Integer =             20
Const HeaderSecWebSocketKeyStringLength As Integer = 17
Const HeaderSecWebSocketKey1StringLength As Integer = 18
Const HeaderSecWebSocketKey2StringLength As Integer = 18
Const HeaderSecWebSocketLocationStringLength As Integer =             22
Const HeaderSecWebSocketOriginStringLength As Integer =             20
Const HeaderSecWebSocketProtocolStringLength As Integer =             22
Const HeaderSecWebSocketVersionStringLength As Integer = 21
Const HeaderServerStringLength As Integer =            6
Const HeaderSetCookieStringLength As Integer =         10
Const HeaderTeStringLength As Integer = 2
Const HeaderTrailerStringLength As Integer =           7
Const HeaderTransferEncodingStringLength As Integer =  17
Const HeaderUpgradeStringLength As Integer =           7
Const HeaderUpgradeInsecureRequestsStringLength As Integer = 25
Const HeaderUserAgentStringLength As Integer = 10
Const HeaderVaryStringLength As Integer =              4
Const HeaderViaStringLength As Integer =               3
Const HeaderWarningStringLength As Integer =           7
Const HeaderWebSocketLocationStringLength As Integer =    18
Const HeaderWebSocketOriginStringLength As Integer=    16
Const HeaderWebSocketProtocolStringLength As Integer =    18
Const HeaderWWWAuthenticateStringLength As Integer =   16

Const HttpStatusCodeString100 = "Continue"
Const HttpStatusCodeString101 = "Switching Protocols"
Const HttpStatusCodeString102 = "Processing"

Const HttpStatusCodeString200 = "OK"
Const HttpStatusCodeString201 = "Created"
Const HttpStatusCodeString202 = "Accepted"
Const HttpStatusCodeString203 = "Non-Authoritative Information"
Const HttpStatusCodeString204 = "No Content"
Const HttpStatusCodeString205 = "Reset Content"
Const HttpStatusCodeString206 = "Partial Content"
Const HttpStatusCodeString207 = "Multi-Status"
Const HttpStatusCodeString226 = "IM Used"

Const HttpStatusCodeString300 = "Multiple Choices"
Const HttpStatusCodeString301 = "Moved Permanently"
Const HttpStatusCodeString302 = "Found"
Const HttpStatusCodeString303 = "See Other"
Const HttpStatusCodeString304 = "Not Modified"
Const HttpStatusCodeString305 = "Use Proxy"
Const HttpStatusCodeString307 = "Temporary Redirect"

Const HttpStatusCodeString400 = "Bad Request"
Const HttpStatusCodeString401 = "Unauthorized"
Const HttpStatusCodeString402 = "Payment Required"
Const HttpStatusCodeString403 = "Forbidden"
Const HttpStatusCodeString404 = "Not Found"
Const HttpStatusCodeString405 = "Method Not Allowed"
Const HttpStatusCodeString406 = "Not Acceptable"
Const HttpStatusCodeString407 = "Proxy Authentication Required"
Const HttpStatusCodeString408 = "Request Timeout"
Const HttpStatusCodeString409 = "Conflict"
Const HttpStatusCodeString410 = "Gone"
Const HttpStatusCodeString411 = "Length Required"
Const HttpStatusCodeString412 = "Precondition Failed"
Const HttpStatusCodeString413 = "Request Entity Too Large"
Const HttpStatusCodeString414 = "Request-URI Too Large"
Const HttpStatusCodeString415 = "Unsupported Media Type"
Const HttpStatusCodeString416 = "Requested Range Not Satisfiable"
Const HttpStatusCodeString417 = "Expectation Failed"
Const HttpStatusCodeString418 = "I am a teapot"
Const HttpStatusCodeString422 = "Unprocessable Entity"
Const HttpStatusCodeString423 = "Locked"
Const HttpStatusCodeString424 = "Failed Dependency"
Const HttpStatusCodeString425 = "Unordered Collection"
Const HttpStatusCodeString426 = "Upgrade Required"
Const HttpStatusCodeString428 = "Precondition Required"
Const HttpStatusCodeString429 = "Too Many Requests"
Const HttpStatusCodeString431 = "Request Header Fields Too Large"
Const HttpStatusCodeString449 = "Retry With"
Const HttpStatusCodeString451 = "Unavailable For Legal Reasons"

Const HttpStatusCodeString500 = "Internal Server Error"
Const HttpStatusCodeString501 = "Not Implemented"
Const HttpStatusCodeString502 = "Bad Gateway"
Const HttpStatusCodeString503 = "Service Unavailable"
Const HttpStatusCodeString504 = "Gateway Timeout"
Const HttpStatusCodeString505 = "HTTP Version Not Supported"
Const HttpStatusCodeString506 = "Variant Also Negotiates"
Const HttpStatusCodeString507 = "Insufficient Storage"
Const HttpStatusCodeString508 = "Loop Detected"
Const HttpStatusCodeString509 = "Bandwidth Limit Exceeded"
Const HttpStatusCodeString510 = "Not Extended"
Const HttpStatusCodeString511 = "Network Authentication Required"

Const HttpStatusCodeString100Length As Integer = 8
Const HttpStatusCodeString101Length As Integer = 19
Const HttpStatusCodeString102Length As Integer = 10

Const HttpStatusCodeString200Length As Integer = 2
Const HttpStatusCodeString201Length As Integer = 7
Const HttpStatusCodeString202Length As Integer = 8
Const HttpStatusCodeString203Length As Integer = 29
Const HttpStatusCodeString204Length As Integer = 10
Const HttpStatusCodeString205Length As Integer = 13
Const HttpStatusCodeString206Length As Integer = 15
Const HttpStatusCodeString207Length As Integer = 12
Const HttpStatusCodeString226Length As Integer = 7

Const HttpStatusCodeString300Length As Integer = 16
Const HttpStatusCodeString301Length As Integer = 17
Const HttpStatusCodeString302Length As Integer = 5
Const HttpStatusCodeString303Length As Integer = 9
Const HttpStatusCodeString304Length As Integer = 12
Const HttpStatusCodeString305Length As Integer = 9
Const HttpStatusCodeString307Length As Integer = 18

Const HttpStatusCodeString400Length As Integer = 11
Const HttpStatusCodeString401Length As Integer = 12
Const HttpStatusCodeString402Length As Integer = 16
Const HttpStatusCodeString403Length As Integer = 9
Const HttpStatusCodeString404Length As Integer = 9
Const HttpStatusCodeString405Length As Integer = 18
Const HttpStatusCodeString406Length As Integer = 14
Const HttpStatusCodeString407Length As Integer = 29
Const HttpStatusCodeString408Length As Integer = 15
Const HttpStatusCodeString409Length As Integer = 8
Const HttpStatusCodeString410Length As Integer = 4
Const HttpStatusCodeString411Length As Integer = 15
Const HttpStatusCodeString412Length As Integer = 19
Const HttpStatusCodeString413Length As Integer = 24
Const HttpStatusCodeString414Length As Integer = 21
Const HttpStatusCodeString415Length As Integer = 22
Const HttpStatusCodeString416Length As Integer = 31
Const HttpStatusCodeString417Length As Integer = 18
Const HttpStatusCodeString418Length As Integer = 13
Const HttpStatusCodeString422Length As Integer = 20
Const HttpStatusCodeString423Length As Integer = 6
Const HttpStatusCodeString424Length As Integer = 17
Const HttpStatusCodeString425Length As Integer = 20
Const HttpStatusCodeString426Length As Integer = 16
Const HttpStatusCodeString428Length As Integer = 21
Const HttpStatusCodeString429Length As Integer = 17
Const HttpStatusCodeString431Length As Integer = 31
Const HttpStatusCodeString449Length As Integer = 10
Const HttpStatusCodeString451Length As Integer = 29

Const HttpStatusCodeString500Length As Integer = 21
Const HttpStatusCodeString501Length As Integer = 15
Const HttpStatusCodeString502Length As Integer = 11
Const HttpStatusCodeString503Length As Integer = 19
Const HttpStatusCodeString504Length As Integer = 15
Const HttpStatusCodeString505Length As Integer = 26
Const HttpStatusCodeString506Length As Integer = 23
Const HttpStatusCodeString507Length As Integer = 20
Const HttpStatusCodeString508Length As Integer = 13
Const HttpStatusCodeString509Length As Integer = 24
Const HttpStatusCodeString510Length As Integer = 12
Const HttpStatusCodeString511Length As Integer = 31

Type StatusCodeNode
	Dim pDescription As WString Ptr
	Dim DescriptionLength As Integer
	Dim StatusCodeIndex As HttpStatusCodes
End Type

Type RequestHeaderNode
	Dim pHeader As WString Ptr
	Dim HeaderLength As Integer
	Dim HeaderIndex As HttpRequestHeaders
End Type

Type ResponseHeaderNode
	Dim pHeader As WString Ptr
	Dim HeaderLength As Integer
	Dim HeaderIndex As HttpResponseHeaders
End Type

Type CgiHeaderNode
	Dim pHeader As WString Ptr
	Dim HeaderLength As Integer
	Dim HeaderIndex As HttpRequestHeaders
End Type

Dim Shared StatusCodeNodesVector(1 To HttpStatusCodesSize) As StatusCodeNode = { _
	Type<StatusCodeNode>(@HttpStatusCodeString100, HttpStatusCodeString100Length, HttpStatusCodes.CodeContinue), _
	Type<StatusCodeNode>(@HttpStatusCodeString101, HttpStatusCodeString101Length, HttpStatusCodes.SwitchingProtocols), _
	Type<StatusCodeNode>(@HttpStatusCodeString102, HttpStatusCodeString102Length, HttpStatusCodes.Processing), _
	Type<StatusCodeNode>(@HttpStatusCodeString200, HttpStatusCodeString200Length, HttpStatusCodes.OK), _
	Type<StatusCodeNode>(@HttpStatusCodeString201, HttpStatusCodeString201Length, HttpStatusCodes.Created), _
	Type<StatusCodeNode>(@HttpStatusCodeString202, HttpStatusCodeString202Length, HttpStatusCodes.Accepted), _
	Type<StatusCodeNode>(@HttpStatusCodeString203, HttpStatusCodeString203Length, HttpStatusCodes.NonAuthoritativeInformation), _
	Type<StatusCodeNode>(@HttpStatusCodeString204, HttpStatusCodeString204Length, HttpStatusCodes.NoContent), _
	Type<StatusCodeNode>(@HttpStatusCodeString205, HttpStatusCodeString205Length, HttpStatusCodes.ResetContent), _
	Type<StatusCodeNode>(@HttpStatusCodeString206, HttpStatusCodeString206Length, HttpStatusCodes.PartialContent), _
	Type<StatusCodeNode>(@HttpStatusCodeString207, HttpStatusCodeString207Length, HttpStatusCodes.MultiStatus), _
	Type<StatusCodeNode>(@HttpStatusCodeString226, HttpStatusCodeString226Length, HttpStatusCodes.IAmUsed), _
	Type<StatusCodeNode>(@HttpStatusCodeString300, HttpStatusCodeString300Length, HttpStatusCodes.MultipleChoices), _
	Type<StatusCodeNode>(@HttpStatusCodeString301, HttpStatusCodeString301Length, HttpStatusCodes.MovedPermanently), _
	Type<StatusCodeNode>(@HttpStatusCodeString302, HttpStatusCodeString302Length, HttpStatusCodes.Found), _
	Type<StatusCodeNode>(@HttpStatusCodeString303, HttpStatusCodeString303Length, HttpStatusCodes.SeeOther), _
	Type<StatusCodeNode>(@HttpStatusCodeString304, HttpStatusCodeString304Length, HttpStatusCodes.NotModified), _
	Type<StatusCodeNode>(@HttpStatusCodeString305, HttpStatusCodeString305Length, HttpStatusCodes.UseProxy), _
	Type<StatusCodeNode>(@HttpStatusCodeString307, HttpStatusCodeString307Length, HttpStatusCodes.TemporaryRedirect), _
	Type<StatusCodeNode>(@HttpStatusCodeString400, HttpStatusCodeString400Length, HttpStatusCodes.BadRequest), _
	Type<StatusCodeNode>(@HttpStatusCodeString401, HttpStatusCodeString401Length, HttpStatusCodes.Unauthorized), _
	Type<StatusCodeNode>(@HttpStatusCodeString402, HttpStatusCodeString402Length, HttpStatusCodes.PaymentRequired), _
	Type<StatusCodeNode>(@HttpStatusCodeString403, HttpStatusCodeString403Length, HttpStatusCodes.Forbidden), _
	Type<StatusCodeNode>(@HttpStatusCodeString404, HttpStatusCodeString404Length, HttpStatusCodes.NotFound), _
	Type<StatusCodeNode>(@HttpStatusCodeString405, HttpStatusCodeString405Length, HttpStatusCodes.MethodNotAllowed), _
	Type<StatusCodeNode>(@HttpStatusCodeString406, HttpStatusCodeString406Length, HttpStatusCodes.NotAcceptable), _
	Type<StatusCodeNode>(@HttpStatusCodeString407, HttpStatusCodeString407Length, HttpStatusCodes.ProxyAuthenticationRequired), _
	Type<StatusCodeNode>(@HttpStatusCodeString408, HttpStatusCodeString408Length, HttpStatusCodes.RequestTimeout), _
	Type<StatusCodeNode>(@HttpStatusCodeString409, HttpStatusCodeString409Length, HttpStatusCodes.Conflict), _
	Type<StatusCodeNode>(@HttpStatusCodeString410, HttpStatusCodeString410Length, HttpStatusCodes.Gone), _
	Type<StatusCodeNode>(@HttpStatusCodeString411, HttpStatusCodeString411Length, HttpStatusCodes.LengthRequired), _
	Type<StatusCodeNode>(@HttpStatusCodeString412, HttpStatusCodeString412Length, HttpStatusCodes.PreconditionFailed), _
	Type<StatusCodeNode>(@HttpStatusCodeString413, HttpStatusCodeString413Length, HttpStatusCodes.RequestEntityTooLarge), _
	Type<StatusCodeNode>(@HttpStatusCodeString414, HttpStatusCodeString414Length, HttpStatusCodes.RequestURITooLarge), _
	Type<StatusCodeNode>(@HttpStatusCodeString415, HttpStatusCodeString415Length, HttpStatusCodes.UnsupportedMediaType), _
	Type<StatusCodeNode>(@HttpStatusCodeString416, HttpStatusCodeString416Length, HttpStatusCodes.RequestedRangeNotSatisfiable), _
	Type<StatusCodeNode>(@HttpStatusCodeString417, HttpStatusCodeString417Length, HttpStatusCodes.ExpectationFailed), _
	Type<StatusCodeNode>(@HttpStatusCodeString418, HttpStatusCodeString418Length, HttpStatusCodes.IAmTeapot), _
	Type<StatusCodeNode>(@HttpStatusCodeString422, HttpStatusCodeString422Length, HttpStatusCodes.UnprocessableEntity), _
	Type<StatusCodeNode>(@HttpStatusCodeString423, HttpStatusCodeString423Length, HttpStatusCodes.Locked), _
	Type<StatusCodeNode>(@HttpStatusCodeString424, HttpStatusCodeString424Length, HttpStatusCodes.FailedDependency), _
	Type<StatusCodeNode>(@HttpStatusCodeString425, HttpStatusCodeString425Length, HttpStatusCodes.UnorderedCollection), _
	Type<StatusCodeNode>(@HttpStatusCodeString426, HttpStatusCodeString426Length, HttpStatusCodes.UpgradeRequired), _
	Type<StatusCodeNode>(@HttpStatusCodeString428, HttpStatusCodeString428Length, HttpStatusCodes.PreconditionRequired), _
	Type<StatusCodeNode>(@HttpStatusCodeString429, HttpStatusCodeString429Length, HttpStatusCodes.TooManyRequests), _
	Type<StatusCodeNode>(@HttpStatusCodeString431, HttpStatusCodeString431Length, HttpStatusCodes.RequestHeaderFieldsTooLarge), _
	Type<StatusCodeNode>(@HttpStatusCodeString449, HttpStatusCodeString449Length, HttpStatusCodes.RetryWith), _
	Type<StatusCodeNode>(@HttpStatusCodeString451, HttpStatusCodeString451Length, HttpStatusCodes.UnavailableForLegalReasons), _
	Type<StatusCodeNode>(@HttpStatusCodeString500, HttpStatusCodeString500Length, HttpStatusCodes.InternalServerError), _
	Type<StatusCodeNode>(@HttpStatusCodeString501, HttpStatusCodeString501Length, HttpStatusCodes.NotImplemented), _
	Type<StatusCodeNode>(@HttpStatusCodeString502, HttpStatusCodeString502Length, HttpStatusCodes.BadGateway), _
	Type<StatusCodeNode>(@HttpStatusCodeString503, HttpStatusCodeString503Length, HttpStatusCodes.ServiceUnavailable), _
	Type<StatusCodeNode>(@HttpStatusCodeString504, HttpStatusCodeString504Length, HttpStatusCodes.GatewayTimeout), _
	Type<StatusCodeNode>(@HttpStatusCodeString505, HttpStatusCodeString505Length, HttpStatusCodes.HTTPVersionNotSupported), _
	Type<StatusCodeNode>(@HttpStatusCodeString506, HttpStatusCodeString506Length, HttpStatusCodes.VariantAlsoNegotiates), _
	Type<StatusCodeNode>(@HttpStatusCodeString507, HttpStatusCodeString507Length, HttpStatusCodes.InsufficientStorage), _
	Type<StatusCodeNode>(@HttpStatusCodeString508, HttpStatusCodeString508Length, HttpStatusCodes.LoopDetected), _
	Type<StatusCodeNode>(@HttpStatusCodeString509, HttpStatusCodeString509Length, HttpStatusCodes.BandwidthLimitExceeded), _
	Type<StatusCodeNode>(@HttpStatusCodeString510, HttpStatusCodeString510Length, HttpStatusCodes.NotExtended), _
	Type<StatusCodeNode>(@HttpStatusCodeString511, HttpStatusCodeString511Length, HttpStatusCodes.NetworkAuthenticationRequired) _
}

Dim Shared RequestHeaderNodesVector(1 To HttpRequestHeadersSize) As RequestHeaderNode = { _
	Type<RequestHeaderNode>(@HeaderHostString, HeaderHostStringLength, HttpRequestHeaders.HeaderHost), _
	Type<RequestHeaderNode>(@HeaderAcceptLanguageString, HeaderAcceptLanguageStringLength, HttpRequestHeaders.HeaderAcceptLanguage), _
	Type<RequestHeaderNode>(@HeaderUserAgentString, HeaderUserAgentStringLength, HttpRequestHeaders.HeaderUserAgent), _
	Type<RequestHeaderNode>(@HeaderAcceptEncodingString, HeaderAcceptEncodingStringLength, HttpRequestHeaders.HeaderAcceptEncoding), _
	Type<RequestHeaderNode>(@HeaderAcceptString, HeaderAcceptStringLength, HttpRequestHeaders.HeaderAccept), _
	Type<RequestHeaderNode>(@HeaderConnectionString, HeaderConnectionStringLength, HttpRequestHeaders.HeaderConnection), _
	Type<RequestHeaderNode>(@HeaderCacheControlString, HeaderCacheControlStringLength, HttpRequestHeaders.HeaderCacheControl), _
	Type<RequestHeaderNode>(@HeaderIfModifiedSinceString, HeaderIfModifiedSinceStringLength, HttpRequestHeaders.HeaderIfModifiedSince), _
	Type<RequestHeaderNode>(@HeaderRefererString, HeaderRefererStringLength, HttpRequestHeaders.HeaderReferer), _
	Type<RequestHeaderNode>(@HeaderIfNoneMatchString, HeaderIfNoneMatchStringLength, HttpRequestHeaders.HeaderIfNoneMatch), _
	Type<RequestHeaderNode>(@HeaderDNTString, HeaderDNTStringLength, HttpRequestHeaders.HeaderDNT), _
	Type<RequestHeaderNode>(@HeaderUpgradeInsecureRequestsString, HeaderUpgradeInsecureRequestsStringLength, HttpRequestHeaders.HeaderUpgradeInsecureRequests), _
	Type<RequestHeaderNode>(@HeaderRangeString, HeaderRangeStringLength, HttpRequestHeaders.HeaderRange), _
	Type<RequestHeaderNode>(@HeaderAuthorizationString, HeaderAuthorizationStringLength, HttpRequestHeaders.HeaderAuthorization), _
	Type<RequestHeaderNode>(@HeaderContentLengthString, HeaderContentLengthStringLength, HttpRequestHeaders.HeaderContentLength), _
	Type<RequestHeaderNode>(@HeaderContentTypeString, HeaderContentTypeStringLength, HttpRequestHeaders.HeaderContentType), _
	Type<RequestHeaderNode>(@HeaderCookieString, HeaderCookieStringLength, HttpRequestHeaders.HeaderCookie), _
	Type<RequestHeaderNode>(@HeaderContentLanguageString, HeaderContentLanguageStringLength, HttpRequestHeaders.HeaderContentLanguage), _
	Type<RequestHeaderNode>(@HeaderAcceptCharsetString, HeaderAcceptCharsetStringLength, HttpRequestHeaders.HeaderAcceptCharset), _
	Type<RequestHeaderNode>(@HeaderContentEncodingString, HeaderContentEncodingStringLength, HttpRequestHeaders.HeaderContentEncoding), _
	Type<RequestHeaderNode>(@HeaderKeepAliveString, HeaderKeepAliveStringLength, HttpRequestHeaders.HeaderKeepAlive), _
	Type<RequestHeaderNode>(@HeaderExpectString, HeaderExpectStringLength, HttpRequestHeaders.HeaderExpect), _
	Type<RequestHeaderNode>(@HeaderContentMd5String, HeaderContentMd5StringLength, HttpRequestHeaders.HeaderContentMd5), _
	Type<RequestHeaderNode>(@HeaderContentRangeString, HeaderContentRangeStringLength, HttpRequestHeaders.HeaderContentRange), _
	Type<RequestHeaderNode>(@HeaderFromString, HeaderFromStringLength, HttpRequestHeaders.HeaderFrom), _
	Type<RequestHeaderNode>(@HeaderIfMatchString, HeaderIfMatchStringLength, HttpRequestHeaders.HeaderIfMatch), _
	Type<RequestHeaderNode>(@HeaderIfRangeString, HeaderIfRangeStringLength, HttpRequestHeaders.HeaderIfRange), _
	Type<RequestHeaderNode>(@HeaderIfUnmodifiedSinceString, HeaderIfUnmodifiedSinceStringLength, HttpRequestHeaders.HeaderIfUnmodifiedSince), _
	Type<RequestHeaderNode>(@HeaderMaxForwardsString, HeaderMaxForwardsStringLength, HttpRequestHeaders.HeaderMaxForwards), _
	Type<RequestHeaderNode>(@HeaderOriginString, HeaderOriginStringLength, HttpRequestHeaders.HeaderOrigin), _
	Type<RequestHeaderNode>(@HeaderPragmaString, HeaderPragmaStringLength, HttpRequestHeaders.HeaderPragma), _
	Type<RequestHeaderNode>(@HeaderProxyAuthorizationString, HeaderProxyAuthorizationStringLength, HttpRequestHeaders.HeaderProxyAuthorization), _
	Type<RequestHeaderNode>(@HeaderSecWebSocketKeyString, HeaderSecWebSocketKeyStringLength, HttpRequestHeaders.HeaderSecWebSocketKey), _
	Type<RequestHeaderNode>(@HeaderSecWebSocketKey1String, HeaderSecWebSocketKey1StringLength, HttpRequestHeaders.HeaderSecWebSocketKey1), _
	Type<RequestHeaderNode>(@HeaderSecWebSocketKey2String, HeaderSecWebSocketKey2StringLength, HttpRequestHeaders.HeaderSecWebSocketKey2), _
	Type<RequestHeaderNode>(@HeaderUpgradeString, HeaderUpgradeStringLength, HttpRequestHeaders.HeaderUpgrade), _
	Type<RequestHeaderNode>(@HeaderSecWebSocketVersionString, HeaderSecWebSocketVersionStringLength, HttpRequestHeaders.HeaderSecWebSocketVersion), _
	Type<RequestHeaderNode>(@HeaderTeString, HeaderTeStringLength, HttpRequestHeaders.HeaderTe), _
	Type<RequestHeaderNode>(@HeaderTrailerString, HeaderTrailerStringLength, HttpRequestHeaders.HeaderTrailer), _
	Type<RequestHeaderNode>(@HeaderTransferEncodingString, HeaderTransferEncodingStringLength, HttpRequestHeaders.HeaderTransferEncoding), _
	Type<RequestHeaderNode>(@HeaderViaString, HeaderViaStringLength, HttpRequestHeaders.HeaderVia), _
	Type<RequestHeaderNode>(@HeaderWarningString, HeaderWarningStringLength, HttpRequestHeaders.HeaderWarning), _
	Type<RequestHeaderNode>(@HeaderWebSocketProtocolString, HeaderWebSocketProtocolStringLength, HttpRequestHeaders.HeaderWebSocketProtocol) _
}

Dim Shared ResponseHeaderNodesVector(1 To HttpResponseHeadersSize) As ResponseHeaderNode = { _
	Type<ResponseHeaderNode>(@HeaderAcceptRangesString, HeaderAcceptRangesStringLength, HttpResponseHeaders.HeaderAcceptRanges), _
	Type<ResponseHeaderNode>(@HeaderAgeString, HeaderAgeStringLength, HttpResponseHeaders.HeaderAge), _
	Type<ResponseHeaderNode>(@HeaderAllowString, HeaderAllowStringLength, HttpResponseHeaders.HeaderAllow), _
	Type<ResponseHeaderNode>(@HeaderCacheControlString, HeaderCacheControlStringLength, HttpResponseHeaders.HeaderCacheControl), _
	Type<ResponseHeaderNode>(@HeaderConnectionString, HeaderConnectionStringLength, HttpResponseHeaders.HeaderConnection), _
	Type<ResponseHeaderNode>(@HeaderContentEncodingString, HeaderContentEncodingStringLength, HttpResponseHeaders.HeaderContentEncoding), _
	Type<ResponseHeaderNode>(@HeaderContentLanguageString, HeaderContentLanguageStringLength, HttpResponseHeaders.HeaderContentLanguage), _
	Type<ResponseHeaderNode>(@HeaderContentLengthString, HeaderContentLengthStringLength, HttpResponseHeaders.HeaderContentLength), _
	Type<ResponseHeaderNode>(@HeaderContentLocationString, HeaderContentLocationStringLength, HttpResponseHeaders.HeaderContentLocation), _
	Type<ResponseHeaderNode>(@HeaderContentMd5String, HeaderContentMd5StringLength, HttpResponseHeaders.HeaderContentMd5), _
	Type<ResponseHeaderNode>(@HeaderContentRangeString, HeaderContentRangeStringLength, HttpResponseHeaders.HeaderContentRange), _
	Type<ResponseHeaderNode>(@HeaderContentTypeString, HeaderContentTypeStringLength, HttpResponseHeaders.HeaderContentType), _
	Type<ResponseHeaderNode>(@HeaderDateString, HeaderDateStringLength, HttpResponseHeaders.HeaderDate), _
	Type<ResponseHeaderNode>(@HeaderETagString, HeaderETagStringLength, HttpResponseHeaders.HeaderETag), _
	Type<ResponseHeaderNode>(@HeaderExpiresString, HeaderExpiresStringLength, HttpResponseHeaders.HeaderExpires), _
	Type<ResponseHeaderNode>(@HeaderKeepAliveString, HeaderKeepAliveStringLength, HttpResponseHeaders.HeaderKeepAlive), _
	Type<ResponseHeaderNode>(@HeaderLastModifiedString, HeaderLastModifiedStringLength, HttpResponseHeaders.HeaderLastModified), _
	Type<ResponseHeaderNode>(@HeaderLocationString, HeaderLocationStringLength, HttpResponseHeaders.HeaderLocation), _
	Type<ResponseHeaderNode>(@HeaderPragmaString, HeaderPragmaStringLength, HttpResponseHeaders.HeaderPragma), _
	Type<ResponseHeaderNode>(@HeaderProxyAuthenticateString, HeaderProxyAuthenticateStringLength, HttpResponseHeaders.HeaderProxyAuthenticate), _
	Type<ResponseHeaderNode>(@HeaderRetryAfterString, HeaderRetryAfterStringLength, HttpResponseHeaders.HeaderRetryAfter), _
	Type<ResponseHeaderNode>(@HeaderSecWebSocketAcceptString, HeaderSecWebSocketAcceptStringLength, HttpResponseHeaders.HeaderSecWebSocketAccept), _
	Type<ResponseHeaderNode>(@HeaderSecWebSocketLocationString, HeaderSecWebSocketLocationStringLength, HttpResponseHeaders.HeaderSecWebSocketLocation), _
	Type<ResponseHeaderNode>(@HeaderSecWebSocketOriginString, HeaderSecWebSocketOriginStringLength, HttpResponseHeaders.HeaderSecWebSocketOrigin), _
	Type<ResponseHeaderNode>(@HeaderSecWebSocketProtocolString, HeaderSecWebSocketProtocolStringLength, HttpResponseHeaders.HeaderSecWebSocketProtocol), _
	Type<ResponseHeaderNode>(@HeaderServerString, HeaderServerStringLength, HttpResponseHeaders.HeaderServer), _
	Type<ResponseHeaderNode>(@HeaderSetCookieString, HeaderSetCookieStringLength, HttpResponseHeaders.HeaderSetCookie), _
	Type<ResponseHeaderNode>(@HeaderTrailerString, HeaderTrailerStringLength, HttpResponseHeaders.HeaderTrailer), _
	Type<ResponseHeaderNode>(@HeaderTransferEncodingString, HeaderTransferEncodingStringLength, HttpResponseHeaders.HeaderTransferEncoding), _
	Type<ResponseHeaderNode>(@HeaderUpgradeString, HeaderUpgradeStringLength, HttpResponseHeaders.HeaderUpgrade), _
	Type<ResponseHeaderNode>(@HeaderVaryString, HeaderVaryStringLength, HttpResponseHeaders.HeaderVary), _
	Type<ResponseHeaderNode>(@HeaderViaString, HeaderViaStringLength, HttpResponseHeaders.HeaderVia), _
	Type<ResponseHeaderNode>(@HeaderWarningString, HeaderWarningStringLength, HttpResponseHeaders.HeaderWarning), _
	Type<ResponseHeaderNode>(@HeaderWebSocketLocationString, HeaderWebSocketLocationStringLength, HttpResponseHeaders.HeaderWebSocketLocation), _
	Type<ResponseHeaderNode>(@HeaderWebSocketOriginString, HeaderWebSocketOriginStringLength, HttpResponseHeaders.HeaderWebSocketOrigin), _
	Type<ResponseHeaderNode>(@HeaderWebSocketProtocolString, HeaderWebSocketProtocolStringLength, HttpResponseHeaders.HeaderWebSocketProtocol), _
	Type<ResponseHeaderNode>(@HeaderWWWAuthenticateString, HeaderWWWAuthenticateStringLength, HttpResponseHeaders.HeaderWwwAuthenticate) _
}

Dim Shared CgiHeaderNodesVector(1 To HttpRequestHeadersSize) As CgiHeaderNode = { _
	Type<CgiHeaderNode>(@"HTTP_ACCEPT", 11, HttpRequestHeaders.HeaderAccept), _
	Type<CgiHeaderNode>(@"HTTP_ACCEPT_CHARSET", 19, HttpRequestHeaders.HeaderAcceptCharset), _
	Type<CgiHeaderNode>(@"HTTP_ACCEPT_ENCODING", 20, HttpRequestHeaders.HeaderAcceptEncoding), _
	Type<CgiHeaderNode>(@"HTTP_ACCEPT_LANGUAGE", 20, HttpRequestHeaders.HeaderAcceptLanguage), _
	Type<CgiHeaderNode>(@"AUTH_TYPE", 9, HttpRequestHeaders.HeaderAuthorization), _
	Type<CgiHeaderNode>(@"HTTP_CACHE_CONTROL", 18, HttpRequestHeaders.HeaderCacheControl), _
	Type<CgiHeaderNode>(@"HTTP_CONNECTION", 15, HttpRequestHeaders.HeaderConnection), _
	Type<CgiHeaderNode>(@"HTTP_CONTENT_ENCODING", 21, HttpRequestHeaders.HeaderContentEncoding), _
	Type<CgiHeaderNode>(@"HTTP_CONTENT_LANGUAGE", 21, HttpRequestHeaders.HeaderContentLanguage), _
	Type<CgiHeaderNode>(@"CONTENT_LENGTH", 14, HttpRequestHeaders.HeaderContentLength), _
	Type<CgiHeaderNode>(@"HTTP_CONTENT_MD5", 16, HttpRequestHeaders.HeaderContentMd5), _
	Type<CgiHeaderNode>(@"HTTP_CONTENT_RANGE", 18, HttpRequestHeaders.HeaderContentRange), _
	Type<CgiHeaderNode>(@"CONTENT_TYPE", 12, HttpRequestHeaders.HeaderContentType), _
	Type<CgiHeaderNode>(@"HTTP_COOKIE", 11, HttpRequestHeaders.HeaderCookie), _
	Type<CgiHeaderNode>(@"HTTP_DNT", 8, HttpRequestHeaders.HeaderDNT), _
	Type<CgiHeaderNode>(@"HTTP_EXPECT", 11, HttpRequestHeaders.HeaderExpect), _
	Type<CgiHeaderNode>(@"HTTP_FROM", 9, HttpRequestHeaders.HeaderFrom), _
	Type<CgiHeaderNode>(@"HTTP_HOST", 9, HttpRequestHeaders.HeaderHost), _
	Type<CgiHeaderNode>(@"HTTP_IF_MATCH", 13, HttpRequestHeaders.HeaderIfMatch), _
	Type<CgiHeaderNode>(@"HTTP_IF_MODIFIED_SINCE", 22, HttpRequestHeaders.HeaderIfModifiedSince), _
	Type<CgiHeaderNode>(@"HTTP_IF_NONE_MATCH", 18, HttpRequestHeaders.HeaderIfNoneMatch), _
	Type<CgiHeaderNode>(@"HTTP_IF_RANGE", 13, HttpRequestHeaders.HeaderIfRange), _
	Type<CgiHeaderNode>(@"HTTP_IF_UNMODIFIED_SINCE", 24, HttpRequestHeaders.HeaderIfUnmodifiedSince), _
	Type<CgiHeaderNode>(@"HTTP_KEEP_ALIVE", 15, HttpRequestHeaders.HeaderKeepAlive), _
	Type<CgiHeaderNode>(@"HTTP_MAX_FORWARDS", 17, HttpRequestHeaders.HeaderMaxForwards), _
	Type<CgiHeaderNode>(@"HTTP_ORIGIN", 11, HttpRequestHeaders.HeaderOrigin), _
	Type<CgiHeaderNode>(@"HTTP_PRAGMA", 11, HttpRequestHeaders.HeaderPragma), _
	Type<CgiHeaderNode>(@"HTTP_PROXY_AUTHORIZATION", 24, HttpRequestHeaders.HeaderProxyAuthorization), _
	Type<CgiHeaderNode>(@"HTTP_RANGE", 10, HttpRequestHeaders.HeaderRange), _
	Type<CgiHeaderNode>(@"HTTP_REFERER", 12, HttpRequestHeaders.HeaderReferer), _
	Type<CgiHeaderNode>(@"HTTP_SEC_WEBSOCKET_KEY", 22, HttpRequestHeaders.HeaderSecWebSocketKey), _
	Type<CgiHeaderNode>(@"HTTP_SEC_WEBSOCKET_KEY1", 23, HttpRequestHeaders.HeaderSecWebSocketKey1), _
	Type<CgiHeaderNode>(@"HTTP_SEC_WEBSOCKET_KEY2", 23, HttpRequestHeaders.HeaderSecWebSocketKey2), _
	Type<CgiHeaderNode>(@"HTTP_SEC_WEBSOCKET_VERSION", 26, HttpRequestHeaders.HeaderSecWebSocketVersion), _
	Type<CgiHeaderNode>(@"HTTP_TE", 7, HttpRequestHeaders.HeaderTe), _
	Type<CgiHeaderNode>(@"HTTP_TRAILER", 12, HttpRequestHeaders.HeaderTrailer), _
	Type<CgiHeaderNode>(@"HTTP_TRANSFER_ENCODING", 22, HttpRequestHeaders.HeaderTransferEncoding), _
	Type<CgiHeaderNode>(@"HTTP_UPGRADE", 12, HttpRequestHeaders.HeaderUpgrade), _
	Type<CgiHeaderNode>(@"HTTP_UPGRADE_INSECURE_REQUESTS", 30, HttpRequestHeaders.HeaderUpgradeInsecureRequests), _
	Type<CgiHeaderNode>(@"HTTP_USER_AGENT", 15, HttpRequestHeaders.HeaderUserAgent), _
	Type<CgiHeaderNode>(@"HTTP_VIA", 8, HttpRequestHeaders.HeaderVia), _
	Type<CgiHeaderNode>(@"HTTP_WARNING", 12, HttpRequestHeaders.HeaderWarning), _
	Type<CgiHeaderNode>(@"HTTP_WEBSOCKET_PROTOCOL", 23, HttpRequestHeaders.HeaderWebSocketProtocol) _
}

Function GetHttpMethodIndex( _
		ByVal s As WString Ptr, _
		ByVal pHttpMethod As HttpMethods Ptr _
	)As Boolean
	
	If lstrcmp(s, HttpMethodGet) = 0 Then
		*pHttpMethod = HttpMethods.HttpGet
		Return True
	End If
	
	If lstrcmp(s, HttpMethodPost) = 0 Then
		*pHttpMethod = HttpMethods.HttpPost
		Return True
	End If
	
	If lstrcmp(s, HttpMethodHead) = 0 Then
		*pHttpMethod = HttpMethods.HttpHead
		Return True
	End If
	
	If lstrcmp(s, HttpMethodPut) = 0 Then
		*pHttpMethod = HttpMethods.HttpPut
		Return True
	End If
	
	If lstrcmp(s, HttpMethodConnect) = 0 Then
		*pHttpMethod = HttpMethods.HttpConnect
		Return True
	End If
	
	If lstrcmp(s, HttpMethodDelete) = 0 Then
		*pHttpMethod = HttpMethods.HttpDelete
		Return True
	End If
	
	If lstrcmp(s, HttpMethodOptions) = 0 Then
		*pHttpMethod = HttpMethods.HttpOptions
		Return True
	End If
	
	If lstrcmp(s, HttpMethodTrace) = 0 Then
		*pHttpMethod = HttpMethods.HttpTrace
		Return True
	End If
	
	Return False
	
End Function

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
	
	If lstrlen(s) = 0 Then
		*pVersion = HttpVersions.Http09
		Return True
	End If
	
	If lstrcmp(s, @HttpVersion11String) = 0 Then
		*pVersion = HttpVersions.Http11
		Return True
	End If
	
	If lstrcmp(s, @HttpVersion10String) = 0 Then
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
		If lstrcmpi(RequestHeaderNodesVector(i).pHeader, pHeader) = 0 Then
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
		If lstrcmpi(ResponseHeaderNodesVector(i).pHeader, pHeader) = 0 Then
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
