#include once "WebServer.bi"
#include once "ClientContext.bi"
#include once "ClientRequest.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "HeapMemoryAllocator.bi"
#include once "Logger.bi"
#include once "Network.bi"
#include once "NetworkStream.bi"
#include once "ReadRequestAsyncTask.bi"
#include once "ServerResponse.bi"
#include once "ThreadPool.bi"
#include once "WebServerIniConfiguration.bi"
#include once "WriteHttpError.bi"

Extern GlobalWebServerVirtualTable As Const IRunnableVirtualTable

Const THREAD_SLEEPING_TIME As DWORD = 60 * 1000

Const SocketListCapacity As Integer = 10

Type _WebServer
	lpVtbl As Const IRunnableVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	
	WorkerThreadsCount As Integer
	pIPool As IThreadPool Ptr
	pIWebSites As IWebSiteCollection Ptr
	pDefaultStream As INetworkStream Ptr
	pDefaultRequest As IClientRequest Ptr
	pDefaultResponse As IServerResponse Ptr
	
	SocketList(0 To SocketListCapacity - 1) As SocketNode
	hEvents(0 To SocketListCapacity - 1) As WSAEVENT
	SocketListLength As Integer
	
	Context As Any Ptr
	StatusHandler As RunnableStatusHandler
	
	ListenAddress As BSTR
	ListenPort As UINT
	
	CurrentStatus As HRESULT
	
End Type

Declare Function AcceptConnection( _
	ByVal this As WebServer Ptr _
)As HRESULT

Declare Function ReadConfiguration( _
	ByVal this As WebServer Ptr _
)As HRESULT

Declare Function CreateServerSocket( _
	ByVal this As WebServer Ptr _
)As HRESULT

Declare Sub SetCurrentStatus( _
	ByVal this As WebServer Ptr, _
	ByVal Status As HRESULT _
)

Declare Sub ServerThread( _
	ByVal this As WebServer Ptr _
)

Sub InitializeWebServer( _
		ByVal this As WebServer Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pIPool As IThreadPool Ptr, _
		ByVal pINetworkStream As INetworkStream Ptr, _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr _
	)
	
	this->lpVtbl = @GlobalWebServerVirtualTable
	this->ReferenceCounter = 0
	
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	
	this->WorkerThreadsCount = 0
	this->pIPool = pIPool
	this->pIWebSites = NULL
	
	this->pDefaultStream = pINetworkStream
	this->pDefaultRequest = pIRequest
	this->pDefaultResponse = pIResponse
	
	this->Context = NULL
	this->StatusHandler = NULL
	
	' this->SocketList = {0}
	' this->hEvents = {0}
	this->CurrentStatus = RUNNABLE_S_STOPPED
	
End Sub

Sub UnInitializeWebServer( _
		ByVal this As WebServer Ptr _
	)
	
	For i As Integer = SocketListCapacity - 1 To 0 Step -1
		WSACloseEvent(this->hEvents(i))
	Next
	
	If this->pIWebSites <> NULL Then
		IWebSiteCollection_Release(this->pIWebSites)
	End If
	
	If this->pDefaultStream <> NULL Then
		INetworkStream_Release(this->pDefaultStream)
	End If
	
	If this->pDefaultRequest <> NULL Then
		IClientRequest_Release(this->pDefaultRequest)
	End If
	
	If this->pDefaultResponse <> NULL Then
		IServerResponse_Release(this->pDefaultResponse)
	End If
	
	If this->pIPool <> NULL Then
		IThreadPool_Release(this->pIPool)
	End If
	
	' If this->SocketList <> INVALID_SOCKET Then
		' closesocket(this->SocketList)
	' End If
	
	IMalloc_Release(this->pIMemoryAllocator)
	
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
	Dim hr As HRESULT = CreateInstance( _
		pIMemoryAllocator, _
		@CLSID_THREADPOOL, _
		@IID_IThreadPool, _
		@pIPool _
	)
	If SUCCEEDED(hr) Then
		Dim pIRequest As IClientRequest Ptr = Any
		hr = CreateInstance( _
			pIMemoryAllocator, _
			@CLSID_CLIENTREQUEST, _
			@IID_IClientRequest, _
			@pIRequest _
		)
		If SUCCEEDED(hr) Then
			Dim pIResponse As IServerResponse Ptr = Any
			hr = CreateInstance( _
				pIMemoryAllocator, _
				@CLSID_SERVERRESPONSE, _
				@IID_IServerResponse, _
				@pIResponse _
			)
			If SUCCEEDED(hr) Then
				Dim pINetworkStream As INetworkStream Ptr = Any
				hr = CreateInstance( _
					pIMemoryAllocator, _
					@CLSID_NETWORKSTREAM, _
					@IID_INetworkStream, _
					@pINetworkStream _
				)
				If SUCCEEDED(hr) Then
					Dim this As WebServer Ptr = IMalloc_Alloc( _
						pIMemoryAllocator, _
						SizeOf(WebServer) _
					)
					If this <> NULL Then
						
						Dim EventsCreated As Boolean = True
						
						For i As Integer = 0 To SocketListCapacity - 1
							this->hEvents(i) = WSACreateEvent()
							If this->hEvents(i) = NULL Then
								EventsCreated = False
								Exit For
							End If
						Next
						
						If EventsCreated Then
							InitializeWebServer( _
								this, _
								pIMemoryAllocator, _
								pIPool, _
								pINetworkStream, _
								pIRequest, _
								pIResponse _
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
					End If
					
					INetworkStream_Release(pINetworkStream)
					
				End If
				
				IServerResponse_Release(pIResponse)
				
			End If
			
			IClientRequest_Release(pIRequest)
			
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
	
	IMalloc_AddRef(this->pIMemoryAllocator)
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
	
	Return this->ReferenceCounter
	
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
	
	Dim hrSocket As HRESULT = CreateServerSocket(this)
	If FAILED(hrSocket) Then
		SetCurrentStatus(this, RUNNABLE_S_STOPPED)
		Return hrSocket
	End If
	
	IThreadPool_SetMaxThreads(this->pIPool, this->WorkerThreadsCount)
	
	Dim hrPool As HRESULT = IThreadPool_Run(this->pIPool)
	If FAILED(hrPool) Then
		SetCurrentStatus(this, RUNNABLE_S_STOPPED)
		Return hrPool
	End If
	
	ServerThread(this)
	
	Return S_OK
	
End Function

Function WebServerStop( _
		ByVal this As WebServer Ptr _
	)As HRESULT
	
	If this->CurrentStatus = RUNNABLE_S_STOPPED Then
		Return S_FALSE
	End If
	
	SetCurrentStatus(this, RUNNABLE_S_STOP_PENDING)
	
	IThreadPool_Stop(this->pIPool)
	
	' If this->SocketList <> INVALID_SOCKET Then
		' closesocket(this->SocketList)
		' this->SocketList = INVALID_SOCKET
	' End If
	
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

Sub SetCurrentStatus( _
		ByVal this As WebServer Ptr, _
		ByVal Status As HRESULT _
	)
	
	this->CurrentStatus = Status
	
	If this->StatusHandler <> NULL Then
		this->StatusHandler(this->Context, Status)
	End If
	
End Sub

Function AcceptConnection( _
		ByVal this As WebServer Ptr _
	)As HRESULT
	
	Dim dwIndex As DWORD = WSAWaitForMultipleEvents( _
		Cast(DWORD, this->SocketListLength), _
		@this->hEvents(0), _
		False, _
		WSA_INFINITE, _
		False _
	)
	If dwIndex = WSA_WAIT_FAILED Then
		Dim dwError As Long = WSAGetLastError()
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Dim EventIndex As Integer = CInt(dwIndex - WSA_WAIT_EVENT_0)
	
	Dim EventType As WSANETWORKEVENTS = Any
	Dim dwEnumEventResult As Long = WSAEnumNetworkEvents( _
		this->SocketList(EventIndex).ClientSocket, _
		this->hEvents(EventIndex), _
		@EventType _
	)
	If dwEnumEventResult = SOCKET_ERROR Then
		Dim dwError As Long = WSAGetLastError()
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	If EventType.lNetworkEvents And FD_ACCEPT Then
		
		If EventType.iErrorCode(FD_ACCEPT_BIT) = 0 Then
			
			Dim RemoteAddress As SOCKADDR_STORAGE = Any
			Dim RemoteAddressLength As Long = SizeOf(SOCKADDR_STORAGE)
			Dim ClientSocket As SOCKET = accept( _
				this->SocketList(EventIndex).ClientSocket, _
				CPtr(SOCKADDR Ptr, @RemoteAddress), _
				@RemoteAddressLength _
			)
			If ClientSocket = INVALID_SOCKET Then
				Dim dwErrorAccept As Long = WSAGetLastError()
				Dim vtErrorCode As VARIANT = Any
				vtErrorCode.vt = VT_UI4
				vtErrorCode.ulVal = dwErrorAccept
				LogWriteEntry( _
					LogEntryType.Error, _
					WStr(!"\t\t\t\tAccept failed\t"), _
					@vtErrorCode _
				)
				Return HRESULT_FROM_WIN32(dwErrorAccept)
			End If
			
			Dim pTask As IReadRequestAsyncTask Ptr = Any
			
			Scope
				Dim pIClientMemoryAllocator As IMalloc Ptr = Any
				Dim hrCreateAllocator As HRESULT = CreateMemoryAllocatorInstance( _
					@CLSID_HEAPMEMORYALLOCATOR, _
					@IID_IMalloc, _
					@pIClientMemoryAllocator _
				)
				If FAILED(hrCreateAllocator) Then
					CloseSocketConnection(ClientSocket)
					Return hrCreateAllocator
				End If
				
				Dim hrCreateTask As HRESULT = CreateInstance( _
					pIClientMemoryAllocator, _
					@CLSID_READREQUESTASYNCTASK, _
					@IID_IReadRequestAsyncTask, _
					@pTask _
				)
				If FAILED(hrCreateTask) Then
					CloseSocketConnection(ClientSocket)
					IMalloc_Release(pIClientMemoryAllocator)
					Return hrCreateTask
				End If
				IMalloc_Release(pIClientMemoryAllocator)
			End Scope
			
			Scope
				IReadRequestAsyncTask_SetWebSiteCollection(pTask, this->pIWebSites)
				IReadRequestAsyncTask_SetSocket(pTask, ClientSocket)
				IReadRequestAsyncTask_SetRemoteAddress( _
					pTask, _
					CPtr(SOCKADDR Ptr, @RemoteAddress), _
					RemoteAddressLength _
				)
			End Scope
			
			Scope
				Dim hrBeginExecute As HRESULT = IReadRequestAsyncTask_BeginExecute( _
					pTask, _
					this->pIPool _
				)
				If FAILED(hrBeginExecute) Then
					Dim vtSCode As VARIANT = Any
					vtSCode.vt = VT_ERROR
					vtSCode.scode = hrBeginExecute
					LogWriteEntry( _
						LogEntryType.Error, _
						WStr(!"IReadRequestAsyncTask_BeginExecute Error\t"), _
						@vtSCode _
					)
					
					' TODO Отправить клиенту Не могу начать асинхронное чтение
					CloseSocketConnection(ClientSocket)
					IReadRequestAsyncTask_Release(pTask)
					Return hrBeginExecute
				End If
				
			End Scope
			
			' Сейчас мы не уменьшаем счётчик ссылок на pTask
			' Счётчик ссылок уменьшим в функции EndExecute
			' Когда задача будет завершена
			
		End If
		
	End If
	
	Return S_OK
	
End Function

Function CreateServerSocket( _
		ByVal this As WebServer Ptr _
	)As HRESULT
	
	Dim wszListenPort As WString * (255 + 1) = Any
	_itow(this->ListenPort, @wszListenPort, 10)
	
	Dim hr As HRESULT = CreateSocketAndListenW( _
		this->ListenAddress, _
		wszListenPort, _
		@this->SocketList(0), _
		SocketListCapacity, _
		@this->SocketListLength _
	)
	If FAILED(hr) Then
		Return hr
	End If
	
	For i As Integer = 0 To this->SocketListLength - 1
		WSAEventSelect( _
			this->SocketList(i).ClientSocket, _
			this->hEvents(i), _
			FD_ACCEPT Or FD_CLOSE _
		)
	Next
	
	Return S_OK
	
End Function

Function ReadConfiguration( _
		ByVal this As WebServer Ptr _
	)As HRESULT
	
	Dim pIConfig As IWebServerConfiguration Ptr = Any
	Dim hr As HRESULT = CreateInstance( _
		this->pIMemoryAllocator, _
		@CLSID_WEBSERVERINICONFIGURATION, _
		@IID_IWebServerConfiguration, _
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
	
	IWebServerConfiguration_Release(pIConfig)
	
	Return S_OK

End Function

Sub ServerThread( _
		ByVal this As WebServer Ptr _
	)
	
	SetCurrentStatus(this, RUNNABLE_S_RUNNING)
	
	Do
		' If this->CachedClientMemoryContextIndex >= this->CachedClientMemoryContextLength Then
			' this->CachedClientMemoryContextIndex = 0
			' DestroyCachedClientMemoryContext(this)
			' CreateCachedClientMemoryContext(this)
		' End If
		
		IClientRequest_Clear(this->pDefaultRequest)
		IServerResponse_Clear(this->pDefaultResponse)
		
		Dim hrAccept As HRESULT = AcceptConnection( _
			this _
		)
		
		INetworkStream_Close(this->pDefaultStream)
		
		' this->CachedClientMemoryContextIndex += 1
		
		If FAILED(hrAccept) Then
			If this->CurrentStatus = RUNNABLE_S_RUNNING Then
				Sleep_(THREAD_SLEEPING_TIME)
			Else
				Exit Do
			End If
		End If
		
	Loop While this->CurrentStatus = RUNNABLE_S_RUNNING
	
	WebServerStop(this)
	
End Sub


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
