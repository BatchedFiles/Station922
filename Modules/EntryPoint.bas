#include "EntryPoint.bi"
#include "win\winsock2.bi"
#include "Http.bi"

#ifdef WINDOWS_SERVICE
#include "WindowsServiceMain.bi"
#else
#include "ConsoleMain.bi"
#endif

#ifdef WITHOUT_RUNTIME
Function EntryPoint Alias "EntryPoint"()As Integer
#endif
	
	Dim RetCode As Integer = 0
	
	Scope
		Dim wsa As WSAData = Any
		If WSAStartup(MAKEWORD(2, 2), @wsa) <> NO_ERROR Then
			RetCode = 1
			GoTo ExitLabel
		End If
	End Scope
	
	Scope
		RetCode = ConsoleMain()
	End Scope
	
CleanUpLabel:

	WSACleanup()
	
ExitLabel:

	#ifdef WITHOUT_RUNTIME
		Return RetCode
	#else
		End(RetCode)
	#endif
	
#ifdef WITHOUT_RUNTIME
End Function
#endif
