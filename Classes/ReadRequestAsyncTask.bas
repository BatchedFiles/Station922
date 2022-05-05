#include once "ReadRequestAsyncTask.bi"
#include once "ClientRequest.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "INetworkStream.bi"
#include once "Logger.bi"
#include once "WriteErrorAsyncTask.bi"
#include once "WriteResponseAsyncTask.bi"

Extern GlobalReadRequestAsyncIoTaskVirtualTable As Const IReadRequestAsyncIoTaskVirtualTable

Type _ReadRequestAsyncTask
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IReadRequestAsyncIoTaskVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	pIWebSites As IWebSiteCollection Ptr
	pIProcessors As IHttpProcessorCollection Ptr
	pIStream As IBaseStream Ptr
	pIHttpReader As IHttpReader Ptr
	pIRequest As IClientRequest Ptr
End Type

Function ProcessReadError( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal hrReadError As HRESULT _
	)As HRESULT
	
	' Создать и запустить задачу подготовки ответа ошибки
	Dim pTask As IWriteErrorAsyncIoTask Ptr = Any
	Dim hrCreateTask As HRESULT = CreateInstance( _
		this->pIMemoryAllocator, _
		@CLSID_WRITEERRORASYNCTASK, _
		@IID_IWriteErrorAsyncIoTask, _
		@pTask _
	)
	If FAILED(hrCreateTask) Then
		Return hrCreateTask
	End If
	
	Dim HttpError As ResponseErrorCode = Any
	
	Select Case hrReadError
		
		Case E_OUTOFMEMORY
			HttpError = ResponseErrorCode.NotEnoughMemory
			
		Case CLIENTREQUEST_E_HTTPVERSIONNOTSUPPORTED
			HttpError = ResponseErrorCode.VersionNotSupported
			
		Case CLIENTREQUEST_E_BADREQUEST
			HttpError = ResponseErrorCode.BadRequest
			
		Case CLIENTREQUEST_E_BADPATH
			HttpError = ResponseErrorCode.PathNotValid
			
		Case CLIENTREQUEST_E_EMPTYREQUEST
			HttpError = ResponseErrorCode.BadRequest
			
		Case CLIENTREQUEST_E_SOCKETERROR
			HttpError = ResponseErrorCode.BadRequest
			
		Case CLIENTREQUEST_E_URITOOLARGE
			HttpError = ResponseErrorCode.RequestUrlTooLarge
			
		Case CLIENTREQUEST_E_HEADERFIELDSTOOLARGE
			HttpError = ResponseErrorCode.RequestHeaderFieldsTooLarge
			
		Case Else
			HttpError = ResponseErrorCode.InternalServerError
			
	End Select
	
	If HttpError < ResponseErrorCode.InternalServerError Then
		IWriteErrorAsyncIoTask_SetHttpReader(pTask, this->pIHttpReader)
		IWriteErrorAsyncIoTask_SetClientRequest(pTask, this->pIRequest)
		IWriteErrorAsyncIoTask_SetWebSiteCollection(pTask, this->pIWebSites)
		IWriteErrorAsyncIoTask_SetHttpProcessorCollection(pTask, this->pIProcessors)
	End If
	
	IWriteErrorAsyncIoTask_SetBaseStream(pTask, this->pIStream)
	IWriteErrorAsyncIoTask_SetErrorCode(pTask, HttpError, hrReadError)
	
	Dim pIResult As IAsyncResult Ptr = Any
	Dim hrBeginExecute As HRESULT = IWriteErrorAsyncIoTask_BeginExecute( _
		pTask, _
		@pIResult _
	)
	If FAILED(hrBeginExecute) Then
		Dim vtSCode As VARIANT = Any
		vtSCode.vt = VT_ERROR
		vtSCode.scode = hrBeginExecute
		LogWriteEntry( _
			LogEntryType.Error, _
			WStr(!"IWriteErrorAsyncTask_BeginExecute Error\t"), _
			@vtSCode _
		)
		
		' TODO Отправить клиенту Не могу начать асинхронное чтение
		IWriteErrorAsyncIoTask_Release(pTask)
		Return hrBeginExecute
	End If
	
	Return S_OK
	
End Function

Sub InitializeReadRequestAsyncTask( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory(@this->IdString, @Str("ReadRequest_Task"), 16)
	#endif
	this->lpVtbl = @GlobalReadRequestAsyncIoTaskVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIWebSites = NULL
	this->pIProcessors = NULL
	this->pIStream = NULL
	this->pIHttpReader = NULL
	this->pIRequest = pIRequest
	
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
	
	If this->pIStream <> NULL Then
		IBaseStream_Release(this->pIStream)
	End If
	
	If this->pIProcessors <> NULL Then
		IHttpProcessorCollection_Release(this->pIProcessors)
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
	
	If IsEqualIID(@IID_IReadRequestAsyncIoTask, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IHttpAsyncIoTask, riid) Then
			*ppv = @this->lpVtbl
		Else
			If IsEqualIID(@IID_IAsyncIoTask, riid) Then
				*ppv = @this->lpVtbl
			Else
				If IsEqualIID(@IID_IUnknown, riid) Then
					*ppv = @this->lpVtbl
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
	
	#ifdef __FB_64BIT__
		InterlockedIncrement64(@this->ReferenceCounter)
	#else
		InterlockedIncrement(@this->ReferenceCounter)
	#endif
	
	Return 1
	
End Function

Function ReadRequestAsyncTaskRelease( _
		ByVal this As ReadRequestAsyncTask Ptr _
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
	
	DestroyReadRequestAsyncTask(this)
	
	Return 0
	
End Function

Function ReadRequestAsyncTaskBeginExecute( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	' TODO Запросить интерфейс вместо конвертирования указателя
	Dim hrBeginReadRequest As HRESULT = IClientRequest_BeginReadRequest( _
		this->pIRequest, _
		CPtr(IUnknown Ptr, @this->lpVtbl), _
		ppIResult _
	)
	If FAILED(hrBeginReadRequest) Then
		Return hrBeginReadRequest
	End If
	
	' Ссылка на this сохранена в pIAsyncResult
	' Ссылка на pIAsyncResult сохранена в унаследованной от OVERLAPPED структуре
	' Ссылку на OVERLAPPED возвратит функция GetQueuedCompletionStatus бассейну потоков
	
	Return ASYNCTASK_S_IO_PENDING
	
End Function

Function ReadRequestAsyncTaskEndExecute( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD _
	)As HRESULT
	
	Dim hrEndReadRequest As HRESULT = IClientRequest_EndReadRequest( _
		this->pIRequest, _
		pIResult _
	)
	If FAILED(hrEndReadRequest) Then
		
		Dim hrProcessReadError As HRESULT = ProcessReadError( _
			this, _
			hrEndReadRequest _
		)
		
		Return hrProcessReadError
	End If
	
	Select Case hrEndReadRequest
		
		Case S_OK
			
			Dim hrPrepare As HRESULT = IClientRequest_Prepare(this->pIRequest)
			If FAILED(hrPrepare) Then
				Dim vtSCode As VARIANT = Any
				vtSCode.vt = VT_ERROR
				vtSCode.scode = hrPrepare
				LogWriteEntry( _
					LogEntryType.Error, _
					WStr(!"IClientRequest_Prepare Error\t"), _
					@vtSCode _
				)
				
				Dim hrProcessReadError As HRESULT = ProcessReadError( _
					this, _
					hrPrepare _
				)
				
				Return hrProcessReadError
			End If
			
	/'
	' IHttpWriter_Clear(pIHttpWriter)
	
	Scope
		Dim KeepAlive As Boolean = True
		IClientRequest_GetKeepAlive(this->pIRequest, @KeepAlive)
		IServerResponse_SetKeepAlive(this->pIResponse, KeepAlive)
	End Scope
	
	Dim HttpMethod As HeapBSTR = Any
	IClientRequest_GetHttpMethod(pIRequest, @HttpMethod)
	
	Dim ClientURI As IClientUri Ptr = Any
	IClientRequest_GetUri(pIRequest, @ClientURI)
	
	' TODO Найти правильный заголовок Host в зависимости от версии 1.0 или 1.1
	Dim HeaderHost As HeapBSTR = Any
	If HttpMethod = HttpMethods.HttpConnect Then
		' pHeaderHost = ClientURI.Authority.Host
		IClientUri_GetHost(ClientURI, HeaderHost)
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
	Return S_OK
	'/
			Dim pTask As IWriteResponseAsyncIoTask Ptr = Any
			Dim hrCreateTask As HRESULT = CreateInstance( _
				this->pIMemoryAllocator, _
				@CLSID_WRITERESPONSEASYNCTASK, _
				@IID_IWriteResponseAsyncIoTask, _
				@pTask _
			)
			If FAILED(hrCreateTask) Then
				Dim hrProcessReadError As HRESULT = ProcessReadError( _
					this, _
					hrCreateTask _
				)
				
				Return hrProcessReadError
			End If
			
			IWriteResponseAsyncIoTask_SetWebSiteCollection(pTask, this->pIWebSites)
			IWriteResponseAsyncIoTask_SetBaseStream(pTask, this->pIStream)
			IWriteResponseAsyncIoTask_SetHttpReader(pTask, this->pIHttpReader)
			IWriteResponseAsyncIoTask_SetHttpProcessorCollection(pTask, this->pIProcessors)
			IWriteResponseAsyncIoTask_SetClientRequest(pTask, this->pIRequest)
			
			Dim pIResult As IAsyncResult Ptr = Any
			Dim hrBeginExecute As HRESULT = IWriteResponseAsyncIoTask_BeginExecute( _
				pTask, _
				@pIResult _
			)
			If FAILED(hrBeginExecute) Then
				Dim vtSCode As VARIANT = Any
				vtSCode.vt = VT_ERROR
				vtSCode.scode = hrBeginExecute
				LogWriteEntry( _
					LogEntryType.Error, _
					WStr(!"IWriteResponseAsyncTask_BeginExecute Error\t"), _
					@vtSCode _
				)
				
				' TODO Отправить клиенту Не могу начать асинхронное чтение
				IWriteResponseAsyncIoTask_Release(pTask)
				Return hrBeginExecute
			End If
			
			Return S_OK
			
		Case S_FALSE
			' Received 0 bytes
			' TODO Вывести байты запроса в лог
			' DebugPrintHttpReader(pIHttpReader)
			
			Return S_FALSE
			
		Case CLIENTREQUEST_S_IO_PENDING
			ReadRequestAsyncTaskAddRef(this)
			
			Dim pIAsyncResult As IAsyncResult Ptr = Any
			Dim hrBeginReadRequest As HRESULT = IClientRequest_BeginReadRequest( _
				this->pIRequest, _
				CPtr(IUnknown Ptr, @this->lpVtbl), _
				@pIAsyncResult _
			)
			If FAILED(hrBeginReadRequest) Then
				ReadRequestAsyncTaskRelease(this)
				Return hrBeginReadRequest
			End If
			
			' Ссылка на this сохранена в pIAsyncResult
			' Ссылка на pIAsyncResult сохранена в унаследованной от OVERLAPPED структуре
			' Ссылку на OVERLAPPED возвратит функция GetQueuedCompletionStatus бассейну потоков
			
			Return ASYNCTASK_S_IO_PENDING
			
	End Select
	
End Function

Function ReadRequestAsyncTaskGetFileHandle( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pFileHandle As HANDLE Ptr _
	)As HRESULT
	
	Dim ns As INetworkStream Ptr = Any
	IBaseStream_QueryInterface(this->pIStream, @IID_INetworkStream, @ns)
	
	Dim s As SOCKET = Any
	INetworkStream_GetSocket(ns, @s)
	
	*pFileHandle = Cast(HANDLE, s)
	
	INetworkStream_Release(ns)
	
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

Function ReadRequestAsyncTaskGetBaseStream( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	
	If this->pIStream <> NULL Then
		IBaseStream_AddRef(this->pIStream)
	End If
	
	*ppStream = this->pIStream
	
	Return S_OK
	
End Function

Function ReadRequestAsyncTaskSetBaseStream( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pStream As IBaseStream Ptr _
	)As HRESULT
	
	If this->pIStream <> NULL Then
		IBaseStream_Release(this->pIStream)
	End If
	
	If pStream <> NULL Then
		IBaseStream_AddRef(pStream)
	End If
	
	this->pIStream = pStream
	
	Return S_OK
	
End Function

Function ReadRequestAsyncTaskGetHttpReader( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	If this->pIHttpReader <> NULL Then
		IHttpReader_AddRef(this->pIHttpReader)
	End If
	
	*ppReader = this->pIHttpReader
	
	Return S_OK
	
End Function

Function ReadRequestAsyncTaskSetHttpReader( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	
	If this->pIHttpReader <> NULL Then
		IHttpReader_Release(this->pIHttpReader)
	End If
	
	If pReader <> NULL Then
		IHttpReader_AddRef(pReader)
	End If
	
	this->pIHttpReader = pReader
	
	' TODO Запросить интерфейс вместо конвертирования указателя
	IClientRequest_SetTextReader( _
		this->pIRequest, _
		CPtr(ITextReader Ptr, this->pIHttpReader) _
	)
	
	Return S_OK
	
End Function

Function ReadRequestAsyncTaskGetHttpProcessorCollection( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	
	If this->pIProcessors <> NULL Then
		IHttpReader_AddRef(this->pIProcessors)
	End If
	
	*ppIProcessors = this->pIProcessors
	
	Return S_OK
	
End Function

Function ReadRequestAsyncTaskSetHttpProcessorCollection( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pIProcessors As IHttpProcessorCollection Ptr _
	)As HRESULT
	
	If this->pIProcessors <> NULL Then
		IBaseStream_Release(this->pIProcessors)
	End If
	
	If pIProcessors <> NULL Then
		IBaseStream_AddRef(pIProcessors)
	End If
	
	this->pIProcessors = pIProcessors
	
	Return S_OK
	
End Function


Function IReadRequestAsyncTaskQueryInterface( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskQueryInterface(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), riid, ppv)
End Function

Function IReadRequestAsyncTaskAddRef( _
		ByVal this As IReadRequestAsyncIoTask Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskAddRef(ContainerOf(this, ReadRequestAsyncTask, lpVtbl))
End Function

Function IReadRequestAsyncTaskRelease( _
		ByVal this As IReadRequestAsyncIoTask Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskRelease(ContainerOf(this, ReadRequestAsyncTask, lpVtbl))
End Function

Function IReadRequestAsyncTaskBeginExecute( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskBeginExecute(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), ppIResult)
End Function

Function IReadRequestAsyncTaskEndExecute( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD _
	)As ULONG
	Return ReadRequestAsyncTaskEndExecute(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pIResult, BytesTransferred)
End Function

Function IReadRequestAsyncIoTaskGetFileHandle( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal pFileHandle As HANDLE Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskGetFileHandle(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pFileHandle)
End Function

Function IReadRequestAsyncTaskGetWebSiteCollection( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskGetWebSiteCollection(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), ppIWebSites)
End Function

Function IReadRequestAsyncTaskSetWebSiteCollection( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskSetWebSiteCollection(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pIWebSites)
End Function

Function IReadRequestAsyncTaskGetBaseStream( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskGetBaseStream(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), ppStream)
End Function

Function IReadRequestAsyncTaskSetBaseStream( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		byVal pStream As IBaseStream Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskSetBaseStream(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pStream)
End Function

Function IReadRequestAsyncTaskGetHttpReader( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskGetHttpReader(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), ppReader)
End Function

Function IReadRequestAsyncTaskSetHttpReader( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskSetHttpReader(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pReader)
End Function

Function IReadRequestAsyncTaskGetHttpProcessorCollection( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskGetHttpProcessorCollection(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), ppIProcessors)
End Function

Function IReadRequestAsyncTaskSetHttpProcessorCollection( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal pIProcessors As IHttpProcessorCollection Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskSetHttpProcessorCollection(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pIProcessors)
End Function

Dim GlobalReadRequestAsyncIoTaskVirtualTable As Const IReadRequestAsyncIoTaskVirtualTable = Type( _
	@IReadRequestAsyncTaskQueryInterface, _
	@IReadRequestAsyncTaskAddRef, _
	@IReadRequestAsyncTaskRelease, _
	@IReadRequestAsyncTaskBeginExecute, _
	@IReadRequestAsyncTaskEndExecute, _
	@IReadRequestAsyncIoTaskGetFileHandle, _
	@IReadRequestAsyncTaskGetWebSiteCollection, _
	@IReadRequestAsyncTaskSetWebSiteCollection, _
	@IReadRequestAsyncTaskGetBaseStream, _
	@IReadRequestAsyncTaskSetBaseStream, _
	@IReadRequestAsyncTaskGetHttpReader, _
	@IReadRequestAsyncTaskSetHttpReader, _
	@IReadRequestAsyncTaskGetHttpProcessorCollection, _
	@IReadRequestAsyncTaskSetHttpProcessorCollection _
)
