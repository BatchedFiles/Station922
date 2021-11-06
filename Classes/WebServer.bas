#include once "WebServer.bi"
#include once "IClientContext.bi"
#include once "IClientRequest.bi"
#include once "INetworkStream.bi"
#include once "IServerResponse.bi"
#include once "IWebServerConfiguration.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "Network.bi"
#include once "ReferenceCounter.bi"
#include once "WorkerThread.bi"
#include once "WriteHttpError.bi"

Extern GlobalWebServerVirtualTable As Const IRunnableVirtualTable

Extern CLSID_CLIENTREQUEST Alias "CLSID_CLIENTREQUEST" As Const CLSID
Extern CLSID_WEBSERVERINICONFIGURATION Alias "CLSID_WEBSERVERINICONFIGURATION" As Const CLSID
Extern CLSID_NETWORKSTREAM Alias "CLSID_NETWORKSTREAM" As Const CLSID
Extern CLSID_SERVERRESPONSE Alias "CLSID_SERVERRESPONSE" As Const CLSID

Extern CLSID_CONSOLELOGGER Alias "CLSID_CONSOLELOGGER" As Const CLSID
Extern CLSID_CLIENTCONTEXT Alias "CLSID_CLIENTCONTEXT" As Const CLSID
Extern CLSID_HEAPMEMORYALLOCATOR Alias "CLSID_HEAPMEMORYALLOCATOR" As Const CLSID

Const THREAD_SLEEPING_TIME As DWORD = 60 * 1000

Const SocketListCapacity As Integer = 10

Type CachedClientContext
	pIClientLogger As ILogger Ptr
	pIClientMemoryAllocator As IMalloc Ptr
	pIClientContext As IClientContext Ptr
	pIServerMemoryAllocator As IMalloc Ptr
	hrLogger As HRESULT
	hrMemoryAllocator As HRESULT
	hrClientContex As HRESULT
End Type

Type _WebServer
	lpVtbl As Const IRunnableVirtualTable Ptr
	RefCounter As ReferenceCounter
	pILogger As ILogger Ptr
	pIMemoryAllocator As IMalloc Ptr
	
	hIOCompletionPort As HANDLE
	WorkerThreadsCount As Integer
	pIWebSites As IWebSiteCollection Ptr
	pINetworkStream As INetworkStream Ptr
	pIRequest As IClientRequest Ptr
	pIResponse As IServerResponse Ptr
	
	ppCachedClientMemoryContext As CachedClientContext Ptr Ptr
	CachedClientMemoryContextLength As Integer
	CachedClientMemoryContextIndex As Integer
	
	SocketList(0 To SocketListCapacity - 1) As SocketNode
	hEvents(0 To SocketListCapacity - 1) As WSAEVENT
	SocketListLength As Integer
	
	Context As Any Ptr
	StatusHandler As RunnableStatusHandler
	
	ListenAddress As BSTR
	ListenPort As UINT
	
	CurrentStatus As HRESULT
	
End Type

Function CreateClientMemoryContext( _
		ByVal pIServerMemoryAllocator As IMalloc Ptr _
	)As CachedClientContext Ptr
	
	Dim pCachedContext As CachedClientContext Ptr = IMalloc_Alloc( _
		pIServerMemoryAllocator, _
		SizeOf(CachedClientContext) _
	)
	
	If pCachedContext <> NULL Then
		ZeroMemory(pCachedContext, SizeOf(CachedClientContext))
		
		pCachedContext->hrLogger = CreateLoggerInstance( _
			pIServerMemoryAllocator, _
			@CLSID_CONSOLELOGGER, _
			@IID_ILogger, _
			@pCachedContext->pIClientLogger _
		)
		
		If SUCCEEDED(pCachedContext->hrLogger) Then
			
			pCachedContext->hrMemoryAllocator = CreateMemoryAllocatorInstance( _
				pCachedContext->pIClientLogger, _
				@CLSID_HEAPMEMORYALLOCATOR, _
				@IID_IMalloc, _
				@pCachedContext->pIClientMemoryAllocator _
			)
			
			If SUCCEEDED(pCachedContext->hrMemoryAllocator) Then
				
				pCachedContext->hrClientContex = CreateInstance( _
					pCachedContext->pIClientLogger, _
					pCachedContext->pIClientMemoryAllocator, _
					@CLSID_CLIENTCONTEXT, _
					@IID_IClientContext, _
					@pCachedContext->pIClientContext _
				)
				
				If SUCCEEDED(pCachedContext->hrClientContex) Then
					IClientContext_SetOperationCode(pCachedContext->pIClientContext, OperationCodes.ReadRequest)
					
					Dim pIReader As IHttpReader Ptr = Any
					IClientContext_GetHttpReader(pCachedContext->pIClientContext, @pIReader)
					
					Scope
						Dim pINetworkStream As INetworkStream Ptr = Any
						IClientContext_GetNetworkStream(pCachedContext->pIClientContext, @pINetworkStream)
						
						' TODO Запросить интерфейс вместо конвертирования указателя
						IHttpReader_SetBaseStream(pIReader, CPtr(IBaseStream Ptr, pINetworkStream))
						
						INetworkStream_Release(pINetworkStream)
					End Scope
					
					Scope
						Dim pIRequest As IClientRequest Ptr = Any
						IClientContext_GetClientRequest(pCachedContext->pIClientContext, @pIRequest)
						
						' TODO Запросить интерфейс вместо конвертирования указателя
						IClientRequest_SetTextReader(pIRequest, CPtr(ITextReader Ptr, pIReader))
						
						IClientRequest_Release(pIRequest)
					End Scope
					
					IHttpReader_Release(pIReader)
					
					IMalloc_AddRef(pIServerMemoryAllocator)
					pCachedContext->pIServerMemoryAllocator = pIServerMemoryAllocator
					
					' IClientContext_Release(pCachedContext->pIClientContext)
					
				End If
				
				IMalloc_Release(pCachedContext->pIClientMemoryAllocator)
				
			End If
			
			ILogger_Release(pCachedContext->pIClientLogger)
			
		End If
		
		' IMalloc_Free( _
			' pIServerMemoryAllocator, _
			' pCachedContext _
		' )
		
	End If
	
	Return pCachedContext
	
End Function

Sub InitializeClientMemoryContext( _
		ByVal pCachedContext As CachedClientContext Ptr, _
		ByVal pIServerMemoryAllocator As IMalloc Ptr _
	)
	
	ZeroMemory(pCachedContext, SizeOf(CachedClientContext))
	
	pCachedContext->hrLogger = CreateLoggerInstance( _
		pIServerMemoryAllocator, _
		@CLSID_CONSOLELOGGER, _
		@IID_ILogger, _
		@pCachedContext->pIClientLogger _
	)
	
	If SUCCEEDED(pCachedContext->hrLogger) Then
		
		pCachedContext->hrMemoryAllocator = CreateMemoryAllocatorInstance( _
			pCachedContext->pIClientLogger, _
			@CLSID_HEAPMEMORYALLOCATOR, _
			@IID_IMalloc, _
			@pCachedContext->pIClientMemoryAllocator _
		)
		
		If SUCCEEDED(pCachedContext->hrMemoryAllocator) Then
			
			pCachedContext->hrClientContex = CreateInstance( _
				pCachedContext->pIClientLogger, _
				pCachedContext->pIClientMemoryAllocator, _
				@CLSID_CLIENTCONTEXT, _
				@IID_IClientContext, _
				@pCachedContext->pIClientContext _
			)
			
			If SUCCEEDED(pCachedContext->hrClientContex) Then
				IClientContext_SetOperationCode(pCachedContext->pIClientContext, OperationCodes.ReadRequest)
				
				Dim pIReader As IHttpReader Ptr = Any
				IClientContext_GetHttpReader(pCachedContext->pIClientContext, @pIReader)
				
				Scope
					Dim pINetworkStream As INetworkStream Ptr = Any
					IClientContext_GetNetworkStream(pCachedContext->pIClientContext, @pINetworkStream)
					
					' TODO Запросить интерфейс вместо конвертирования указателя
					IHttpReader_SetBaseStream(pIReader, CPtr(IBaseStream Ptr, pINetworkStream))
					
					INetworkStream_Release(pINetworkStream)
				End Scope
				
				Scope
					Dim pIRequest As IClientRequest Ptr = Any
					IClientContext_GetClientRequest(pCachedContext->pIClientContext, @pIRequest)
					
					' TODO Запросить интерфейс вместо конвертирования указателя
					IClientRequest_SetTextReader(pIRequest, CPtr(ITextReader Ptr, pIReader))
					
					IClientRequest_Release(pIRequest)
				End Scope
				
				IHttpReader_Release(pIReader)
				
				' IMalloc_AddRef(pIServerMemoryAllocator)
				' pCachedContext->pIServerMemoryAllocator = pIServerMemoryAllocator
				
				' IClientContext_Release(pCachedContext->pIClientContext)
				
			End If
			
			IMalloc_Release(pCachedContext->pIClientMemoryAllocator)
			
		End If
		
		ILogger_Release(pCachedContext->pIClientLogger)
		
	End If
	
End Sub

Sub DestroyClientMemoryContext( _
		ByVal pClientMemoryContext As CachedClientContext Ptr _
	)
	
	If pClientMemoryContext <> NULL Then
		
		' If SUCCEEDED(pClientMemoryContext->hrClientContex) Then
			' MessageBoxA(NULL, "pIClientContext", NULL, MB_OK)
			' IMalloc_Release(pClientMemoryContext->pIClientContext)
		' End If
		
		' If SUCCEEDED(pClientMemoryContext->hrMemoryAllocator) Then
			' MessageBoxA(NULL, "pIClientMemoryAllocator", NULL, MB_OK)
			' IMalloc_Release(pClientMemoryContext->pIClientMemoryAllocator)
		' End If
		
		' If SUCCEEDED(pClientMemoryContext->hrLogger) Then
			' MessageBoxA(NULL, "pIClientLogger", NULL, MB_OK)
			' ILogger_Release(pClientMemoryContext->pIClientLogger)
		' End If
		
		Dim allocator As IMalloc Ptr = pClientMemoryContext->pIServerMemoryAllocator
		
		IMalloc_Free(allocator, pClientMemoryContext)
		IMalloc_Release(allocator)
	End If
	
End Sub

Declare Function AcceptConnection( _
	ByVal this As WebServer Ptr _
)As HRESULT

Declare Function ReadConfiguration( _
	ByVal this As WebServer Ptr _
)As HRESULT

Declare Function CreateServerSocket( _
	ByVal this As WebServer Ptr _
)As HRESULT

Declare Function InitializeIOCP( _
	ByVal this As WebServer Ptr _
)As HRESULT

Declare Function ProcessErrorAssociateWithIOCP( _
	ByVal this As WebServer Ptr, _
	ByVal ClientSocket As SOCKET, _
	ByVal pCachedContext As CachedClientContext Ptr _
)As HRESULT

Declare Sub SetCurrentStatus( _
	ByVal this As WebServer Ptr, _
	ByVal Status As HRESULT _
)

Declare Function AssociateWithIOCP( _
	ByVal this As WebServer Ptr, _
	ByVal ClientSocket As SOCKET, _
	ByVal CompletionKey As ULONG_PTR _
)As HRESULT

Declare Function ServerThread( _
	ByVal this As WebServer Ptr _
)As DWORD

Declare Sub CreateCachedClientMemoryContext( _
	ByVal this As WebServer Ptr _
)

Declare Sub DestroyCachedClientMemoryContext( _
	ByVal this As WebServer Ptr _
)

Sub InitializeWebServer( _
		ByVal this As WebServer Ptr, _
		ByVal pILogger As ILogger Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pINetworkStream As INetworkStream Ptr, _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr _
	)
	
	this->lpVtbl = @GlobalWebServerVirtualTable
	ReferenceCounterInitialize(@this->RefCounter)
	ILogger_AddRef(pILogger)
	this->pILogger = pILogger
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->hIOCompletionPort = NULL
	this->WorkerThreadsCount = 0
	this->pIWebSites = NULL
	this->pINetworkStream = pINetworkStream
	this->pIRequest = pIRequest
	this->pIResponse = pIResponse
	this->ppCachedClientMemoryContext = NULL
	this->CachedClientMemoryContextIndex  = 0
	
	this->Context = NULL
	this->StatusHandler = NULL
	
	' this->SocketList = {0}
	' this->hEvents = {0}
	this->CurrentStatus = RUNNABLE_S_STOPPED
	
	#ifdef PERFORMANCE_TESTING
		QueryPerformanceFrequency(@this->Frequency)
	#endif
	
End Sub

Sub UnInitializeWebServer( _
		ByVal this As WebServer Ptr _
	)
	
	For i As Integer = SocketListCapacity - 1 To 0 Step -1
		WSACloseEvent(this->hEvents(i))
	Next
	
	If this->ppCachedClientMemoryContext <> NULL Then
		IMalloc_Free(this->pIMemoryAllocator, this->ppCachedClientMemoryContext)
	End If
	
	If this->pIWebSites <> NULL Then
		IWebSiteCollection_Release(this->pIWebSites)
	End If
	
	If this->pINetworkStream <> NULL Then
		INetworkStream_Release(this->pINetworkStream)
	End If
	
	If this->pIRequest <> NULL Then
		IClientRequest_Release(this->pIRequest)
	End If
	
	If this->pIResponse <> NULL Then
		IServerResponse_Release(this->pIResponse)
	End If
	
	' If this->SocketList <> INVALID_SOCKET Then
		' closesocket(this->SocketList)
	' End If
	
	If this->hIOCompletionPort <> NULL Then
		CloseHandle(this->hIOCompletionPort)
	End If
	
	DestroyCachedClientMemoryContext(this)
	
	ReferenceCounterUnInitialize(@this->RefCounter)
	IMalloc_Release(this->pIMemoryAllocator)
	ILogger_Release(this->pILogger)
	
End Sub

Function CreateWebServer( _
		ByVal pILogger As ILogger Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As WebServer Ptr
	
#if __FB_DEBUG__
	Dim vtAllocatedBytes As VARIANT = Any
	vtAllocatedBytes.vt = VT_I4
	vtAllocatedBytes.lVal = SizeOf(WebServer)
	ILogger_LogDebug(pILogger, WStr(!"WebServer creating\t"), vtAllocatedBytes)
#endif
	
	Dim pIRequest As IClientRequest Ptr = Any
	Dim hr As HRESULT = CreateInstance( _
		pILogger, _
		pIMemoryAllocator, _
		@CLSID_CLIENTREQUEST, _
		@IID_IClientRequest, _
		@pIRequest _
	)
	If SUCCEEDED(hr) Then
		Dim pIResponse As IServerResponse Ptr = Any
		hr = CreateInstance( _
			pILogger, _
			pIMemoryAllocator, _
			@CLSID_SERVERRESPONSE, _
			@IID_IServerResponse, _
			@pIResponse _
		)
		If SUCCEEDED(hr) Then
			Dim pINetworkStream As INetworkStream Ptr = Any
			hr = CreateInstance( _
				pILogger, _
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
						InitializeWebServer(this, pILogger, pIMemoryAllocator, pINetworkStream, pIRequest, pIResponse)
						
#if __FB_DEBUG__
						Dim vtEmpty As VARIANT = Any
						vtEmpty.vt = VT_EMPTY
						ILogger_LogDebug(pILogger, WStr("WebServer created"), vtEmpty)
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
	
	Return NULL
	
End Function

Sub DestroyWebServer( _
		ByVal this As WebServer Ptr _
	)
	
#if __FB_DEBUG__
	Dim vtEmpty As VARIANT = Any
	vtEmpty.vt = VT_EMPTY
	ILogger_LogDebug(this->pILogger, WStr("WebServer destroying"), vtEmpty)
#endif
	
	ILogger_AddRef(this->pILogger)
	Dim pILogger As ILogger Ptr = this->pILogger
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeWebServer(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
#if __FB_DEBUG__
	ILogger_LogDebug(pILogger, WStr("WebServer destroyed"), vtEmpty)
#endif
	
	IMalloc_Release(pIMemoryAllocator)
	ILogger_Release(pILogger)
	
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
	
	ReferenceCounterIncrement(@this->RefCounter)
	
	Return 1
	
End Function

Function WebServerRelease( _
		ByVal this As WebServer Ptr _
	)As ULONG
	
	ReferenceCounterDecrement(@this->RefCounter)
	
	If this->RefCounter.Counter = 0 Then
		
		DestroyWebServer(this)
		
		Return 0
	End If
	
	Return 1
	
End Function

Function WebServerRun( _
		ByVal this As WebServer Ptr _
	)As HRESULT
	
	If this->CurrentStatus <> RUNNABLE_S_STOPPED Then
		Return S_FALSE
	End If
	
	SetCurrentStatus(this, RUNNABLE_S_START_PENDING)
	
	Dim hr As HRESULT = ReadConfiguration(this)
	If FAILED(hr) Then
		SetCurrentStatus(this, RUNNABLE_S_STOPPED)
		Return hr
	End If
	
	hr = CreateServerSocket(this)
	If FAILED(hr) Then
		SetCurrentStatus(this, RUNNABLE_S_STOPPED)
		Return hr
	End If
	
	hr = InitializeIOCP(this)
	If FAILED(hr) Then
		SetCurrentStatus(this, RUNNABLE_S_STOPPED)
		Return hr
	End If
	
	' CreateCachedClientMemoryContext(this)
	
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
	
	' If this->SocketList <> INVALID_SOCKET Then
		' closesocket(this->SocketList)
		' this->SocketList = INVALID_SOCKET
	' End If
	
	If this->hIOCompletionPort <> NULL Then
		CloseHandle(this->hIOCompletionPort)
		this->hIOCompletionPort = NULL
	End If
	
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
				ILogger_LogError(this->pILogger, WStr(!"\t\t\t\tAccept failed\t"), vtErrorCode)
				Return HRESULT_FROM_WIN32(dwErrorAccept)
			End If
	
			Dim CachedContext As CachedClientContext = Any
			InitializeClientMemoryContext( _
				@CachedContext, _
				this->pIMemoryAllocator _
			)
			
			Scope
				Dim hrAssociateWithIOCP As HRESULT = ProcessErrorAssociateWithIOCP( _
					this, _
					ClientSocket, _
					@CachedContext _
				)
				If FAILED(hrAssociateWithIOCP) Then
					IClientContext_Release(CachedContext.pIClientContext)
					CloseSocketConnection(ClientSocket)
					Return E_FAIL
				End If
			End Scope
			
			IClientContext_SetRemoteAddress( _
				CachedContext.pIClientContext, _
				CPtr(SOCKADDR Ptr, @RemoteAddress), _
				RemoteAddressLength _
			)
			
			Scope
				Dim pINetworkStream As INetworkStream Ptr = Any
				IClientContext_GetNetworkStream(CachedContext.pIClientContext, @pINetworkStream)
				INetworkStream_SetSocket(pINetworkStream, ClientSocket)
				INetworkStream_Release(pINetworkStream)
			End Scope
			
			Scope
				Dim pIRequest As IClientRequest Ptr = Any
				IClientContext_GetClientRequest(CachedContext.pIClientContext, @pIRequest)
				
				' TODO Запросить интерфейс вместо конвертирования указателя
				Dim pIAsyncResult As IAsyncResult Ptr = Any
				Dim hrBeginReadRequest As HRESULT = IClientRequest_BeginReadRequest( _
					pIRequest, _
					CPtr(IUnknown Ptr, CachedContext.pIClientContext), _
					@pIAsyncResult _
				)
				IClientRequest_Release(pIRequest)
				
				If FAILED(hrBeginReadRequest) Then
					Dim vtSCode As VARIANT = Any
					vtSCode.vt = VT_ERROR
					vtSCode.scode = hrBeginReadRequest
					
					Dim pILogger As ILogger Ptr = Any
					IClientContext_GetLogger(CachedContext.pIClientContext, @pILogger)
					
					ILogger_LogError(pILogger, WStr(!"IClientRequest_BeginReadRequest\t"), vtSCode)
					
					ILogger_Release(pILogger)
					
					' TODO Отправить клиенту Не могу начать асинхронное чтение
					' Return S_FALSE
				End If
				
			End Scope
			
			IClientContext_Release(CachedContext.pIClientContext)
			
			' Ссылка на pIContext сохранена в pIAsyncResult
			' Указатель на pIAsyncResult сохранён в структуре OVERLAPPED
			
		End If
		
	End If
	
	Return S_OK
	
End Function

Function ProcessErrorAssociateWithIOCP( _
		ByVal this As WebServer Ptr, _
		ByVal ClientSocket As SOCKET, _
		ByVal pCachedContext As CachedClientContext Ptr _
	)As HRESULT
	
	If FAILED(pCachedContext->hrLogger) Then
		' TODO Отправить клиенту Не могу создать кучу памяти
		' INetworkStream_SetSocket(this->pINetworkStream, ClientSocket)
		' WriteHttpNotEnoughMemory(pCachedContext->pIClientContext, NULL)
		Return pCachedContext->hrMemoryAllocator
	End If
	
	If FAILED(pCachedContext->hrMemoryAllocator) Then
		' TODO Отправить клиенту Не могу создать кучу памяти
		' INetworkStream_SetSocket(this->pINetworkStream, ClientSocket)
		' WriteHttpNotEnoughMemory(pCachedContext->pIClientContext, NULL)
		Return pCachedContext->hrMemoryAllocator
	End If
	
	If FAILED(pCachedContext->hrClientContex) Then
		' TODO Отправить клиенту Не могу выделить память в куче
		' INetworkStream_SetSocket(this->pINetworkStream, ClientSocket)
		' WriteHttpNotEnoughMemory(pCachedContext->pIClientContext, NULL)
		Return pCachedContext->hrClientContex
	End If
	
	Dim hrAssociate As HRESULT = AssociateWithIOCP( _
		this, _
		ClientSocket, _
		0 _
	)
	If FAILED(hrAssociate) Then
		' TODO Отправить клиенту Не могу ассоциировать с портом завершения
		' INetworkStream_SetSocket(this->pINetworkStream, ClientSocket)
		' WriteHttpNotEnoughMemory(pCachedContext->pIClientContext, NULL)
		' IClientContext_Release(pCachedContext->pIClientContext)
		Return hrAssociate
	End If
	
	Return S_OK
	
End Function

Sub CreateCachedClientMemoryContext( _
		ByVal this As WebServer Ptr _
	)
	
	' TODO Асинхронное создание списка контекстов
	For i As Integer = 0 To this->CachedClientMemoryContextLength - 1
		
		this->ppCachedClientMemoryContext[i] = CreateClientMemoryContext( _
			this->pIMemoryAllocator _
		)
		
	Next
	
End Sub

Sub DestroyCachedClientMemoryContext( _
		ByVal this As WebServer Ptr _
	)
	
	For i As Integer = 0 To this->CachedClientMemoryContextLength - 1
		DestroyClientMemoryContext( _
			this->ppCachedClientMemoryContext[i] _
		)
	Next
	
End Sub

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
		this->pILogger, _
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
	
	IWebServerConfiguration_GetCachedClientMemoryContextCount(pIConfig, @this->CachedClientMemoryContextLength)
	
	IWebServerConfiguration_GetWebSiteCollection(pIConfig, @this->pIWebSites)
	
	IWebServerConfiguration_Release(pIConfig)
	
	this->ppCachedClientMemoryContext = IMalloc_Alloc( _
		this->pIMemoryAllocator, _
		this->CachedClientMemoryContextLength * SizeOf(CachedClientContext Ptr Ptr) _
	)
	If this->ppCachedClientMemoryContext = NULL Then
		Return E_OUTOFMEMORY
	End If
	
	Return S_OK

End Function

Function InitializeIOCP( _
		ByVal this As WebServer Ptr _
	)As HRESULT
	
	this->hIOCompletionPort = CreateIoCompletionPort( _
		INVALID_HANDLE_VALUE, _
		NULL, _
		Cast(ULONG_PTR, 0), _
		this->WorkerThreadsCount _
	)
	If this->hIOCompletionPort = NULL Then
		Dim dwError As DWORD = GetLastError()
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Const DefaultStackSize As SIZE_T_ = 0
	
	For i As Integer = 0 To this->WorkerThreadsCount - 1
		
		Dim pWorkerContext As WorkerThreadContext Ptr = CreateWorkerThreadContext( _
			this->hIOCompletionPort, _
			this->pILogger, _
			this->pIWebSites _
		)
		If pWorkerContext = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim ThreadId As DWORD = Any
		Dim hThread As HANDLE = CreateThread( _
			NULL, _
			DefaultStackSize, _
			@WorkerThread, _
			pWorkerContext, _
			0, _
			@ThreadId _
		)
		If hThread = NULL Then
			Dim dwError As DWORD = GetLastError()
			DestroyWorkerThreadContext(pWorkerContext)
			Return HRESULT_FROM_WIN32(dwError)
		End If
		
		CloseHandle(hThread)
		
	Next
	
	Return S_OK
	
End Function

Function AssociateWithIOCP( _
		ByVal this As WebServer Ptr, _
		ByVal ClientSocket As SOCKET, _
		ByVal CompletionKey As ULONG_PTR _
	)As HRESULT
	
	Dim hPort As HANDLE = CreateIoCompletionPort( _
		Cast(HANDLE, ClientSocket), _
		this->hIOCompletionPort, _
		CompletionKey, _
		0 _
	)
	If hPort = NULL Then
		Dim dwError As DWORD = GetLastError()
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Return S_OK
	
End Function

Function ServerThread( _
		ByVal this As WebServer Ptr _
	)As DWORD
	
	SetCurrentStatus(this, RUNNABLE_S_RUNNING)
	
	Do
		' If this->CachedClientMemoryContextIndex >= this->CachedClientMemoryContextLength Then
			' this->CachedClientMemoryContextIndex = 0
			' DestroyCachedClientMemoryContext(this)
			' CreateCachedClientMemoryContext(this)
		' End If
		
		IClientRequest_Clear(this->pIRequest)
		IServerResponse_Clear(this->pIResponse)
		Dim hrAccept As HRESULT = AcceptConnection( _
			this _
		)
		INetworkStream_Close(this->pINetworkStream)
		
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
	
	Return 0
	
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

' Function IWebServerSuspend( _
		' ByVal this As IRunnable Ptr _
	' )As HRESULT
	' Return WebServerSuspend(ContainerOf(this, WebServer, lpVtbl))
' End Function

' Function IWebServerResume( _
		' ByVal this As IRunnable Ptr _
	' )As HRESULT
	' Return WebServerResume(ContainerOf(this, WebServer, lpVtbl))
' End Function

Dim GlobalWebServerVirtualTable As Const IRunnableVirtualTable = Type( _
	@IWebServerQueryInterface, _
	@IWebServerAddRef, _
	@IWebServerRelease, _
	@IWebServerRun, _
	@IWebServerStop, _
	@IWebServerIsRunning, _
	@IWebServerRegisterStatusHandler _
)
