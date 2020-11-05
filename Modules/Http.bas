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

Type HeaderNode
	Dim pHeader As WString Ptr
	Dim HeaderLength As Integer
	Dim HeaderIndex As HttpRequestHeaders
End Type

Dim Shared RequestHeadersVector(1 To HttpRequestHeadersSize) As HeaderNode = { _
	Type<HeaderNode>(@HeaderHostString, HeaderHostStringLength, HttpRequestHeaders.HeaderHost), _
	Type<HeaderNode>(@HeaderAcceptLanguageString, HeaderAcceptLanguageStringLength, HttpRequestHeaders.HeaderAcceptLanguage), _
	Type<HeaderNode>(@HeaderUserAgentString, HeaderUserAgentStringLength, HttpRequestHeaders.HeaderUserAgent), _
	Type<HeaderNode>(@HeaderAcceptEncodingString, HeaderAcceptEncodingStringLength, HttpRequestHeaders.HeaderAcceptEncoding), _
	Type<HeaderNode>(@HeaderAcceptString, HeaderAcceptStringLength, HttpRequestHeaders.HeaderAccept), _
	Type<HeaderNode>(@HeaderConnectionString, HeaderConnectionStringLength, HttpRequestHeaders.HeaderConnection), _
	Type<HeaderNode>(@HeaderCacheControlString, HeaderCacheControlStringLength, HttpRequestHeaders.HeaderCacheControl), _
	Type<HeaderNode>(@HeaderIfModifiedSinceString, HeaderIfModifiedSinceStringLength, HttpRequestHeaders.HeaderIfModifiedSince), _
	Type<HeaderNode>(@HeaderRefererString, HeaderRefererStringLength, HttpRequestHeaders.HeaderReferer), _
	Type<HeaderNode>(@HeaderIfNoneMatchString, HeaderIfNoneMatchStringLength, HttpRequestHeaders.HeaderIfNoneMatch), _
	Type<HeaderNode>(@HeaderDNTString, HeaderDNTStringLength, HttpRequestHeaders.HeaderDNT), _
	Type<HeaderNode>(@HeaderUpgradeInsecureRequestsString, HeaderUpgradeInsecureRequestsStringLength, HttpRequestHeaders.HeaderUpgradeInsecureRequests), _
	Type<HeaderNode>(@HeaderRangeString, HeaderRangeStringLength, HttpRequestHeaders.HeaderRange), _
	Type<HeaderNode>(@HeaderAuthorizationString, HeaderAuthorizationStringLength, HttpRequestHeaders.HeaderAuthorization), _
	Type<HeaderNode>(@HeaderContentLengthString, HeaderContentLengthStringLength, HttpRequestHeaders.HeaderContentLength), _
	Type<HeaderNode>(@HeaderContentTypeString, HeaderContentTypeStringLength, HttpRequestHeaders.HeaderContentType), _
	Type<HeaderNode>(@HeaderCookieString, HeaderCookieStringLength, HttpRequestHeaders.HeaderCookie), _
	Type<HeaderNode>(@HeaderContentLanguageString, HeaderContentLanguageStringLength, HttpRequestHeaders.HeaderContentLanguage), _
	Type<HeaderNode>(@HeaderAcceptCharsetString, HeaderAcceptCharsetStringLength, HttpRequestHeaders.HeaderAcceptCharset), _
	Type<HeaderNode>(@HeaderContentEncodingString, HeaderContentEncodingStringLength, HttpRequestHeaders.HeaderContentEncoding), _
	Type<HeaderNode>(@HeaderKeepAliveString, HeaderKeepAliveStringLength, HttpRequestHeaders.HeaderKeepAlive), _
	Type<HeaderNode>(@HeaderExpectString, HeaderExpectStringLength, HttpRequestHeaders.HeaderExpect), _
	Type<HeaderNode>(@HeaderContentMd5String, HeaderContentMd5StringLength, HttpRequestHeaders.HeaderContentMd5), _
	Type<HeaderNode>(@HeaderContentRangeString, HeaderContentRangeStringLength, HttpRequestHeaders.HeaderContentRange), _
	Type<HeaderNode>(@HeaderFromString, HeaderFromStringLength, HttpRequestHeaders.HeaderFrom), _
	Type<HeaderNode>(@HeaderIfMatchString, HeaderIfMatchStringLength, HttpRequestHeaders.HeaderIfMatch), _
	Type<HeaderNode>(@HeaderIfRangeString, HeaderIfRangeStringLength, HttpRequestHeaders.HeaderIfRange), _
	Type<HeaderNode>(@HeaderIfUnmodifiedSinceString, HeaderIfUnmodifiedSinceStringLength, HttpRequestHeaders.HeaderIfUnmodifiedSince), _
	Type<HeaderNode>(@HeaderMaxForwardsString, HeaderMaxForwardsStringLength, HttpRequestHeaders.HeaderMaxForwards), _
	Type<HeaderNode>(@HeaderOriginString, HeaderOriginStringLength, HttpRequestHeaders.HeaderOrigin), _
	Type<HeaderNode>(@HeaderPragmaString, HeaderPragmaStringLength, HttpRequestHeaders.HeaderPragma), _
	Type<HeaderNode>(@HeaderProxyAuthorizationString, HeaderProxyAuthorizationStringLength, HttpRequestHeaders.HeaderProxyAuthorization), _
	Type<HeaderNode>(@HeaderSecWebSocketKeyString, HeaderSecWebSocketKeyStringLength, HttpRequestHeaders.HeaderSecWebSocketKey), _
	Type<HeaderNode>(@HeaderSecWebSocketKey1String, HeaderSecWebSocketKey1StringLength, HttpRequestHeaders.HeaderSecWebSocketKey1), _
	Type<HeaderNode>(@HeaderSecWebSocketKey2String, HeaderSecWebSocketKey2StringLength, HttpRequestHeaders.HeaderSecWebSocketKey2), _
	Type<HeaderNode>(@HeaderUpgradeString, HeaderUpgradeStringLength, HttpRequestHeaders.HeaderUpgrade), _
	Type<HeaderNode>(@HeaderSecWebSocketVersionString, HeaderSecWebSocketVersionStringLength, HttpRequestHeaders.HeaderSecWebSocketVersion), _
	Type<HeaderNode>(@HeaderTeString, HeaderTeStringLength, HttpRequestHeaders.HeaderTe), _
	Type<HeaderNode>(@HeaderTrailerString, HeaderTrailerStringLength, HttpRequestHeaders.HeaderTrailer), _
	Type<HeaderNode>(@HeaderTransferEncodingString, HeaderTransferEncodingStringLength, HttpRequestHeaders.HeaderTransferEncoding), _
	Type<HeaderNode>(@HeaderViaString, HeaderViaStringLength, HttpRequestHeaders.HeaderVia), _
	Type<HeaderNode>(@HeaderWarningString, HeaderWarningStringLength, HttpRequestHeaders.HeaderWarning), _
	Type<HeaderNode>(@HeaderWebSocketProtocolString, HeaderWebSocketProtocolStringLength, HttpRequestHeaders.HeaderWebSocketProtocol) _
}

Dim Shared ResponseHeadersVector(1 To HttpResponseHeadersSize) As HeaderNode = { _
	Type<HeaderNode>(@HeaderAcceptRangesString, HeaderAcceptRangesStringLength, HttpResponseHeaders.HeaderAcceptRanges), _
	Type<HeaderNode>(@HeaderAgeString, HeaderAgeStringLength, HttpResponseHeaders.HeaderAge), _
	Type<HeaderNode>(@HeaderAllowString, HeaderAllowStringLength, HttpResponseHeaders.HeaderAllow), _
	Type<HeaderNode>(@HeaderCacheControlString, HeaderCacheControlStringLength, HttpResponseHeaders.HeaderCacheControl), _
	Type<HeaderNode>(@HeaderConnectionString, HeaderConnectionStringLength, HttpResponseHeaders.HeaderConnection), _
	Type<HeaderNode>(@HeaderContentEncodingString, HeaderContentEncodingStringLength, HttpResponseHeaders.HeaderContentEncoding), _
	Type<HeaderNode>(@HeaderContentLanguageString, HeaderContentLanguageStringLength, HttpResponseHeaders.HeaderContentLanguage), _
	Type<HeaderNode>(@HeaderContentLengthString, HeaderContentLengthStringLength, HttpResponseHeaders.HeaderContentLength), _
	Type<HeaderNode>(@HeaderContentLocationString, HeaderContentLocationStringLength, HttpResponseHeaders.HeaderContentLocation), _
	Type<HeaderNode>(@HeaderContentMd5String, HeaderContentMd5StringLength, HttpResponseHeaders.HeaderContentMd5), _
	Type<HeaderNode>(@HeaderContentRangeString, HeaderContentRangeStringLength, HttpResponseHeaders.HeaderContentRange), _
	Type<HeaderNode>(@HeaderContentTypeString, HeaderContentTypeStringLength, HttpResponseHeaders.HeaderContentType), _
	Type<HeaderNode>(@HeaderDateString, HeaderDateStringLength, HttpResponseHeaders.HeaderDate), _
	Type<HeaderNode>(@HeaderETagString, HeaderETagStringLength, HttpResponseHeaders.HeaderETag), _
	Type<HeaderNode>(@HeaderExpiresString, HeaderExpiresStringLength, HttpResponseHeaders.HeaderExpires), _
	Type<HeaderNode>(@HeaderKeepAliveString, HeaderKeepAliveStringLength, HttpResponseHeaders.HeaderKeepAlive), _
	Type<HeaderNode>(@HeaderLastModifiedString, HeaderLastModifiedStringLength, HttpResponseHeaders.HeaderLastModified), _
	Type<HeaderNode>(@HeaderLocationString, HeaderLocationStringLength, HttpResponseHeaders.HeaderLocation), _
	Type<HeaderNode>(@HeaderPragmaString, HeaderPragmaStringLength, HttpResponseHeaders.HeaderPragma), _
	Type<HeaderNode>(@HeaderProxyAuthenticateString, HeaderProxyAuthenticateStringLength, HttpResponseHeaders.HeaderProxyAuthenticate), _
	Type<HeaderNode>(@HeaderRetryAfterString, HeaderRetryAfterStringLength, HttpResponseHeaders.HeaderRetryAfter), _
	Type<HeaderNode>(@HeaderSecWebSocketAcceptString, HeaderSecWebSocketAcceptStringLength, HttpResponseHeaders.HeaderSecWebSocketAccept), _
	Type<HeaderNode>(@HeaderSecWebSocketLocationString, HeaderSecWebSocketLocationStringLength, HttpResponseHeaders.HeaderSecWebSocketLocation), _
	Type<HeaderNode>(@HeaderSecWebSocketOriginString, HeaderSecWebSocketOriginStringLength, HttpResponseHeaders.HeaderSecWebSocketOrigin), _
	Type<HeaderNode>(@HeaderSecWebSocketProtocolString, HeaderSecWebSocketProtocolStringLength, HttpResponseHeaders.HeaderSecWebSocketProtocol), _
	Type<HeaderNode>(@HeaderServerString, HeaderServerStringLength, HttpResponseHeaders.HeaderServer), _
	Type<HeaderNode>(@HeaderSetCookieString, HeaderSetCookieStringLength, HttpResponseHeaders.HeaderSetCookie), _
	Type<HeaderNode>(@HeaderTrailerString, HeaderTrailerStringLength, HttpResponseHeaders.HeaderTrailer), _
	Type<HeaderNode>(@HeaderTransferEncodingString, HeaderTransferEncodingStringLength, HttpResponseHeaders.HeaderTransferEncoding), _
	Type<HeaderNode>(@HeaderUpgradeString, HeaderUpgradeStringLength, HttpResponseHeaders.HeaderUpgrade), _
	Type<HeaderNode>(@HeaderVaryString, HeaderVaryStringLength, HttpResponseHeaders.HeaderVary), _
	Type<HeaderNode>(@HeaderViaString, HeaderViaStringLength, HttpResponseHeaders.HeaderVia), _
	Type<HeaderNode>(@HeaderWarningString, HeaderWarningStringLength, HttpResponseHeaders.HeaderWarning), _
	Type<HeaderNode>(@HeaderWebSocketLocationString, HeaderWebSocketLocationStringLength, HttpResponseHeaders.HeaderWebSocketLocation), _
	Type<HeaderNode>(@HeaderWebSocketOriginString, HeaderWebSocketOriginStringLength, HttpResponseHeaders.HeaderWebSocketOrigin), _
	Type<HeaderNode>(@HeaderWebSocketProtocolString, HeaderWebSocketProtocolStringLength, HttpResponseHeaders.HeaderWebSocketProtocol), _
	Type<HeaderNode>(@HeaderWWWAuthenticateString, HeaderWWWAuthenticateStringLength, HttpResponseHeaders.HeaderWwwAuthenticate) _
}

Function GetHttpMethod( _
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

Function GetHttpVersion( _
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
		If lstrcmpi(RequestHeadersVector(i).pHeader, pHeader) = 0 Then
			*pIndex = RequestHeadersVector(i).HeaderIndex
			Return True
		End If
	Next
	
	*pIndex = 0
	Return False
	
End Function

Function GetKnownResponseHeaderIndex( _
		ByVal pHeader As WString Ptr, _
		ByVal pIndex As HttpResponseHeaders Ptr _
	)As Boolean
	
	For i As Integer = 1 To HttpResponseHeadersSize
		If lstrcmpi(ResponseHeadersVector(i).pHeader, pHeader) = 0 Then
			*pIndex = ResponseHeadersVector(i).HeaderIndex
			Return True
		End If
	Next
	
	*pIndex = 0
	Return False
	
End Function

Function KnownResponseHeaderToString( _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal BufferLength As Integer Ptr _
	)As WString Ptr
	
	Dim intBufferLength As Integer = 0
	Select Case HeaderIndex
		
		Case HttpResponseHeaders.HeaderAcceptRanges
			intBufferLength = HeaderAcceptRangesStringLength
			KnownResponseHeaderToString = @HeaderAcceptRangesString
			
		Case HttpResponseHeaders.HeaderAge
			intBufferLength = HeaderAgeStringLength
			KnownResponseHeaderToString = @HeaderAgeString
			
		Case HttpResponseHeaders.HeaderAllow
			intBufferLength = HeaderAllowStringLength
			KnownResponseHeaderToString = @HeaderAllowString
			
		Case HttpResponseHeaders.HeaderCacheControl
			intBufferLength = HeaderCacheControlStringLength
			KnownResponseHeaderToString = @HeaderCacheControlString
			
		Case HttpResponseHeaders.HeaderConnection
			intBufferLength = HeaderConnectionStringLength
			KnownResponseHeaderToString = @HeaderConnectionString
			
		Case HttpResponseHeaders.HeaderContentEncoding
			intBufferLength = HeaderContentEncodingStringLength
			KnownResponseHeaderToString = @HeaderContentEncodingString
			
		Case HttpResponseHeaders.HeaderContentLength
			intBufferLength = HeaderContentLengthStringLength
			KnownResponseHeaderToString = @HeaderContentLengthString
			
		Case HttpResponseHeaders.HeaderContentLanguage
			intBufferLength = HeaderContentLanguageStringLength
			KnownResponseHeaderToString = @HeaderContentLanguageString
			
		Case HttpResponseHeaders.HeaderContentLocation
			intBufferLength = HeaderContentLocationStringLength
			KnownResponseHeaderToString = @HeaderContentLocationString
			
		Case HttpResponseHeaders.HeaderContentMd5
			intBufferLength = HeaderContentMd5StringLength
			KnownResponseHeaderToString = @HeaderContentMd5String
			
		Case HttpResponseHeaders.HeaderContentRange
			intBufferLength = HeaderContentRangeStringLength
			KnownResponseHeaderToString = @HeaderContentRangeString
			
		Case HttpResponseHeaders.HeaderContentType
			intBufferLength = HeaderContentTypeStringLength
			KnownResponseHeaderToString = @HeaderContentTypeString
			
		Case HttpResponseHeaders.HeaderDate
			intBufferLength = HeaderDateStringLength
			KnownResponseHeaderToString = @HeaderDateString
			
		Case HttpResponseHeaders.HeaderEtag
			intBufferLength = HeaderETagStringLength
			KnownResponseHeaderToString = @HeaderETagString
			
		Case HttpResponseHeaders.HeaderExpires
			intBufferLength = HeaderExpiresStringLength
			KnownResponseHeaderToString = @HeaderExpiresString
			
		Case HttpResponseHeaders.HeaderKeepAlive
			intBufferLength = HeaderKeepAliveStringLength
			KnownResponseHeaderToString = @HeaderKeepAliveString
			
		Case HttpResponseHeaders.HeaderLastModified
			intBufferLength = HeaderLastModifiedStringLength
			KnownResponseHeaderToString = @HeaderLastModifiedString
			
		Case HttpResponseHeaders.HeaderLocation
			intBufferLength = HeaderLocationStringLength
			KnownResponseHeaderToString = @HeaderLocationString
			
		Case HttpResponseHeaders.HeaderPragma
			intBufferLength = HeaderPragmaStringLength
			KnownResponseHeaderToString = @HeaderPragmaString
			
		Case HttpResponseHeaders.HeaderProxyAuthenticate
			intBufferLength = HeaderProxyAuthenticateStringLength
			KnownResponseHeaderToString = @HeaderProxyAuthenticateString
			
		Case HttpResponseHeaders.HeaderRetryAfter
			intBufferLength = HeaderRetryAfterStringLength
			KnownResponseHeaderToString = @HeaderRetryAfterString
			
		Case HttpResponseHeaders.HeaderSecWebSocketAccept
			intBufferLength = HeaderSecWebSocketAcceptStringLength
			KnownResponseHeaderToString = @HeaderSecWebSocketAcceptString
			
		Case HttpResponseHeaders.HeaderSecWebSocketLocation
			intBufferLength = HeaderSecWebSocketLocationStringLength
			KnownResponseHeaderToString = @HeaderSecWebSocketLocationString
			
		Case HttpResponseHeaders.HeaderSecWebSocketOrigin
			intBufferLength = HeaderSecWebSocketOriginStringLength
			KnownResponseHeaderToString = @HeaderSecWebSocketOriginString
			
		Case HttpResponseHeaders.HeaderSecWebSocketProtocol
			intBufferLength = HeaderSecWebSocketProtocolStringLength
			KnownResponseHeaderToString = @HeaderSecWebSocketProtocolString
			
		Case HttpResponseHeaders.HeaderServer
			intBufferLength = HeaderServerStringLength
			KnownResponseHeaderToString = @HeaderServerString
			
		Case HttpResponseHeaders.HeaderSetCookie
			intBufferLength = HeaderSetCookieStringLength
			KnownResponseHeaderToString = @HeaderSetCookieString
			
		Case HttpResponseHeaders.HeaderTrailer
			intBufferLength = HeaderTrailerStringLength
			KnownResponseHeaderToString = @HeaderTrailerString
			
		Case HttpResponseHeaders.HeaderTransferEncoding
			intBufferLength = HeaderTransferEncodingStringLength
			KnownResponseHeaderToString = @HeaderTransferEncodingString
			
		Case HttpResponseHeaders.HeaderUpgrade
			intBufferLength = HeaderUpgradeStringLength
			KnownResponseHeaderToString = @HeaderUpgradeString
			
		Case HttpResponseHeaders.HeaderVary
			intBufferLength = HeaderVaryStringLength
			KnownResponseHeaderToString = @HeaderVaryString
			
		Case HttpResponseHeaders.HeaderVia
			intBufferLength = HeaderViaStringLength
			KnownResponseHeaderToString = @HeaderViaString
			
		Case HttpResponseHeaders.HeaderWarning
			intBufferLength = HeaderWarningStringLength
			KnownResponseHeaderToString = @HeaderWarningString
			
		Case HttpResponseHeaders.HeaderWebSocketLocation
			intBufferLength = HeaderWebSocketLocationStringLength
			KnownResponseHeaderToString = @HeaderWebSocketLocationString
			
		Case HttpResponseHeaders.HeaderWebSocketOrigin
			intBufferLength = HeaderWebSocketOriginStringLength
			KnownResponseHeaderToString = @HeaderWebSocketOriginString
			
		Case HttpResponseHeaders.HeaderWebSocketProtocol
			intBufferLength = HeaderWebSocketProtocolStringLength
			KnownResponseHeaderToString = @HeaderWebSocketProtocolString
			
		Case HttpResponseHeaders.HeaderWwwAuthenticate
			intBufferLength = HeaderWWWAuthenticateStringLength
			KnownResponseHeaderToString = @HeaderWWWAuthenticateString
			
		Case Else
			intBufferLength = 0
			KnownResponseHeaderToString = 0
			
	End Select
	
	If BufferLength <> 0 Then
		*BufferLength = intBufferLength
	End If
	
End Function

Function GetStatusDescription( _
		ByVal StatusCode As HttpStatusCodes, _
		ByVal BufferLength As Integer Ptr _
	)As WString Ptr
	
	Dim intBufferLength As Integer = 0
	
	Select Case StatusCode
		
		Case HttpStatusCodes.CodeContinue
			intBufferLength = HttpStatusCodeString100Length
			GetStatusDescription = @HttpStatusCodeString100
			
		Case HttpStatusCodes.SwitchingProtocols
			intBufferLength = HttpStatusCodeString101Length
			GetStatusDescription = @HttpStatusCodeString101
			
		Case HttpStatusCodes.Processing
			intBufferLength = HttpStatusCodeString102Length
			GetStatusDescription = @HttpStatusCodeString102
			
		Case HttpStatusCodes.OK
			intBufferLength = HttpStatusCodeString200Length
			GetStatusDescription = @HttpStatusCodeString200
			
		Case HttpStatusCodes.Created
			intBufferLength = HttpStatusCodeString201Length
			GetStatusDescription = @HttpStatusCodeString201
			
		Case HttpStatusCodes.Accepted
			intBufferLength = HttpStatusCodeString202Length
			GetStatusDescription = @HttpStatusCodeString202
			
		Case HttpStatusCodes.NonAuthoritativeInformation
			intBufferLength = HttpStatusCodeString203Length
			GetStatusDescription = @HttpStatusCodeString203
			
		Case HttpStatusCodes.NoContent
			intBufferLength = HttpStatusCodeString204Length
			GetStatusDescription = @HttpStatusCodeString204
			
		Case HttpStatusCodes.ResetContent
			intBufferLength = HttpStatusCodeString205Length
			GetStatusDescription = @HttpStatusCodeString205
			
		Case HttpStatusCodes.PartialContent
			intBufferLength = HttpStatusCodeString206Length
			GetStatusDescription = @HttpStatusCodeString206
			
		Case HttpStatusCodes.MultiStatus
			intBufferLength = HttpStatusCodeString207Length
			GetStatusDescription = @HttpStatusCodeString207
			
		Case HttpStatusCodes.IAmUsed
			intBufferLength = HttpStatusCodeString226Length
			GetStatusDescription = @HttpStatusCodeString226
			
		Case HttpStatusCodes.MultipleChoices
			intBufferLength = HttpStatusCodeString300Length
			GetStatusDescription = @HttpStatusCodeString300
			
		Case HttpStatusCodes.MovedPermanently
			intBufferLength = HttpStatusCodeString301Length
			GetStatusDescription = @HttpStatusCodeString301
			
		Case HttpStatusCodes.Found
			intBufferLength = HttpStatusCodeString302Length
			GetStatusDescription = @HttpStatusCodeString302
			
		Case HttpStatusCodes.SeeOther
			intBufferLength = HttpStatusCodeString303Length
			GetStatusDescription = @HttpStatusCodeString303
			
		Case HttpStatusCodes.NotModified
			intBufferLength = HttpStatusCodeString304Length
			GetStatusDescription = @HttpStatusCodeString304
			
		Case HttpStatusCodes.UseProxy
			intBufferLength = HttpStatusCodeString305Length
			GetStatusDescription = @HttpStatusCodeString305
			
		Case HttpStatusCodes.TemporaryRedirect
			intBufferLength = HttpStatusCodeString307Length
			GetStatusDescription = @HttpStatusCodeString307
			
		Case HttpStatusCodes.BadRequest
			intBufferLength = HttpStatusCodeString400Length
			GetStatusDescription = @HttpStatusCodeString400
			
		Case HttpStatusCodes.Unauthorized
			intBufferLength = HttpStatusCodeString401Length
			GetStatusDescription = @HttpStatusCodeString401
			
		Case HttpStatusCodes.PaymentRequired
			intBufferLength = HttpStatusCodeString402Length
			GetStatusDescription = @HttpStatusCodeString402
			
		Case HttpStatusCodes.Forbidden
			intBufferLength = HttpStatusCodeString403Length
			GetStatusDescription = @HttpStatusCodeString403
			
		Case HttpStatusCodes.NotFound
			intBufferLength = HttpStatusCodeString404Length
			GetStatusDescription = @HttpStatusCodeString404
			
		Case HttpStatusCodes.MethodNotAllowed
			intBufferLength = HttpStatusCodeString405Length
			GetStatusDescription = @HttpStatusCodeString405
			
		Case HttpStatusCodes.NotAcceptable
			intBufferLength = HttpStatusCodeString406Length
			GetStatusDescription = @HttpStatusCodeString406
			
		Case HttpStatusCodes.ProxyAuthenticationRequired
			intBufferLength = HttpStatusCodeString407Length
			GetStatusDescription = @HttpStatusCodeString407
			
		Case HttpStatusCodes.RequestTimeout
			intBufferLength = HttpStatusCodeString408Length
			GetStatusDescription = @HttpStatusCodeString408
			
		Case HttpStatusCodes.Conflict
			intBufferLength = HttpStatusCodeString409Length
			GetStatusDescription = @HttpStatusCodeString409
			
		Case HttpStatusCodes.Gone
			intBufferLength = HttpStatusCodeString410Length
			GetStatusDescription = @HttpStatusCodeString410
			
		Case HttpStatusCodes.LengthRequired
			intBufferLength = HttpStatusCodeString411Length
			GetStatusDescription = @HttpStatusCodeString411
			
		Case HttpStatusCodes.PreconditionFailed
			intBufferLength = HttpStatusCodeString412Length
			GetStatusDescription = @HttpStatusCodeString412
			
		Case HttpStatusCodes.RequestEntityTooLarge
			intBufferLength = HttpStatusCodeString413Length
			GetStatusDescription = @HttpStatusCodeString413
			
		Case HttpStatusCodes.RequestURITooLarge
			intBufferLength = HttpStatusCodeString414Length
			GetStatusDescription = @HttpStatusCodeString414
			
		Case HttpStatusCodes.UnsupportedMediaType
			intBufferLength = HttpStatusCodeString415Length
			GetStatusDescription = @HttpStatusCodeString415
			
		Case HttpStatusCodes.RequestedRangeNotSatisfiable
			intBufferLength = HttpStatusCodeString416Length
			GetStatusDescription = @HttpStatusCodeString416
			
		Case HttpStatusCodes.ExpectationFailed
			intBufferLength = HttpStatusCodeString417Length
			GetStatusDescription = @HttpStatusCodeString417
			
		Case HttpStatusCodes.IAmTeapot
			intBufferLength = HttpStatusCodeString418Length
			GetStatusDescription = @HttpStatusCodeString418
			
		' UnprocessableEntity = 422
		' Locked = 423
		' FailedDependency = 424
		' UnorderedCollection = 425
		
		Case HttpStatusCodes.UpgradeRequired
			intBufferLength = HttpStatusCodeString426Length
			GetStatusDescription = @HttpStatusCodeString426
			
		Case HttpStatusCodes.PreconditionRequired
			intBufferLength = HttpStatusCodeString428Length
			GetStatusDescription = @HttpStatusCodeString428
			
		Case HttpStatusCodes.TooManyRequests
			intBufferLength = HttpStatusCodeString429Length
			GetStatusDescription = @HttpStatusCodeString429
			
		Case HttpStatusCodes.RequestHeaderFieldsTooLarge
			intBufferLength = HttpStatusCodeString431Length
			GetStatusDescription = @HttpStatusCodeString431
			
		' RetryWith = 449
		
		Case HttpStatusCodes.UnavailableForLegalReasons
			intBufferLength = HttpStatusCodeString451Length
			GetStatusDescription = @HttpStatusCodeString451
			
		Case HttpStatusCodes.InternalServerError
			intBufferLength = HttpStatusCodeString500Length
			GetStatusDescription = @HttpStatusCodeString500
			
		Case HttpStatusCodes.NotImplemented
			intBufferLength = HttpStatusCodeString501Length
			GetStatusDescription = @HttpStatusCodeString501
			
		Case HttpStatusCodes.BadGateway
			intBufferLength = HttpStatusCodeString502Length
			GetStatusDescription = @HttpStatusCodeString502
			
		Case HttpStatusCodes.ServiceUnavailable
			intBufferLength = HttpStatusCodeString503Length
			GetStatusDescription = @HttpStatusCodeString503
			
		Case HttpStatusCodes.GatewayTimeout
			intBufferLength = HttpStatusCodeString504Length
			GetStatusDescription = @HttpStatusCodeString504
			
		Case HttpStatusCodes.HTTPVersionNotSupported
			intBufferLength = HttpStatusCodeString505Length
			GetStatusDescription = @HttpStatusCodeString505
			
		Case HttpStatusCodes.VariantAlsoNegotiates
			intBufferLength = HttpStatusCodeString506Length
			GetStatusDescription = @HttpStatusCodeString506
			
		Case HttpStatusCodes.InsufficientStorage
			intBufferLength = HttpStatusCodeString507Length
			GetStatusDescription = @HttpStatusCodeString507
			
		Case HttpStatusCodes.LoopDetected
			intBufferLength = HttpStatusCodeString508Length
			GetStatusDescription = @HttpStatusCodeString508
			
		Case HttpStatusCodes.BandwidthLimitExceeded
			intBufferLength = HttpStatusCodeString509Length
			GetStatusDescription = @HttpStatusCodeString509
			
		Case HttpStatusCodes.NotExtended
			intBufferLength = HttpStatusCodeString510Length
			GetStatusDescription = @HttpStatusCodeString510
			
		Case HttpStatusCodes.NetworkAuthenticationRequired
			intBufferLength = HttpStatusCodeString511Length
			GetStatusDescription = @HttpStatusCodeString511
			
		Case Else
			intBufferLength = HttpStatusCodeString200Length
			GetStatusDescription = @HttpStatusCodeString200
			
	End Select
	
	If BufferLength <> 0 Then
		*BufferLength = intBufferLength
	End If
	
End Function

Function KnownRequestCgiHeaderToString( _
		ByVal HeaderIndex As HttpRequestHeaders, _
		ByVal pBufferLength As Integer Ptr _
	)As WString Ptr
	
	Dim intBufferLength As Integer = 0
	
	Select Case HeaderIndex
		
		Case HttpRequestHeaders.HeaderAccept
			intBufferLength = 11
			KnownRequestCgiHeaderToString = @"HTTP_ACCEPT"
			
		Case HttpRequestHeaders.HeaderAcceptCharset
			intBufferLength = 19
			KnownRequestCgiHeaderToString = @"HTTP_ACCEPT_CHARSET"
			
		Case HttpRequestHeaders.HeaderAcceptEncoding
			intBufferLength = 20
			KnownRequestCgiHeaderToString = @"HTTP_ACCEPT_ENCODING"
			
		Case HttpRequestHeaders.HeaderAcceptLanguage
			intBufferLength = 20
			KnownRequestCgiHeaderToString = @"HTTP_ACCEPT_LANGUAGE"
			
		Case HttpRequestHeaders.HeaderAuthorization
			intBufferLength = 9
			KnownRequestCgiHeaderToString = @"AUTH_TYPE"
			
		Case HttpRequestHeaders.HeaderCacheControl
			intBufferLength = 18
			KnownRequestCgiHeaderToString = @"HTTP_CACHE_CONTROL"
			
		Case HttpRequestHeaders.HeaderConnection
			intBufferLength = 15
			KnownRequestCgiHeaderToString = @"HTTP_CONNECTION"
			
		Case HttpRequestHeaders.HeaderContentEncoding
			intBufferLength = 21
			KnownRequestCgiHeaderToString = @"HTTP_CONTENT_ENCODING"
			
		Case HttpRequestHeaders.HeaderContentLanguage
			intBufferLength = 21
			KnownRequestCgiHeaderToString = @"HTTP_CONTENT_LANGUAGE"
			
		Case HttpRequestHeaders.HeaderContentLength
			intBufferLength = 14
			KnownRequestCgiHeaderToString = @"CONTENT_LENGTH"
			
		Case HttpRequestHeaders.HeaderContentMd5
			intBufferLength = 16
			KnownRequestCgiHeaderToString = @"HTTP_CONTENT_MD5"
			
		Case HttpRequestHeaders.HeaderContentRange
			intBufferLength = 18
			KnownRequestCgiHeaderToString = @"HTTP_CONTENT_RANGE"
			
		Case HttpRequestHeaders.HeaderContentType
			intBufferLength = 12
			KnownRequestCgiHeaderToString = @"CONTENT_TYPE"
			
		Case HttpRequestHeaders.HeaderCookie
			intBufferLength = 11
			KnownRequestCgiHeaderToString = @"HTTP_COOKIE"
			
		Case HttpRequestHeaders.HeaderDNT
			intBufferLength = 8
			KnownRequestCgiHeaderToString = @"HTTP_DNT"
			
		Case HttpRequestHeaders.HeaderExpect
			intBufferLength = 11
			KnownRequestCgiHeaderToString = @"HTTP_EXPECT"
			
		Case HttpRequestHeaders.HeaderFrom
			intBufferLength = 9
			KnownRequestCgiHeaderToString = @"HTTP_FROM"
			
		Case HttpRequestHeaders.HeaderHost
			intBufferLength = 9
			KnownRequestCgiHeaderToString = @"HTTP_HOST"
			
		Case HttpRequestHeaders.HeaderIfMatch
			intBufferLength = 13
			KnownRequestCgiHeaderToString = @"HTTP_IF_MATCH"
			
		Case HttpRequestHeaders.HeaderIfModifiedSince
			intBufferLength = 22
			KnownRequestCgiHeaderToString = @"HTTP_IF_MODIFIED_SINCE"
			
		Case HttpRequestHeaders.HeaderIfNoneMatch
			intBufferLength = 18
			KnownRequestCgiHeaderToString = @"HTTP_IF_NONE_MATCH"
			
		Case HttpRequestHeaders.HeaderIfRange
			intBufferLength = 13
			KnownRequestCgiHeaderToString = @"HTTP_IF_RANGE"
			
		Case HttpRequestHeaders.HeaderIfUnmodifiedSince
			intBufferLength = 24
			KnownRequestCgiHeaderToString = @"HTTP_IF_UNMODIFIED_SINCE"
			
		Case HttpRequestHeaders.HeaderKeepAlive
			intBufferLength = 15
			KnownRequestCgiHeaderToString = @"HTTP_KEEP_ALIVE"
			
		Case HttpRequestHeaders.HeaderMaxForwards
			intBufferLength = 17
			KnownRequestCgiHeaderToString = @"HTTP_MAX_FORWARDS"
			
		Case HttpRequestHeaders.HeaderOrigin
			intBufferLength = 11
			KnownRequestCgiHeaderToString = @"HTTP_ORIGIN"
			
		Case HttpRequestHeaders.HeaderPragma
			intBufferLength = 11
			KnownRequestCgiHeaderToString = @"HTTP_PRAGMA"
			
		Case HttpRequestHeaders.HeaderProxyAuthorization
			intBufferLength = 24
			KnownRequestCgiHeaderToString = @"HTTP_PROXY_AUTHORIZATION"
			
		Case HttpRequestHeaders.HeaderRange
			intBufferLength = 10
			KnownRequestCgiHeaderToString = @"HTTP_RANGE"
			
		Case HttpRequestHeaders.HeaderReferer
			intBufferLength = 12
			KnownRequestCgiHeaderToString = @"HTTP_REFERER"
			
		Case HttpRequestHeaders.HeaderSecWebSocketKey
			intBufferLength = 22
			KnownRequestCgiHeaderToString = @"HTTP_SEC_WEBSOCKET_KEY"
			
		Case HttpRequestHeaders.HeaderSecWebSocketKey1
			intBufferLength = 23
			KnownRequestCgiHeaderToString = @"HTTP_SEC_WEBSOCKET_KEY1"
			
		Case HttpRequestHeaders.HeaderSecWebSocketKey2
			intBufferLength = 23
			KnownRequestCgiHeaderToString = @"HTTP_SEC_WEBSOCKET_KEY2"
			
		Case HttpRequestHeaders.HeaderSecWebSocketVersion
			intBufferLength = 26
			KnownRequestCgiHeaderToString = @"HTTP_SEC_WEBSOCKET_VERSION"
			
		Case HttpRequestHeaders.HeaderTe
			intBufferLength = 7
			KnownRequestCgiHeaderToString = @"HTTP_TE"
			
		Case HttpRequestHeaders.HeaderTrailer
			intBufferLength = 12
			KnownRequestCgiHeaderToString = @"HTTP_TRAILER"
			
		Case HttpRequestHeaders.HeaderTransferEncoding
			intBufferLength = 22
			KnownRequestCgiHeaderToString = @"HTTP_TRANSFER_ENCODING"
			
		Case HttpRequestHeaders.HeaderUpgrade
			intBufferLength = 12
			KnownRequestCgiHeaderToString = @"HTTP_UPGRADE"
			
		Case HttpRequestHeaders.HeaderUpgradeInsecureRequests
			intBufferLength = 30
			KnownRequestCgiHeaderToString = @"HTTP_UPGRADE_INSECURE_REQUESTS"
			
		Case HttpRequestHeaders.HeaderUserAgent
			intBufferLength = 15
			KnownRequestCgiHeaderToString = @"HTTP_USER_AGENT"
			
		Case HttpRequestHeaders.HeaderVia
			intBufferLength = 8
			KnownRequestCgiHeaderToString = @"HTTP_VIA"
			
		Case HttpRequestHeaders.HeaderWarning
			intBufferLength = 12
			KnownRequestCgiHeaderToString = @"HTTP_WARNING"
			
		Case HttpRequestHeaders.HeaderWebSocketProtocol
			intBufferLength = 23
			KnownRequestCgiHeaderToString = @"HTTP_WEBSOCKET_PROTOCOL"
			
		Case Else
			intBufferLength = 0
			KnownRequestCgiHeaderToString = 0
			
	End Select
	
	If pBufferLength <> 0 Then
		*pBufferLength = intBufferLength
	End If
	
End Function
