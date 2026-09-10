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

	Dim IsService As Boolean = False

	For i As Integer = 1 To CInt(Args)
		Dim resCompare As Long = lstrcmpiW( _
			ppLines[i], _
			@ServiceParam _
		)

		If resCompare = CompareResultEqual Then
			IsService = True
		End If
	Next

	LocalFree(ppLines)

	Return IsService

End Function


Dim RetCode As Integer = Any

Dim IsService As Boolean = IsServiceParam()

If IsService Then
	RetCode = WindowsServiceMain()
Else
	RetCode = ConsoleMain()
End If

End(CLng(RetCode))
