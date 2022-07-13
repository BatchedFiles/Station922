#include once "WindowsServiceMain.bi"
#include once "CreateInstance.bi"
#include once "Logger.bi"
#include once "WebServer.bi"

Const MaxWaitHint As DWORD = 3000
Const ServiceName = WStr("Station922")

Type ServiceContext
	hStopEvent As HANDLE
	pIWebServer As IRunnable Ptr
	ServiceStatusHandle As SERVICE_STATUS_HANDLE
	ServiceStatus As SERVICE_STATUS
	ServiceCheckPoint As DWORD
End Type

Type SERVICE_TABLE_ENTRYW_ZERO
	Dim Table As SERVICE_TABLE_ENTRYW
	Dim Zero As SERVICE_TABLE_ENTRYW
End Type

Function RunnableStatusHandler( _
		ByVal Context As Any Ptr, _
		ByVal Status As HRESULT _
	)As HRESULT
	
	#if __FB_DEBUG__
	Scope
		Dim vtSCode As VARIANT = Any
		vtSCode.vt = VT_ERROR
		vtSCode.scode = Status
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"RunnableStatusHandler\t"), _
			@vtSCode _
		)
	End Scope
	#endif
	
	Return S_OK
	
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

Function SvcCtrlHandlerEx( _
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
			IRunnable_Stop(pServiceContext->pIWebServer)
			
		Case Else
			Return ERROR_CALL_NOT_IMPLEMENTED
			
	End Select
	
	Return NO_ERROR
	
End Function

Sub SvcMain( _
		ByVal dwNumServicesArgs As DWORD, _
		ByVal lpServiceArgVectors As LPWSTR ptr _
	)
	
	Dim Context As ServiceContext = Any
	ZeroMemory(@Context, SizeOf(ServiceContext))
	
	Context.ServiceStatusHandle = RegisterServiceCtrlHandlerExW( _
		@ServiceName, _
		@SvcCtrlHandlerEx, _
		@Context _
	)
	If Context.ServiceStatusHandle = 0 Then
		' TODO Обработать ошибку
		' Dim dwError As DWORD = GetLastError()
		Exit Sub
	End If
	
	Context.ServiceStatus.dwServiceType = SERVICE_WIN32_OWN_PROCESS
	Context.ServiceStatus.dwServiceSpecificExitCode = 0
	
	ReportSvcStatus(@Context, SERVICE_START_PENDING, NO_ERROR, MaxWaitHint)
	
	Dim pIMemoryAllocator As IMalloc Ptr = Any
	Dim hrGetMalloc As HRESULT = CoGetMalloc(1, @pIMemoryAllocator)
	If FAILED(hrGetMalloc) Then
		ReportSvcStatus(@Context, SERVICE_STOPPED, ERROR_NOT_ENOUGH_MEMORY, 0)
		Exit Sub
	End If
	
	Dim hrCreateWebServer As HRESULT = CreateInstance( _
		pIMemoryAllocator, _
		@CLSID_WEBSERVER, _
		@IID_IRunnable, _
		@Context.pIWebServer _
	)
	If FAILED(hrCreateWebServer) Then
		IMalloc_Release(pIMemoryAllocator)
		ReportSvcStatus(@Context, SERVICE_STOPPED, ERROR_NOT_ENOUGH_MEMORY, 0)
		Exit Sub
	End If
	
	IMalloc_Release(pIMemoryAllocator)
	
	ReportSvcStatus(@Context, SERVICE_START_PENDING, NO_ERROR, MaxWaitHint)
	
	Context.hStopEvent = CreateEventW( _
		NULL, _
		TRUE, _
		FALSE, _
		NULL _
	)
	If Context.hStopEvent = NULL Then
		Dim dwError As DWORD = GetLastError()
		IRunnable_Release(Context.pIWebServer)
		ReportSvcStatus(@Context, SERVICE_STOPPED, dwError, 0)
		Exit Sub
	End If
	
	ReportSvcStatus(@Context, SERVICE_START_PENDING, NO_ERROR, MaxWaitHint)
	
	IRunnable_RegisterStatusHandler(Context.pIWebServer, @Context, @RunnableStatusHandler)
	
	Dim hrRun As HRESULT = IRunnable_Run(Context.pIWebServer)
	If FAILED(hrRun) Then
		CloseHandle(Context.hStopEvent)
		IRunnable_Release(Context.pIWebServer)
		ReportSvcStatus(@Context, SERVICE_STOPPED, ERROR_NOT_ENOUGH_MEMORY, 0)
		Exit Sub
	End If
	
	ReportSvcStatus(@Context, SERVICE_RUNNING, NO_ERROR, 0)
	
	WaitForSingleObject(Context.hStopEvent, INFINITE)
	
	ReportSvcStatus(@Context, SERVICE_STOP_PENDING, NO_ERROR, 0)
	
	IRunnable_Release(Context.pIWebServer)
	
	ReportSvcStatus(@Context, SERVICE_STOPPED, NO_ERROR, 0)
	
End Sub

Function WindowsServiceMain()As Long
	
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
