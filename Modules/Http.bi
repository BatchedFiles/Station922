#ifndef HTTP_BI
#define HTTP_BI

Const AllSupportHttpMethods =          "CONNECT,DELETE,GET,HEAD,OPTIONS,POST,PUT,TRACE"
Const AllSupportHttpMethodsForFile =   "CONNECT,DELETE,GET,HEAD,OPTIONS,PUT,TRACE"
Const AllSupportHttpMethodsForScript = "CONNECT,DELETE,GET,HEAD,OPTIONS,POST,PUT,TRACE"

' Требуемый размер буфера для описания кода состояния Http
Const MaxHttpStatusCodeBufferLength As Integer = 32 - 1

Enum HttpVersions
	Http11
	Http10
	Http09
End Enum

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
	RequestedRangeNotSatisfiable = 416
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

Enum HttpMethods
	HttpGet
	HttpHead
	HttpPost
	HttpPut
	HttpDelete
	HttpOptions
	HttpTrace
	HttpConnect
	HttpPatch
	HttpCopy
	HttpMove
	HttpPropfind
	Unknown
End Enum

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
	HeaderServer                ' *
	HeaderSetCookie
	HeaderTrailer
	HeaderTransferEncoding      ' *
	HeaderUpgrade
	HeaderVary                  ' *
	HeaderVia
	HeaderWarning
	HeaderWwwAuthenticate
End Enum

Enum ZipModes
	None
	GZip
	Deflate
End Enum

Declare Function GetHttpMethod( _
	ByVal s As WString Ptr _
)As HttpMethods

' Возвращает указатель на строку с именем метода Http
' Очищать память для строки не нужно
Declare Function HttpMethodToString( _
	ByVal HttpMethod As HttpMethods, _
	ByVal BufferLength As Integer Ptr _
)As WString Ptr

Declare Function GetKnownRequestHeader( _
	ByVal wHeader As WString Ptr, _
	ByVal pHeader As HttpRequestHeaders Ptr _
)As Boolean

' Возвращает указатель на строку с заголовком запроса
' Очищать память для строки не нужно
Declare Function KnownRequestHeaderToString( _
	ByVal Header As HttpRequestHeaders, _
	ByVal BufferLength As Integer Ptr _
)As WString Ptr

' Возвращает индексный номер указанного заголовка HTTP ответа
Declare Function GetKnownResponseHeader( _
	ByVal wHeader As WString Ptr, _
	ByVal pHeader As HttpResponseHeaders Ptr _
)As Boolean

' Возвращает указатель на строку с заголовком ответа по индексу
' Очищать память для строки не нужно
Declare Function KnownResponseHeaderToString( _
	ByVal HeaderIndex As HttpResponseHeaders, _
	ByVal BufferLength As Integer Ptr _
)As WString Ptr

' Возвращает указатель на строку с описанием кода состояния
' Очищать память для строки не нужно
Declare Function GetStatusDescription( _
	ByVal StatusCode As HttpStatusCodes, _
	ByVal BufferLength As Integer Ptr _
)As WString Ptr

' Возвращает заголовок HTTP для CGI
' Очищать память для строки не нужно
Declare Function KnownRequestCgiHeaderToString( _
	ByVal Header As HttpRequestHeaders, _
	ByVal BufferLength As Integer Ptr _
)As WString Ptr

#endif
