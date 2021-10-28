#include once "WebServer.bi"
#include once "IClientContext.bi"
#include once "IClientRequest.bi"
#include once "INetworkStream.bi"
#include once "IServerResponse.bi"
#include once "IWebServerConfiguration.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "Network.bi"
#include once "NetworkServer.bi"
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

Type CachedClientContext
	Dim pILogger As ILogger Ptr
	Dim pIMemoryAllocator As IMalloc Ptr
	Dim pIContext As IClientContext Ptr
	Dim hrLogger As HRESULT
	Dim hrMemoryAllocator As HRESULT
	Dim hrClientContex As HRESULT
End Type

Function CreateClientMemoryContext( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As CachedClientContext Ptr
	
	Dim pCachedContext As CachedClientContext Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(CachedClientContext) _
	)
	
	If pCachedContext <> NULL Then
		
		pCachedContext->hrLogger = CreateLoggerInstance( _
			pIMemoryAllocator, _
			@CLSID_CONSOLELOGGER, _
			@IID_ILogger, _
			@pCachedContext->pILogger _
		)
		
		If SUCCEEDED(pCachedContext->hrLogger) Then
			
			pCachedContext->hrMemoryAllocator = CreateMemoryAllocatorInstance( _
				pCachedContext->pILogger, _
				@CLSID_HEAPMEMORYALLOCATOR, _
				@IID_IMalloc, _
				@pCachedContext->pIMemoryAllocator _
			)
			
			If SUCCEEDED(pCachedContext->hrMemoryAllocator) Then
				pCachedContext->hrClientContex = CreateInstance( _
					pCachedContext->pILogger, _
					pCachedContext->pIMemoryAllocator, _
					@CLSID_CLIENTCONTEXT, _
					@IID_IClientContext, _
					@pCachedContext->pIContext _
				)
				
				If SUCCEEDED(pCachedContext->hrClientContex) Then
					IClientContext_SetOperationCode(pCachedContext->pIContext, OperationCodes.ReadRequest)
					
					Dim pIReader As IHttpReader Ptr = Any
					IClientContext_GetHttpReader(pCachedContext->pIContext, @pIReader)
					
					Scope
						Dim pINetworkStream As INetworkStream Ptr = Any
						IClientContext_GetNetworkStream(pCachedContext->pIContext, @pINetworkStream)
						
						' TODO Запросить интерфейс вместо конвертирования указателя
						IHttpReader_SetBaseStream(pIReader, CPtr(IBaseStream Ptr, pINetworkStream))
						
						INetworkStream_Release(pINetworkStream)
					End Scope
					
					Scope
						Dim pIRequest As IClientRequest Ptr = Any
						IClientContext_GetClientRequest(pCachedContext->pIContext, @pIRequest)
						
						' TODO Запросить интерфейс вместо конвертирования указателя
						IClientRequest_SetTextReader(pIRequest, CPtr(ITextReader Ptr, pIReader))
						
						IClientRequest_Release(pIRequest)
					End Scope
					
					IHttpReader_Release(pIReader)
					
					Return pCachedContext
					
				End If
				
			End If
			
		End If
		
	End If
	
	Return NULL
	
End Function

Sub DestroyClientMemoryContext( _
		ByVal pClientMemoryContext As CachedClientContext Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	If SUCCEEDED(pClientMemoryContext->hrMemoryAllocator) Then
		IMalloc_Release(pClientMemoryContext->pIMemoryAllocator)
	End If
	
	If SUCCEEDED(pClientMemoryContext->hrLogger) Then
		ILogger_Release(pClientMemoryContext->pILogger)
	End If
	
	IMalloc_Free(pIMemoryAllocator, pClientMemoryContext)
	
End Sub

Type _WebServer
	Dim lpVtbl As Const IRunnableVirtualTable Ptr
	Dim RefCounter As ReferenceCounter
	Dim pILogger As ILogger Ptr
	Dim pIMemoryAllocator As IMalloc Ptr
	
	Dim hIOCompletionPort As HANDLE
	Dim WorkerThreadsCount As Integer
	Dim pIWebSites As IWebSiteCollection Ptr
	Dim pINetworkStream As INetworkStream Ptr
	Dim pIRequest As IClientRequest Ptr
	Dim pIResponse As IServerResponse Ptr
	
	Dim ppCachedClientMemoryContext As CachedClientContext Ptr Ptr
	Dim CachedClientMemoryContextLength As Integer
	Dim CachedClientMemoryContextIndex As Integer
	
	Dim Context As Any Ptr
	Dim StatusHandler As RunnableStatusHandler
	
	Dim ListenAddress As BSTR
	Dim ListenPort As UINT
	
	Dim ListenSocket As SOCKET
	Dim CurrentStatus As HRESULT
	
End Type

Declare Function AcceptConnection( _
	ByVal this As WebServer Ptr, _
	ByVal pCachedContext As CachedClientContext Ptr _
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
	ByVal pCachedContext As CachedClientContext Ptr, _
	ByVal dwErrorAccept As Long _
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
	ByVal lpParam As LPVOID _
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
	
	this->ListenSocket = INVALID_SOCKET
	this->CurrentStatus = RUNNABLE_S_STOPPED
	
	#ifdef PERFORMANCE_TESTING
		QueryPerformanceFrequency(@this->Frequency)
	#endif
	
End Sub

Sub UnInitializeWebServer( _
		ByVal this As WebServer Ptr _
	)
	
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
	
	If this->ListenSocket <> INVALID_SOCKET Then
		closesocket(this->ListenSocket)
	End If
	
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
	
	Dim vtAllocatedBytes As VARIANT = Any
	vtAllocatedBytes.vt = VT_I4
	vtAllocatedBytes.lVal = SizeOf(WebServer)
	ILogger_LogDebug(pILogger, WStr(!"WebServer creating\t"), vtAllocatedBytes)
	
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
					
					InitializeWebServer(this, pILogger, pIMemoryAllocator, pINetworkStream, pIRequest, pIResponse)
					
					Dim vtEmpty As VARIANT = Any
					vtEmpty.vt = VT_EMPTY
					ILogger_LogDebug(pILogger, WStr("WebServer created"), vtEmpty)
					
					Return this
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
	
	Dim vtEmpty As VARIANT = Any
	vtEmpty.vt = VT_EMPTY
	ILogger_LogDebug(this->pILogger, WStr("WebServer destroying"), vtEmpty)
	
	ILogger_AddRef(this->pILogger)
	Dim pILogger As ILogger Ptr = this->pILogger
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeWebServer(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	ILogger_LogDebug(pILogger, WStr("WebServer destroyed"), vtEmpty)
	
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
	
	CreateCachedClientMemoryContext(this)
	
	Const DefaultStackSize As SIZE_T_ = 0
	Dim dwThreadId As DWORD = Any
	Dim hThread As HANDLE = CreateThread( _
		NULL, _
		DefaultStackSize, _
		@ServerThread, _
		this, _
		0, _
		@dwThreadId _
	)
	If hThread = NULL Then
		Dim dwError As DWORD = GetLastError()
		SetCurrentStatus(this, RUNNABLE_S_STOPPED)
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	WebServerAddRef(this)
	
	CloseHandle(hThread)
	
	Return S_OK
	
End Function

Function WebServerStop( _
		ByVal this As WebServer Ptr _
	)As HRESULT
	
	If this->CurrentStatus = RUNNABLE_S_STOPPED Then
		Return S_FALSE
	End If
	
	SetCurrentStatus(this, RUNNABLE_S_STOP_PENDING)
	
	If this->ListenSocket <> INVALID_SOCKET Then
		closesocket(this->ListenSocket)
		this->ListenSocket = INVALID_SOCKET
	End If
	
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
		ByVal this As WebServer Ptr, _
		ByVal pCachedContext As CachedClientContext Ptr _
	)As HRESULT
	
	Scope
		Dim RemoteAddress As SOCKADDR_STORAGE = Any
		Dim RemoteAddressLength As Long = SizeOf(SOCKADDR_STORAGE)
		Dim ClientSocket As SOCKET = accept( _
			this->ListenSocket, _
			CPtr(SOCKADDR Ptr, @RemoteAddress), _
			@RemoteAddressLength _
		)
		Dim dwErrorAccept As Long = WSAGetLastError()
		
		Dim hrAssociateWithIOCP As HRESULT = ProcessErrorAssociateWithIOCP( _
			this, _
			ClientSocket, _
			pCachedContext, _
			dwErrorAccept _
		)
		If FAILED(hrAssociateWithIOCP) Then
			Return E_FAIL
		End If
		
		IClientContext_SetRemoteAddress(pCachedContext->pIContext, CPtr(SOCKADDR Ptr, @RemoteAddress), RemoteAddressLength)
		
		Dim pINetworkStream As INetworkStream Ptr = Any
		IClientContext_GetNetworkStream(pCachedContext->pIContext, @pINetworkStream)
		INetworkStream_SetSocket(pINetworkStream, ClientSocket)
		INetworkStream_Release(pINetworkStream)
	End Scope
	
	Scope
		Dim pIRequest As IClientRequest Ptr = Any
		IClientContext_GetClientRequest(pCachedContext->pIContext, @pIRequest)
		
		' TODO Запросить интерфейс вместо конвертирования указателя
		Dim pIAsyncResult As IAsyncResult Ptr = Any
		Dim hrBeginReadRequest As HRESULT = IClientRequest_BeginReadRequest( _
			pIRequest, _
			CPtr(IUnknown Ptr, pCachedContext->pIContext), _
			@pIAsyncResult _
		)
		If FAILED(hrBeginReadRequest) Then
			Dim vtSCode As VARIANT = Any
			vtSCode.vt = VT_ERROR
			vtSCode.scode = hrBeginReadRequest
			
			Dim pILogger As ILogger Ptr = Any
			IClientContext_GetLogger(pCachedContext->pIContext, @pILogger)
			
			ILogger_LogDebug(pILogger, WStr(!"Error IClientRequest_BeginReadRequest\t"), vtSCode)
			
			ILogger_Release(pILogger)
			
			' TODO Отправить клиенту Не могу начать асинхронное чтение
			Return S_FALSE
		End If
		
		IClientRequest_Release(pIRequest)
	End Scope
	
	IClientContext_Release(pCachedContext->pIContext)
	
	' Ссылка на pIContext сохранена в pIAsyncResult
	' Указатель на pIAsyncResult сохранён в структуре OVERLAPPED
	
	Return S_OK
	
End Function

Function ProcessErrorAssociateWithIOCP( _
		ByVal this As WebServer Ptr, _
		ByVal ClientSocket As SOCKET, _
		ByVal pCachedContext As CachedClientContext Ptr, _
		ByVal dwErrorAccept As Long _
	)As HRESULT
	
	Scope
		Dim vtErrorCode As VARIANT = Any
		vtErrorCode.vt = VT_UI4
		vtErrorCode.ulVal = dwErrorAccept
		
		Dim pILogger As ILogger Ptr = Any
		IClientContext_GetLogger(pCachedContext->pIContext, @pILogger)
		
		ILogger_LogDebug(pILogger, WStr(!"\t\t\t\tClient connected\t"), vtErrorCode)
		
		ILogger_Release(pILogger)
	End Scope
	
	If ClientSocket = INVALID_SOCKET Then
		If pCachedContext->pIContext <> NULL Then
			IClientContext_Release(pCachedContext->pIContext)
		End If
		Return HRESULT_FROM_WIN32(dwErrorAccept)
	End If
	
	If pCachedContext->pIMemoryAllocator = NULL Then
		' TODO Отправить клиенту Не могу создать кучу памяти
		INetworkStream_SetSocket(this->pINetworkStream, ClientSocket)
		WriteHttpNotEnoughMemory(pCachedContext->pIContext, NULL)
		' CloseSocketConnection(ClientSocket)
		Return pCachedContext->hrMemoryAllocator
	End If
	
	If FAILED(pCachedContext->hrClientContex) Then
		' TODO Отправить клиенту Не могу выделить память в куче
		INetworkStream_SetSocket(this->pINetworkStream, ClientSocket)
		WriteHttpNotEnoughMemory(pCachedContext->pIContext, NULL)
		' CloseSocketConnection(ClientSocket)
		Return pCachedContext->hrClientContex
	End If
	
	Dim hrAssociate As HRESULT = AssociateWithIOCP( _
		this, _
		ClientSocket, _
		0 _
	)
	If FAILED(hrAssociate) Then
		' TODO Отправить клиенту Не могу ассоциировать с портом завершения
		INetworkStream_SetSocket(this->pINetworkStream, ClientSocket)
		WriteHttpNotEnoughMemory(pCachedContext->pIContext, NULL)
		IClientContext_Release(pCachedContext->pIContext)
		' CloseSocketConnection(ClientSocket)
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
			this->ppCachedClientMemoryContext[i], _
			this->pIMemoryAllocator _
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
		@this->ListenSocket _
	)
	If FAILED(hr) Then
		Return hr
	End If
	
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
		Return HRESULT_FROM_WIN32(GetLastError())
	End If
	
	Return S_OK
	
End Function

Function ServerThread( _
		ByVal lpParam As LPVOID _
	)As DWORD
	
	Dim this As WebServer Ptr = lpParam
	
	SetCurrentStatus(this, RUNNABLE_S_RUNNING)
	
	Do
		If this->CachedClientMemoryContextIndex >= this->CachedClientMemoryContextLength Then
			this->CachedClientMemoryContextIndex = 0
			DestroyCachedClientMemoryContext(this)
			CreateCachedClientMemoryContext(this)
		End If
		
		IClientRequest_Clear(this->pIRequest)
		IServerResponse_Clear(this->pIResponse)
		Dim hr As HRESULT = AcceptConnection( _
			this, _
			this->ppCachedClientMemoryContext[this->CachedClientMemoryContextIndex] _
		)
		INetworkStream_Close(this->pINetworkStream)
		
		this->CachedClientMemoryContextIndex += 1
		
		If FAILED(hr) Then
			If this->CurrentStatus = RUNNABLE_S_RUNNING Then
				Sleep_(THREAD_SLEEPING_TIME)
			Else
				Exit Do
			End If
		End If
		
	Loop While this->CurrentStatus = RUNNABLE_S_RUNNING
	
	WebServerStop(this)
	
	WebServerRelease(this)
	
	Dim vtEmpty As VARIANT = Any
	vtEmpty.vt = VT_EMPTY
	ILogger_LogDebug(this->pILogger, WStr("Server stopped"), vtEmpty)
	
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
