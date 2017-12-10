#ifndef WEBUTILS_BI
#define WEBUTILS_BI

#ifndef unicode
#define unicode
#endif
#include once "windows.bi"
#include once "ReadHeadersResult.bi"

Const NewLineString = !"\r\n"

' Кодировка документа
Enum DocumentCharsets
	ASCII
	Utf8BOM
	Utf16LE
	Utf16BE
End Enum

' Заполняет буфер экранированной строкой, безопасной для html
' Принимающий буфер должен быть в 6 раз длиннее строки
Declare Function GetSafeString( _
	ByVal Buffer As WString Ptr, _
	ByVal BufferLength As Integer, _
	ByVal strSafe As WString Ptr _
)As Integer

' Определяет кодировку документа (массива байт)
Declare Function GetDocumentCharset( _
	ByVal b As ZString Ptr _
)As DocumentCharsets

' Ищет символы CrLf в буфере
Declare Function FindCrLfA(_
	ByVal Buffer As ZString Ptr, _
	ByVal Start As Integer, _
	ByVal BufferLength As Integer _
)As Integer

' Ищет символы CrLf в юникодном буфере
Declare Function FindCrLfW( _
	ByVal Buffer As WString Ptr, _
	ByVal Start As Integer, _
	ByVal BufferLength As Integer _
)As Integer

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
	ByVal state As ReadHeadersResult Ptr, _
	ByVal ClientSocket As SOCKET, _
	ByVal www As WebSite Ptr, _
	ByVal hOutput As Handle _
)As Boolean

#endif
