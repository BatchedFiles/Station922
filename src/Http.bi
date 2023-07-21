#ifndef HTTP_BI
#define HTTP_BI

#include once "windows.bi"

Const HttpVersion10String = WStr("HTTP/1.0")
Const HttpVersion11String = WStr("HTTP/1.1")

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
Const HeaderPurposeString            = WStr("Purpose")
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
Const HeaderXContentTypeOptionsString = WStr("X-Content-Type-Options")

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

Const WEBSITE_S_CREATE_NEW As HRESULT =                     MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0401)
Const WEBSITE_S_ALREADY_EXISTS As HRESULT =                 MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0402)
Const WEBSITE_S_DIRECTORY_LISTING As HRESULT =              MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0403)

Const HTTPREADER_E_INTERNALBUFFEROVERFLOW As HRESULT =      MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0401)
Const HTTPREADER_E_SOCKETERROR As HRESULT =                 MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0402)
Const HTTPREADER_E_CLIENTCLOSEDCONNECTION As HRESULT =      MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0403)
Const HTTPREADER_E_INSUFFICIENT_BUFFER As HRESULT =         MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0404)

Const CLIENTURI_E_URITOOLARGE As HRESULT =                  MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0411)
Const CLIENTURI_E_CONTAINSBADCHAR As HRESULT =              MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0412)
Const CLIENTURI_E_PATHNOTFOUND As HRESULT =                 MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0413)

Const CLIENTREQUEST_E_BADHOST As HRESULT =                  MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0421)
Const CLIENTREQUEST_E_BADREQUEST As HRESULT =               MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0422)
Const CLIENTREQUEST_E_BADPATH As HRESULT =                  MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0423)
Const CLIENTREQUEST_E_PATHNOTFOUND As HRESULT =             MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0424)
Const CLIENTREQUEST_E_URITOOLARGE As HRESULT =              MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0425)
Const CLIENTREQUEST_E_HTTPVERSIONNOTSUPPORTED As HRESULT =  MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0426)
Const CLIENTREQUEST_E_CONTENTTYPEEMPTY As HRESULT =         MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0427)

Const WEBSITE_E_SITENOTFOUND As HRESULT =                   MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0441)
Const WEBSITE_E_REDIRECTED As HRESULT =                     MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0442)
Const WEBSITE_E_FILENOTFOUND As HRESULT =                   MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0443)
Const WEBSITE_E_FILEGONE As HRESULT =                       MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0444)
Const WEBSITE_E_FORBIDDEN As HRESULT =                      MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0445)
Const WEBSITE_E_NEEDAUTHENTICATE As HRESULT =               MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0446)
Const WEBSITE_E_BADAUTHENTICATEPARAM As HRESULT =           MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0447)
Const WEBSITE_E_NEEDBASICAUTHENTICATE As HRESULT =          MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0448)
Const WEBSITE_E_EMPTYPASSWORD As HRESULT =                  MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0449)
Const WEBSITE_E_BADUSERNAMEPASSWORD As HRESULT =            MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h044A)

Const HTTPPROCESSOR_E_NOTIMPLEMENTED As HRESULT =           MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0451)
Const HTTPPROCESSOR_E_RANGENOTSATISFIABLE As HRESULT =      MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0452)
Const HTTPPROCESSOR_E_LENGTHREQUIRED As HRESULT =           MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0453)

Enum ResponseErrorCode
	MovedPermanently
	
	BadRequest
	PathNotValid
	HostNotFound
	SiteNotFound
	NeedAuthenticate
	BadAuthenticateParam
	NeedBasicAuthenticate
	EmptyPassword
	BadUserNamePassword
	Forbidden
	FileNotFound
	MethodNotAllowed
	FileGone
	LengthRequired
	RequestEntityTooLarge
	RequestUrlTooLarge
	RequestRangeNotSatisfiable
	RequestHeaderFieldsTooLarge
	
	InternalServerError
	FileNotAvailable
	CannotCreateChildProcess
	CannotCreatePipe
	NotImplemented
	ContentTypeEmpty
	ContentEncodingNotEmpty
	BadGateway
	NotEnoughMemory
	CannotCreateThread
	GatewayTimeout
	VersionNotSupported
End Enum

' Требуемый размер буфера для описания кода состояния Http
Const MaxHttpStatusCodeBufferLength As Integer = 32 - 1

' Максимальное количество заголовков запроса
Const HttpRequestHeadersMaximum As Integer = 43

Const HttpZipModesMaximum As Integer = 2

Enum HttpVersions
	Http11
	Http10
	Http09
End Enum

Const HttpVersionsSize As Integer = 3

Enum HttpStatusCodes
	CodeContinue = 100
	SwitchingProtocols = 101
	Processing = 102
	OK = 200
	Created = 201
	Accepted = 202
	NonAuthoritativeInformation = 203
	NoContent = 204
	ResetContent = 205
	PartialContent = 206
	MultiStatus = 207
	IAmUsed = 226
	MultipleChoices = 300
	MovedPermanently = 301
	Found = 302
	SeeOther = 303
	NotModified = 304
	UseProxy = 305
	TemporaryRedirect = 307
	BadRequest = 400
	Unauthorized = 401
	PaymentRequired = 402
	Forbidden = 403
	NotFound = 404
	MethodNotAllowed = 405
	NotAcceptable = 406
	ProxyAuthenticationRequired = 407
	RequestTimeout = 408
	Conflict = 409
	Gone = 410
	LengthRequired = 411
	PreconditionFailed = 412
	RequestEntityTooLarge = 413
	RequestURITooLarge = 414
	UnsupportedMediaType = 415
	RangeNotSatisfiable = 416
	ExpectationFailed = 417
	IAmTeapot = 418
	UnprocessableEntity = 422
	Locked = 423
	FailedDependency = 424
	UnorderedCollection = 425
	UpgradeRequired = 426
	PreconditionRequired = 428
	TooManyRequests = 429
	RequestHeaderFieldsTooLarge = 431
	RetryWith = 449
	UnavailableForLegalReasons = 451
	InternalServerError = 500
	NotImplemented = 501
	BadGateway = 502
	ServiceUnavailable = 503
	GatewayTimeout = 504
	HTTPVersionNotSupported = 505
	VariantAlsoNegotiates = 506
	InsufficientStorage = 507
	LoopDetected = 508
	BandwidthLimitExceeded = 509
	NotExtended = 510
	NetworkAuthenticationRequired = 511
End Enum

Const HttpStatusCodesSize As Integer = 60

Enum HttpRequestHeaders
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
	HeaderDNT
	HeaderExpect
	HeaderFrom
	HeaderHost
	HeaderIfMatch
	HeaderIfModifiedSince
	HeaderIfNoneMatch
	HeaderIfRange
	HeaderIfUnModifiedSince
	HeaderKeepAlive
	HeaderMaxForwards
	HeaderOrigin
	HeaderPragma
	HeaderProxyAuthorization
	HeaderPurpose
	HeaderRange
	HeaderReferer
	HeaderSecWebSocketKey
	HeaderSecWebSocketKey1
	HeaderSecWebSocketKey2
	HeaderSecWebSocketVersion
	HeaderTe
	HeaderTrailer
	HeaderTransferEncoding
	HeaderUpgrade
	HeaderUpgradeInsecureRequests
	HeaderUserAgent
	HeaderVia
	HeaderWarning
	HeaderWebSocketProtocol
End Enum

Const HttpRequestHeadersSize As Integer = 44

' Помечены заголовки, которые клиент не может переопределить черз файл *.headers
Enum HttpResponseHeaders
	HeaderAcceptRanges          ' *
	HeaderAge
	HeaderAllow
	HeaderCacheControl
	HeaderConnection            ' *
	HeaderContentEncoding
	HeaderContentLanguage
	HeaderContentLength         ' *
	HeaderContentLocation
	HeaderContentMd5
	HeaderContentRange
	HeaderContentType
	HeaderDate                  ' *
	HeaderETag
	HeaderExpires
	HeaderKeepAlive             ' *
	HeaderLastModified
	HeaderLocation
	HeaderPragma
	HeaderProxyAuthenticate
	HeaderRetryAfter
	HeaderSecWebSocketAccept ' *
	HeaderSecWebSocketLocation ' *
	HeaderSecWebSocketOrigin ' *
	HeaderSecWebSocketProtocol ' *
	HeaderServer                ' *
	HeaderSetCookie
	HeaderTrailer
	HeaderTransferEncoding      ' *
	HeaderUpgrade
	HeaderVary                  ' *
	HeaderVia
	HeaderWarning
	HeaderWebSocketLocation ' *
	HeaderWebSocketOrigin ' *
	HeaderWebSocketProtocol ' *
	HeaderWwwAuthenticate
	HeaderXContentTypeOptions ' *
End Enum

Const HttpResponseHeadersSize As Integer = 38

Enum ZipModes
	None
	GZip
	Deflate
End Enum

Const ZipModesSize As Integer = 2

' Возвращает указатель на строку с описанием кода состояния
' Очищать память для строки не нужно
Declare Function GetStatusDescription( _
	ByVal StatusCode As HttpStatusCodes, _
	ByVal pBufferLength As Integer Ptr _
)As WString Ptr

Declare Function GetKnownCgiHeaderIndex( _
	ByVal wHeader As WString Ptr, _
	ByVal pHeader As HttpResponseHeaders Ptr _
)As Boolean

' Возвращает заголовок HTTP для CGI
' Очищать память для строки не нужно
Declare Function KnownCgiHeaderToString( _
	ByVal Header As HttpRequestHeaders, _
	ByVal pBufferLength As Integer Ptr _
)As WString Ptr

#endif
