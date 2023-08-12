#include once "windows.bi"
#include once "win\shellapi.bi"
#include once "ConsoleMain.bi"
#include once "WindowsServiceMain.bi"

Const ServiceParam = WStr("/service")
Const CompareResultEqual As Long = 0

Private Function IsServiceParam()As Boolean
	
	Dim pLine As LPWSTR = GetCommandLineW()
	Dim Args As Long = Any
	Dim ppLines As LPWSTR Ptr = CommandLineToArgvW( _
		pLine, _
		@Args _
	)
	
	Dim IsService As Boolean = Any
	
	If Args > 1 Then
		Dim CompareResult As Long = lstrcmpiW(ppLines[1], ServiceParam)
		If CompareResult = CompareResultEqual Then
			IsService = True
		Else
			IsService = False
		End If
	Else
		IsService = False
	End If
	
	LocalFree(ppLines)
	
	Return IsService
	
End Function

#ifndef WITHOUT_RUNTIME
Private Function EntryPoint()As Integer
#else
Function EntryPoint Alias "EntryPoint"()As Integer
#endif
	
	Dim RetCode As Integer = Any
	
	Dim IsService As Boolean = IsServiceParam()
	
	If IsService Then
		RetCode = WindowsServiceMain()
	Else
		RetCode = ConsoleMain()
	End If
	
	Return RetCode
	
End Function

#ifndef WITHOUT_RUNTIME
Dim RetCode As Long = CLng(EntryPoint())
End(RetCode)
#endif
