#ifndef WEBUTILS_BI
#define WEBUTILS_BI

#include once "IAsyncIoTask.bi"
#include once "IClientRequest.bi"
#include once "IBaseStream.bi"
#include once "IServerResponse.bi"
#include once "IWriteErrorAsyncIoTask.bi"

' Заполняет буфер экранированной строкой, безопасной для html
' Принимающий буфер должен быть в 6 раз длиннее строки
' Declare Function GetHtmlSafeString( _
	' ByVal Buffer As WString Ptr, _
	' ByVal BufferLength As Integer, _
	' ByVal HtmlSafe As WString Ptr, _
	' ByVal pHtmlSafeLength As Integer Ptr _
' )As Boolean

' Заполняет буфер датой и временем в http формате
Declare Sub GetHttpDate( _
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

Declare Function SetResponseCompression( _
	ByVal pIRequest As IClientRequest Ptr, _
	ByVal pIResponse As IServerResponse Ptr, _
	ByVal PathTranslated As WString Ptr, _
	ByVal pAcceptEncoding As Boolean Ptr _
)As Handle

Declare Sub AddResponseCacheHeaders( _
	ByVal pIRequest As IClientRequest Ptr, _
	ByVal pIResponse As IServerResponse Ptr, _
	ByVal pDateLastFileModified As FILETIME Ptr, _
	ByVal ETag As HeapBSTR _
)

Declare Function FindWebSiteWeakPtr( _
	ByVal pIWebSites As IWebSiteCollection Ptr, _
	ByVal pIRequest As IClientRequest Ptr, _
	ByVal ppIWebSiteWeakPtr As IWebSite Ptr Ptr _
)As HRESULT

Declare Function StartExecuteTask( _
	ByVal pTask As IAsyncIoTask Ptr _
)As HRESULT

Declare Function ProcessErrorRequestResponse( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal pIStream As IBaseStream Ptr, _
	ByVal pIHttpReader As IHttpReader Ptr, _
	ByVal pIRequest As IClientRequest Ptr, _
	ByVal hrReadError As HRESULT, _
	ByVal ppTask As IWriteErrorAsyncIoTask Ptr Ptr _
)As HRESULT

Declare Function BindToThreadPool( _
	ByVal hHandle As Handle, _
	ByVal pUserData As Any Ptr _
)As HRESULT

#endif
