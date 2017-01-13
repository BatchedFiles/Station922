#ifndef unicode
#define unicode
#endif

#include once "windows.bi"
#include once "win\winsock2.bi"
#include once "win\ws2tcpip.bi"

#include once "ReadHeadersResult.bi"

Const NewLineString = !"\r\n"
Const SpaceString = " "
Const ColonString = ":"
Const ColonWithSpaceString = ": "
Const DateFormatString = "ddd, dd MMM yyyy "
Const LogDateFormatString = "yyyy.MM.dd.LOG"
Const TimeFormatString = "HH:mm:ss GMT"

' Кодировка документа
Enum DocumentCharsets
	ASCII
	Utf8BOM
	Utf16LE
	Utf16BE
End Enum

' Инкапсуляция клиентского и серверного сокетов как параметр для процедуры потока
Type ClientServerSocket
	Dim OutSock As SOCKET
	Dim InSock As SOCKET
	Dim ThreadId As DWord
	Dim hThread As HANDLE
End Type

' Инициализация объекта состояния в начальное значение
Declare Sub InitializeState(ByVal state As ReadHeadersResult Ptr)

' Заполняет буфер html страницей с ошибкой
' Возвращает длину буфера в символах
Declare Function FormatErrorMessageBody(ByVal Buffer As WString Ptr, ByVal StatusCode As Integer, ByVal VirtualPath As WString Ptr, ByVal strMessage As WString Ptr)As LongInt

' Заполняет буфер экранированной строкой, безопасной для html
' Принимающий буфер должен быть в 6 раз длиннее строки
Declare Sub GetSafeString(ByVal Buffer As WString Ptr, ByVal strSafe As WString Ptr)

' Определяет кодировку документа (массива байт)
Declare Function GetDocumentCharset(ByVal b As UByte Ptr)As DocumentCharsets

' Расшифровываем интернет-кодировку в юникод-строку
Declare Sub UrlDecode(ByVal Buffer As WString Ptr, ByVal strUrl As WString Ptr)

' Ищет символы CrLf в буфере
Declare Function FindCrLfA(ByVal Buffer As ZString Ptr, ByVal Start As Integer, ByVal BufferLength As Integer)As Integer

' Ищет символы CrLf в юникодном буфере
Declare Function FindCrLfW(ByVal Buffer As WString Ptr, ByVal Start As Integer, ByVal BufferLength As Integer)As Integer

' Заполняет буфер датой и временем в http формате
Declare Sub GetHttpDate Overload(ByVal Buffer As WString Ptr)
Declare Sub GetHttpDate Overload(ByVal Buffer As WString Ptr, ByVal dt As SYSTEMTIME Ptr)

' Получение данных от входящего сокета и отправка на исходящий
Declare Sub SendReceiveData(ByVal OutSock As SOCKET, ByVal InSock As SOCKET)

' Процедура потока
Declare Function SendReceiveDataThreadProc(ByVal lpParam As LPVOID)As DWORD
