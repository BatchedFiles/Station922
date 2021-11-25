#include once "ReadRequestAsyncTask.bi"
#include once "ClientRequest.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "HeapMemoryAllocator.bi"
#include once "HttpReader.bi"
#include once "ICloneable.bi"
#include once "Logger.bi"
#include once "Network.bi"
#include once "NetworkStream.bi"

Extern GlobalReadRequestAsyncTaskVirtualTable As Const IReadRequestAsyncTaskVirtualTable
Extern GlobalReadRequestAsyncTaskCloneableVirtualTable As Const ICloneableVirtualTable

Type _ReadRequestAsyncTask
	lpVtbl As Const IReadRequestAsyncTaskVirtualTable Ptr
	lpCloneableVtbl As Const ICloneableVirtualTable Ptr
	crSection As CRITICAL_SECTION
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	pIWebSites As IWebSiteCollection Ptr
	ClientSocket As SOCKET
	RemoteAddress As SOCKADDR_STORAGE
	RemoteAddressLength As Integer
	pINetworkStream As INetworkStream Ptr
	pIHttpReader As IHttpReader Ptr
	pIRequest As IClientRequest Ptr
	Associated As Boolean
End Type

/'
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
'/

Function AssociateWithIOCP( _
		ByVal pPool As IThreadPool Ptr, _
		ByVal ClientSocket As SOCKET, _
		ByVal CompletionKey As ULONG_PTR _
	)As HRESULT
	
	Dim hIOCompletionPort As HANDLE = Any
	IThreadPool_GetCompletionPort(pPool, @hIOCompletionPort)
	
	Dim hPort As HANDLE = CreateIoCompletionPort( _
		Cast(HANDLE, ClientSocket), _
		hIOCompletionPort, _
		CompletionKey, _
		0 _
	)
	If hPort = NULL Then
		Dim dwError As DWORD = GetLastError()
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Return S_OK
	
End Function

Sub InitializeReadRequestAsyncTask( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pINetworkStream As INetworkStream Ptr, _
		ByVal pIHttpReader As IHttpReader Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)
	
	this->lpVtbl = @GlobalReadRequestAsyncTaskVirtualTable
	this->lpCloneableVtbl = @GlobalReadRequestAsyncTaskCloneableVirtualTable
	this->ReferenceCounter = 0
	
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIWebSites = NULL
	this->ClientSocket = INVALID_SOCKET
	ZeroMemory(@this->RemoteAddress, SizeOf(SOCKADDR_STORAGE))
	this->RemoteAddressLength = 0
	this->pINetworkStream = pINetworkStream
	this->pIHttpReader = pIHttpReader
	this->pIRequest = pIRequest
	this->Associated = False
	' TODO Запросить интерфейс вместо конвертирования указателя
	IHttpReader_SetBaseStream( _
		pIHttpReader, _
		CPtr(IBaseStream Ptr, pINetworkStream) _
	)
	' TODO Запросить интерфейс вместо конвертирования указателя
	IClientRequest_SetTextReader( _
		pIRequest, _
		CPtr(ITextReader Ptr, pIHttpReader) _
	)
	
End Sub

Sub InitializeCloneReadRequestAsyncTask( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pINetworkStream As INetworkStream Ptr, _
		ByVal pIHttpReader As IHttpReader Ptr, _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pWebSites As IWebSiteCollection Ptr, _
		ByVal ClientSocket As SOCKET, _
		ByVal RemoteAddress As SOCKADDR Ptr, _
		ByVal RemoteAddressLength As Integer, _
		ByVal Associated As Boolean _
	)
	
	this->lpVtbl = @GlobalReadRequestAsyncTaskVirtualTable
	this->lpCloneableVtbl = @GlobalReadRequestAsyncTaskCloneableVirtualTable
	this->ReferenceCounter = 0
	
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	
	IWebSiteCollection_AddRef(pWebSites)
	this->pIWebSites = pWebSites
	
	this->ClientSocket = ClientSocket
	
	this->RemoteAddressLength = RemoteAddressLength
	CopyMemory(@this->RemoteAddress, RemoteAddress, RemoteAddressLength)
	
	this->pINetworkStream = pINetworkStream
	this->pIHttpReader = pIHttpReader
	this->pIRequest = pIRequest
	this->Associated = Associated
	' TODO Запросить интерфейс вместо конвертирования указателя
	IHttpReader_SetBaseStream( _
		pIHttpReader, _
		CPtr(IBaseStream Ptr, pINetworkStream) _
	)
	' TODO Запросить интерфейс вместо конвертирования указателя
	IClientRequest_SetTextReader( _
		pIRequest, _
		CPtr(ITextReader Ptr, pIHttpReader) _
	)
	
End Sub

Sub UnInitializeReadRequestAsyncTask( _
		ByVal this As ReadRequestAsyncTask Ptr _
	)
	
	If this->pIRequest <> NULL Then
		IClientRequest_Release(this->pIRequest)
	End If
	
	If this->pIHttpReader <> NULL Then
		IHttpReader_Release(this->pIHttpReader)
	End If
	
	If this->pINetworkStream <> NULL Then
		INetworkStream_Release(this->pINetworkStream)
	End If
	
	If this->pIWebSites <> NULL Then
		IWebSiteCollection_Release(this->pIWebSites)
	End If
	
	IMalloc_Release(this->pIMemoryAllocator)
	
End Sub

Function CreateReadRequestAsyncTask( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As ReadRequestAsyncTask Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(ReadRequestAsyncTask)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"ReadRequestAsyncTask creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim pINetworkStream As INetworkStream Ptr = Any
	Dim hrCreateNetworkStream As HRESULT = CreateInstance( _
		pIMemoryAllocator, _
		@CLSID_NETWORKSTREAM, _
		@IID_INetworkStream, _
		@pINetworkStream _
	)
	
	If SUCCEEDED(hrCreateNetworkStream) Then
		Dim pIHttpReader As IHttpReader Ptr = Any
		Dim hrCreateHttpReader As HRESULT = CreateInstance( _
			pIMemoryAllocator, _
			@CLSID_HTTPREADER, _
			@IID_IHttpReader, _
			@pIHttpReader _
		)
		
		If SUCCEEDED(hrCreateHttpReader) Then
			Dim pIRequest As IClientRequest Ptr = Any
			Dim hrCreateRequest As HRESULT = CreateInstance( _
				pIMemoryAllocator, _
				@CLSID_CLIENTREQUEST, _
				@IID_IClientRequest, _
				@pIRequest _
			)
			
			If SUCCEEDED(hrCreateRequest) Then
				Dim this As ReadRequestAsyncTask Ptr = IMalloc_Alloc( _
					pIMemoryAllocator, _
					SizeOf(ReadRequestAsyncTask) _
				)
				
				If this <> NULL Then
					InitializeReadRequestAsyncTask( _
						this, _
						pIMemoryAllocator, _
						pINetworkStream, _
						pIHttpReader, _
						pIRequest _
					)
					
					#if __FB_DEBUG__
					Scope
						Dim vtEmpty As VARIANT = Any
						VariantInit(@vtEmpty)
						LogWriteEntry( _
							LogEntryType.Debug, _
							WStr("ReadRequestAsyncTask created"), _
							@vtEmpty _
						)
					End Scope
					#endif
					
					Return this
				End If
				
				IClientRequest_Release(pIRequest)
			End If
			
			IHttpReader_Release(pIHttpReader)
		End If
		
		INetworkStream_Release(pINetworkStream)
	End If
	
	Return NULL
	
End Function

Sub DestroyReadRequestAsyncTask( _
		ByVal this As ReadRequestAsyncTask Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("ReadRequestAsyncTask destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeReadRequestAsyncTask(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("ReadRequestAsyncTask destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function ReadRequestAsyncTaskQueryInterface( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IReadRequestAsyncTask, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IAsyncTask, riid) Then
			*ppv = @this->lpVtbl
		Else
			If IsEqualIID(@IID_IUnknown, riid) Then
				*ppv = @this->lpVtbl
			Else
				If IsEqualIID(@IID_ICloneable, riid) Then
					*ppv = @this->lpCloneableVtbl
				Else
					*ppv = NULL
					Return E_NOINTERFACE
				End If
			End If
		End If
	End If
	
	ReadRequestAsyncTaskAddRef(this)
	
	Return S_OK
	
End Function

Function ReadRequestAsyncTaskAddRef( _
		ByVal this As ReadRequestAsyncTask Ptr _
	)As ULONG
	
	Scope
		this->ReferenceCounter += 1
	End Scope
	
	Return this->ReferenceCounter
	
End Function

Function ReadRequestAsyncTaskRelease( _
		ByVal this As ReadRequestAsyncTask Ptr _
	)As ULONG
	
	Scope
		this->ReferenceCounter -= 1
	End Scope
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyReadRequestAsyncTask(this)
	
	Return 0
	
End Function

Function ReadRequestAsyncTaskBeginExecute( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr _
	)As HRESULT
	
	If this->Associated = False Then
		Dim hrAssociateWithIOCP As HRESULT = AssociateWithIOCP( _
			pPool, _
			this->ClientSocket, _
			Cast(ULONG_PTR, 0) _
		)
		If FAILED(hrAssociateWithIOCP) Then
			Return hrAssociateWithIOCP
		End If
	End If
	
	this->Associated = True
	
	INetworkStream_SetSocket(this->pINetworkStream, this->ClientSocket)
	
	' TODO Запросить интерфейс вместо конвертирования указателя
	Dim pIAsyncResult As IAsyncResult Ptr = Any
	Dim hrBeginReadRequest As HRESULT = IClientRequest_BeginReadRequest( _
		this->pIRequest, _
		CPtr(IUnknown Ptr, @this->lpVtbl), _
		@pIAsyncResult _
	)
	If FAILED(hrBeginReadRequest) Then
		' TODO Отправить клиенту Не могу начать асинхронное чтение
		' ProcessBeginReadError(pIContext, hrBeginReadRequest)
		Return hrBeginReadRequest
	End If
	
	' Ссылка на this сохранена в pIAsyncResult
	' Ссылка на pIAsyncResult сохранена в унаследованной от OVERLAPPED структуре
	' Ссылку на OVERLAPPED возвратит функция GetQueuedCompletionStatus бассейну потоков
	
	Return S_OK
	
End Function

Function ReadRequestAsyncTaskEndExecute( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal CompletionKey As ULONG_PTR _
	)As HRESULT
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("ReadRequestAsyncTaskEndExecute"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	Dim hrEndReadRequest As HRESULT = IClientRequest_EndReadRequest( _
		this->pIRequest, _
		pIResult _
	)
	If FAILED(hrEndReadRequest) Then
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Error, _
			WStr(!"E_FAIL"), _
			@vtEmpty _
		)
		' TODO Вывести байты запроса HttpReader в лог
		' DebugPrintHttpReader(pIHttpReader)
		
		' ProcessEndReadError(pIContext, hrEndReadRequest)
		CloseSocketConnection(this->ClientSocket)
		Return E_FAIL
	End If
	
	Select Case hrEndReadRequest
		
		Case S_OK
			/'
			
			' TODO Вывести байты запроса в лог
			' DebugPrintHttpReader(pIHttpReader)
			
			hrResult = PrepareRequestResponse( _
				pIContext, _
				pIWebSites _
			)
			'/
			
		Case S_FALSE
			' TODO Вывести байты запроса в лог
			' DebugPrintHttpReader(pIHttpReader)
			
			CloseSocketConnection(this->ClientSocket)
			
		Case CLIENTREQUEST_S_IO_PENDING
			' Создать задачу чтения
			/'
			Dim pTask As IReadRequestAsyncTask Ptr = Any
			
			Scope
				Dim pIClientMemoryAllocator As IMalloc Ptr = Any
				Dim hrCreateAllocator As HRESULT = CreateMemoryAllocatorInstance( _
					@CLSID_HEAPMEMORYALLOCATOR, _
					@IID_IMalloc, _
					@pIClientMemoryAllocator _
				)
				If FAILED(hrCreateAllocator) Then
					CloseSocketConnection(this->ClientSocket)
					Return hrCreateAllocator
				End If
				
				Dim hrClone As HRESULT = ReadRequestAsyncTaskCloneableClone( _
					this, _
					pIClientMemoryAllocator, _
					@IID_IReadRequestAsyncTask, _
					@pTask _
				)
				IF FAILED(hrClone) Then
					CloseSocketConnection(this->ClientSocket)
					IMalloc_Release(pIClientMemoryAllocator)
					Return hrClone
				End If
				
				IMalloc_Release(pIClientMemoryAllocator)
				
			End Scope
			'/
			
			' Запустить задачу
			/'
			Scope
				Dim hrBeginExecute As HRESULT = IReadRequestAsyncTask_BeginExecute( _
					pTask, _
					pPool _
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
					CloseSocketConnection(this->ClientSocket)
					IReadRequestAsyncTask_Release(pTask)
					Return hrBeginExecute
				End If
			End Scope
			'/
			Scope
				ReadRequestAsyncTaskAddRef(this)
				
				Dim pIAsyncResult As IAsyncResult Ptr = Any
				Dim hrBeginReadRequest As HRESULT = IClientRequest_BeginReadRequest( _
					this->pIRequest, _
					CPtr(IUnknown Ptr, @this->lpVtbl), _
					@pIAsyncResult _
				)
				If FAILED(hrBeginReadRequest) Then
					ReadRequestAsyncTaskRelease(this)
					
					Dim vtSCode As VARIANT = Any
					vtSCode.vt = VT_ERROR
					vtSCode.scode = hrBeginReadRequest
					LogWriteEntry( _
						LogEntryType.Error, _
						WStr(!"IClientRequest_BeginReadRequest Error\t"), _
						@vtSCode _
					)
					' TODO Отправить клиенту Не могу начать асинхронное чтение
					' ProcessBeginReadError(pIContext, hrBeginReadRequest)
					CloseSocketConnection(this->ClientSocket)
					Return hrBeginReadRequest
				End If
			End Scope
			
			' Сейчас мы не уменьшаем счётчик ссылок на pTask
			' Счётчик ссылок уменьшим в функции EndExecute
			' Когда задача будет завершена
			
	End Select
	
	Return S_OK
	
End Function

Function ReadRequestAsyncTaskGetAssociatedWithIOCP( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pAssociated As Boolean Ptr _
	)As HRESULT
	
	*pAssociated = this->Associated
	
	Return S_OK
	
End Function

Function ReadRequestAsyncTaskSetAssociatedWithIOCP( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal Associated As Boolean _
	)As HRESULT
	
	this->Associated = Associated
	
	Return S_OK
	
End Function

Function ReadRequestAsyncTaskGetSocket( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pResult As SOCKET Ptr _
	)As HRESULT
	
	*pResult = this->ClientSocket
	
	Return S_OK
	
End Function
	
Function ReadRequestAsyncTaskSetSocket( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal ClientSocket As SOCKET _
	)As HRESULT
	
	this->ClientSocket = ClientSocket
	
	Return S_OK
	
End Function

Function ReadRequestAsyncTaskGetWebSiteCollection( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	
	If this->pIWebSites <> NULL Then
		IWebSiteCollection_AddRef(this->pIWebSites)
	End If
	
	*ppIWebSites = this->pIWebSites
	
	Return S_OK
	
End Function

Function ReadRequestAsyncTaskSetWebSiteCollection( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	
	If pIWebSites <> NULL Then
		IWebSiteCollection_AddRef(pIWebSites)
	End If
	
	If this->pIWebSites <> NULL Then
		IWebSiteCollection_Release(this->pIWebSites)
	End If
	
	this->pIWebSites = pIWebSites
	
	Return S_OK
	
End Function

Function ReadRequestAsyncTaskGetRemoteAddress( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pRemoteAddress As SOCKADDR Ptr, _
		ByVal pRemoteAddressLength As Integer Ptr _
	)As HRESULT
	
	*pRemoteAddressLength = this->RemoteAddressLength
	CopyMemory(pRemoteAddress, @this->RemoteAddress, this->RemoteAddressLength)
	
	Return S_OK
	
End Function

Function ReadRequestAsyncTaskSetRemoteAddress( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal RemoteAddress As SOCKADDR Ptr, _
		ByVal RemoteAddressLength As Integer _
	)As HRESULT
	
	this->RemoteAddressLength = RemoteAddressLength
	CopyMemory(@this->RemoteAddress, RemoteAddress, RemoteAddressLength)
	
	Return S_OK
	
End Function

Function ReadRequestAsyncTaskCloneableClone( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pMalloc As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(ReadRequestAsyncTask)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"ReadRequestAsyncTask cloning\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim pNetworkStreamClone As ICloneable Ptr = Any
	INetworkStream_QueryInterface( _
		this->pINetworkStream, _
		@IID_ICloneable, _
		@pNetworkStreamClone _
	)
	Dim pINetworkStream As INetworkStream Ptr = Any
	Dim hrCreateNetworkStreamClone As HRESULT = ICloneable_Clone( _
		pNetworkStreamClone, _
		pMalloc, _
		@IID_INetworkStream, _
		@pINetworkStream _
	)
	
	ICloneable_Release(pNetworkStreamClone)
	
	If SUCCEEDED(hrCreateNetworkStreamClone) Then
		
		Dim pHttpReaderClone As ICloneable Ptr = Any
		IHttpReader_QueryInterface( _
			this->pIHttpReader, _
			@IID_ICloneable, _
			@pHttpReaderClone _
		)
		
		Dim pReader As IHttpReader Ptr = Any
		Dim hrCreateHttpReaderClone As HRESULT = ICloneable_Clone( _
			pHttpReaderClone, _
			pMalloc, _
			@IID_IHttpReader, _
			@pReader _
		)
		
		ICloneable_Release(pHttpReaderClone)
		
		If SUCCEEDED(hrCreateHttpReaderClone) Then
			
			Dim pClientRequestClone As ICloneable Ptr = Any
			IClientRequest_QueryInterface( _
				this->pIRequest, _
				@IID_ICloneable, _
				@pClientRequestClone _
			)
			
			Dim pRequest As IClientRequest Ptr = Any
			Dim hrCreateClientRequestClone As HRESULT = ICloneable_Clone( _
				pClientRequestClone, _
				pMalloc, _
				@IID_IClientRequest, _
				@pRequest _
			)
			
			If SUCCEEDED(hrCreateClientRequestClone) Then
				
				Dim pClone As ReadRequestAsyncTask Ptr = IMalloc_Alloc( _
					pMalloc, _
					SizeOf(ReadRequestAsyncTask) _
				)
				
				If pClone <> NULL Then
					
					InitializeCloneReadRequestAsyncTask( _
						pClone, _
						pMalloc, _
						pINetworkStream, _
						pReader, _
						pRequest, _
						this->pIWebSites, _
						this->ClientSocket, _
						CPtr(SOCKADDR Ptr, @this->RemoteAddress), _
						this->RemoteAddressLength, _
						this->Associated _
					)
					
					Dim hrClone As HRESULT = ReadRequestAsyncTaskQueryInterface( _
						pClone, _
						riid, _
						ppvObject _
					)
					
					If SUCCEEDED(hrClone) Then
						
						#if __FB_DEBUG__
						Scope
							Dim vtEmpty As VARIANT = Any
							VariantInit(@vtEmpty)
							LogWriteEntry( _
								LogEntryType.Debug, _
								WStr("ReadRequestAsyncTask cloned"), _
								@vtEmpty _
							)
						End Scope
						#endif
						
						Return S_OK
						
					End If
					
					*ppvObject = NULL
					IMalloc_Free(pMalloc, pClone)
					Return hrClone
				End If
				
				*ppvObject = NULL
				IClientRequest_Release(pRequest)
				Return E_OUTOFMEMORY
			End If
			
			*ppvObject = NULL
			IHttpReader_Release(pReader)
			Return hrCreateClientRequestClone
		End If
		
		*ppvObject = NULL
		INetworkStream_Release(pINetworkStream)
		Return hrCreateHttpReaderClone
	End If
	
	*ppvObject = NULL
	Return hrCreateNetworkStreamClone
	
End Function

Function IReadRequestAsyncTaskQueryInterface( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskQueryInterface(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), riid, ppv)
End Function

Function IReadRequestAsyncTaskAddRef( _
		ByVal this As IReadRequestAsyncTask Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskAddRef(ContainerOf(this, ReadRequestAsyncTask, lpVtbl))
End Function

Function IReadRequestAsyncTaskRelease( _
		ByVal this As IReadRequestAsyncTask Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskRelease(ContainerOf(this, ReadRequestAsyncTask, lpVtbl))
End Function

Function IReadRequestAsyncTaskBeginExecute( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskBeginExecute(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pPool)
End Function

Function IReadRequestAsyncTaskEndExecute( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal CompletionKey As ULONG_PTR _
	)As ULONG
	Return ReadRequestAsyncTaskEndExecute(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pPool, pIResult, BytesTransferred, CompletionKey)
End Function

Function IReadRequestAsyncTaskGetAssociatedWithIOCP( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		ByVal pAssociated As Boolean Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskGetAssociatedWithIOCP(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pAssociated)
End Function

Function IReadRequestAsyncTaskSetAssociatedWithIOCP( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		ByVal Associated As Boolean _
	)As HRESULT
	Return ReadRequestAsyncTaskSetAssociatedWithIOCP(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), Associated)
End Function

Function IReadRequestAsyncTaskGetWebSiteCollection( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskGetWebSiteCollection(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), ppIWebSites)
End Function

Function IReadRequestAsyncTaskSetWebSiteCollection( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskSetWebSiteCollection(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pIWebSites)
End Function

Function IReadRequestAsyncTaskGetSocket( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		ByVal pResult As SOCKET Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskGetSocket(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pResult)
End Function

Function IReadRequestAsyncTaskSetSocket( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		ByVal sock As SOCKET _
	)As HRESULT
	Return ReadRequestAsyncTaskSetSocket(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), sock)
End Function

Function IReadRequestAsyncTaskGetRemoteAddress( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		ByVal pRemoteAddress As SOCKADDR Ptr, _
		ByVal pRemoteAddressLength As Integer Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskGetRemoteAddress(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pRemoteAddress, pRemoteAddressLength)
End Function

Function IReadRequestAsyncTaskSetRemoteAddress( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		ByVal RemoteAddress As SOCKADDR Ptr, _
		ByVal RemoteAddressLength As Integer _
	)As HRESULT
	Return ReadRequestAsyncTaskSetRemoteAddress(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), RemoteAddress, RemoteAddressLength)
End Function

Dim GlobalReadRequestAsyncTaskVirtualTable As Const IReadRequestAsyncTaskVirtualTable = Type( _
	@IReadRequestAsyncTaskQueryInterface, _
	@IReadRequestAsyncTaskAddRef, _
	@IReadRequestAsyncTaskRelease, _
	@IReadRequestAsyncTaskBeginExecute, _
	@IReadRequestAsyncTaskEndExecute, _
	@IReadRequestAsyncTaskGetAssociatedWithIOCP, _
	@IReadRequestAsyncTaskSetAssociatedWithIOCP, _
	@IReadRequestAsyncTaskGetWebSiteCollection, _
	@IReadRequestAsyncTaskSetWebSiteCollection, _
	@IReadRequestAsyncTaskGetSocket, _
	@IReadRequestAsyncTaskSetSocket, _
	@IReadRequestAsyncTaskGetRemoteAddress, _
	@IReadRequestAsyncTaskSetRemoteAddress _
)

Function IReadRequestAsyncTaskCloneableQueryInterface( _
		ByVal this As ICloneable Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskQueryInterface(ContainerOf(this, ReadRequestAsyncTask, lpCloneableVtbl), riid, ppvObject)
End Function

Function IReadRequestAsyncTaskCloneableAddRef( _
		ByVal this As ICloneable Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskAddRef(ContainerOf(this, ReadRequestAsyncTask, lpCloneableVtbl))
End Function

Function IReadRequestAsyncTaskCloneableRelease( _
		ByVal this As ICloneable Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskRelease(ContainerOf(this, ReadRequestAsyncTask, lpCloneableVtbl))
End Function

Function IReadRequestAsyncTaskCloneableClone( _
		ByVal this As ICloneable Ptr, _
		ByVal pMalloc As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskCloneableClone(ContainerOf(this, ReadRequestAsyncTask, lpCloneableVtbl), pMalloc, riid, ppvObject)
End Function

Dim GlobalReadRequestAsyncTaskCloneableVirtualTable As Const ICloneableVirtualTable = Type( _
	@IReadRequestAsyncTaskCloneableQueryInterface, _
	@IReadRequestAsyncTaskCloneableAddRef, _
	@IReadRequestAsyncTaskCloneableRelease, _
	@IReadRequestAsyncTaskCloneableClone _
)
