#include once "IRunnable.bi"
#include once "CreateInstance.bi"
#include once "ILogger.bi"

Extern CLSID_WEBSERVER Alias "CLSID_WEBSERVER" As Const CLSID
Extern CLSID_CONSOLELOGGER Alias "CLSID_CONSOLELOGGER" As Const CLSID

Type ServerContext
	Dim hStopEvent As HANDLE
	Dim pILogger As ILogger Ptr
	Dim pIWebServer As IRunnable Ptr
End Type

Function RunnableStatusHandler( _
		ByVal Context As Any Ptr, _
		ByVal Status As HRESULT _
	)As HRESULT
	
	Dim pContext As ServerContext Ptr = Context
	
	Dim vtSCode As VARIANT = Any
	vtSCode.vt = VT_ERROR
	vtSCode.scode = Status
	ILogger_LogDebug(pContext->pILogger, WStr(!"RunnableStatusHandler\t"), vtSCode)
	
	If FAILED(Status) Then
		SetEvent(pContext->hStopEvent)
	End If
	
	If Status = RUNNABLE_S_STOPPED Then
		SetEvent(pContext->hStopEvent)
	End If
	
	Return S_OK
	
End Function

Function wMain()As Long
	
	Dim pIMemoryAllocator As IMalloc Ptr = Any
	Dim hr As HRESULT = CoGetMalloc(1, @pIMemoryAllocator)
	If FAILED(hr) Then
		Return 1
	End If
	
	Dim pILogger As ILogger Ptr = Any
	hr = CreateLoggerInstance( _
		pIMemoryAllocator, _
		@CLSID_CONSOLELOGGER, _
		@IID_ILogger, _
		@pILogger _
	)
	If FAILED(hr) Then
		IMalloc_Release(pIMemoryAllocator)
		Return 1
	End If
	
	Dim pIWebServer As IRunnable Ptr = Any
	hr = CreateInstance( _
		pILogger, _
		pIMemoryAllocator, _
		@CLSID_WEBSERVER, _
		@IID_IRunnable, _
		@pIWebServer _
	)
	If FAILED(hr) Then
		ILogger_Release(pILogger)
		IMalloc_Release(pIMemoryAllocator)
		Return 1
	End If
	
	IMalloc_Release(pIMemoryAllocator)
	
	Dim hStopEvent As HANDLE = CreateEvent( _
		NULL, _
		TRUE, _
		FALSE, _
		NULL _
	)
	If hStopEvent = NULL Then
		IRunnable_Release(pIWebServer)
		Return 4
	End If
	
	Dim Context As ServerContext = Any
	With Context
		.hStopEvent = hStopEvent
		.pILogger = pILogger
		.pIWebServer = pIWebServer
	End With
	
	IRunnable_RegisterStatusHandler(pIWebServer, @Context, @RunnableStatusHandler)
	
	hr = IRunnable_Run(pIWebServer)
	If FAILED(hr) Then
		Return 2
	End If
	
	WaitForSingleObject(hStopEvent, INFINITE)
	
	hr = IRunnable_Stop(pIWebServer)
	If FAILED(hr) Then
		Return 3
	End If
	
	IRunnable_Release(pIWebServer)
	ILogger_Release(pILogger)
	
	Return 0
	
End Function
