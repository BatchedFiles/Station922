#include "EntryPoint.bi"
#include "Http.bi"
#include "InitializeVirtualTables.bi"
#include "win\winsock2.bi"
#ifdef WINDOWS_SERVICE
	#include "WindowsServiceMain.bi"
#else
	#include "ConsoleMain.bi"
#endif

Type MainFunction As Function()As Integer

Function MainEntryPoint()As Integer
	
	InitializeVirtualTables()
	
	If CreateRequestHeadersTree() = False Then
		Return 2
	End If
	
	Dim objWsaData As WSAData = Any
	If WSAStartup(MAKEWORD(2, 2), @objWsaData) <> NO_ERROR Then
		Return 1
	End If
	
	Dim lpfnMain As MainFunction = Any
	#ifdef WINDOWS_SERVICE
		lpfnMain = @WindowsServiceMain
	#else
		lpfnMain = @ConsoleMain
	#endif
	
	Dim RetCode As Integer = lpfnMain()
	
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
