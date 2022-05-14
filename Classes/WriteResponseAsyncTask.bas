#include once "WriteResponseAsyncTask.bi"
#include once "ReadRequestAsyncTask.bi"
#include once "ClientRequest.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "HeapBSTR.bi"
#include once "INetworkStream.bi"
#include once "Logger.bi"
#include once "ServerResponse.bi"
#include once "WebUtils.bi"

Extern GlobalWriteResponseAsyncIoTaskVirtualTable As Const IWriteResponseAsyncIoTaskVirtualTable

Type _WriteResponseAsyncTask
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IWriteResponseAsyncIoTaskVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	pIWebSites As IWebSiteCollection Ptr
	pIProcessors As IHttpProcessorCollection Ptr
	pIHttpReader As IHttpReader Ptr
	pIStream As IBaseStream Ptr
	pIRequest As IClientRequest Ptr
	pIResponse As IServerResponse Ptr
End Type

Sub InitializeWriteResponseAsyncTask( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pIResponse As IServerResponse Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory(@this->IdString, @Str("WriteResponseTsk"), 16)
	#endif
	this->lpVtbl = @GlobalWriteResponseAsyncIoTaskVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIWebSites = NULL
	this->pIProcessors = NULL
	this->pIHttpReader = NULL
	this->pIStream = NULL
	this->pIRequest = NULL
	this->pIResponse = pIResponse
	
End Sub

Sub UnInitializeWriteResponseAsyncTask( _
		ByVal this As WriteResponseAsyncTask Ptr _
	)
	
	If this->pIResponse <> NULL Then
		IServerResponse_Release(this->pIResponse)
	End If
	
	If this->pIRequest <> NULL Then
		IClientRequest_Release(this->pIRequest)
	End If
	
	If this->pIStream <> NULL Then
		IBaseStream_Release(this->pIStream)
	End If
	
	If this->pIHttpReader <> NULL Then
		IHttpReader_Release(this->pIHttpReader)
	End If
	
	If this->pIProcessors <> NULL Then
		IHttpProcessorCollection_Release(this->pIProcessors)
	End If
	
	If this->pIWebSites <> NULL Then
		IWebSiteCollection_Release(this->pIWebSites)
	End If
	
	IMalloc_Release(this->pIMemoryAllocator)
	
End Sub

Function CreateWriteResponseAsyncTask( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As WriteResponseAsyncTask Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(WriteResponseAsyncTask)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"WriteResponseAsyncTask creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim pIResponse As IServerResponse Ptr = Any
	Dim hrCreateRequest As HRESULT = CreateInstance( _
		pIMemoryAllocator, _
		@CLSID_SERVERRESPONSE, _
		@IID_IServerResponse, _
		@pIResponse _
	)
	
	If SUCCEEDED(hrCreateRequest) Then
		
		Dim this As WriteResponseAsyncTask Ptr = IMalloc_Alloc( _
			pIMemoryAllocator, _
			SizeOf(WriteResponseAsyncTask) _
		)
		
		If this <> NULL Then
			InitializeWriteResponseAsyncTask( _
				this, _
				pIMemoryAllocator, _
				pIResponse _
			)
			
			#if __FB_DEBUG__
			Scope
				Dim vtEmpty As VARIANT = Any
				VariantInit(@vtEmpty)
				LogWriteEntry( _
					LogEntryType.Debug, _
					WStr("WriteResponseAsyncTask created"), _
					@vtEmpty _
				)
			End Scope
			#endif
			
			Return this
		End If
		
		IServerResponse_Release(pIResponse)
	End If
	
	Return NULL
	
End Function

Sub DestroyWriteResponseAsyncTask( _
		ByVal this As WriteResponseAsyncTask Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("WriteResponseAsyncTask destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeWriteResponseAsyncTask(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("WriteResponseAsyncTask destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function WriteResponseAsyncTaskQueryInterface( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IWriteResponseAsyncIoTask, riid) Then
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
	
	WriteResponseAsyncTaskAddRef(this)
	
	Return S_OK
	
End Function

Function WriteResponseAsyncTaskAddRef( _
		ByVal this As WriteResponseAsyncTask Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		InterlockedIncrement64(@this->ReferenceCounter)
	#else
		InterlockedIncrement(@this->ReferenceCounter)
	#endif
	
	Return 1
	
End Function

Function WriteResponseAsyncTaskRelease( _
		ByVal this As WriteResponseAsyncTask Ptr _
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
	
	DestroyWriteResponseAsyncTask(this)
	
	Return 0
	
End Function

Function WriteResponseAsyncTaskBeginExecute( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Dim processor As IHttpAsyncProcessor Ptr = Any
	Dim hrProcessor As HRESULT = IHttpProcessorCollection_Item( _
		this->pIProcessors, _
		"", _
		@processor _
	)
	If FAILED(hrProcessor) Then
		Return hrProcessor
	End If
	
	IHttpAsyncProcessor_Release(processor)
	
	Return ASYNCTASK_S_IO_PENDING
	
End Function

Function WriteResponseAsyncTaskEndExecute( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
	)As HRESULT
	
	*ppNextTask = NULL
	Return E_FAIL
	
End Function

Function WriteResponseAsyncTaskGetFileHandle( _
		ByVal this As WriteResponseAsyncTask Ptr, _
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

Function WriteResponseAsyncTaskGetWebSiteCollection( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	
	If this->pIWebSites <> NULL Then
		IWebSiteCollection_AddRef(this->pIWebSites)
	End If
	
	*ppIWebSites = this->pIWebSites
	
	Return S_OK
	
End Function

Function WriteResponseAsyncTaskSetWebSiteCollection( _
		ByVal this As WriteResponseAsyncTask Ptr, _
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

Function WriteResponseAsyncTaskGetBaseStream( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	
	If this->pIStream <> NULL Then
		IBaseStream_AddRef(this->pIStream)
	End If
	
	*ppStream = this->pIStream
	
	Return S_OK
	
End Function

Function WriteResponseAsyncTaskSetBaseStream( _
		ByVal this As WriteResponseAsyncTask Ptr, _
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

Function WriteResponseAsyncTaskGetHttpReader( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	If this->pIHttpReader <> NULL Then
		IHttpReader_AddRef(this->pIHttpReader)
	End If
	
	*ppReader = this->pIHttpReader
	
	Return S_OK
	
End Function

Function WriteResponseAsyncTaskSetHttpReader( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	
	If this->pIHttpReader <> NULL Then
		IHttpReader_Release(this->pIHttpReader)
	End If
	
	If pReader <> NULL Then
		IHttpReader_AddRef(pReader)
	End If
	
	this->pIHttpReader = pReader
	
	Return S_OK
	
End Function

Function WriteResponseAsyncTaskGetHttpProcessorCollection( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	
	If this->pIProcessors <> NULL Then
		IHttpReader_AddRef(this->pIProcessors)
	End If
	
	*ppIProcessors = this->pIProcessors
	
	Return S_OK
	
End Function

Function WriteResponseAsyncTaskSetHttpProcessorCollection( _
		ByVal this As WriteResponseAsyncTask Ptr, _
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

Function WriteResponseAsyncTaskGetClientRequest( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	
	If this->pIRequest <> NULL Then
		IClientRequest_AddRef(this->pIRequest)
	End If
	
	*ppIRequest = this->pIRequest
	
	Return S_OK
	
End Function

Function WriteResponseAsyncTaskSetClientRequest( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT
	
	If pIRequest <> NULL Then
		IClientRequest_AddRef(pIRequest)
	End If
	
	If this->pIRequest <> NULL Then
		IClientRequest_Release(this->pIRequest)
	End If
	
	this->pIRequest = pIRequest
	
	Return S_OK
	
End Function

Function WriteResponseAsyncTaskPrepare( _
		ByVal this As WriteResponseAsyncTask Ptr _
	)As HRESULT
	
	Scope
		Dim KeepAlive As Boolean = True
		IClientRequest_GetKeepAlive(this->pIRequest, @KeepAlive)
		IServerResponse_SetKeepAlive(this->pIResponse, KeepAlive)
	End Scope
	
	Dim HttpVersion As HttpVersions = Any
	IClientRequest_GetHttpVersion(this->pIRequest, @HttpVersion)
	IServerResponse_SetHttpVersion(this->pIResponse, HttpVersion)
	
	Dim hrPrepareResponse As HRESULT = Any
	
	Dim pIWebSite As IWebSite Ptr = Any
	Dim hrFindSite As HRESULT = FindWebSite( _
		this->pIRequest, _
		this->pIWebSites, _
		@pIWebSite _
	)
	If FAILED(hrFindSite) Then
		hrPrepareResponse = SERVERRESPONSE_E_SITENOTFOUND
	Else
		Dim IsSiteMoved As Boolean = Any
		IWebSite_GetIsMoved(pIWebSite, @IsSiteMoved)
		
		/'
			' Dim ClientURI As IClientUri Ptr = Any
			' IClientRequest_GetUri(this->pIRequest, @ClientURI)
		
			Dim IsSiteMoved As Boolean = Any
			' TODO ������� ��� � robots.txt
			' ���� �������� �������� /robots.txt �� �� ��������������
			Dim IsRobotsTxt As Integer = lstrcmpiW(ClientURI.Path, WStr("/robots.txt"))
			If IsRobotsTxt = 0 Then
				IsSiteMoved = False
			Else
				IWebSite_GetIsMoved(pIWebSite, @IsSiteMoved)
			End If
		'/
		
		If IsSiteMoved Then
			' ���� ��������� �� ������ ������
			hrPrepareResponse = SERVERRESPONSE_E_SITEMOVED
		Else
			
			Dim HttpMethod As HeapBSTR = Any
			IClientRequest_GetHttpMethod(this->pIRequest, @HttpMethod)
			
			Dim pIProcessor As IHttpAsyncProcessor Ptr = Any
			Dim hrProcessorItem As HRESULT = IHttpProcessorCollection_Item( _
				this->pIProcessors, _
				HttpMethod, _
				@pIProcessor _
			)
			If FAILED(hrProcessorItem) Then
				hrPrepareResponse = SERVERRESPONSE_E_NOTIMPLEMENTED
			Else
				
				/'
				Dim pIMemoryAllocator As IMalloc Ptr = Any
				IClientContext_GetMemoryAllocator(pIContext, @pIMemoryAllocator)
				
				Dim IsKnownHttpMethod As Boolean = Any
				Dim RequestedFileAccess As FileAccess = Any
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
						RequestedFileAccess = FileAccess.ReadAccess
						IServerResponse_SetSendOnlyHeaders(pIResponse, True)
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
									
									' TODO ��������� ��������� ������ ��������������� ���������
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
									'/
									
									' hrPrepareResponse = S_OK
									hrPrepareResponse = E_UNEXPECTED
									
									/'
									
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
				
				'/
				
				IHttpAsyncProcessor_Release(pIProcessor)
			End If
			
			HeapSysFreeString(HttpMethod)
			
		End If
		
		IWebSite_Release(pIWebSite)
		
	End If
	
	Return hrPrepareResponse
	
End Function


Function IWriteResponseAsyncTaskQueryInterface( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskQueryInterface(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), riid, ppv)
End Function

Function IWriteResponseAsyncTaskAddRef( _
		ByVal this As IWriteResponseAsyncIoTask Ptr _
	)As ULONG
	Return WriteResponseAsyncTaskAddRef(ContainerOf(this, WriteResponseAsyncTask, lpVtbl))
End Function

Function IWriteResponseAsyncTaskRelease( _
		ByVal this As IWriteResponseAsyncIoTask Ptr _
	)As ULONG
	Return WriteResponseAsyncTaskRelease(ContainerOf(this, WriteResponseAsyncTask, lpVtbl))
End Function

Function IWriteResponseAsyncTaskBeginExecute( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As ULONG
	Return WriteResponseAsyncTaskBeginExecute(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), ppIResult)
End Function

Function IWriteResponseAsyncTaskEndExecute( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
	)As ULONG
	Return WriteResponseAsyncTaskEndExecute(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), pIResult, BytesTransferred, ppNextTask)
End Function

Function IWriteResponseAsyncTaskGetFileHandle( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal pFileHandle As HANDLE Ptr _
	)As ULONG
	Return WriteResponseAsyncTaskGetFileHandle(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), pFileHandle)
End Function

Function IWriteResponseAsyncTaskGetWebSiteCollection( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskGetWebSiteCollection(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), ppIWebSites)
End Function

Function IWriteResponseAsyncTaskSetWebSiteCollection( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskSetWebSiteCollection(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), pIWebSites)
End Function

Function IWriteResponseAsyncTaskGetBaseStream( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskGetBaseStream(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), ppStream)
End Function

Function IWriteResponseAsyncTaskSetBaseStream( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		byVal pStream As IBaseStream Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskSetBaseStream(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), pStream)
End Function

Function IWriteResponseAsyncTaskGetHttpReader( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskGetHttpReader(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), ppReader)
End Function

Function IWriteResponseAsyncTaskSetHttpReader( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskSetHttpReader(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), pReader)
End Function

Function IWriteResponseAsyncTaskGetClientRequest( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskGetClientRequest(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), ppIRequest)
End Function

Function IWriteResponseAsyncTaskSetClientRequest( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskSetClientRequest(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), pIRequest)
End Function

Function IWriteResponseAsyncTaskGetHttpProcessorCollection( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskGetHttpProcessorCollection(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), ppIProcessors)
End Function

Function IWriteResponseAsyncTaskSetHttpProcessorCollection( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal pIProcessors As IHttpProcessorCollection Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskSetHttpProcessorCollection(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), pIProcessors)
End Function

Function IWriteResponseAsyncTaskPrepare( _
		ByVal this As IWriteResponseAsyncIoTask Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskPrepare(ContainerOf(this, WriteResponseAsyncTask, lpVtbl))
End Function

Dim GlobalWriteResponseAsyncIoTaskVirtualTable As Const IWriteResponseAsyncIoTaskVirtualTable = Type( _
	@IWriteResponseAsyncTaskQueryInterface, _
	@IWriteResponseAsyncTaskAddRef, _
	@IWriteResponseAsyncTaskRelease, _
	@IWriteResponseAsyncTaskBeginExecute, _
	@IWriteResponseAsyncTaskEndExecute, _
	@IWriteResponseAsyncTaskGetFileHandle, _
	@IWriteResponseAsyncTaskGetWebSiteCollection, _
	@IWriteResponseAsyncTaskSetWebSiteCollection, _
	@IWriteResponseAsyncTaskGetBaseStream, _
	@IWriteResponseAsyncTaskSetBaseStream, _
	@IWriteResponseAsyncTaskGetHttpReader, _
	@IWriteResponseAsyncTaskSetHttpReader, _
	@IWriteResponseAsyncTaskGetHttpProcessorCollection, _
	@IWriteResponseAsyncTaskSetHttpProcessorCollection, _
	@IWriteResponseAsyncTaskGetClientRequest, _
	@IWriteResponseAsyncTaskSetClientRequest, _
	@IWriteResponseAsyncTaskPrepare _
)