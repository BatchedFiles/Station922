#ifndef WEBUTILS_BI
#define WEBUTILS_BI

#include once "IClientRequest.bi"
#include once "IServerResponse.bi"
#include once "ITextWriter.bi"
#include once "IWebSite.bi"

' Заполняет буфер экранированной строкой, безопасной для html
' Принимающий буфер должен быть в 6 раз длиннее строки
' Declare Function GetHtmlSafeString( _
	' ByVal Buffer As WString Ptr, _
	' ByVal BufferLength As Integer, _
	' ByVal HtmlSafe As WString Ptr, _
	' ByVal pHtmlSafeLength As Integer Ptr _
' )As Boolean

' Определяет кодировку документа (массива байт)
Declare Function GetDocumentCharset( _
	ByVal b As ZString Ptr _
)As DocumentCharsets

' Заполняет буфер датой и временем в http формате
Declare Sub GetHttpDate Overload( _
	ByVal Buffer As WString Ptr _
)

Declare Sub GetHttpDate Overload( _
	ByVal Buffer As WString Ptr, _
	ByVal dt As SYSTEMTIME Ptr _
)

' Проверка аутентификации
Declare Function HttpAuthUtil( _
	ByVal pIRequest As IClientRequest Ptr, _
	ByVal pIResponse As IServerResponse Ptr, _
	ByVal pStream As IBaseStream Ptr, _
	ByVal pIWebSite As IWebSite Ptr, _
	ByVal ProxyAuthorization As Boolean _
)As Boolean

Declare Sub GetETag( _
	ByVal wETag As WString Ptr, _
	ByVal pDateLastFileModified As FILETIME Ptr, _
	ByVal ZipEnable As Boolean, _
	ByVal ResponseZipMode As ZipModes _
)

Declare Sub MakeContentRangeHeader( _
	ByVal pIWriter As ITextWriter Ptr, _
	ByVal FirstBytePosition As ULongInt, _
	ByVal LastBytePosition As ULongInt, _
	ByVal TotalLength As ULongInt _
)

Declare Function AllResponseHeadersToBytes( _
	ByVal pIRequest As IClientRequest Ptr, _
	ByVal pIResponse As IServerResponse Ptr, _
	ByVal zBuffer As ZString Ptr, _
	ByVal ContentLength As ULongInt _
)As Integer

Declare Function SetResponseCompression( _
	ByVal pIRequest As IClientRequest Ptr, _
	ByVal pIResponse As IServerResponse Ptr, _
	ByVal PathTranslated As WString Ptr, _
	ByVal pAcceptEncoding As Boolean Ptr _
)As Handle

Declare Sub AddResponseCacheHeaders( _
	ByVal pIRequest As IClientRequest Ptr, _
	ByVal pIResponse As IServerResponse Ptr, _
	ByVal hFile As HANDLE _
)

#endif
