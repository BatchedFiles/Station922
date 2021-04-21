#include once "windows.bi"
#include once "win\winsock2.bi"
#include once "PrintDebugInfo.bi"

Declare Function wMain()As Long

#ifdef WITHOUT_RUNTIME
Function EntryPoint()As Integer
#else
Function main Alias "main"()As Long
#endif
	
	Dim RetCode As Long = 0
	
	Scope
		Dim wsa As WSAData = Any
		If WSAStartup(MAKEWORD(2, 2), @wsa) <> NO_ERROR Then
			RetCode = 1
			GoTo ExitLabel
		End If
	End Scope
	
	RetCode = wMain()
	
CleanUpLabel:

	WSACleanup()
	
ExitLabel:

	Return RetCode
	
#ifdef WITHOUT_RUNTIME
End Function
#else
End Function
#endif
