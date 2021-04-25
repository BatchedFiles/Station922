#include once "WorkerThread.bi"
#include once "IAsyncResult.bi"
#include once "IClientContext.bi"
#include once "IRequestedFile.bi"
#include once "IRequestProcessor.bi"
#include once "CreateInstance.bi"
#include once "PrintDebugInfo.bi"
#include once "WriteHttpError.bi"

Extern CLSID_HTTPGETPROCESSOR Alias "CLSID_HTTPGETPROCESSOR" As Const CLSID
Extern CLSID_REQUESTEDFILE Alias "CLSID_REQUESTEDFILE" As Const CLSID
Extern CLSID_ASYNCRESULT Alias "CLSID_ASYNCRESULT" As Const CLSID

Enum DataError
	HostNotFound
	SiteNotFound
	MovedPermanently
	NotEnoughMemory
	HttpMethodNotSupported
End Enum

Sub ProcessBeginReadError( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal hrDataError As DataError _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	Dim pINetworkStream As INetworkStream Ptr = Any
	IClientContext_GetNetworkStream(pIContext, @pINetworkStream)
	
	Select Case hrDataError
		
		Case DataError.NotEnoughMemory
			' TODO Запросить интерфейс вместо конвертирования указателя
			WriteHttpNotEnoughMemory(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), NULL)
			
	End Select
	
	INetworkStream_Release(pINetworkStream)
	IServerResponse_Release(pIResponse)
	
End Sub

Sub ProcessEndReadError( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal hrEndReadRequest As HRESULT _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	Dim pINetworkStream As INetworkStream Ptr = Any
	IClientContext_GetNetworkStream(pIContext, @pINetworkStream)
	
	Select Case hrEndReadRequest
		
		Case CLIENTREQUEST_E_HTTPVERSIONNOTSUPPORTED
			' TODO Запросить интерфейс вместо конвертирования указателя
			WriteHttpVersionNotSupported(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), NULL)
			
		Case CLIENTREQUEST_E_BADREQUEST
			' TODO Запросить интерфейс вместо конвертирования указателя
			WriteHttpBadRequest(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), NULL)
			
		Case CLIENTREQUEST_E_BADPATH
			' TODO Запросить интерфейс вместо конвертирования указателя
			WriteHttpPathNotValid(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), NULL)
			
		Case CLIENTREQUEST_E_EMPTYREQUEST
			' Пустой запрос, клиент закрыл соединение
			
		Case CLIENTREQUEST_E_SOCKETERROR
			' Ошибка сокета
			
		Case CLIENTREQUEST_E_URITOOLARGE
			' TODO Запросить интерфейс вместо конвертирования указателя
			WriteHttpRequestUrlTooLarge(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), NULL)
			
		Case CLIENTREQUEST_E_HEADERFIELDSTOOLARGE
			' TODO Запросить интерфейс вместо конвертирования указателя
			WriteHttpRequestHeaderFieldsTooLarge(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), NULL)
			
		Case CLIENTREQUEST_E_HTTPMETHODNOTSUPPORTED
			IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderAllow, @AllSupportHttpMethods)
			' TODO Запросить интерфейс вместо конвертирования указателя
			WriteHttpNotImplemented(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), NULL)
			
		Case Else
			' TODO Запросить интерфейс вместо конвертирования указателя
			WriteHttpBadRequest(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), NULL)
			
	End Select
	
	INetworkStream_Release(pINetworkStream)
	IServerResponse_Release(pIResponse)
	
End Sub

Sub ProcessDataError( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal hrDataError As DataError, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	Dim pINetworkStream As INetworkStream Ptr = Any
	IClientContext_GetNetworkStream(pIContext, @pINetworkStream)
	
	Select Case hrDataError
		
		Case DataError.HostNotFound
			' TODO Запросить интерфейс вместо конвертирования указателя
			WriteHttpHostNotFound(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), NULL)
			
		Case DataError.SiteNotFound
			' TODO Запросить интерфейс вместо конвертирования указателя
			WriteHttpSiteNotFound(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), NULL)
			
		Case DataError.MovedPermanently
			' TODO Запросить интерфейс вместо конвертирования указателя
			WriteMovedPermanently(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), pIWebSite)
			
		Case DataError.NotEnoughMemory
			' TODO Запросить интерфейс вместо конвертирования указателя
			WriteHttpNotEnoughMemory(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), pIWebSite)
			
		Case DataError.HttpMethodNotSupported
			' TODO Запросить интерфейс вместо конвертирования указателя
			WriteHttpNotImplemented(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), NULL)
			
	End Select
	
	INetworkStream_Release(pINetworkStream)
	IServerResponse_Release(pIResponse)
	
End Sub

Sub ProcessBeginWriteError( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal hrBeginProcess As HRESULT, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	Dim pINetworkStream As INetworkStream Ptr = Any
	IClientContext_GetNetworkStream(pIContext, @pINetworkStream)
	
	Select Case hrBeginProcess
		
		Case REQUESTPROCESSOR_E_FILENOTFOUND
			' TODO Запросить интерфейс вместо конвертирования указателя
			WriteHttpFileNotFound(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), pIWebSite)
			
		Case REQUESTPROCESSOR_E_FILEGONE
			' TODO Запросить интерфейс вместо конвертирования указателя
			WriteHttpFileGone(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), pIWebSite)
			
		Case REQUESTPROCESSOR_E_FORBIDDEN
			' TODO Запросить интерфейс вместо конвертирования указателя
			WriteHttpForbidden(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), pIWebSite)
			
		Case Else
			' TODO Запросить интерфейс вместо конвертирования указателя
			WriteHttpInternalServerError(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), pIWebSite)
			
	End Select
	
	INetworkStream_Release(pINetworkStream)
	IServerResponse_Release(pIResponse)
	
End Sub

Sub ProcessEndWriteError( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal hrEndProcess As HRESULT _
	)
	
End Sub

Function PrepareRequestResponse( _
		ByVal hIoCompletionPort As HANDLE, _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	
	Dim hrResult As HRESULT = S_OK
	
	Dim pIRequest As IClientRequest Ptr = Any
	IClientContext_GetClientRequest(pIContext, @pIRequest)
	
	hrResult = IClientRequest_Prepare(pIRequest)
	If FAILED(hrResult) Then
		ProcessEndReadError(pIContext, pIRequest, hrResult)
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
			pHeaderHost = ClientURI.pUrl
		Else
			IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderHost, @pHeaderHost)
		End If
		
		Dim HttpVersion As HttpVersions = Any
		IClientRequest_GetHttpVersion(pIRequest, @HttpVersion)
		IServerResponse_SetHttpVersion(pIResponse, HttpVersion)
		
		Dim HeaderHostLength As Integer = lstrlenW(pHeaderHost)
		If HeaderHostLength = 0 AndAlso HttpVersion = HttpVersions.Http11 Then
			ProcessDataError(pIContext, pIRequest, DataError.HostNotFound, NULL)
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
				ProcessDataError(pIContext, pIRequest, DataError.SiteNotFound, NULL)
				hrResult = E_FAIL
			Else
				
				Dim IsSiteMoved As Boolean = Any
				' TODO Грязный хак с robots.txt
				Dim IsRobotsTxt As Integer = lstrcmpiW(ClientURI.pUrl, WStr("/robots.txt"))
				If IsRobotsTxt = 0 Then
					IsSiteMoved = False
				Else
					IWebSite_GetIsMoved(pIWebSite, @IsSiteMoved)
				End If
				
				If IsSiteMoved Then
					' Сайт перемещён на другой ресурс
					' если запрошен документ /robots.txt то не перенаправлять
					ProcessDataError(pIContext, pIRequest, DataError.MovedPermanently, pIWebSite)
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
						ProcessDataError(pIContext, pIRequest, DataError.HttpMethodNotSupported, pIWebSite)
						hrResult = E_FAIL
					Else
						If FAILED(hrCreateRequestProcessor) Then
							ProcessDataError(pIContext, pIRequest, DataError.NotEnoughMemory, pIWebSite)
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
								ProcessDataError(pIContext, pIRequest, DataError.NotEnoughMemory, pIWebSite)
								hrResult = E_FAIL
							Else
								IClientContext_SetRequestedFile(pIContext, pIFile)
								
								Dim hrGetFile As HRESULT = IWebSite_OpenRequestedFile( _
									pIWebSite, _
									pIFile, _
									@ClientURI.Path, _
									RequestedFileAccess _
								)
								If FAILED(hrGetFile) Then
									ProcessDataError(pIContext, pIRequest, DataError.NotEnoughMemory, pIWebSite)
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
										ProcessBeginWriteError(pIContext, pIRequest, hrPrepare, pIWebSite)
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
											ProcessBeginWriteError(pIContext, pIRequest, hrBeginProcess, pIWebSite)
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
		ByVal hIoCompletionPort As HANDLE, _
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
			DebugPrintHttpReader(pIHttpReader2)
			IHttpReader_Release(pIHttpReader2)
			
			ProcessEndReadError(pIContext, pIRequest, hrEndReadRequest)
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
				ProcessBeginReadError(pIContext, pIRequest, hrBeginReadRequest)
				hrResult = hrBeginReadRequest
			End If
			
			IClientRequest_Release(pIRequest)
			
		Case S_FALSE
			' Клиент закрыл соединение
			Dim pIHttpReader2 As IHttpReader Ptr = Any
			IClientContext_GetHttpReader(pIContext, @pIHttpReader2)
			DebugPrintHttpReader(pIHttpReader2)
			IHttpReader_Release(pIHttpReader2)
			
			hrResult = E_FAIL
			
		Case S_OK
			Dim pIHttpReader2 As IHttpReader Ptr = Any
			IClientContext_GetHttpReader(pIContext, @pIHttpReader2)
			DebugPrintHttpReader(pIHttpReader2)
			IHttpReader_Release(pIHttpReader2)
			
			' Dim pIMemoryAllocator As IMalloc Ptr = Any
			' IClientContext_GetMemoryAllocator(pIContext, @pIMemoryAllocator)
			
			' Dim pINewAsyncResult As IMutableAsyncResult Ptr = Any
			' Dim hr As HRESULT = CreateInstance( _
				' pIMemoryAllocator, _
				' @CLSID_ASYNCRESULT, _
				' @IID_IMutableAsyncResult, _
				' @pINewAsyncResult _
			' )
			' IMalloc_Release(pIMemoryAllocator)
			
			' If FAILED(hr) Then
				' ProcessBeginReadError(pIContext, pIRequest, DataError.NotEnoughMemory)
				' hrResult = hr
			' Else
				hrResult = PrepareRequestResponse( _
					hIoCompletionPort, _
					pIContext, _
					pIAsyncResult, _
					pIWebSites _
				)
				
			' End If
			
	End Select
	
	Return hrResult
	
End Function

Function WriteResponse( _
		ByVal hIoCompletionPort As HANDLE, _
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
			ProcessEndWriteError(pIContext, pIRequest, hrEndProcess)
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
				ProcessBeginWriteError(pIContext, pIRequest, hrBeginProcess, pIWebSite)
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
				' IClientContext_SetRequestProcessor(pIContext, NULL)
				' IClientContext_SetRequestedFile(pIContext, NULL)
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
					ProcessBeginReadError(pIContext, pIRequest, hrBeginReadRequest)
					hrResult = E_FAIL
				End If
				
			Else
				hrResult = E_FAIL
			End If
			
	End Select
	
	IClientRequest_Release(pIRequest)
	
	Return hrResult
	
End Function

Function ProcessCloseOperation( _
		ByVal hIoCompletionPort As HANDLE, _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	
	' Dim hClientContextHeap As HANDLE = Any
	' IClientContext_GetClientContextHeap(pIContext, @hClientContextHeap)
	
	IClientContext_Release(pIContext)
	IAsyncResult_Release(pIAsyncResult)
	
	' HeapDestroy(hClientContextHeap)
	
	Return S_FALSE
	
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
			DebugPrintDWORD(WStr(!"GetQueuedCompletionStatus Error\t"), GetLastError())
			' If dwError = ERROR_ABANDONED_WAIT_0 Then
				' Exit Do
			' End If
			If pOverlapped = NULL Then
				Exit Do
			End If
			
			' TODO Запросить интерфейс вместо конвертирования указателя
			' If BytesTransferred = 0 Then
			' End If
			' Dim pIContext As IClientContext Ptr = Any
			' IAsyncResult_GetAsyncState(pOverlapped->pIAsync, CPtr(IUnknown Ptr Ptr, @pIContext))
			
			' Dim hClientContextHeap As HANDLE = Any
			' IClientContext_GetClientContextHeap(pIContext, @hClientContextHeap)
			
			' IClientContext_Release(pIContext)
			' IAsyncResult_Release(pOverlapped->pIAsync)
			
			' HeapDestroy(hClientContextHeap)
			res = PostQueuedCompletionStatus( _
				pWorkerContext->hIOCompletionClosePort, _
				BytesTransferred, _
				CompletionKey, _
				CPtr(LPOVERLAPPED, pOverlapped) _
			)
			If res = 0 Then
				DebugPrintDWORD(WStr(!"Error to Post CloserCompletionPort\t"), GetLastError())
			End If
			
		Else
			DebugPrintDWORD(WStr(!"\t\t\tBytesTransferred\t"), BytesTransferred)
			
			If BytesTransferred <> 0 Then
				Dim pIContext As IClientContext Ptr = Any
				' TODO Запросить интерфейс вместо конвертирования указателя
				IAsyncResult_GetAsyncState(pOverlapped->pIAsync, CPtr(IUnknown Ptr Ptr, @pIContext))
				
				Dim OpCode As OperationCodes = Any
				IClientContext_GetOperationCode(pIContext, @OpCode)
				
				' Dim hrProcess As HRESULT = S_OK
				
				Select Case OpCode
					
					Case OperationCodes.ReadRequest
						' hrProcess = ReadRequest( _
						ReadRequest( _
							pWorkerContext->hIOCompletionPort, _
							pIContext, _
							pOverlapped->pIAsync, _
							pWorkerContext->pIWebSites _
						)
						
					' Case OperationCodes.PrepareResponse
						' hrProcess = PrepareRequestResponse( _
						' PrepareRequestResponse( _
							' pWorkerContext->hIOCompletionPort, _
							' pIContext, _
							' pOverlapped->pIAsync, _
							' pWorkerContext->pIWebSites _
						' )
						
					Case OperationCodes.WriteResponse
						' hrProcess = WriteResponse( _
						WriteResponse( _
							pWorkerContext->hIOCompletionPort, _
							pIContext, _
							pOverlapped->pIAsync, _
							pWorkerContext->pIWebSites _
						)
						
					Case OperationCodes.OpClose
						' hrProcess = ProcessCloseOperation( _
						ProcessCloseOperation( _
							pWorkerContext->hIOCompletionPort, _
							pIContext, _
							pOverlapped->pIAsync _
						)
						
				End Select
				
				IClientContext_Release(pIContext)
				IAsyncResult_Release(pOverlapped->pIAsync)
				
				' If FAILED(hrProcess) Then
					' res = PostQueuedCompletionStatus( _
						' pWorkerContext->hIOCompletionClosePort, _
						' BytesTransferred, _
						' CompletionKey, _
						' CPtr(LPOVERLAPPED, pOverlapped) _
					' )
					' If res = 0 Then
						' Dim dwError As DWORD = GetLastError()
						' #ifndef WINDOWS_SERVICE
							' DebugPrint(!"Error to Post CloserCompletionPort\t", dwError)
						' #endif
					' End If
				' End If
				
			Else
				
				' Dim pIContext As IClientContext Ptr = Any
				' TODO Запросить интерфейс вместо конвертирования указателя
				' IAsyncResult_GetAsyncState(pOverlapped->pIAsync, CPtr(IUnknown Ptr Ptr, @pIContext))
				' Scope
					' Dim pINetworkStream As INetworkStream Ptr = Any
					' IClientContext_GetNetworkStream(pIContext, @pINetworkStream)
					
					' INetworkStream_Close(pINetworkStream)
					' INetworkStream_Release(pINetworkStream)
				' End Scope
				' IClientContext_Release(pIContext)
				
				res = PostQueuedCompletionStatus( _
					pWorkerContext->hIOCompletionClosePort, _
					BytesTransferred, _
					CompletionKey, _
					CPtr(LPOVERLAPPED, pOverlapped) _
				)
				If res = 0 Then
					DebugPrintDWORD(WStr(!"Error to Post CloserCompletionPort\t"), GetLastError())
				End If
				
			End If
			
		End If
		
	Loop
	
	CloseHandle(pWorkerContext->hThread)
	IWebSiteCollection_Release(pWorkerContext->pIWebSites)
	CoTaskMemFree(pWorkerContext)
	
	Return 0
	
End Function

Function CloserThread( _
		ByVal lpParam As LPVOID _
	)As DWORD
	
	Dim pCloserContext As CloserThreadContext Ptr = CPtr(CloserThreadContext Ptr, lpParam)
	
	' TODO Удалять контексты из списка все что старше трёх секунд пачками
	Do
		
		Dim BytesTransferred As DWORD = Any
		Dim CompletionKey As ULONG_PTR = Any
		Dim pOverlapped As LPASYNCRESULTOVERLAPPED = Any
		
		Dim res As Integer = GetQueuedCompletionStatus( _
			pCloserContext->hIOCompletionClosePort, _
			@BytesTransferred, _
			@CompletionKey, _
			CPtr(LPOVERLAPPED Ptr, @pOverlapped), _
			INFINITE _
		)
		If res = 0 Then
			' TODO Обработать ошибку
			DebugPrintDWORD(WStr(!"GetQueuedCompletionStatus CloserThread Error\t"), GetLastError())
			If pOverlapped = NULL Then
				Exit Do
			End If
			
		Else
			
			' TODO Запросить интерфейс вместо конвертирования указателя
			' Dim pIContext As IClientContext Ptr = Any
			' IAsyncResult_GetAsyncState(pOverlapped->pIAsync, CPtr(IUnknown Ptr Ptr, @pIContext))
			' IClientContext_Release(pIContext)
			
			Const dwSleepTime As DWORD = 3000
			Sleep_(dwSleepTime)
			IAsyncResult_Release(pOverlapped->pIAsync)
		End If
		
	Loop
	
	CloseHandle(pCloserContext->hThread)
	CoTaskMemFree(pCloserContext)
	
	Return 0
	
End Function
