#include once "WebServer.bi"
#include once "AcceptConnectionAsyncTask.bi"
#include once "ContainerOf.bi"
#include once "HeapBSTR.bi"
#include once "HeapMemoryAllocator.bi"
#include once "HttpReader.bi"
#include once "IniConfiguration.bi"
#include once "Network.bi"
#include once "ThreadPool.bi"
#include once "WebUtils.bi"

Extern GlobalWebServerVirtualTable As Const IRunnableVirtualTable

Const THREAD_SLEEPING_TIME As DWORD = 60 * 1000

Const SocketListCapacity As Integer = 10

Extern pIWebSitesWeakPtr As IWebSiteCollection Ptr
Extern pIProcessorsWeakPtr As IHttpProcessorCollection Ptr

Type _WebServer
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IRunnableVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	WorkerThreadsCount As UInteger
	CachedClientMemoryContextLength As UInteger
	Context As Any Ptr
	pIPool As IThreadPool Ptr
	StatusHandler As RunnableStatusHandler
	SocketList(0 To SocketListCapacity - 1) As SocketNode
	SocketListLength As Integer
	ListenAddress As HeapBSTR
	ListenPort As UINT
	CurrentStatus As HRESULT
End Type

Function CreateAcceptConnectionTask( _
		ByVal this As WebServer Ptr, _
		ByVal ServerSocket As SOCKET, _
		ByVal ppTask As IAcceptConnectionAsyncIoTask Ptr Ptr _
	)As HRESULT
	
	Dim pTask As IAcceptConnectionAsyncIoTask Ptr = Any
	Dim hrCreateTask As HRESULT = CreateAcceptConnectionAsyncTask( _
		this->pIMemoryAllocator, _
		@IID_IAcceptConnectionAsyncIoTask, _
		@pTask _
	)
	If FAILED(hrCreateTask) Then
		*ppTask = NULL
		Return hrCreateTask
	End If
	
	IAcceptConnectionAsyncIoTask_SetListenSocket(pTask, ServerSocket)
	
	Dim hrBind As HRESULT = BindToThreadPool( _
		Cast(HANDLE, ServerSocket), _
		pTask _
	)
	If FAILED(hrBind) Then
		IAcceptConnectionAsyncIoTask_Release(pTask)
		*ppTask = NULL
		Return hrBind
	End If
	
	*ppTask = pTask
	Return S_OK
	
End Function

Function ReadConfiguration( _
		ByVal this As WebServer Ptr _
	)As HRESULT
	
	Dim pIConfig As IWebServerConfiguration Ptr = Any
	Dim hrCreateConfiguration As HRESULT = CreateWebServerIniConfiguration( _
		this->pIMemoryAllocator, _
		@IID_IIniConfiguration, _
		@pIConfig _
	)
	If FAILED(hrCreateConfiguration) Then
		Return hrCreateConfiguration
	End If
	
	IWebServerConfiguration_GetListenAddress(pIConfig, @this->ListenAddress)
	
	IWebServerConfiguration_GetListenPort(pIConfig, @this->ListenPort)
	
	IWebServerConfiguration_GetWorkerThreadsCount(pIConfig, @this->WorkerThreadsCount)
	
	IWebServerConfiguration_GetCachedClientMemoryContextCount(pIConfig, @this->CachedClientMemoryContextLength)
	
	Dim hrWebSites As HRESULT = IWebServerConfiguration_GetWebSiteCollection(pIConfig, @pIWebSitesWeakPtr)
	If FAILED(hrWebSites) Then
		Return hrWebSites
	End If
	
	Dim hrProcessors As HRESULT = IWebServerConfiguration_GetHttpProcessorCollection(pIConfig, @pIProcessorsWeakPtr)
	If FAILED(hrProcessors) Then
		Return hrProcessors
	End If
	
	IWebServerConfiguration_Release(pIConfig)
	
	Return S_OK
	
End Function

Function CreateServerSocketSink( _
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
	
	HeapSysFreeString(this->ListenAddress)
	this->ListenAddress = NULL
	
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
	
	If this->StatusHandler Then
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
	
	this->Context = NULL
	this->StatusHandler = NULL
	
	' this->SocketList = {0}
	' this->hEvents = {0}
	this->CurrentStatus = RUNNABLE_S_STOPPED
	
	this->ListenAddress = NULL
	
End Sub

Sub UnInitializeWebServer( _
		ByVal this As WebServer Ptr _
	)
	
	If pIWebSitesWeakPtr Then
		IWebSiteCollection_Release(pIWebSitesWeakPtr)
	End If
	
	If pIProcessorsWeakPtr Then
		IHttpProcessorCollection_Release(pIProcessorsWeakPtr)
	End If
	
	If this->pIPool Then
		IThreadPool_Release(this->pIPool)
	End If
	
	If this->ListenAddress Then
		HeapSysFreeString(this->ListenAddress)
	End If
	
End Sub

Sub WebServerCreated( _
		ByVal this As WebServer Ptr _
	)
	
End Sub

Function CreateWebServer( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Dim pIPool As IThreadPool Ptr = Any
	Dim hrCreateThreadPool As HRESULT = CreateThreadPool( _
		pIMemoryAllocator, _
		@IID_IThreadPool, _
		@pIPool _
	)
	If FAILED(hrCreateThreadPool) Then
		*ppv = NULL
		Return hrCreateThreadPool
	End If
	
	Dim this As WebServer Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(WebServer) _
	)
	
	If this Then
		InitializeWebServer(this, pIMemoryAllocator, pIPool)
		WebServerCreated(this)
		
		Dim hrQueryInterface As HRESULT = WebServerQueryInterface( _
			this, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyWebServer(this)
		End If
		
		Return hrQueryInterface
	End If
	
	IThreadPool_Release(pIPool)
	
	*ppv = NULL
	Return E_OUTOFMEMORY
	
End Function

Sub WebServerDestroyed( _
		ByVal this As WebServer Ptr _
	)
	
End Sub

Sub DestroyWebServer( _
		ByVal this As WebServer Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeWebServer(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	WebServerDestroyed(this)
	
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
	
	Dim hrSocket As HRESULT = CreateServerSocketSink(this)
	If FAILED(hrSocket) Then
		SetCurrentStatus(this, RUNNABLE_S_STOPPED)
		Return hrSocket
	End If
	
	SetCurrentStatus(this, RUNNABLE_S_CONTINUE)
	
	Dim hrCreateMemoryPool As HRESULT = CreateMemoryPool(this->CachedClientMemoryContextLength)
	If FAILED(hrCreateMemoryPool) Then
		SetCurrentStatus(this, RUNNABLE_S_STOPPED)
		Return hrCreateMemoryPool
	End If
	
	SetCurrentStatus(this, RUNNABLE_S_CONTINUE)
	
	IThreadPool_SetMaxThreads(this->pIPool, this->WorkerThreadsCount)
	
	Dim hrPool As HRESULT = IThreadPool_Run( _
		this->pIPool _
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

Dim pIWebSitesWeakPtr As IWebSiteCollection Ptr
Dim pIProcessorsWeakPtr As IHttpProcessorCollection Ptr
