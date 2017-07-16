#ifndef unicode
#define unicode
#endif

' Все поддерживаемые методы самим сервером
Const AllSupportHttpMethodsServer = "CONNECT, DELETE, GET, HEAD, OPTIONS, PUT, TRACE"


Const HttpMethodCopy = 			"COPY"
Const HttpMethodConnect = 		"CONNECT"
Const HttpMethodDelete = 		"DELETE"
Const HttpMethodGet = 			"GET"
Const HttpMethodHead = 			"HEAD"
Const HttpMethodMove = 			"MOVE"
Const HttpMethodOptions = 		"OPTIONS"
Const HttpMethodPatch = 		"PATCH"
Const HttpMethodPost = 			"POST"
Const HttpMethodPropfind = 		"PROPFIND"
Const HttpMethodPut = 			"PUT"
Const HttpMethodTrace = 		"TRACE"

Const HttpMethodCopyLength As Integer = 	4
Const HttpMethodConnectLength As Integer = 	7
Const HttpMethodDeleteLength As Integer = 	6
Const HttpMethodGetLength As Integer = 		3
Const HttpMethodHeadLength As Integer = 	4
Const HttpMethodMoveLength As Integer = 	4
Const HttpMethodOptionsLength As Integer = 	7
Const HttpMethodPatchLength As Integer = 	5
Const HttpMethodPostLength As Integer = 	4
Const HttpMethodPropfindLength As Integer = 8
Const HttpMethodPutLength As Integer = 		3
Const HttpMethodTraceLength As Integer = 	5


Const HeaderAcceptString = "Accept"
Const HeaderAcceptCharsetString = "Accept-Charset"
Const HeaderAcceptEncodingString = "Accept-Encoding"
Const HeaderAcceptLanguageString = "Accept-Language"
Const HeaderAcceptRangesString = "Accept-Ranges"
Const HeaderAgeString = "Age"
Const HeaderConnectionString = "Connection"
Const HeaderCacheControlString = "Cache-Control"
Const HeaderDateString = "Date"
Const HeaderKeepAliveString = "Keep-Alive"
Const HeaderPragmaString = "Pragma"
Const HeaderTrailerString = "Trailer"
Const HeaderTransferEncodingString = "Transfer-Encoding"
Const HeaderUpgradeString = "Upgrade"
Const HeaderViaString = "Via"
Const HeaderWarningString = "Warning"
Const HeaderAllowString = "Allow"
Const HeaderContentLengthString = "Content-Length"
Const HeaderContentTypeString = "Content-Type"
Const HeaderContentEncodingString = "Content-Encoding"
Const HeaderContentLanguageString = "Content-Language"
Const HeaderContentLocationString = "Content-Location"
Const HeaderContentMd5String = "Content-MD5"
Const HeaderContentRangeString = "Content-Range"
Const HeaderExpiresString = "Expires"
Const HeaderLastModifiedString = "Last-Modified"
Const HeaderAuthorizationString = "Authorization"
Const HeaderCookieString = "Cookie"
Const HeaderExpectString = "Expect"
Const HeaderFromString = "From"
Const HeaderHostString = "Host"
Const HeaderIfMatchString = "If-Match"
Const HeaderIfModifiedSinceString = "If-Modified-Since"
Const HeaderIfNoneMatchString = "If-None-Match"
Const HeaderIfRangeString = "If-Range"
Const HeaderIfUnmodifiedSinceString = "If-Unmodified-Since"
Const HeaderMaxForwardsString = "Max-Forwards"
Const HeaderProxyAuthorizationString = "Proxy-Authorization"
Const HeaderRefererString = "Referer"
Const HeaderRangeString = "Range"
Const HeaderTeString = "TE"
Const HeaderUserAgentString = "User-Agent"
Const HeaderETagString = "ETag"
Const HeaderLocationString = "Location"
Const HeaderProxyAuthenticateString = "Proxy-Authenticate"
Const HeaderRetryAfterString = "Retry-After"
Const HeaderServerString = "Server"
Const HeaderSetCookieString = "Set-Cookie"
Const HeaderVaryString = "Vary"
Const HeaderWWWAuthenticateString = "WWW-Authenticate"

Const HeaderAcceptRangesStringLength As Integer = 13
Const HeaderAgeStringLength As Integer = 3
Const HeaderAllowStringLength As Integer = 5
Const HeaderCacheControlStringLength As Integer = 13
Const HeaderConnectionStringLength As Integer = 10
Const HeaderContentEncodingStringLength As Integer = 16
Const HeaderContentLengthStringLength As Integer = 14
Const HeaderContentLanguageStringLength As Integer = 16
Const HeaderContentLocationStringLength As Integer = 16
Const HeaderContentMd5StringLength As Integer = 11
Const HeaderContentRangeStringLength As Integer = 13
Const HeaderContentTypeStringLength As Integer = 12
Const HeaderDateStringLength As Integer = 4
Const HeaderETagStringLength As Integer = 4
Const HeaderExpiresStringLength As Integer = 7
Const HeaderKeepAliveStringLength As Integer = 10
Const HeaderLastModifiedStringLength As Integer = 13
Const HeaderLocationStringLength As Integer = 8
Const HeaderPragmaStringLength As Integer = 6
Const HeaderProxyAuthenticateStringLength As Integer = 18
Const HeaderRetryAfterStringLength As Integer = 11
Const HeaderServerStringLength As Integer = 6
Const HeaderSetCookieStringLength As Integer = 10
Const HeaderTrailerStringLength As Integer = 7
Const HeaderTransferEncodingStringLength As Integer = 17
Const HeaderUpgradeStringLength As Integer = 7
Const HeaderVaryStringLength As Integer = 4
Const HeaderViaStringLength As Integer = 3
Const HeaderWarningStringLength As Integer = 7
Const HeaderWWWAuthenticateStringLength As Integer = 16


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


' Версии протокола http
Enum HttpVersions
	Http11
	Http10
	Http09
End Enum

' Методы Http
Enum HttpMethods
	None
	HttpGet
	HttpHead
	HttpPut
	HttpDelete
	HttpOptions
	HttpTrace
	HttpConnect
	HttpPatch
	HttpPost
	HttpCopy
	HttpMove
	HttpPropfind
End Enum

' Индексы заголовков в массиве заголовков запроса
Enum HttpRequestHeaderIndices
	HeaderAccept
	HeaderAcceptCharset
	HeaderAcceptEncoding
	HeaderAcceptLanguage
	HeaderAuthorization
	HeaderCacheControl
	HeaderConnection
	HeaderContentEncoding
	HeaderContentLanguage
	HeaderContentLength
	HeaderContentMd5
	HeaderContentRange
	HeaderContentType
	HeaderCookie
	HeaderExpect
	HeaderFrom
	HeaderHost
	HeaderIfMatch
	HeaderIfModifiedSince
	HeaderIfNoneMatch
	HeaderIfRange
	HeaderIfUnmodifiedSince
	HeaderKeepAlive
	HeaderMaxForwards
	HeaderPragma
	HeaderProxyAuthorization
	HeaderRange
	HeaderReferer
	HeaderTe
	HeaderTrailer
	HeaderTransferEncoding
	HeaderUpgrade
	HeaderUserAgent
	HeaderVia
	HeaderWarning
End Enum

' Индексы заголовков в массиве заголовков ответа
' Помечены заголовки, которые клиент может переопределить черз файл *.headers
Enum HttpResponseHeaderIndices
	HeaderAcceptRanges		'
	HeaderAge				'
	HeaderAllow				'
	HeaderCacheControl		'
	HeaderConnection
	HeaderContentEncoding	'
	HeaderContentLanguage	'
	HeaderContentLength
	HeaderContentLocation	'
	HeaderContentMd5		'
	HeaderContentRange		'
	HeaderContentType		'
	HeaderDate
	HeaderETag				'
	HeaderExpires			'
	HeaderKeepAlive
	HeaderLastModified		'
	HeaderLocation			'
	HeaderPragma			'
	HeaderProxyAuthenticate	'
	HeaderRetryAfter		'
	HeaderServer
	HeaderSetCookie			'
	HeaderTrailer			'
	HeaderTransferEncoding
	HeaderUpgrade			'
	HeaderVary
	HeaderVia				'
	HeaderWarning			'
	HeaderWwwAuthenticate	'
End Enum


' Заполняет буфер именем метода Http
' Возвращает длину строки без учёта нулевого символа
Declare Function GetHttpMethodName(ByVal Buffer As WString Ptr, ByVal HttpMethod As HttpMethods)As Integer

' Устанавливает текущий метод http из переменной RequestLine
Declare Function GetHttpMethod(ByVal s As WString Ptr)As HttpMethods

' Возвращает индексный номер указанного заголовка HTTP запроса
Declare Function GetKnownRequestHeaderIndex(ByVal Header As WString Ptr)As Integer

' Заполняет буфер заголовком запроса по индексу
' Возвращает длину строки без учёта нулевого символа
Declare Function GetKnownRequestHeaderName(ByVal Buffer As WString Ptr, ByVal HeaderIndex As HttpRequestHeaderIndices)As Integer

' Возвращает индексный номер указанного заголовка HTTP ответа
Declare Function GetKnownResponseHeaderIndex(ByVal Header As WString Ptr)As Integer

' Заполняет буфер заголовком ответа по индексу
' Возвращает длину строки без учёта нулевого символа
Declare Function GetKnownResponseHeaderName(ByVal Buffer As WString Ptr, ByVal HeaderIndex As HttpResponseHeaderIndices)As Integer

' Заполняет буфер описанием http кода
' Для буфера необходимо и достаточно выделить память под 31 символ + 1 для нулевого
' Возвращает длину строки без учёта нулевого символа
Declare Function GetStatusDescription(ByVal Buffer As WString Ptr, ByVal StatusCode As Integer)As Integer
