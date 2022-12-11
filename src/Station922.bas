#include once "windows.bi"
#include once "win\shellapi.bi"
#include once "ConsoleMain.bi"
#include once "Network.bi"
#include once "WindowsServiceMain.bi"

Const ServiceParam = WStr("/service")
Const CompareResultEqual As Long = 0

Function EntryPoint()As Integer
	
	Dim hrNetworkStartup As HRESULT = NetworkStartUp()
	If FAILED(hrNetworkStartup) Then
		Return 1
	End If
	
	Scope
		Dim resLoadWsa As Boolean = LoadWsaFunctions()
		If resLoadWsa = False Then
			NetworkCleanup()
			Return 1
		End If
	End Scope
	
	Dim RetCode As Integer = Any
	Scope
		Dim pLine As LPWSTR = GetCommandLineW()
		Dim Args As Long = Any
		Dim ppLines As LPWSTR Ptr = CommandLineToArgvW( _
			pLine, _
			@Args _
		)
		
		If Args > 1 Then
			Dim CompareResult As Long = lstrcmpiW(ppLines[1], ServiceParam)
			If CompareResult = CompareResultEqual Then
				RetCode = WindowsServiceMain()
			Else
				RetCode = ConsoleMain()
			End If
		Else
			RetCode = ConsoleMain()
		End If
		
		LocalFree(ppLines)
	End Scope
	
	NetworkCleanUp()
	
	Return RetCode
	
End Function

#ifndef WITHOUT_RUNTIME
Dim RetCode As Long = CLng(EntryPoint())
End(RetCode)
#endif
