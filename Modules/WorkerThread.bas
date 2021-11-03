#include once "WorkerThread.bi"
#include once "IAsyncResult.bi"
#include once "IClientContext.bi"
#include once "IRequestedFile.bi"
#include once "IRequestProcessor.bi"
#include once "CreateInstance.bi"
#include once "WriteHttpError.bi"

Extern CLSID_HTTPGETPROCESSOR Alias "CLSID_HTTPGETPROCESSOR" As Const CLSID
Extern CLSID_REQUESTEDFILE Alias "CLSID_REQUESTEDFILE" As Const CLSID

Enum DataError
	HostNotFound
	SiteNotFound
	MovedPermanently
	NotEnoughMemory
	HttpMethodNotSupported
End Enum

Type _WorkerThreadContext
	hIOCompletionPort As HANDLE
	pILogger As ILogger Ptr
	pIWebSites As IWebSiteCollection Ptr
End Type

Function CreateWorkerThreadContext( _
		ByVal hIOCompletionPort As HANDLE, _
		ByVal pILogger As ILogger Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As WorkerThreadContext Ptr
	
	Dim this As WorkerThreadContext Ptr = CoTaskMemAlloc(SizeOf(WorkerThreadContext))
	If this = NULL Then
		Return NULL
	End If
	
	this->hIOCompletionPort = hIOCompletionPort
	
	ILogger_AddRef(pILogger)
	this->pILogger = pILogger
	
	IWebSiteCollection_AddRef(pIWebSites)
	this->pIWebSites = pIWebSites
	
	Return this
	
End Function

Sub DestroyWorkerThreadContext( _
		ByVal this As WorkerThreadContext Ptr _
	)
	
	ILogger_Release(this->pILogger)
	IWebSiteCollection_Release(this->pIWebSites)
	
	CoTaskMemFree(this)
	
End Sub

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
					
					Dim pILogger As ILogger Ptr = Any
					IClientContext_GetLogger(pIContext, @pILogger)
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
								pILogger, _
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
								pILogger, _
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
								pILogger, _
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
					ILogger_Release(pILogger)
					
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
	
	Dim hrResult As HRESULT = S_OK
	Dim hrEndReadRequest As HRESULT = Any
	
	Scope
		Dim pIRequest As IClientRequest Ptr = Any
		IClientContext_GetClientRequest(pIContext, @pIRequest)
		
		hrEndReadRequest = IClientRequest_EndReadRequest(pIRequest, pIAsyncResult)
		If FAILED(hrEndReadRequest) Then
			Dim pIHttpReader2 As IHttpReader Ptr = Any
			IClientContext_GetHttpReader(pIContext, @pIHttpReader2)
			
			' TODO Вывести байты запроса в лог
			' DebugPrintHttpReader(pIHttpReader2)
			
			IHttpReader_Release(pIHttpReader2)
			
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
			' Клиент закрыл соединение
			Dim pIHttpReader2 As IHttpReader Ptr = Any
			IClientContext_GetHttpReader(pIContext, @pIHttpReader2)
			
			' TODO Вывести байты запроса в лог
			' DebugPrintHttpReader(pIHttpReader2)
			
			IHttpReader_Release(pIHttpReader2)
			
			hrResult = E_FAIL
			
		Case S_OK
			Dim pIHttpReader2 As IHttpReader Ptr = Any
			IClientContext_GetHttpReader(pIContext, @pIHttpReader2)
			
			' TODO Вывести байты запроса в лог
			' DebugPrintHttpReader(pIHttpReader2)
			
			IHttpReader_Release(pIHttpReader2)
			
			hrResult = PrepareRequestResponse( _
				pIContext, _
				pIWebSites _
			)
			
	End Select
	
	Return hrResult
	
End Function

Function WriteResponse( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	
	Dim hrResult As HRESULT = S_OK
	Dim hrEndProcess As HRESULT = Any
	
	Dim pIRequest As IClientRequest Ptr = Any
	IClientContext_GetClientRequest(pIContext, @pIRequest)
	
	Scope
		Dim pIProcessor As IRequestProcessor Ptr = Any
		IClientContext_GetRequestProcessor(pIContext, @pIProcessor)
		
		hrEndProcess = IRequestProcessor_EndProcess(pIProcessor, pIAsyncResult)
		IRequestProcessor_Release(pIProcessor)
		
		If FAILED(hrEndProcess) Then
			ProcessEndWriteError(pIContext, hrEndProcess)
			hrResult = E_FAIL
		End If
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
				hrResult = E_FAIL
			End If
			
	End Select
	
	IClientRequest_Release(pIRequest)
	
	Return hrResult
	
End Function

Function WorkerThread( _
		ByVal lpParam As LPVOID _
	)As DWORD
	
	Dim pWorkerContext As WorkerThreadContext Ptr = CPtr(WorkerThreadContext Ptr, lpParam)
	
	Do
		
		Dim BytesTransferred As DWORD = Any
		Dim CompletionKey As ULONG_PTR = Any
		Dim pOverlapped As LPASYNCRESULTOVERLAPPED = Any
		
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
			ILogger_LogDebug(pWorkerContext->pILogger, WStr(!"GetQueuedCompletionStatus Error\t"), vtErrorCode)
			
			If pOverlapped = NULL Then
				Exit Do
			End If
			
		Else
			Dim pIContext As IClientContext Ptr = Any
			IAsyncResult_GetAsyncState(pOverlapped->pIAsync, CPtr(IUnknown Ptr Ptr, @pIContext))
			
			Dim pILogger As ILogger Ptr = Any
			IClientContext_GetLogger(pIContext, @pILogger)
			
			Dim vtBytesTransferred As VARIANT = Any
			vtBytesTransferred.vt = VT_UI4
			vtBytesTransferred.ulVal = BytesTransferred
			ILogger_LogDebug(pILogger, WStr(!"\t\t\t\tBytesTransferred\t"), vtBytesTransferred)
			
			If BytesTransferred <> 0 Then
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
				
			End If
			
			ILogger_Release(pILogger)
			IClientContext_Release(pIContext)
			
		End If
		
		IAsyncResult_Release(pOverlapped->pIAsync)
		
	Loop
	
	DestroyWorkerThreadContext(pWorkerContext)
	
	Return 0
	
End Function
