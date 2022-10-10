#include once "WebServer.bi"
#include once "AcceptConnectionAsyncTask.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "HttpReader.bi"
#include once "IniConfiguration.bi"
#include once "Logger.bi"
#include once "Network.bi"
#include once "ThreadPool.bi"
#include once "WebUtils.bi"

Extern GlobalWebServerVirtualTable As Const IRunnableVirtualTable

Const THREAD_SLEEPING_TIME As DWORD = 60 * 1000

Const SocketListCapacity As Integer = 10

Type _WebServer
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IRunnableVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	
	WorkerThreadsCount As Integer
	pIPool As IThreadPool Ptr
	pIWebSites As IWebSiteCollection Ptr
	pIProcessors As IHttpProcessorCollection Ptr
	
	SocketList(0 To SocketListCapacity - 1) As SocketNode
	SocketListLength As Integer
	
	Context As Any Ptr
	StatusHandler As RunnableStatusHandler
	
	ListenAddress As BSTR
	ListenPort As UINT
	
	CurrentStatus As HRESULT
	
End Type

Function FinishExecuteTaskSink( _
		ByVal BytesTransferred As DWORD, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
	)As HRESULT
	
	IAsyncResult_SetCompleted( _
		pIResult, _
		BytesTransferred, _
		True _
	)
	
	Dim pTask As IAsyncIoTask Ptr = Any
	IAsyncResult_GetAsyncStateWeakPtr(pIResult, @pTask)
	
	#if __FB_DEBUG__
	Scope
		Dim vtResponse As VARIANT = Any
		vtResponse.vt = VT_BSTR
		vtResponse.bstrVal = SysAllocString(WStr(!"IAsyncIoTask_EndExecute"))
		LogWriteEntry( _
			LogEntryType.Debug, _
			NULL, _
			@vtResponse _
		)
		VariantClear(@vtResponse)
	End Scope
	#endif
	
	Dim hrEndExecute As HRESULT = IAsyncIoTask_EndExecute( _
		pTask, _
		pIResult, _
		BytesTransferred, _
		ppNextTask _
	)
	If FAILED(hrEndExecute) Then
		Dim vtErrorCode As VARIANT = Any
		vtErrorCode.vt = VT_ERROR
		vtErrorCode.scode = hrEndExecute
		LogWriteEntry( _
			LogEntryType.Error, _
			WStr(!"IAsyncIoTask_EndExecute Error\t"), _
			@vtErrorCode _
		)
	End If
	
	' Освобождаем ссылки на задачу и футуру
	' Так как мы не сделали это при запуске задачи
	
	IAsyncResult_Release(pIResult)
	IAsyncIoTask_Release(pTask)
	
	Return hrEndExecute
	
End Function

Function ThreadPoolCallBack( _
		ByVal param As Any Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal CompletionKey As ULONG_PTR, _
		ByVal pOverlap As OVERLAPPED Ptr _
	)As Integer
	
	#if __FB_DEBUG__
	Scope
		Dim vtBytesTransferred As VARIANT = Any
		vtBytesTransferred.vt = VT_UI4
		vtBytesTransferred.ulVal = BytesTransferred
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"\t\t\t\tBytesTransferred\t"), _
			@vtBytesTransferred _
		)
	End Scope
	#endif
	
	Dim hrFinishExecute As HRESULT = Any
	Dim pNextTask As IAsyncIoTask Ptr = Any
	Scope
		Dim pIResult As IAsyncResult Ptr = GetAsyncResultFromOverlappedWeakPtr(pOverlap)
		
		hrFinishExecute = FinishExecuteTaskSink( _
			BytesTransferred, _
			pIResult, _
			@pNextTask _
		)
	End Scope
	
	If SUCCEEDED(hrFinishExecute) Then
		
		Select Case hrFinishExecute
			
			Case S_OK
				#if __FB_DEBUG__
				Scope
					Dim vtResponse As VARIANT = Any
					vtResponse.vt = VT_BSTR
					vtResponse.bstrVal = SysAllocString(WStr(!"\t\t\t\tСontinue reading socket\r\n\r\n\r\n\r\n"))
					LogWriteEntry( _
						LogEntryType.Debug, _
						NULL, _
						@vtResponse _
					)
					VariantClear(@vtResponse)
				End Scope
				#endif
				
				Dim hrStart As HRESULT = StartExecuteTask(pNextTask)
				If FAILED(hrStart) Then
					IAsyncIoTask_Release(pNextTask)
				End If
				
			Case S_FALSE
				#if __FB_DEBUG__
				Scope
					Dim vtResponse As VARIANT = Any
					vtResponse.vt = VT_BSTR
					vtResponse.bstrVal = SysAllocString(WStr(!"\t\t\t\tEnd of file\r\n\r\n\r\n\r\n"))
					LogWriteEntry( _
						LogEntryType.Debug, _
						NULL, _
						@vtResponse _
					)
					VariantClear(@vtResponse)
				End Scope
				#endif
				
			Case ASYNCTASK_S_KEEPALIVE_FALSE
				#if __FB_DEBUG__
				Scope
					Dim vtResponse As VARIANT = Any
					vtResponse.vt = VT_BSTR
					vtResponse.bstrVal = SysAllocString(WStr(!"\t\t\t\tClient refused connection\r\n\r\n\r\n\r\n"))
					LogWriteEntry( _
						LogEntryType.Debug, _
						NULL, _
						@vtResponse _
					)
					VariantClear(@vtResponse)
				End Scope
				#endif
				
		End Select
	End If
	
	Return 0
	
End Function

Function CreateAcceptConnectionTask( _
		ByVal this As WebServer Ptr, _
		ByVal ServerSocket As SOCKET, _
		ByVal ppTask As IAcceptConnectionAsyncIoTask Ptr Ptr _
	)As HRESULT
	
	Dim pTask As IAcceptConnectionAsyncIoTask Ptr = Any
	Dim hrCreateTask As HRESULT = CreatePermanentInstance( _
		this->pIMemoryAllocator, _
		@CLSID_ACCEPTCONNECTIONASYNCTASK, _
		@IID_IAcceptConnectionAsyncIoTask, _
		@pTask _
	)
	If FAILED(hrCreateTask) Then
		Dim vtSCode As VARIANT = Any
		vtSCode.vt = VT_ERROR
		vtSCode.scode = hrCreateTask
		LogWriteEntry( _
			LogEntryType.Error, _
			WStr(!"IAcceptConnectionAsyncIoTask Create Error\t"), _
			@vtSCode _
		)
		*ppTask = NULL
		Return hrCreateTask
	End If
	
	IAcceptConnectionAsyncIoTask_SetWebSiteCollectionWeakPtr(pTask, this->pIWebSites)
	IAcceptConnectionAsyncIoTask_SetHttpProcessorCollectionWeakPtr(pTask, this->pIProcessors)
	IAcceptConnectionAsyncIoTask_SetListenSocket(pTask, ServerSocket)
	IAcceptConnectionAsyncIoTask_BindToThreadPool(pTask, this->pIPool)
	
	*ppTask = pTask
	Return S_OK
	
End Function

Function ReadConfiguration( _
		ByVal this As WebServer Ptr _
	)As HRESULT
	
	Dim pIConfig As IWebServerConfiguration Ptr = Any
	Dim hr As HRESULT = CreateInstance( _
		this->pIMemoryAllocator, _
		@CLSID_INICONFIGURATION, _
		@IID_IIniConfiguration, _
		@pIConfig _
	)
	If FAILED(hr) Then
		Return E_OUTOFMEMORY
	End If
	
	IWebServerConfiguration_GetListenAddress(pIConfig, @this->ListenAddress)
	
	IWebServerConfiguration_GetListenPort(pIConfig, @this->ListenPort)
	
	IWebServerConfiguration_GetWorkerThreadsCount(pIConfig, @this->WorkerThreadsCount)
	
	' IWebServerConfiguration_GetCachedClientMemoryContextCount(pIConfig, @this->CachedClientMemoryContextLength)
	
	IWebServerConfiguration_GetWebSiteCollection(pIConfig, @this->pIWebSites)
	
	IWebServerConfiguration_GetHttpProcessorCollection(pIConfig, @this->pIProcessors)
	
	IWebServerConfiguration_Release(pIConfig)
	
	Return S_OK
	
End Function

Function CreateServerSocket( _
		ByVal this As WebServer Ptr _
	)As HRESULT
	
	Dim wszListenPort As WString * (255 + 1) = Any
	_itow(this->ListenPort, @wszListenPort, 10)
	
	Dim hrCreateSocket As HRESULT = CreateSocketAndListenW( _
		this->ListenAddress, _
		wszListenPort, _
		@this->SocketList(0), _
		SocketListCapacity, _
		@this->SocketListLength _
	)
	If FAILED(hrCreateSocket) Then
		Return hrCreateSocket
	End If
	
	Return S_OK
	
End Function

Sub SetCurrentStatus( _
		ByVal this As WebServer Ptr, _
		ByVal Status As HRESULT _
	)
	
	this->CurrentStatus = Status
	
	If this->StatusHandler <> NULL Then
		this->StatusHandler(this->Context, Status)
	End If
	
End Sub

Sub InitializeWebServer( _
		ByVal this As WebServer Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pIPool As IThreadPool Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_WEBSERVER), _
			Len(WebServer.IdString) _
		)
	#endif
	this->lpVtbl = @GlobalWebServerVirtualTable
	this->ReferenceCounter = 0
	
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	
	this->WorkerThreadsCount = 0
	this->pIPool = pIPool
	this->pIWebSites = NULL
	this->pIProcessors = NULL
	
	this->Context = NULL
	this->StatusHandler = NULL
	
	' this->SocketList = {0}
	' this->hEvents = {0}
	this->CurrentStatus = RUNNABLE_S_STOPPED
	
End Sub

Sub UnInitializeWebServer( _
		ByVal this As WebServer Ptr _
	)
	
	If this->pIWebSites <> NULL Then
		IWebSiteCollection_Release(this->pIWebSites)
	End If
	
	If this->pIProcessors <> NULL Then
		IHttpProcessorCollection_Release(this->pIProcessors)
	End If
	
	If this->pIPool <> NULL Then
		IThreadPool_Release(this->pIPool)
	End If
	
End Sub

Function CreateWebServer( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As WebServer Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(WebServer)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"WebServer creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim pIPool As IThreadPool Ptr = Any
	Dim hrCreateThreadPool As HRESULT = CreatePermanentInstance( _
		pIMemoryAllocator, _
		@CLSID_THREADPOOL, _
		@IID_IThreadPool, _
		@pIPool _
	)
	
	If SUCCEEDED(hrCreateThreadPool) Then
		
		Dim this As WebServer Ptr = IMalloc_Alloc( _
			pIMemoryAllocator, _
			SizeOf(WebServer) _
		)
		
		If this <> NULL Then
			
			InitializeWebServer( _
				this, _
				pIMemoryAllocator, _
				pIPool _
			)
			
			#if __FB_DEBUG__
			Scope
				Dim vtEmpty As VARIANT = Any
				VariantInit(@vtEmpty)
				LogWriteEntry( _
					LogEntryType.Debug, _
					WStr("WebServer created"), _
					@vtEmpty _
				)
			End Scope
			#endif
			
			Return this
		End If
		
		IThreadPool_Release(pIPool)
	End If
	
	Return NULL
	
End Function

Sub DestroyWebServer( _
		ByVal this As WebServer Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("WebServer destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeWebServer(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("WebServer destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function WebServerQueryInterface( _
		ByVal this As WebServer Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IRunnable, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	WebServerAddRef(this)
	
	Return S_OK
	
End Function

Function WebServerAddRef( _
		ByVal this As WebServer Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return 1
	
End Function

Function WebServerRelease( _
		ByVal this As WebServer Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyWebServer(this)
	
	Return 0
	
End Function

Function WebServerRun( _
		ByVal this As WebServer Ptr _
	)As HRESULT
	
	If this->CurrentStatus <> RUNNABLE_S_STOPPED Then
		Return S_FALSE
	End If
	
	SetCurrentStatus(this, RUNNABLE_S_START_PENDING)
	
	Dim hrConfig As HRESULT = ReadConfiguration(this)
	If FAILED(hrConfig) Then
		SetCurrentStatus(this, RUNNABLE_S_STOPPED)
		Return hrConfig
	End If
	
	SetCurrentStatus(this, RUNNABLE_S_CONTINUE)
	
	Dim hrSocket As HRESULT = CreateServerSocket(this)
	If FAILED(hrSocket) Then
		SetCurrentStatus(this, RUNNABLE_S_STOPPED)
		Return hrSocket
	End If
	
	SetCurrentStatus(this, RUNNABLE_S_CONTINUE)
	
	IThreadPool_SetMaxThreads(this->pIPool, this->WorkerThreadsCount)
	
	Dim hrPool As HRESULT = IThreadPool_Run( _
		this->pIPool, _
		@ThreadPoolCallBack, _
		NULL _
	)
	If FAILED(hrPool) Then
		SetCurrentStatus(this, RUNNABLE_S_STOPPED)
		Return hrPool
	End If
	
	For i As Integer = 0 To this->SocketListLength - 1
		
		SetCurrentStatus(this, RUNNABLE_S_CONTINUE)
		
		Dim pTask As IAcceptConnectionAsyncIoTask Ptr = Any
		Dim hrCreate As HRESULT = CreateAcceptConnectionTask( _
			this, _
			this->SocketList(i).ClientSocket, _
			@pTask _
		)
		If FAILED(hrCreate) Then
			IThreadPool_Stop(this->pIPool)
			SetCurrentStatus(this, RUNNABLE_S_STOPPED)
			Return hrCreate
		End If
		
		SetCurrentStatus(this, RUNNABLE_S_CONTINUE)
		
		Dim hrBeginExecute As HRESULT = StartExecuteTask( _
			CPtr(IAsyncIoTask Ptr, pTask) _
		)
		If FAILED(hrBeginExecute) Then
			Return hrBeginExecute
		End If
		
		' Сейчас мы не уменьшаем счётчик ссылок на задачу
		' Счётчик ссылок уменьшим в пуле потоков после функции EndExecute
		
	Next
	
	SetCurrentStatus(this, RUNNABLE_S_RUNNING)
	
	Return S_OK
	
End Function

Function WebServerStop( _
		ByVal this As WebServer Ptr _
	)As HRESULT
	
	SetCurrentStatus(this, RUNNABLE_S_STOP_PENDING)
	
	IThreadPool_Stop(this->pIPool)
	
	For i As Integer = 0 To this->SocketListLength - 1
		closesocket(this->SocketList(i).ClientSocket)
	Next
	
	SetCurrentStatus(this, RUNNABLE_S_STOPPED)
	
	Return S_OK
	
End Function

Function WebServerIsRunning( _
		ByVal this As WebServer Ptr _
	)As HRESULT
	
	Return this->CurrentStatus
	
End Function

Function WebServerRegisterStatusHandler( _
		ByVal this As WebServer Ptr, _
		ByVal Context As Any Ptr, _
		ByVal StatusHandler As RunnableStatusHandler _
	)As HRESULT
	
	this->Context = Context
	this->StatusHandler = StatusHandler
	
	Return S_OK
	
End Function


Function IWebServerQueryInterface( _
		ByVal this As IRunnable Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return WebServerQueryInterface(ContainerOf(this, WebServer, lpVtbl), riid, ppv)
End Function

Function IWebServerAddRef( _
		ByVal this As IRunnable Ptr _
	)As ULONG
	Return WebServerAddRef(ContainerOf(this, WebServer, lpVtbl))
End Function

Function IWebServerRelease( _
		ByVal this As IRunnable Ptr _
	)As ULONG
	Return WebServerRelease(ContainerOf(this, WebServer, lpVtbl))
End Function

Function IWebServerRun( _
		ByVal this As IRunnable Ptr _
	)As HRESULT
	Return WebServerRun(ContainerOf(this, WebServer, lpVtbl))
End Function

Function IWebServerStop( _
		ByVal this As IRunnable Ptr _
	)As HRESULT
	Return WebServerStop(ContainerOf(this, WebServer, lpVtbl))
End Function

Function IWebServerIsRunning( _
		ByVal this As IRunnable Ptr _
	)As HRESULT
	Return WebServerIsRunning(ContainerOf(this, WebServer, lpVtbl))
End Function

Function IWebServerRegisterStatusHandler( _
		ByVal this As IRunnable Ptr, _
		ByVal Context As Any Ptr, _
		ByVal StatusHandler As RunnableStatusHandler _
	)As HRESULT
	Return WebServerRegisterStatusHandler(ContainerOf(this, WebServer, lpVtbl), Context, StatusHandler)
End Function

Dim GlobalWebServerVirtualTable As Const IRunnableVirtualTable = Type( _
	@IWebServerQueryInterface, _
	@IWebServerAddRef, _
	@IWebServerRelease, _
	@IWebServerRun, _
	@IWebServerStop, _
	@IWebServerIsRunning, _
	@IWebServerRegisterStatusHandler _
)
