#ifndef unicode
#define unicode
#endif

#include once "Http.bi"
#include once "URI.bi"
#include once "StreamSocketReader.bi"
#include once "WebSite.bi"

Enum ParseRequestLineResult
	' Ошибок нет
	Success
	' Версия протокола не поддерживается
	HTTPVersionNotSupported
	' Фальшивый Host
	BadHost
	' Ошибка в запросе, синтаксисе запроса
	BadRequest
	' Плохой путь
	BadPath
	' Клиент закрыл соединение
	EmptyRequest
	' Ошибка сокета
	SocketError
	' Url слишком длинный
	RequestUrlTooLong
	' Превышена допустимая длина заголовков
	RequestHeaderFieldsTooLarge 
End Enum

Type ByteRange
	Dim StartIndex As Integer
	Dim EndIndex As Integer
End Type

Type WebRequest
	' Размер буфера для строки с заголовками запроса в символах (не включая нулевой)
	Const MaxRequestHeaderBuffer As Integer = 32 * 1024 - 1
	' Максимальное количество заголовков запроса
	Const RequestHeaderMaximum As Integer = 35
	' Сжатие данных, поддерживаемое клиентом
	Const MaxRequestZipEnabled As Integer = 2
	' Сжатие GZip
	Const GZipIndex As Integer = 0
	' Сжатие Deflate
	Const DeflateIndex As Integer = 1
	
	' Буфер заголовков запроса клиента
	Dim RequestHeaderBuffer As WString * (MaxRequestHeaderBuffer + 1)
	' Длина буфера запроса клиента
	Dim RequestHeaderBufferLength As Integer
	
	' Распознанные заголовки запроса
	Dim RequestHeaders(RequestHeaderMaximum - 1) As WString Ptr
	
	' Версия http‐протокола
	Dim HttpVersion As HttpVersions
	' Метод HTTP
	Dim HttpMethod As HttpMethods
	
	' URI запрошенный клиентом
	Dim ClientURI As URI
	
	' Поддерживать соединение с клиентом
	Dim KeepAlive As Boolean
	
	' Список поддерживаемых сжатий данных
	Dim RequestZipModes(MaxRequestZipEnabled - 1) As Boolean
	
	' Байтовый диапазон запроса
	Dim RequestByteRange As ByteRange
	
	' Инициализация объекта запроса в начальное значение
	Declare Sub Initialize()
	
	' Читает запрос клиента и заполняет данные
	Declare Function ReadAllHeaders(ByVal ClientReader As StreamSocketReader Ptr)As Boolean
	
	' Добавляет заголовок в массив заголовков запроса клиента
	Declare Function AddRequestHeader(ByVal Header As WString Ptr, ByVal Value As WString Ptr)As Integer
	
End Type