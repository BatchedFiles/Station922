#ifdef service

#define unicode
#include once "windows.bi"

Declare Sub ReportSvcStatus(ByVal dwCurrentState As DWORD, ByVal dwWin32ExitCode As DWORD, ByVal dwWaitHint As DWORD)
Declare Sub SvcMain(byval dwNumServicesArgs as DWORD, byval lpServiceArgVectors as LPWSTR ptr)
Declare Sub SvcCtrlHandler(ByVal dwCtrl As DWORD)
' Функция сервисного потока
Declare Function ServiceProc(ByVal lpParam As LPVOID)As DWORD

Const SVCNAME = "FBWebServer"

Dim Shared gSvcStatus As SERVICE_STATUS
Dim Shared gSvcStatusHandle As SERVICE_STATUS_HANDLE
Dim Shared ghSvcStopEvent As HANDLE
Dim Shared hMainThread As HANDLE
Dim Shared dwCheckPoint As DWORD


Function EntryPoint Alias "EntryPoint"()As Integer
	Dim DispatchTable(1) As SERVICE_TABLE_ENTRY = Any
	DispatchTable(0).lpServiceName = @SVCNAME
	DispatchTable(0).lpServiceProc = @SvcMain
	DispatchTable(1).lpServiceName = 0
	DispatchTable(1).lpServiceProc = 0
	
	
	' This call returns when the service has stopped. 
	' The process should simply terminate when the call returns.
	If StartServiceCtrlDispatcher(@DispatchTable(0)) = 0 Then
		' Произошла ошибка
	End If
	ExitProcess(0)
	Return 0
End Function

' //
' // Purpose: 
' //   Entry point for the service
' //
' // Parameters:
' //   dwArgc - Number of arguments in the lpszArgv array
' //   lpszArgv - Array of strings. The first string is the name of
' //     the service and subsequent strings are passed by the process
' //     that called the StartService function to start the service.
' // 
' // Return value:
' //   None.
' //
Sub SvcMain(byval dwNumServicesArgs as DWORD, byval lpServiceArgVectors as LPWSTR ptr)
	' Register the handler function for the service
	gSvcStatusHandle = RegisterServiceCtrlHandler(@SVCNAME, @SvcCtrlHandler)
	If gSvcStatusHandle = 0 Then
		' Какая‐то ошибка
		Exit Sub
	End If
	
	' These SERVICE_STATUS members remain as set here
	gSvcStatus.dwServiceType = SERVICE_WIN32_OWN_PROCESS
	gSvcStatus.dwServiceSpecificExitCode = 0
	
	' Report initial status to the SCM
	ReportSvcStatus(SERVICE_START_PENDING, NO_ERROR, 3000)
	
	ghSvcStopEvent = CreateEvent(NULL, True, False, NULL)
	If ghSvcStopEvent = NULL Then
		ReportSvcStatus(SERVICE_STOPPED, NO_ERROR, 0)
		Exit Sub
	End If
	
	' Запустить поток, в котором будет происходить обработка запроса
	Dim ThreadId As Integer = Any
	hMainThread = CreateThread(NULL, 0, @ServiceProc, 0, 0, @ThreadId)
	If hMainThread = NULL Then
		ReportSvcStatus(SERVICE_STOPPED, NO_ERROR, 0)
		Exit Sub
	End If
	
	' Report running status when initialization is complete.
	ReportSvcStatus(SERVICE_RUNNING, NO_ERROR, 0)
	
	' Perform work until service stops.
	' Check whether to stop the service.
	WaitForSingleObject(ghSvcStopEvent, INFINITE)
	ReportSvcStatus(SERVICE_STOPPED, NO_ERROR, 0)
End Sub

' //
' // Purpose: 
' //   Called by SCM whenever a control code is sent to the service
' //   using the ControlService function.
' //
' // Parameters:
' //   dwCtrl - control code
' // 
' // Return value:
' //   None
' //
Sub SvcCtrlHandler(ByVal dwCtrl As DWORD)
	' Handle the requested control code. 
	Select Case dwCtrl
		case SERVICE_CONTROL_STOP
			ReportSvcStatus(SERVICE_STOP_PENDING, NO_ERROR, 0)
			' Signal the service to stop.
			SetEvent(ghSvcStopEvent)
		Case SERVICE_CONTROL_INTERROGATE
			ReportSvcStatus(gSvcStatus.dwCurrentState, NO_ERROR, 0)
		Case Else 
			
	End Select
End Sub

' //
' // Purpose: 
' //   Sets the current service status and reports it to the SCM.
' //
' // Parameters:
' //   dwCurrentState - The current state (see SERVICE_STATUS)
' //   dwWin32ExitCode - The system error code
' //   dwWaitHint - Estimated time for pending operation, 
' //     in milliseconds
' // 
' // Return value:
' //   None
' //
Sub ReportSvcStatus(ByVal dwCurrentState As DWORD, ByVal dwWin32ExitCode As DWORD, ByVal dwWaitHint As DWORD)
	' Fill in the SERVICE_STATUS structure.
	gSvcStatus.dwCurrentState = dwCurrentState
	gSvcStatus.dwWin32ExitCode = dwWin32ExitCode
	gSvcStatus.dwWaitHint = dwWaitHint
	
	If dwCurrentState = SERVICE_START_PENDING Then
		gSvcStatus.dwControlsAccepted = 0
	Else
		gSvcStatus.dwControlsAccepted = SERVICE_ACCEPT_STOP
	End If
	
	If dwCurrentState = SERVICE_RUNNING Or dwCurrentState = SERVICE_STOPPED Then
		gSvcStatus.dwCheckPoint = 0
	Else
		dwCheckPoint += 1
		gSvcStatus.dwCheckPoint = dwCheckPoint
	End If
	
	' Report the status of the service to the SCM.
	SetServiceStatus(gSvcStatusHandle, @gSvcStatus)
End Sub

#endif
