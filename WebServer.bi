#ifndef WEBSERVER_BI
#define WEBSERVER_BI

#ifndef unicode
#define unicode
#endif
#include once "windows.bi"
#include once "win\shlwapi.bi"
#include once "ThreadProc.bi"

' Точка входа
Declare Function EntryPoint Alias "EntryPoint"( _
)As Integer

' Функция сервисного потока
#ifdef service
Declare Function ServiceProc( _
	ByVal lpParam As LPVOID _
)As DWORD
#endif

' Получение идентификатора лог‐файла
Declare Function GetLogFileHandle( _
	ByVal dtCurrent As SYSTEMTIME Ptr, _
	ByVal LogDir As WString Ptr _
)As Handle

#endif
