#include once "IRunnable.bi"
#include once "CreateInstance.bi"
#include once "Logger.bi"

Extern CLSID_WEBSERVER Alias "CLSID_WEBSERVER" As Const CLSID
Extern CLSID_CONSOLELOGGER Alias "CLSID_CONSOLELOGGER" As Const CLSID

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
	Dim hr As HRESULT = CoGetMalloc(1, @pIMemoryAllocator)
	If FAILED(hr) Then
		Return 1
	End If
	
	Dim pIWebServer As IRunnable Ptr = Any
	hr = CreateInstance( _
		pIMemoryAllocator, _
		@CLSID_WEBSERVER, _
		@IID_IRunnable, _
		@pIWebServer _
	)
	If FAILED(hr) Then
		IMalloc_Release(pIMemoryAllocator)
		Return 1
	End If
	
	IMalloc_Release(pIMemoryAllocator)
	
	Dim Context As ServerContext = Any
	With Context
		.pIWebServer = pIWebServer
	End With
	
	IRunnable_RegisterStatusHandler(pIWebServer, @Context, @RunnableStatusHandler)
	
	hr = IRunnable_Run(pIWebServer)
	If FAILED(hr) Then
		Return 2
	End If
	
	hr = IRunnable_Stop(pIWebServer)
	If FAILED(hr) Then
		Return 3
	End If
	
	IRunnable_Release(pIWebServer)
	
	Return 0
	
End Function
