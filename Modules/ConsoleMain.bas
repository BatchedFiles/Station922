#ifndef WINDOWS_SERVICE

#include "ConsoleMain.bi"
#include "CreateInstance.bi"
#include "WebServer.bi"

Function ConsoleMain()As Integer
	
	Dim pIWebServer As IRunnable Ptr = Any
	Dim hr As HRESULT = CreateInstance(GetProcessHeap(), @CLSID_WEBSERVER, @IID_IRunnable, @pIWebServer)
	
	If FAILED(hr) Then
		Return 1
	End If
	
	hr = IRunnable_Run(pIWebServer)
	If FAILED(hr) Then
		Return 2
	End If
	
	Const BufferLength As Integer = 7
	Dim Buffer As WString * (BufferLength + 1) = Any
	Dim NumberOfCharsRead As DWORD = Any
	ReadConsole(GetStdHandle(STD_INPUT_HANDLE), @Buffer, BufferLength, @NumberOfCharsRead, NULL)
	
	hr = IRunnable_Stop(pIWebServer)
	
	IRunnable_Release(pIWebServer)
	
	Return 0
	
End Function

#endif
