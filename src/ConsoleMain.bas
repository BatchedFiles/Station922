#include once "ConsoleMain.bi"
#include once "WebUtils.bi"

Public Function ConsoleMain()As Integer

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

	Do
		Dim resWait As DWORD = WaitForSingleObjectEx( _
			hStopEvent, _
			INFINITE, _
			TRUE _
		)

		Select Case resWait

			Case WAIT_OBJECT_0
				' The event became a signal
				' exit from loop
				Exit Do

			Case WAIT_IO_COMPLETION
				' The asynchronous procedure has ended
				' we continue to wait
				Continue Do

			Case Else ' WAIT_ABANDONED, WAIT_TIMEOUT, WAIT_FAILED
				Exit Do

		End Select
	Loop

	Station922CleanUp()

	CloseHandle(hStopEvent)

	Return 0

End Function
