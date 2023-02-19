#include once "ConsoleMain.bi"
#include once "HeapMemoryAllocator.bi"
#include once "WebUtils.bi"

Function ConsoleMain()As Integer
	
	Dim hStopEvent As HANDLE = CreateEventW( _
		NULL, _
		TRUE, _
		FALSE, _
		NULL _
	)
	If hStopEvent = NULL Then
		Return 1
	End If
	
	Scope
		Dim hrInitialize As HRESULT = Station922Initialize()
		If FAILED(hrInitialize) Then
			Return 1
		End If
	End Scope
	
	WaitForSingleObject(hStopEvent, INFINITE)
	
	CloseHandle(hStopEvent)
	
	Return 0
	
End Function
