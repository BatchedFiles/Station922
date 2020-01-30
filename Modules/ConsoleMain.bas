#ifndef WINDOWS_SERVICE

#include "ConsoleMain.bi"
#include "CreateInstance.bi"
#include "IRunnable.bi"

Extern CLSID_WEBSERVER Alias "CLSID_WEBSERVER" As Const CLSID

Function ConsoleMain()As Integer
	
	Dim pIWebServer As IRunnable Ptr = Any
	Dim hr As HRESULT = CreateInstance(GetProcessHeap(), @CLSID_WEBSERVER, @IID_IRunnable, @pIWebServer)
	
	If FAILED(hr) Then
		Return 1
	End If
	
	IRunnable_Run(pIWebServer)
	
	IRunnable_Stop(pIWebServer)
	
	IRunnable_Release(pIWebServer)
	
	Return 0
	
End Function

#endif
