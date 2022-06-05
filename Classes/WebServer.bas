#include once "WebServer.bi"
#include once "ClientRequest.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "HttpReader.bi"
#include once "Logger.bi"
#include once "Network.bi"
#include once "NetworkStream.bi"
#include once "ReadRequestAsyncTask.bi"
#include once "ServerResponse.bi"
#include once "ThreadPool.bi"
#include once "WebServerIniConfiguration.bi"

Extern GlobalWebServerVirtualTable As Const IRunnableVirtualTable

Const THREAD_SLEEPING_TIME As DWORD = 60 * 1000

Const SocketListCapacity As Integer = 10

Type _WebServer
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IRunnableVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	
	WorkerThreadsCount As Integer
	pIPool As IThreadPool Ptr
	pIWebSites As IWebSiteCollection Ptr
	pIProcessors As IHttpProcessorCollection Ptr
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

Function StartExecuteTask( _
		ByVal pTask As IAsyncIoTask Ptr _
	)As HRESULT
	
	#if __FB_DEBUG__
	Scope
		Dim vtResponse As VARIANT = Any
		vtResponse.vt = VT_BSTR
		vtResponse.bstrVal = SysAllocString(WStr(!"IAsyncIoTask_BeginExecute"))
		LogWriteEntry( _
			LogEntryType.Debug, _
			NULL, _
			@vtResponse _
		)
		VariantClear(@vtResponse)
	End Scope
	#endif
	
	Dim pIResult As IAsyncResult Ptr = Any
	Dim hrBeginExecute As HRESULT = IAsyncIoTask_BeginExecute( _
		pTask, _
		@pIResult _
	)
	If FAILED(hrBeginExecute) Then
		IAsyncIoTask_Release(pTask)
		
		Dim vtSCode As VARIANT = Any
		vtSCode.vt = VT_ERROR
		vtSCode.scode = hrBeginExecute
		LogWriteEntry( _
			LogEntryType.Error, _
			WStr(!"IAsyncTask_BeginExecute Error\t"), _
			@vtSCode _
		)
		
		Return hrBeginExecute
	End If
	
	Return S_OK
	
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
				
				StartExecuteTask(pNextTask)
				
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

Function CreateReadTask( _
		ByVal this As WebServer Ptr, _
		ByVal ClientSocket As SOCKET, _
		ByVal pRemoteAddress As SOCKADDR Ptr, _
		ByVal RemoteAddressLength As Integer _
	)As IReadRequestAsyncIoTask Ptr
	
	Dim pIClientMemoryAllocator As IMalloc Ptr = GetHeapMemoryAllocatorInstance()
	
	If pIClientMemoryAllocator <> NULL Then
		
		Dim pIHttpReader As IHttpReader Ptr = Any
		Dim hrCreateHttpReader As HRESULT = CreateInstance( _
			pIClientMemoryAllocator, _
			@CLSID_HTTPREADER, _
			@IID_IHttpReader, _
			@pIHttpReader _
		)
		
		If SUCCEEDED(hrCreateHttpReader) Then
			
			Dim pINetworkStream As INetworkStream Ptr = Any
			Dim hrCreateNetworkStream As HRESULT = CreateInstance( _
				pIClientMemoryAllocator, _
				@CLSID_NETWORKSTREAM, _
				@IID_INetworkStream, _
				@pINetworkStream _
			)
			
			If SUCCEEDED(hrCreateNetworkStream) Then
				
				INetworkStream_SetSocket(pINetworkStream, ClientSocket)
				INetworkStream_SetRemoteAddress( _
					pINetworkStream, _
					pRemoteAddress, _
					RemoteAddressLength _
				)
				
				' TODO Запросить интерфейс вместо конвертирования указателя
				IHttpReader_SetBaseStream( _
					pIHttpReader, _
					CPtr(IBaseStream Ptr, pINetworkStream) _
				)
				
				Dim pTask As IReadRequestAsyncIoTask Ptr = Any
				Dim hrCreateTask As HRESULT = CreateInstance( _
					pIClientMemoryAllocator, _
					@CLSID_READREQUESTASYNCTASK, _
					@IID_IReadRequestAsyncIoTask, _
					@pTask _
				)
				
				If SUCCEEDED(hrCreateTask) Then
					IReadRequestAsyncIoTask_SetWebSiteCollectionWeakPtr(pTask, this->pIWebSites)
					IReadRequestAsyncIoTask_SetHttpProcessorCollectionWeakPtr(pTask, this->pIProcessors)
					IReadRequestAsyncIoTask_SetBaseStream(pTask, CPtr(IBaseStream Ptr, pINetworkStream))
					IReadRequestAsyncIoTask_SetHttpReader(pTask, pIHttpReader)
					
					Dim hrAssociate As HRESULT = IThreadPool_AssociateTask( _
						this->pIPool, _
						Cast(ULONG_PTR, 0), _
						CPtr(IAsyncIoTask Ptr, pTask) _
					)
					If FAILED(hrAssociate) Then
						
					End If
					
					INetworkStream_Release(pINetworkStream)
					IHttpReader_Release(pIHttpReader)
					IMalloc_Release(pIClientMemoryAllocator)
					
					pIClientMemoryAllocator = NULL
					pINetworkStream = NULL
					pIHttpReader = NULL
					
					Return pTask
				End If
				
				If pINetworkStream <> NULL Then
					INetworkStream_Release(pINetworkStream)
				End If
			End If
			
			If pIHttpReader <> NULL Then
				IHttpReader_Release(pIHttpReader)
			End If
		End If
		
		If pIClientMemoryAllocator <> NULL Then
			IMalloc_Release(pIClientMemoryAllocator)
		End If
	End If
	
	Return NULL
				
End Function

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
	
	If dwIndex <> WSA_WAIT_FAILED Then
		
		Dim EventIndex As Integer = CInt(dwIndex - WSA_WAIT_EVENT_0)
		
		Dim EventType As WSANETWORKEVENTS = Any
		Dim dwEnumEventResult As Long = WSAEnumNetworkEvents( _
			this->SocketList(EventIndex).ClientSocket, _
			this->hEvents(EventIndex), _
			@EventType _
		)
		
		If dwEnumEventResult <> SOCKET_ERROR Then
			
			Dim AcceptFlag As Integer = EventType.lNetworkEvents And FD_ACCEPT
			
			If AcceptFlag Then
				
				Dim errorCode As Integer = EventType.iErrorCode(FD_ACCEPT_BIT)
				
				If errorCode = 0 Then
					
					Dim RemoteAddress As SOCKADDR_STORAGE = Any
					Dim RemoteAddressLength As Long = SizeOf(SOCKADDR_STORAGE)
					Dim ClientSocket As SOCKET = accept( _
						this->SocketList(EventIndex).ClientSocket, _
						CPtr(SOCKADDR Ptr, @RemoteAddress), _
						@RemoteAddressLength _
					)
					
					If ClientSocket <> INVALID_SOCKET Then
						
						Dim pTask As IReadRequestAsyncIoTask Ptr = CreateReadTask( _
							this, _
							ClientSocket, _
							CPtr(SOCKADDR Ptr, @RemoteAddress), _
							RemoteAddressLength _
						)
						
						If pTask <> NULL Then
							
							Dim hrBeginExecute As HRESULT = StartExecuteTask( _
								CPtr(IAsyncIoTask Ptr, pTask) _
							)
							
							If SUCCEEDED(hrBeginExecute) Then
								' Сейчас мы не уменьшаем счётчик ссылок на задачу
								' Счётчик ссылок уменьшим в пуле потоков после функции EndExecute
								Return S_OK
							End If
							
						End If
						
						CloseSocketConnection(ClientSocket)
					End If
					
					Dim dwErrorAccept As Long = WSAGetLastError()
					Dim vtErrorCode As VARIANT = Any
					vtErrorCode.vt = VT_UI4
					vtErrorCode.ulVal = dwErrorAccept
					LogWriteEntry( _
						LogEntryType.Error, _
						WStr(!"\t\t\t\tAccept failed\t"), _
						@vtErrorCode _
					)
					
				End If
				
			End If
			
		End If
		
	End If
	
	Return E_FAIL
	
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
	
	IWebServerConfiguration_GetHttpProcessorCollection(pIConfig, @this->pIProcessors)
	
	IWebServerConfiguration_Release(pIConfig)
	
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
			FD_ACCEPT _
		)
	Next
	
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
		
		' IClientRequest_Clear(this->pDefaultRequest)
		' IServerResponse_Clear(this->pDefaultResponse)
		
		Dim hrAccept As HRESULT = AcceptConnection( _
			this _
		)
		
		' INetworkStream_Close(this->pDefaultStream)
		
		' this->CachedClientMemoryContextIndex += 1
		
		If FAILED(hrAccept) Then
			Dim vtSCode As VARIANT = Any
			vtSCode.vt = VT_ERROR
			vtSCode.scode = hrAccept
			LogWriteEntry( _
				LogEntryType.Error, _
				WStr(!"AcceptConnection Error\t"), _
				@vtSCode _
			)
			
			If this->CurrentStatus = RUNNABLE_S_RUNNING Then
				Sleep_(THREAD_SLEEPING_TIME)
			Else
				Exit Do
			End If
		End If
		
	Loop While this->CurrentStatus = RUNNABLE_S_RUNNING
	
	WebServerStop(this)
	
End Sub

Sub InitializeWebServer( _
		ByVal this As WebServer Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pIPool As IThreadPool Ptr, _
		ByVal pINetworkStream As INetworkStream Ptr, _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory(@this->IdString, @Str("WebServerWebServ"), 16)
	#endif
	this->lpVtbl = @GlobalWebServerVirtualTable
	this->ReferenceCounter = 0
	
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	
	this->WorkerThreadsCount = 0
	this->pIPool = pIPool
	this->pIWebSites = NULL
	this->pIProcessors = NULL
	
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
	
	If this->pIProcessors <> NULL Then
		IHttpProcessorCollection_Release(this->pIProcessors)
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
	
	#ifdef __FB_64BIT__
		InterlockedIncrement64(@this->ReferenceCounter)
	#else
		InterlockedIncrement(@this->ReferenceCounter)
	#endif
	
	Return 1
	
End Function

Function WebServerRelease( _
		ByVal this As WebServer Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		If InterlockedDecrement64(@this->ReferenceCounter) Then
			Return 1
		End If
	#else
		If InterlockedDecrement(@this->ReferenceCounter) Then
			Return 1
		End If
	#endif
	
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
	
	Dim hrPool As HRESULT = IThreadPool_Run( _
		this->pIPool, _
		@ThreadPoolCallBack, _
		NULL _
	)
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
