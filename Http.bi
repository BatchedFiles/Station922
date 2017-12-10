#ifndef HTTP_BI
#define HTTP_BI

Const AllSupportHttpMethods =          "CONNECT, DELETE, GET, HEAD, OPTIONS, POST, PUT, TRACE"
Const AllSupportHttpMethodsForFile =   "DELETE, GET, HEAD, OPTIONS, PUT, TRACE"
Const AllSupportHttpMethodsForScript = "DELETE, GET, HEAD, OPTIONS, POST, PUT, TRACE"

' Требуемый размер буфера для описания кода состояния Http
Const MaxHttpStatusCodeBufferLength As Integer = 32 - 1

Enum HttpVersions
	Http11
	Http10
	Http09
End Enum

Enum HttpMethods
	None
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
End Enum

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

' Помечены заголовки, которые клиент не может переопределить черз файл *.headers
Enum HttpResponseHeaderIndices
	HeaderAcceptRanges
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

' Возвращает метод http
Declare Function GetHttpMethod( _
	ByVal s As WString Ptr _
)As HttpMethods

' Возвращает указатель на строку с именем метода Http
' Очищать память для строки не нужно
Declare Function HttpMethodToString( _
	ByVal HttpMethod As HttpMethods, _
	ByVal BufferLength As Integer Ptr _
)As WString Ptr

' Возвращает индексный номер указанного заголовка HTTP запроса
' Если заголовок не распознан, то возвращает -1
Declare Function GetKnownRequestHeaderIndex( _
	ByVal Header As WString Ptr _
)As Integer

' Возвращает указатель на строку с заголовком запроса
' Очищать память для строки не нужно
Declare Function KnownRequestHeaderToString( _
	ByVal HeaderIndex As HttpRequestHeaderIndices, _
	ByVal BufferLength As Integer Ptr _
)As WString Ptr

' Возвращает индексный номер указанного заголовка HTTP ответа
' Если заголовок не распознан, то возвращает -1
Declare Function GetKnownResponseHeaderIndex( _
	ByVal Header As WString Ptr _
)As Integer

' Возвращает указатель на строку с заголовком ответа по индексу
' Очищать память для строки не нужно
Declare Function KnownResponseHeaderToString( _
	ByVal HeaderIndex As HttpResponseHeaderIndices, _
	ByVal BufferLength As Integer Ptr _
)As WString Ptr

' Возвращает указатель на строку с описанием кода состояния
' Очищать память для строки не нужно
Declare Function GetStatusDescription( _
	ByVal StatusCode As Integer, _
	ByVal BufferLength As Integer Ptr _
)As WString Ptr

' Возвращает заголовок HTTP для CGI
' Очищать память для строки не нужно
Declare Function KnownRequestCgiHeaderToString( _
	ByVal HeaderIndex As HttpRequestHeaderIndices, _
	ByVal BufferLength As Integer Ptr _
)As WString Ptr

#endif
