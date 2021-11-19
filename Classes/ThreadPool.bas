#include once "ThreadPool.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "IAsyncResult.bi"
#include once "IClientContext.bi"
#include once "IRequestedFile.bi"
#include once "IRequestProcessor.bi"
#include once "CreateInstance.bi"
#include once "Logger.bi"
#include once "WriteHttpError.bi"

Extern GlobalThreadPoolVirtualTable As Const IThreadPoolVirtualTable

Enum DataError
	HostNotFound
	SiteNotFound
	MovedPermanently
	NotEnoughMemory
	HttpMethodNotSupported
End Enum

Type _ThreadPool
	lpVtbl As Const IThreadPoolVirtualTable Ptr
	crSection As CRITICAL_SECTION
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	hIOCompletionPort As HANDLE
	WorkerThreadsCount As Integer
End Type

Function WorkerThread( _
		ByVal lpParam As LPVOID _
	)As DWORD
	
	Dim this As ThreadPool Ptr = lpParam
	
	Do
		
		Dim BytesTransferred As DWORD = Any
		Dim CompletionKey As ULONG_PTR = Any
		Dim pOverlapped As ASYNCRESULTOVERLAPPED Ptr = Any
		
		Dim res As Integer = GetQueuedCompletionStatus( _
			this->hIOCompletionPort, _
			@BytesTransferred, _
			@CompletionKey, _
			CPtr(LPOVERLAPPED Ptr, @pOverlapped), _
			INFINITE _
		)
		If res = 0 Then
		Else
		End If
		
	Loop
	
	Return 0
	
End Function

Function AssociateWithIOCP( _
		ByVal this As ThreadPool Ptr, _
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

Sub InitializeThreadPool( _
		ByVal this As ThreadPool Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	this->lpVtbl = @GlobalThreadPoolVirtualTable
	' InitializeCriticalSectionAndSpinCount( _
		' @this->crSection, _
		' MAX_CRITICAL_SECTION_SPIN_COUNT _
	' )
	this->ReferenceCounter = 0
	
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	
	this->hIOCompletionPort = NULL
	this->WorkerThreadsCount = 0
	
End Sub

Sub UnInitializeThreadPool( _
		ByVal this As ThreadPool Ptr _
	)
	
	If this->hIOCompletionPort <> NULL Then
		CloseHandle(this->hIOCompletionPort)
	End If
	
	IMalloc_Release(this->pIMemoryAllocator)
	' DeleteCriticalSection(@this->crSection)
	
End Sub

Function CreateThreadPool( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As ThreadPool Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(ThreadPool)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"ThreadPool creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim this As ThreadPool Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(ThreadPool) _
	)
	If this <> NULL Then
		InitializeThreadPool( _
			this, _
			pIMemoryAllocator _
		)
		
		#if __FB_DEBUG__
		Scope
			Dim vtEmpty As VARIANT = Any
			VariantInit(@vtEmpty)
			LogWriteEntry( _
				LogEntryType.Debug, _
				WStr("ThreadPool created"), _
				@vtEmpty _
			)
		End Scope
		#endif
		
		Return this
	End If
	
	Return NULL
	
End Function

Sub DestroyThreadPool( _
		ByVal this As ThreadPool Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("ThreadPool destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeThreadPool(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("ThreadPool destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function ThreadPoolQueryInterface( _
		ByVal this As ThreadPool Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IThreadPool, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	ThreadPoolAddRef(this)
	
	Return S_OK
	
End Function

Function ThreadPoolAddRef( _
		ByVal this As ThreadPool Ptr _
	)As ULONG
	
	' EnterCriticalSection(@this->crSection)
	Scope
		this->ReferenceCounter += 1
	End Scope
	' LeaveCriticalSection(@this->crSection)
	
	Return this->ReferenceCounter
	
End Function

Function ThreadPoolRelease( _
		ByVal this As ThreadPool Ptr _
	)As ULONG
	
	' EnterCriticalSection(@this->crSection)
	Scope
		this->ReferenceCounter -= 1
	End Scope
	' LeaveCriticalSection(@this->crSection)
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyThreadPool(this)
	
	Return 0
	
End Function

Function ThreadPoolGetMaxThreads( _
		ByVal this As ThreadPool Ptr, _
		ByVal pMaxThreads As Integer Ptr _
	)As HRESULT
	
	*pMaxThreads = this->WorkerThreadsCount
	
	Return S_OK
	
End Function

Function ThreadPoolSetMaxThreads( _
		ByVal this As ThreadPool Ptr, _
		ByVal MaxThreads As Integer _
	)As HRESULT
	
	this->WorkerThreadsCount = MaxThreads
	
	Return S_OK
	
End Function

Function ThreadPoolRun( _
		ByVal this As ThreadPool Ptr _
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
		
		Dim ThreadId As DWORD = Any
		Dim hThread As HANDLE = CreateThread( _
			NULL, _
			DefaultStackSize, _
			@WorkerThread, _
			this, _
			0, _
			@ThreadId _
		)
		If hThread = NULL Then
			Dim dwError As DWORD = GetLastError()
			Return HRESULT_FROM_WIN32(dwError)
		End If
		
		CloseHandle(hThread)
		
	Next
	
	Return S_OK
	
End Function

Function ThreadPoolStop( _
		ByVal this As ThreadPool Ptr _
	)As HRESULT
	
	If this->hIOCompletionPort <> NULL Then
		CloseHandle(this->hIOCompletionPort)
		this->hIOCompletionPort = NULL
	End If
	
	Return S_OK
	
End Function


Function IThreadPoolQueryInterface( _
		ByVal this As IThreadPool Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return ThreadPoolQueryInterface(ContainerOf(this, ThreadPool, lpVtbl), riid, ppv)
End Function

Function IThreadPoolAddRef( _
		ByVal this As IThreadPool Ptr _
	)As ULONG
	Return ThreadPoolAddRef(ContainerOf(this, ThreadPool, lpVtbl))
End Function

Function IThreadPoolRelease( _
		ByVal this As IThreadPool Ptr _
	)As ULONG
	Return ThreadPoolRelease(ContainerOf(this, ThreadPool, lpVtbl))
End Function

Function IThreadPoolGetMaxThreads( _
		ByVal this As IThreadPool Ptr, _
		ByVal pMaxThreads As Integer Ptr _
	)As HRESULT
	Return ThreadPoolGetMaxThreads(ContainerOf(this, ThreadPool, lpVtbl), pMaxThreads)
End Function

Function IThreadPoolSetMaxThreads( _
		ByVal this As IThreadPool Ptr, _
		ByVal MaxThreads As Integer _
	)As HRESULT
	Return ThreadPoolSetMaxThreads(ContainerOf(this, ThreadPool, lpVtbl), MaxThreads)
End Function

Function IThreadPoolRun( _
		ByVal this As IThreadPool Ptr _
	)As HRESULT
	Return ThreadPoolRun(ContainerOf(this, ThreadPool, lpVtbl))
End Function

Function IThreadPoolStop( _
		ByVal this As IThreadPool Ptr _
	)As HRESULT
	Return ThreadPoolStop(ContainerOf(this, ThreadPool, lpVtbl))
End Function

Dim GlobalThreadPoolVirtualTable As Const IThreadPoolVirtualTable = Type( _
	@IThreadPoolQueryInterface, _
	@IThreadPoolAddRef, _
	@IThreadPoolRelease, _
	@IThreadPoolGetMaxThreads, _
	@IThreadPoolSetMaxThreads, _
	@IThreadPoolRun, _
	@IThreadPoolStop _
)

/'
Declare Function ProcessErrorAssociateWithIOCP( _
	ByVal this As WebServer Ptr, _
	ByVal ClientSocket As SOCKET, _
	ByVal pCachedContext As CachedClientContext Ptr _
)As HRESULT

Sub ProcessBeginReadError( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal hrDataError As DataError _
	)
	
	Select Case hrDataError
		
		Case DataError.NotEnoughMemory
			WriteHttpNotEnoughMemory(pIContext, NULL)
			
	End Select
	
End Sub

Sub ProcessEndReadError( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal hrEndReadRequest As HRESULT _
	)
	
	Select Case hrEndReadRequest
		
		Case CLIENTREQUEST_E_HTTPVERSIONNOTSUPPORTED
			WriteHttpVersionNotSupported(pIContext, NULL)
			
		Case CLIENTREQUEST_E_BADREQUEST
			WriteHttpBadRequest(pIContext, NULL)
			
		Case CLIENTREQUEST_E_BADPATH
			WriteHttpPathNotValid(pIContext, NULL)
			
		Case CLIENTREQUEST_E_EMPTYREQUEST
			' Пустой запрос, клиент закрыл соединение
			
		Case CLIENTREQUEST_E_SOCKETERROR
			' Ошибка сокета
			
		Case CLIENTREQUEST_E_URITOOLARGE
			WriteHttpRequestUrlTooLarge(pIContext, NULL)
			
		Case CLIENTREQUEST_E_HEADERFIELDSTOOLARGE
			WriteHttpRequestHeaderFieldsTooLarge(pIContext, NULL)
			
		Case CLIENTREQUEST_E_HTTPMETHODNOTSUPPORTED
			Dim pIResponse As IServerResponse Ptr = Any
			IClientContext_GetServerResponse(pIContext, @pIResponse)
			
			IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderAllow, @AllSupportHttpMethods)
			
			WriteHttpNotImplemented(pIContext, NULL)
			
			IServerResponse_Release(pIResponse)
			
		Case Else
			WriteHttpBadRequest(pIContext, NULL)
			
	End Select
	
End Sub

Sub ProcessDataError( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal hrDataError As DataError, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Select Case hrDataError
		
		Case DataError.HostNotFound
			WriteHttpHostNotFound(pIContext, NULL)
			
		Case DataError.SiteNotFound
			WriteHttpSiteNotFound(pIContext, NULL)
			
		Case DataError.MovedPermanently
			WriteMovedPermanently(pIContext, pIWebSite)
			
		Case DataError.NotEnoughMemory
			WriteHttpNotEnoughMemory(pIContext, pIWebSite)
			
		Case DataError.HttpMethodNotSupported
			WriteHttpNotImplemented(pIContext, NULL)
			
	End Select
	
End Sub

Sub ProcessBeginWriteError( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal hrBeginProcess As HRESULT, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Select Case hrBeginProcess
		
		Case REQUESTPROCESSOR_E_FILENOTFOUND
			WriteHttpFileNotFound(pIContext, pIWebSite)
			
		Case REQUESTPROCESSOR_E_FILEGONE
			WriteHttpFileGone(pIContext, pIWebSite)
			
		Case REQUESTPROCESSOR_E_FORBIDDEN
			WriteHttpForbidden(pIContext, pIWebSite)
			
		Case REQUESTPROCESSOR_E_RANGENOTSATISFIABLE
			WriteHttpRequestRangeNotSatisfiable(pIContext, pIWebSite)
			
		Case Else
			WriteHttpInternalServerError(pIContext, pIWebSite)
			
	End Select
	
End Sub

Sub ProcessEndWriteError( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal hrEndProcess As HRESULT _
	)
	
End Sub

Function PrepareRequestResponse( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	
	Dim hrResult As HRESULT = S_OK
	
	Dim pIRequest As IClientRequest Ptr = Any
	IClientContext_GetClientRequest(pIContext, @pIRequest)
	
	hrResult = IClientRequest_Prepare(pIRequest)
	If FAILED(hrResult) Then
		ProcessEndReadError(pIContext, hrResult)
		hrResult = E_FAIL
	Else
		
		' IHttpWriter_Clear(pIHttpWriter)
		
		Dim pIResponse As IServerResponse Ptr = Any
		IClientContext_GetServerResponse(pIContext, @pIResponse)
		IServerResponse_Clear(pIResponse)
		
		Scope
			Dim KeepAlive As Boolean = True
			IClientRequest_GetKeepAlive(pIRequest, @KeepAlive)
			IServerResponse_SetKeepAlive(pIResponse, KeepAlive)
		End Scope
		
		Dim HttpMethod As HttpMethods = Any
		IClientRequest_GetHttpMethod(pIRequest, @HttpMethod)
		
		Dim ClientURI As Station922Uri = Any
		IClientRequest_GetUri(pIRequest, @ClientURI)
		
		' TODO Найти правильный заголовок Host в зависимости от версии 1.0 или 1.1
		Dim pHeaderHost As WString Ptr = Any
		If HttpMethod = HttpMethods.HttpConnect Then
			pHeaderHost = ClientURI.Authority.Host
		Else
			IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderHost, @pHeaderHost)
		End If
		
		Dim HttpVersion As HttpVersions = Any
		IClientRequest_GetHttpVersion(pIRequest, @HttpVersion)
		IServerResponse_SetHttpVersion(pIResponse, HttpVersion)
		
		Dim HeaderHostLength As Integer = lstrlenW(pHeaderHost)
		If HeaderHostLength = 0 AndAlso HttpVersion = HttpVersions.Http11 Then
			ProcessDataError(pIContext, DataError.HostNotFound, NULL)
			hrResult = E_FAIL
		Else
			
			Dim pIWebSite As IWebSite Ptr = Any
			Dim hrFindSite As HRESULT = Any
			If HttpMethod = HttpMethods.HttpConnect Then
				hrFindSite = IWebSiteCollection_Item(pIWebSites, NULL, @pIWebSite)
			Else
				hrFindSite = IWebSiteCollection_Item(pIWebSites, pHeaderHost, @pIWebSite)
			End If
			
			If FAILED(hrFindSite) Then
				ProcessDataError(pIContext, DataError.SiteNotFound, NULL)
				hrResult = E_FAIL
			Else
				
				Dim IsSiteMoved As Boolean = Any
				' TODO Грязный хак с robots.txt
				Dim IsRobotsTxt As Integer = lstrcmpiW(ClientURI.Path, WStr("/robots.txt"))
				If IsRobotsTxt = 0 Then
					IsSiteMoved = False
				Else
					IWebSite_GetIsMoved(pIWebSite, @IsSiteMoved)
				End If
				
				If IsSiteMoved Then
					' Сайт перемещён на другой ресурс
					' если запрошен документ /robots.txt то не перенаправлять
					ProcessDataError(pIContext, DataError.MovedPermanently, pIWebSite)
					hrResult = E_FAIL
				Else
					
					Dim pIMemoryAllocator As IMalloc Ptr = Any
					IClientContext_GetMemoryAllocator(pIContext, @pIMemoryAllocator)
					
					Dim IsKnownHttpMethod As Boolean = Any
					Dim RequestedFileAccess As FileAccess = Any
					Dim pIProcessor As IRequestProcessor Ptr = Any
					Dim hrCreateRequestProcessor As HRESULT = Any
					
					Select Case HttpMethod
						
						Case HttpMethods.HttpGet
							IsKnownHttpMethod = True
							RequestedFileAccess = FileAccess.ReadAccess
							hrCreateRequestProcessor = CreateInstance( _
								pIMemoryAllocator, _
								@CLSID_HTTPGETPROCESSOR, _
								@IID_IRequestProcessor, _
								@pIProcessor _
							)
							
						Case HttpMethods.HttpHead
							IsKnownHttpMethod = True
							IServerResponse_SetSendOnlyHeaders(pIResponse, True)
							RequestedFileAccess = FileAccess.ReadAccess
							hrCreateRequestProcessor = CreateInstance( _
								pIMemoryAllocator, _
								@CLSID_HTTPGETPROCESSOR, _
								@IID_IRequestProcessor, _
								@pIProcessor _
							)
							
						' Case HttpMethods.HttpPost
							' RequestedFileAccess = FileAccess.UpdateAccess
							' ProcessRequestVirtualTable = @ProcessPostRequest
							
						' Case HttpMethods.HttpPut
							' RequestedFileAccess = FileAccess.CreateAccess
							' ProcessRequestVirtualTable = @ProcessPutRequest
							
						' Case HttpMethods.HttpDelete
							' RequestedFileAccess = FileAccess.DeleteAccess
							' ProcessRequestVirtualTable = @ProcessDeleteRequest
							
						' Case HttpMethods.HttpOptions
							' RequestedFileAccess = FileAccess.ReadAccess
							' ProcessRequestVirtualTable = @ProcessOptionsRequest
							
						' Case HttpMethods.HttpTrace
							' RequestedFileAccess = FileAccess.ReadAccess
							' ProcessRequestVirtualTable = @ProcessTraceRequest
							
						' Case HttpMethods.HttpConnect
							' RequestedFileAccess = FileAccess.ReadAccess
							' ProcessRequestVirtualTable = @ProcessConnectRequest
							
						Case Else
							IsKnownHttpMethod = False
							RequestedFileAccess = FileAccess.ReadAccess
							pIProcessor = NULL
							hrCreateRequestProcessor = E_OUTOFMEMORY
							
					End Select
					
					If IsKnownHttpMethod = False Then
						ProcessDataError(pIContext, DataError.HttpMethodNotSupported, pIWebSite)
						hrResult = E_FAIL
					Else
						If FAILED(hrCreateRequestProcessor) Then
							ProcessDataError(pIContext, DataError.NotEnoughMemory, pIWebSite)
							hrResult = E_FAIL
						Else
							IClientContext_SetRequestProcessor(pIContext, pIProcessor)
							
							Dim pIFile As IRequestedFile Ptr = Any
							Dim hrCreateRequestedFile As HRESULT = CreateInstance( _
								pIMemoryAllocator, _
								@CLSID_REQUESTEDFILE, _
								@IID_IRequestedFile, _
								@pIFile _
							)
							If FAILED(hrCreateRequestedFile) Then
								ProcessDataError(pIContext, DataError.NotEnoughMemory, pIWebSite)
								hrResult = E_FAIL
							Else
								IClientContext_SetRequestedFile(pIContext, pIFile)
								
								Dim hrGetFile As HRESULT = IWebSite_OpenRequestedFile( _
									pIWebSite, _
									pIFile, _
									ClientURI.Path, _
									RequestedFileAccess _
								)
								If FAILED(hrGetFile) Then
									ProcessDataError(pIContext, DataError.NotEnoughMemory, pIWebSite)
									hrResult = E_FAIL
								Else
									
									Dim pINetworkStream As INetworkStream Ptr = Any
									IClientContext_GetNetworkStream(pIContext, @pINetworkStream)
									Dim pIHttpReader As IHttpReader Ptr = Any
									IClientContext_GetHttpReader(pIContext, @pIHttpReader)
									
									Dim pc As ProcessorContext = Any
									pc.pIRequest = pIRequest
									pc.pIResponse = pIResponse
									pc.pINetworkStream = pINetworkStream
									pc.pIWebSite = pIWebSite
									pc.pIClientReader = pIHttpReader
									pc.pIRequestedFile = pIFile
									pc.pIMemoryAllocator = pIMemoryAllocator
									
									Dim hrPrepare As HRESULT = IRequestProcessor_Prepare( _
										pIProcessor, _
										@pc _
									)
									If FAILED(hrPrepare) Then
										ProcessBeginWriteError(pIContext, hrPrepare, pIWebSite)
									Else
										IClientContext_SetOperationCode(pIContext, OperationCodes.WriteResponse)
										
										' TODO Запросить интерфейс вместо конвертирования указателя
										Dim pINewAsyncResult As IAsyncResult Ptr = Any
										Dim hrBeginProcess As HRESULT = IRequestProcessor_BeginProcess( _
											pIProcessor, _
											@pc, _
											CPtr(IUnknown Ptr, pIContext), _
											@pINewAsyncResult _
										)
										If FAILED(hrBeginProcess) Then
											ProcessBeginWriteError(pIContext, hrBeginProcess, pIWebSite)
											hrResult = E_FAIL
										End If
										
									End If
									
									IHttpReader_Release(pIHttpReader)
									INetworkStream_Release(pINetworkStream)
								End If
								
								IRequestedFile_Release(pIFile)
							End If
							
							IRequestProcessor_Release(pIProcessor)
						End If
					End If
					
					IMalloc_Release(pIMemoryAllocator)
					
				End If
				
				IWebSite_Release(pIWebSite)
				
			End If
			
		End If
		
		IServerResponse_Release(pIResponse)
		
	End If
	
	IClientRequest_Release(pIRequest)
	
	Return hrResult
	
End Function

Function ReadRequest( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	
	IClientContext_AddRef(pIContext)
	IAsyncResult_AddRef(pIAsyncResult)
	
	Dim hrResult As HRESULT = S_OK
	Dim hrEndReadRequest As HRESULT = Any
	
	Scope
		Dim pIRequest As IClientRequest Ptr = Any
		IClientContext_GetClientRequest(pIContext, @pIRequest)
		
		hrEndReadRequest = IClientRequest_EndReadRequest(pIRequest, pIAsyncResult)
		If FAILED(hrEndReadRequest) Then
			Dim pIHttpReader As IHttpReader Ptr = Any
			IClientContext_GetHttpReader(pIContext, @pIHttpReader)
			
			' TODO Вывести байты запроса в лог
			' DebugPrintHttpReader(pIHttpReader)
			
			IHttpReader_Release(pIHttpReader)
			
			ProcessEndReadError(pIContext, hrEndReadRequest)
			IClientRequest_Release(pIRequest)
			Return E_FAIL
		End If
		
		IClientRequest_Release(pIRequest)
	End Scope
	
	Select Case hrEndReadRequest
		
		Case CLIENTREQUEST_S_IO_PENDING
			IClientContext_SetOperationCode(pIContext, OperationCodes.ReadRequest)
			
			Dim pIRequest As IClientRequest Ptr = Any
			IClientContext_GetClientRequest(pIContext, @pIRequest)
			
			' TODO Запросить интерфейс вместо конвертирования указателя
			Dim pINewAsyncResult As IAsyncResult Ptr = Any
			Dim hrBeginReadRequest As HRESULT = IClientRequest_BeginReadRequest( _
				pIRequest, _
				CPtr(IUnknown Ptr, pIContext), _
				@pINewAsyncResult _
			)
			If FAILED(hrBeginReadRequest) Then
				ProcessBeginReadError(pIContext, hrBeginReadRequest)
				hrResult = hrBeginReadRequest
			End If
			
			IClientRequest_Release(pIRequest)
			
			
		Case S_FALSE
			Dim pIHttpReader As IHttpReader Ptr = Any
			IClientContext_GetHttpReader(pIContext, @pIHttpReader)
			
			' TODO Вывести байты запроса в лог
			' DebugPrintHttpReader(pIHttpReader)
			
			IHttpReader_Release(pIHttpReader)
			
			hrResult = E_FAIL
			
			
		Case S_OK
			Dim pIHttpReader As IHttpReader Ptr = Any
			IClientContext_GetHttpReader(pIContext, @pIHttpReader)
			
			' TODO Вывести байты запроса в лог
			' DebugPrintHttpReader(pIHttpReader)
			
			IHttpReader_Release(pIHttpReader)
			
			hrResult = PrepareRequestResponse( _
				pIContext, _
				pIWebSites _
			)
			
	End Select
	
	IAsyncResult_Release(pIAsyncResult)
	IClientContext_Release(pIContext)
	
	Return hrResult
	
End Function

Function WriteResponse( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	
	IClientContext_AddRef(pIContext)
	IAsyncResult_AddRef(pIAsyncResult)
	
	Dim hrResult As HRESULT = S_OK
	Dim hrEndProcess As HRESULT = Any
	
	Dim pIRequest As IClientRequest Ptr = Any
	IClientContext_GetClientRequest(pIContext, @pIRequest)
	
	Scope
		Dim pIProcessor As IRequestProcessor Ptr = Any
		IClientContext_GetRequestProcessor(pIContext, @pIProcessor)
		
		hrEndProcess = IRequestProcessor_EndProcess(pIProcessor, pIAsyncResult)
		If FAILED(hrEndProcess) Then
			ProcessEndWriteError(pIContext, hrEndProcess)
			hrResult = E_FAIL
		End If
		
		IRequestProcessor_Release(pIProcessor)
	End Scope
	
	Select Case hrEndProcess
		
		Case REQUESTPROCESSOR_S_IO_PENDING
			IClientContext_SetOperationCode(pIContext, OperationCodes.WriteResponse)
			
			Dim pINetworkStream As INetworkStream Ptr = Any
			IClientContext_GetNetworkStream(pIContext, @pINetworkStream)
			
			Dim pIFile As IRequestedFile Ptr = Any
			IClientContext_GetRequestedFile(pIContext, @pIFile)
			
			Dim pIResponse As IServerResponse Ptr = Any
			IClientContext_GetServerResponse(pIContext, @pIResponse)
			
			Dim pIHttpReader As IHttpReader Ptr
			IClientContext_GetHttpReader(pIContext, @pIHttpReader)
			
			Dim pHeaderHost As WString Ptr = Any
			' If HttpMethod = HttpMethods.HttpConnect Then
				' pHeaderHost = ClientURI.pUrl
			' Else
				IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderHost, @pHeaderHost)
			' End If
			Dim pIWebSite As IWebSite Ptr = Any
			IWebSiteCollection_Item(pIWebSites, pHeaderHost, @pIWebSite)

			Dim pIMemoryAllocator As IMalloc Ptr = Any
			IClientContext_GetMemoryAllocator(pIContext, @pIMemoryAllocator)
			
			Dim pc As ProcessorContext = Any
			pc.pIRequest = pIRequest
			pc.pIResponse = pIResponse
			pc.pINetworkStream = pINetworkStream
			pc.pIWebSite = pIWebSite
			pc.pIClientReader = pIHttpReader
			pc.pIRequestedFile = pIFile
			pc.pIMemoryAllocator = pIMemoryAllocator
			
			Dim pIProcessor As IRequestProcessor Ptr = Any
			IClientContext_GetRequestProcessor(pIContext, @pIProcessor)
			
			' TODO Запросить интерфейс вместо конвертирования указателя
			Dim pINewAsyncResult As IAsyncResult Ptr = Any
			Dim hrBeginProcess As HRESULT = IRequestProcessor_BeginProcess( _
				pIProcessor, _
				@pc, _
				CPtr(IUnknown Ptr, pIContext), _
				@pINewAsyncResult _
			)
			IRequestProcessor_Release(pIProcessor)
			
			If FAILED(hrBeginProcess) Then
				ProcessBeginWriteError(pIContext, hrBeginProcess, pIWebSite)
				hrResult = E_FAIL
			End If
			
			IMalloc_Release(pIMemoryAllocator)
			IWebSite_Release(pIWebSite)
			IHttpReader_Release(pIHttpReader)
			IServerResponse_Release(pIResponse)
			IRequestedFile_Release(pIFile)
			INetworkStream_Release(pINetworkStream)
			
		Case S_FALSE
			hrEndProcess = E_FAIL
			
		Case Else
			' Запустить чтение заново
			Dim KeepAlive As Boolean = True
			Scope
				Dim pIResponse As IServerResponse Ptr = Any
				IClientContext_GetServerResponse(pIContext, @pIResponse)
				
				IServerResponse_GetKeepAlive(pIResponse, @KeepAlive)
				
				IServerResponse_Release(pIResponse)
			End Scope
			
			If KeepAlive Then
				#if __FB_DEBUG__
				Scope
					Dim vtEmpty As VARIANT = Any
					VariantInit@(vtEmpty)
					LogWriteEntry( _
						LogEntryType.Debug, _
						WStr(!"KeepAlive = True"), _
						@vtEmpty _
					)
				End Scope
				#endif
				IClientContext_SetOperationCode(pIContext, OperationCodes.ReadRequest)
				
				Scope
					Dim pIHttpReader As IHttpReader Ptr
					IClientContext_GetHttpReader(pIContext, @pIHttpReader)
					IHttpReader_Clear(pIHttpReader)
					IHttpReader_Release(pIHttpReader)
				End Scope
				
				IClientRequest_Clear(pIRequest)
				
				' TODO Запросить интерфейс вместо конвертирования указателя
				Dim pINewAsyncResult As IAsyncResult Ptr = Any
				Dim hrBeginReadRequest As HRESULT = IClientRequest_BeginReadRequest( _
					pIRequest, _
					CPtr(IUnknown Ptr, pIContext), _
					@pINewAsyncResult _
				)
				If FAILED(hrBeginReadRequest) Then
					ProcessBeginReadError(pIContext, hrBeginReadRequest)
					hrResult = E_FAIL
				End If
				
			Else
				#if __FB_DEBUG__
				Scope
					Dim vtEmpty As VARIANT = Any
					VariantInit@(vtEmpty)
					LogWriteEntry( _
						LogEntryType.Debug, _
						WStr(!"KeepAlive = False"), _
						@vtEmpty _
					)
				End Scope
				#endif
				hrResult = E_FAIL
			End If
			
	End Select
	
	IClientRequest_Release(pIRequest)
	
	IAsyncResult_Release(pIAsyncResult)
	IClientContext_Release(pIContext)
	
	Return hrResult
	
End Function

Function WorkerThread( _
		ByVal lpParam As LPVOID _
	)As DWORD
	
	Dim pWorkerContext As WorkerThreadContext Ptr = CPtr(WorkerThreadContext Ptr, lpParam)
	
	Do
		
		Dim BytesTransferred As DWORD = Any
		Dim CompletionKey As ULONG_PTR = Any
		Dim pOverlapped As ASYNCRESULTOVERLAPPED Ptr = Any
		
		Dim res As Integer = GetQueuedCompletionStatus( _
			pWorkerContext->hIOCompletionPort, _
			@BytesTransferred, _
			@CompletionKey, _
			CPtr(LPOVERLAPPED Ptr, @pOverlapped), _
			INFINITE _
		)
		If res = 0 Then
			' TODO Обработать ошибку
			
			Dim dwError As DWORD = GetLastError()
			Dim vtErrorCode As VARIANT = Any
			vtErrorCode.vt = VT_UI4
			vtErrorCode.ulVal = dwError
			LogWriteEntry( _
				LogEntryType.Error, _
				WStr(!"GetQueuedCompletionStatus Error\t"), _
				@vtErrorCode _
			)
			
			If pOverlapped = NULL Then
				Exit Do
			End If
			
		Else
			' If BytesTransferred <> 0 Then
				IAsyncResult_SetCompleted(pOverlapped->pIAsync, BytesTransferred, True)
				
				Dim pIContext As IClientContext Ptr = Any
				IAsyncResult_GetAsyncState(pOverlapped->pIAsync, CPtr(IUnknown Ptr Ptr, @pIContext))
				
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
				
				Dim OpCode As OperationCodes = Any
				IClientContext_GetOperationCode(pIContext, @OpCode)
				
				Select Case OpCode
					
					Case OperationCodes.ReadRequest
						ReadRequest( _
							pIContext, _
							pOverlapped->pIAsync, _
							pWorkerContext->pIWebSites _
						)
						
					Case OperationCodes.WriteResponse
						WriteResponse( _
							pIContext, _
							pOverlapped->pIAsync, _
							pWorkerContext->pIWebSites _
						)
						
				End Select
				
				IClientContext_Release(pIContext)
				
			' End If
			
		End If
		
		IAsyncResult_Release(pOverlapped->pIAsync)
		
	Loop
	
	DestroyWorkerThreadContext(pWorkerContext)
	
	Return 0
	
End Function
'/