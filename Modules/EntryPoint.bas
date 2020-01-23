#include "EntryPoint.bi"
#include "Http.bi"
#include "InitializeVirtualTables.bi"
#include "win\winsock2.bi"

#ifdef WINDOWS_SERVICE

#include "WindowsServiceMain.bi"
#define MAIN_FUNCTION WindowsServiceMain()

#else

#include "ConsoleMain.bi"
#define MAIN_FUNCTION ConsoleMain()

#endif

Function MainEntryPoint()As Integer
	
	InitializeVirtualTables()
	
	If CreateRequestHeadersTree() = False Then
		Return 2
	End If
	
	Dim objWsaData As WSAData = Any
	If WSAStartup(MAKEWORD(2, 2), @objWsaData) <> NO_ERROR Then
		Return 1
	End If
	
	Dim RetCode As Integer = MAIN_FUNCTION
	
	WSACleanup()
	
	Return RetCode
	
End Function

#ifdef WITHOUT_RUNTIME

Sub EntryPoint Alias "EntryPoint"()
	
	ExitProcess(MainEntryPoint)
	
End Sub

#else

End(MainEntryPoint)

#endif
