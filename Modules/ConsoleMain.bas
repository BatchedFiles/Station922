#include once "CreateInstance.bi"
#include once "Logger.bi"
#include once "WebServer.bi"

Type ServerContext
	pIWebServer As IRunnable Ptr
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

Function wMain()As Long
	
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
	With Context
		.pIWebServer = pIWebServer
	End With
	
	IRunnable_RegisterStatusHandler(pIWebServer, @Context, @RunnableStatusHandler)
	
	Dim hrRun As HRESULT = IRunnable_Run(pIWebServer)
	If FAILED(hrRun) Then
		Return 2
	End If
	
	Dim hrStop As HRESULT = IRunnable_Stop(pIWebServer)
	If FAILED(hrStop) Then
		Return 3
	End If
	
	IRunnable_Release(pIWebServer)
	
	Return 0
	
End Function
