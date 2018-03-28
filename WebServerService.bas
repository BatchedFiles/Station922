#ifdef service

#include "WebServerService.bi"

Function EntryPoint Alias "EntryPoint"()As Integer
	Dim DispatchTable(1) As SERVICE_TABLE_ENTRY = Any
	DispatchTable(0).lpServiceName = @ServiceName
	DispatchTable(0).lpServiceProc = @SvcMain
	DispatchTable(1).lpServiceName = 0
	DispatchTable(1).lpServiceProc = 0
	
	If StartServiceCtrlDispatcher(@DispatchTable(0)) = 0 Then
		Return 1
	End If
	Return 0
End Function

Sub SvcMain( _
		ByVal dwNumServicesArgs As DWORD, _
		ByVal lpServiceArgVectors As LPWSTR ptr _
	)
	Dim Context As ServiceContext
	
	Context.ServiceStatusHandle = RegisterServiceCtrlHandlerEx(@ServiceName, @SvcCtrlHandlerEx, @Context)
	If Context.ServiceStatusHandle = 0 Then
		Exit Sub
	End If
	
	Context.ServiceStatus.dwServiceType = SERVICE_WIN32_OWN_PROCESS
	Context.ServiceStatus.dwServiceSpecificExitCode = 0
	
	ReportSvcStatus(@Context, SERVICE_START_PENDING, NO_ERROR, 3000)
	
	Context.ServiceStopEvent = CreateEvent(NULL, TRUE, FALSE, NULL)
	If Context.ServiceStopEvent = NULL Then
		ReportSvcStatus(@Context, SERVICE_STOPPED, NO_ERROR, 0)
		Exit Sub
	End If
	
	ReportSvcStatus(@Context, SERVICE_START_PENDING, NO_ERROR, 3000)
	
	Dim ThreadId As DWord = Any
	Dim hMainThread As HANDLE = CreateThread(NULL, 0, @ServiceProc, 0, 0, @ThreadId)
	If hMainThread = NULL Then
		ReportSvcStatus(@Context, SERVICE_STOPPED, NO_ERROR, 0)
		Exit Sub
	End If
	CloseHandle(hMainThread)
	
	ReportSvcStatus(@Context, SERVICE_RUNNING, NO_ERROR, 0)
	
	WaitForSingleObject(Context.ServiceStopEvent, INFINITE)
	
	ReportSvcStatus(@Context, SERVICE_STOPPED, NO_ERROR, 0)
End Sub

Function SvcCtrlHandlerEx( _
		ByVal dwCtrl As DWORD, _
		ByVal dwEventType As DWORD, _
		ByVal lpEventData As LPVOID, _
		ByVal lpContext As LPVOID _
	)As DWORD
	
	Dim lpContext2 As ServiceContext Ptr = lpContext
	
	Select Case dwCtrl
		Case SERVICE_CONTROL_INTERROGATE
			ReportSvcStatus(lpContext2, lpContext2->ServiceStatus.dwCurrentState, NO_ERROR, 0)
			
		Case SERVICE_CONTROL_STOP
			ReportSvcStatus(lpContext2, SERVICE_STOP_PENDING, NO_ERROR, 0)
			SetEvent(lpContext2->ServiceStopEvent)
			
		Case Else
			Return ERROR_CALL_NOT_IMPLEMENTED
			
	End Select
	
	Return NO_ERROR
	
End Function
	
Sub ReportSvcStatus( _
		ByVal lpContext As ServiceContext Ptr, _
		ByVal dwCurrentState As DWORD, _
		ByVal dwWin32ExitCode As DWORD, _
		ByVal dwWaitHint As DWORD _
	)
	lpContext->ServiceStatus.dwCurrentState = dwCurrentState
	lpContext->ServiceStatus.dwWin32ExitCode = dwWin32ExitCode
	lpContext->ServiceStatus.dwWaitHint = dwWaitHint
	
	If dwCurrentState = SERVICE_START_PENDING Then
		lpContext->ServiceStatus.dwControlsAccepted = 0
	Else
		lpContext->ServiceStatus.dwControlsAccepted = SERVICE_ACCEPT_STOP
	End If
	
	If dwCurrentState = SERVICE_RUNNING Or dwCurrentState = SERVICE_STOPPED Then
		lpContext->ServiceStatus.dwCheckPoint = 0
	Else
		lpContext->ServiceCheckPoint += 1
		lpContext->ServiceStatus.dwCheckPoint = lpContext->ServiceCheckPoint
	End If
	
	SetServiceStatus(lpContext->ServiceStatusHandle, @lpContext->ServiceStatus)
End Sub

#endif
