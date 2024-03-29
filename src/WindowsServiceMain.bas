#include once "WindowsServiceMain.bi"
#include once "WebUtils.bi"

Const MaxWaitHint As DWORD = 10
Const ServiceName = WStr("Station922")

Type ServiceContext
	hStopEvent As HANDLE
	ServiceStatusHandle As SERVICE_STATUS_HANDLE
	ServiceStatus As SERVICE_STATUS
	ServiceCheckPoint As DWORD
End Type

Type SERVICE_TABLE_ENTRYW_ZERO
	Dim Table As SERVICE_TABLE_ENTRYW
	Dim Zero As SERVICE_TABLE_ENTRYW
End Type

Private Sub ReportSvcStatus( _
		ByVal lpContext As ServiceContext Ptr, _
		ByVal dwCurrentState As DWORD, _
		ByVal dwWin32ExitCode As DWORD, _
		ByVal dwWaitHint As DWORD _
	)
	
	lpContext->ServiceStatus.dwCurrentState = dwCurrentState
	lpContext->ServiceStatus.dwWin32ExitCode = dwWin32ExitCode
	lpContext->ServiceStatus.dwWaitHint = dwWaitHint
	
	Select Case dwCurrentState
		
		Case SERVICE_STOPPED
			lpContext->ServiceStatus.dwCheckPoint = 0
			
		Case SERVICE_START_PENDING, SERVICE_STOP_PENDING
			lpContext->ServiceCheckPoint += 1
			lpContext->ServiceStatus.dwCheckPoint = lpContext->ServiceCheckPoint
			lpContext->ServiceStatus.dwControlsAccepted = SERVICE_ACCEPT_STOP Or SERVICE_ACCEPT_SHUTDOWN
			
		Case SERVICE_RUNNING
			lpContext->ServiceStatus.dwCheckPoint = 0
			lpContext->ServiceStatus.dwControlsAccepted = SERVICE_ACCEPT_STOP Or SERVICE_ACCEPT_SHUTDOWN
			
	End Select
	
	SetServiceStatus(lpContext->ServiceStatusHandle, @lpContext->ServiceStatus)
	
End Sub

Private Function SvcCtrlHandlerEx( _
		ByVal dwCtrl As DWORD, _
		ByVal dwEventType As DWORD, _
		ByVal lpEventData As LPVOID, _
		ByVal lpContext As LPVOID _
	)As DWORD
	
	Dim pServiceContext As ServiceContext Ptr = lpContext
	
	Select Case dwCtrl
		
		Case SERVICE_CONTROL_INTERROGATE
			ReportSvcStatus( _
				pServiceContext, _
				pServiceContext->ServiceStatus.dwCurrentState, _
				NO_ERROR, _
				0 _
			)
			
		Case SERVICE_CONTROL_STOP, SERVICE_CONTROL_SHUTDOWN
			ReportSvcStatus( _
				pServiceContext, _
				SERVICE_STOP_PENDING, _
				NO_ERROR, _
				MaxWaitHint _
			)
			
			SetEvent(pServiceContext->hStopEvent)
			
		Case Else
			Return ERROR_CALL_NOT_IMPLEMENTED
			
	End Select
	
	Return NO_ERROR
	
End Function

Private Sub SvcMain( _
		ByVal dwNumServicesArgs As DWORD, _
		ByVal lpServiceArgVectors As LPWSTR Ptr _
	)
	
	Dim Context As ServiceContext = Any
	ZeroMemory(@Context, SizeOf(ServiceContext))
	
	Context.ServiceStatusHandle = RegisterServiceCtrlHandlerExW( _
		@ServiceName, _
		@SvcCtrlHandlerEx, _
		@Context _
	)
	If Context.ServiceStatusHandle = 0 Then
		Exit Sub
	End If
	
	Context.ServiceStatus.dwServiceType = SERVICE_WIN32_OWN_PROCESS
	Context.ServiceStatus.dwServiceSpecificExitCode = 0
	
	ReportSvcStatus(@Context, SERVICE_START_PENDING, NO_ERROR, MaxWaitHint)
	
	Context.hStopEvent = CreateEventW( _
		NULL, _
		TRUE, _
		FALSE, _
		NULL _
	)
	If Context.hStopEvent = NULL Then
		Dim dwError As DWORD = GetLastError()
		ReportSvcStatus(@Context, SERVICE_STOPPED, dwError, 0)
		Exit Sub
	End If
	
	ReportSvcStatus(@Context, SERVICE_START_PENDING, NO_ERROR, MaxWaitHint)
	
	Scope
		Dim hrInitialize As HRESULT = Station922Initialize()
		If FAILED(hrInitialize) Then
			CloseHandle(Context.hStopEvent)
			ReportSvcStatus(@Context, SERVICE_STOPPED, ERROR_NOT_ENOUGH_MEMORY, 0)
			Exit Sub
		End If
	End Scope
	
	ReportSvcStatus(@Context, SERVICE_RUNNING, NO_ERROR, 0)
	
	WaitAlertableLoop(Context.hStopEvent)
	
	ReportSvcStatus(@Context, SERVICE_STOP_PENDING, NO_ERROR, 0)
	
	Scope
		Station922CleanUp()
		CloseHandle(Context.hStopEvent)
	End Scope
	
	ReportSvcStatus(@Context, SERVICE_STOPPED, NO_ERROR, 0)
	
End Sub

Public Function WindowsServiceMain()As Integer
	
	Dim DispatchTable As SERVICE_TABLE_ENTRYW_ZERO = Type( _
		Type<SERVICE_TABLE_ENTRYW>(@ServiceName, @SvcMain), _
		Type<SERVICE_TABLE_ENTRYW>(NULL, NULL) _
	)
	
	Dim resStartService As BOOL = StartServiceCtrlDispatcherW( _
		CPtr(SERVICE_TABLE_ENTRYW Ptr, _
		@DispatchTable) _
	)
	If resStartService = 0 Then
		Return 1
	End If
	
	Return 0
	
End Function
