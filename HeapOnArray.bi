#ifndef unicode
	#define unicode
#endif
#include once "windows.bi"
#include once "win\winsock2.bi"
#include once "win\ws2tcpip.bi"
#include once "ThreadProc.bi"

' Параметр в процедуре потока
Type ThreadParam
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

Type HeapThreadParam
	' Флаг занятости участка памяти
	Dim IsUsed As Boolean
	Dim Param As ThreadParam
End Type

' Размер кучи
Const MyHeapSize As Integer = 2048 * SizeOf(HeapThreadParam)

' Подготавливает импровизированную кучу
Declare Sub MyHeapCreate(ByVal hHeap As Any Ptr)

' Уничтожает импровизированную кучу
Declare Sub MyHeapDestroy(ByVal hHeap As Any Ptr)

' Выделяет память в импровизированной куче
' При ошибке возвращает 0
Declare Function MyHeapAlloc(ByVal hHeap As Any Ptr)As ThreadParam Ptr

' Освобождает память из кучи
Declare Sub MyHeapFree(ByVal hMem As ThreadParam Ptr)
