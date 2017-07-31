' Кодирование в Base64 и обратно
#ifndef unicode
	#define unicode
#endif
#include once "windows.bi"
#include once "win\shlwapi.bi"

Const B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

' Кодирует массив байт в base64
' sOut — буфер под закодированную строку
' sEncodedB — указатель на массив байт, которые нужно закодировать
' BytesCount — количество байт в массиве
' Функция может записать за выделенный буфер, если он будет слишком мал
' Размер требуемого буфера под результирующую строку должен быть не менее ((BytesCount \ 3) + 1) * 4 символов + 1 символ под нулевой
' Функция записывает завершающий ноль
' Возвращает количество символов (без учёта завершающего нуля)
Declare Function Encode64(ByVal sOut As WString Ptr, ByVal sEncodedB As UByte Ptr, ByVal BytesCount As Integer)As Integer

' Декодирует из base64 в массив байт
' b — указатель на массив байт, которые нужно заполнить
' s — строка, возможно, с символами vbCrLf
' Возвращает длину массива
Declare Function Decode64(ByVal b As UByte Ptr, ByVal s As WString Ptr)As Integer
