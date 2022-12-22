#include once "ConsoleMain.bi"
#include once "CreateInstance.bi"
#include once "WebServer.bi"

Type ServerContext
	pIWebServer As IRunnable Ptr
	hStopEvent As HANDLE
End Type

Function ConsoleRunnableStatusHandler( _
		ByVal Context As Any Ptr, _
		ByVal Status As HRESULT _
	)As HRESULT
	
	Dim pServerContext As ServerContext Ptr = Context
	
	Select Case Status
		
		Case RUNNABLE_S_STOPPED
			SetEvent(pServerContext->hStopEvent)
			
		Case RUNNABLE_S_START_PENDING
			
		Case RUNNABLE_S_RUNNING
			
		Case RUNNABLE_S_STOP_PENDING
			
		Case RUNNABLE_S_CONTINUE
			
	End Select
	
	Return S_OK
	
End Function

Function ConsoleMain()As Integer
	
	Dim pIMemoryAllocator As IMalloc Ptr = Any
	Dim hrGetAllocator As HRESULT = CoGetMalloc(1, @pIMemoryAllocator)
	If FAILED(hrGetAllocator) Then
		Return 1
	End If
	
	Dim pIWebServer As IRunnable Ptr = Any
	Dim hrCreateServer As HRESULT = CreateInstance( _
		pIMemoryAllocator, _
		@CLSID_WEBSERVER, _
		@IID_IRunnable, _
		@pIWebServer _
	)
	If FAILED(hrCreateServer) Then
		IMalloc_Release(pIMemoryAllocator)
		Return 1
	End If
	
	IMalloc_Release(pIMemoryAllocator)
	
	Dim Context As ServerContext = Any
	Context.pIWebServer = pIWebServer
	
	Context.hStopEvent = CreateEventW( _
		NULL, _
		TRUE, _
		FALSE, _
		NULL _
	)
	If Context.hStopEvent = NULL Then
		IRunnable_Release(Context.pIWebServer)
		Return 1
	End If
	
	IRunnable_RegisterStatusHandler( _
		pIWebServer, _
		@Context, _
		@ConsoleRunnableStatusHandler _
	)
	
	Dim hrRun As HRESULT = IRunnable_Run(pIWebServer)
	If FAILED(hrRun) Then
		Return 2
	End If
	
	WaitForSingleObject(Context.hStopEvent, INFINITE)
	
	Dim hrStop As HRESULT = IRunnable_Stop(pIWebServer)
	If FAILED(hrStop) Then
		Return 3
	End If
	
	IRunnable_Release(pIWebServer)
	
	Return 0
	
End Function
