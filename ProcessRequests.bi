#ifndef unicode
	#define unicode
#endif

#include once "windows.bi"
#include once "win\winsock2.bi"
#include once "win\ws2tcpip.bi"

#include once "WebSite.bi"
#include once "ReadHeadersResult.bi"

' Размер буфера в символах для записи в него кода html страницы с ошибкой
Const MaxHttpErrorBuffer As Integer = 16 * 1024 - 1

' Максимальный размер полученного от клиента тела запроса
Const MaxRequestBodyContentLength As LongInt = 20 * 1024 * 1024

' Отправляет клиенту перенаправление
Declare Sub WriteHttp301Error(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal hOutput As Handle)

' Отправляет клиенту «Ресурс создан»
Declare Sub WriteHttp201(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal hOutput As Handle)

' Обработка запроса CONNECT
Declare Function ProcessConnectRequest(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal hOutput As Handle)As Boolean

' Обработка запроса OPTIONS
Declare Function ProcessOptionsRequest(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal fileExtention As WString Ptr, ByVal hOutput As Handle)As Boolean

' Обработка запросов GET и HEAD
Declare Function ProcessGetHeadRequest(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal fileExtention As WString Ptr, ByVal hOutput As Handle)As Boolean

' Обработка запроса PUT
Declare Function ProcessPutRequest(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal fileExtention As WString Ptr, ByVal hOutput As Handle)As Boolean

' Обработка запроса DELETE
Declare Function ProcessDeleteRequest(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal fileExtention As WString Ptr, ByVal hOutput As Handle)As Boolean

' Обработка запроса TRACE
Declare Function ProcessTraceRequest(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal hOutput As Handle)As Boolean

Declare Function ProcessPatchRequest(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal hOutput As Handle)As Boolean

Declare Function ProcessPostRequest(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal hOutput As Handle)As Boolean

' Записывает ошибку ответа в поток
Declare Sub WriteHttpError(ByVal state As ReadHeadersResult Ptr, ByVal ClientSocket As SOCKET, ByVal strMessage As WString Ptr, ByVal VirtualPath As WString Ptr, ByVal hOutput As Handle)

' Отправляет ошибку 404 или 410 клиенту
Declare Sub WriteNotFoundError(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal hOutput As Handle)

' Проверка аутентификации
Declare Function HttpAuthUtil(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal hOutput As Handle)As Boolean
