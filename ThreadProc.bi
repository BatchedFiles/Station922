#ifndef unicode
#define unicode
#endif

#include once "windows.bi"
#include once "win\winsock2.bi"
#include once "win\ws2tcpip.bi"

#include once "Network.bi"

' Процедура потока
Declare Function ThreadProc(ByVal lpParam As LPVOID)As DWORD

' Параметр в процедуре потока
Type ThreadParam
	' Флаг занятости участка памяти
	Dim IsUsed As Boolean
	' Клиентский и серверный сокеты
	Dim ClientSocket As SOCKET
	Dim ServerSocket As SOCKET
	Dim RemoteAddress As SOCKADDR_IN
	Dim RemoteAddressLength As Integer
	' Идентификаторы ввода‐вывода
	Dim hOutput As Handle
	' Идентификатор потока
	Dim ThreadId As DWord
	Dim hThread As HANDLE
	' Папка с программой
	Dim ExeDir As WString Ptr
End Type

