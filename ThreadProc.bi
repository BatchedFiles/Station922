#ifndef unicode
#define unicode
#endif

#include once "windows.bi"
#include once "win\winsock2.bi"
#include once "win\ws2tcpip.bi"

#include once "Network.bi"

' Процедура потока
Declare Function ThreadProc(ByVal lpParam As LPVOID)As DWORD
