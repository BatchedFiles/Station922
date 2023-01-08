#include once "WriteErrorAsyncTask.bi"
#include once "win\wininet.bi"
#include once "ReadRequestAsyncTask.bi"
#include once "ClientRequest.bi"
#include once "ContainerOf.bi"
#include once "HeapBSTR.bi"
#include once "HttpWriter.bi"
#include once "ServerResponse.bi"
#include once "WebUtils.bi"

Extern GlobalWriteErrorAsyncIoTaskVirtualTable As Const IWriteErrorAsyncIoTaskVirtualTable

Extern pIWebSitesWeakPtr As IWebSiteCollection Ptr
Extern pIProcessorsWeakPtr As IHttpProcessorCollection Ptr

Const CompareResultEqual As Long = 0

Const DefaultHeaderWwwAuthenticate = WStr("Basic realm=""Need username and password""")
Const DefaultHeaderWwwAuthenticate1 = WStr("Basic realm=""Authorization""")
Const DefaultHeaderWwwAuthenticate2 = WStr("Basic realm=""Use Basic auth""")
Const DefaultRetryAfterString = WStr("300")

Type _WriteErrorAsyncTask
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IWriteErrorAsyncIoTaskVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pIHttpReader As IHttpReader Ptr
	pIStream As IBaseStream Ptr
	pIRequest As IClientRequest Ptr
	pIResponse As IServerResponse Ptr
	pIBuffer As IAttributedStream Ptr
	pIHttpWriter As IHttpWriter Ptr
	ComplectionPort As HANDLE
	HttpError As ResponseErrorCode
	hrErrorCode As HRESULT
End Type

Function WriteErrorAsyncTaskGetStatusCode( _
		ByVal this As WriteErrorAsyncTask Ptr _
	)As HttpStatusCodes
	
	Select Case this->HttpError
		
		Case ResponseErrorCode.MovedPermanently
			Dim pIWebSiteWeakPtr As IWebSite Ptr = Any
			Dim hrFindSite As HRESULT = FindWebSiteWeakPtr( _
				pIWebSitesWeakPtr, _
				this->pIRequest, _
				@pIWebSiteWeakPtr _
			)
			
			If SUCCEEDED(hrFindSite) Then
				Dim MovedUrl As HeapBSTR = Any
				IWebSite_GetMovedUrl(pIWebSiteWeakPtr, @MovedUrl)
				
				Dim ClientURI As IClientUri Ptr = Any
				IClientRequest_GetUri(this->pIRequest, @ClientURI)
				
				Dim Path As HeapBSTR = Any
				IClientUri_GetPath(ClientURI, @Path)
				
				Dim buf As WString * (INTERNET_MAX_URL_LENGTH * 2 + 1) = Any
				lstrcpyW(@buf, MovedUrl)
				lstrcatW(@buf, Path)
				
				IServerResponse_AddKnownResponseHeaderWstr( _
					this->pIResponse, _
					HttpResponseHeaders.HeaderLocation, _
					@buf _
				)
				
				HeapSysFreeString(Path)
				IClientUri_Release(ClientURI)
				HeapSysFreeString(MovedUrl)
			End If
			
			Return HttpStatusCodes.MovedPermanently
			
		Case ResponseErrorCode.BadRequest
			Return HttpStatusCodes.BadRequest
			
		Case ResponseErrorCode.PathNotValid
			Return HttpStatusCodes.BadRequest
			
		Case ResponseErrorCode.HostNotFound
			Return HttpStatusCodes.BadRequest
			
		Case ResponseErrorCode.SiteNotFound
			Return HttpStatusCodes.NotFound
			
		Case ResponseErrorCode.NeedAuthenticate
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				this->pIResponse, _
				HttpResponseHeaders.HeaderWwwAuthenticate, _
				@DefaultHeaderWwwAuthenticate, _
				Len(DefaultHeaderWwwAuthenticate) _
			)
			Return HttpStatusCodes.Unauthorized
			
		Case ResponseErrorCode.BadAuthenticateParam
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				this->pIResponse, _
				HttpResponseHeaders.HeaderWwwAuthenticate, _
				@DefaultHeaderWwwAuthenticate1, _
				Len(DefaultHeaderWwwAuthenticate1) _
			)
			Return HttpStatusCodes.Unauthorized
			
		Case ResponseErrorCode.NeedBasicAuthenticate
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				this->pIResponse, _
				HttpResponseHeaders.HeaderWwwAuthenticate, _
				@DefaultHeaderWwwAuthenticate2, _
				Len(DefaultHeaderWwwAuthenticate2) _
			)
			Return HttpStatusCodes.Unauthorized
			
		Case ResponseErrorCode.EmptyPassword
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				this->pIResponse, _
				HttpResponseHeaders.HeaderWwwAuthenticate, _
				@DefaultHeaderWwwAuthenticate, _
				Len(DefaultHeaderWwwAuthenticate) _
			)
			Return HttpStatusCodes.Unauthorized
			
		Case ResponseErrorCode.BadUserNamePassword
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				this->pIResponse, _
				HttpResponseHeaders.HeaderWwwAuthenticate, _
				@DefaultHeaderWwwAuthenticate, _
				Len(DefaultHeaderWwwAuthenticate) _
			)
			Return HttpStatusCodes.Unauthorized
			
		Case ResponseErrorCode.Forbidden
			Return HttpStatusCodes.Forbidden
			
		Case ResponseErrorCode.FileNotFound
			Return HttpStatusCodes.NotFound
			
		Case ResponseErrorCode.MethodNotAllowed
			Return HttpStatusCodes.MethodNotAllowed
			
		Case ResponseErrorCode.FileGone
			Return HttpStatusCodes.Gone
			
		Case ResponseErrorCode.LengthRequired
			Return HttpStatusCodes.LengthRequired
			
		Case ResponseErrorCode.RequestEntityTooLarge
			Return HttpStatusCodes.RequestEntityTooLarge
			
		Case ResponseErrorCode.RequestUrlTooLarge
			Return HttpStatusCodes.RequestURITooLarge
			
		Case ResponseErrorCode.RequestRangeNotSatisfiable
			Return HttpStatusCodes.RangeNotSatisfiable
			
		Case ResponseErrorCode.RequestHeaderFieldsTooLarge
			Return HttpStatusCodes.RequestHeaderFieldsTooLarge
			
		Case ResponseErrorCode.InternalServerError
			Return HttpStatusCodes.InternalServerError
			
		Case ResponseErrorCode.FileNotAvailable
			Return HttpStatusCodes.InternalServerError
			
		Case ResponseErrorCode.CannotCreateChildProcess
			Return HttpStatusCodes.InternalServerError
			
		Case ResponseErrorCode.CannotCreatePipe
			Return HttpStatusCodes.InternalServerError
			
		Case ResponseErrorCode.NotImplemented
			Dim AllMethods As HeapBSTR = Any
			IHttpProcessorCollection_GetAllMethods( _
				pIProcessorsWeakPtr, _
				@AllMethods _
			)
			IServerResponse_AddKnownResponseHeader( _
				this->pIResponse, _
				HttpResponseHeaders.HeaderAllow, _
				AllMethods _
			)
			HeapSysFreeString(AllMethods)
			Return HttpStatusCodes.NotImplemented
			
		Case ResponseErrorCode.ContentTypeEmpty
			Return HttpStatusCodes.NotImplemented
			
		Case ResponseErrorCode.ContentEncodingNotEmpty
			Return HttpStatusCodes.NotImplemented
			
		Case ResponseErrorCode.BadGateway
			Return HttpStatusCodes.BadGateway
			
		Case ResponseErrorCode.NotEnoughMemory
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				this->pIResponse, _
				HttpResponseHeaders.HeaderRetryAfter, _
				@DefaultRetryAfterString, _
				Len(DefaultRetryAfterString) _
			)
			Return HttpStatusCodes.ServiceUnavailable
			
		Case ResponseErrorCode.CannotCreateThread
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				this->pIResponse, _
				HttpResponseHeaders.HeaderRetryAfter, _
				@DefaultRetryAfterString, _
				Len(DefaultRetryAfterString) _
			)
			Return HttpStatusCodes.ServiceUnavailable
			
		Case ResponseErrorCode.GatewayTimeout
			Return HttpStatusCodes.GatewayTimeout
			
		Case ResponseErrorCode.VersionNotSupported
			Return HttpStatusCodes.HTTPVersionNotSupported
			
		Case Else
			Return HttpStatusCodes.InternalServerError
			
	End Select
	
End Function

Sub InitializeWriteErrorAsyncTask( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pIHttpWriter As IHttpWriter Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_WRITEERRORASYNCTASK), _
			Len(WriteErrorAsyncTask.IdString) _
		)
	#endif
	this->lpVtbl = @GlobalWriteErrorAsyncIoTaskVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIHttpReader = NULL
	this->pIStream = NULL
	this->pIRequest = NULL
	this->pIResponse = pIResponse
	this->pIBuffer = NULL
	this->pIHttpWriter = pIHttpWriter
	this->ComplectionPort = NULL
	
End Sub

Sub UnInitializeWriteErrorAsyncTask( _
		ByVal this As WriteErrorAsyncTask Ptr _
	)
	
	If this->pIRequest Then
		IClientRequest_Release(this->pIRequest)
	End If
	
	If this->pIStream Then
		IBaseStream_Release(this->pIStream)
	End If
	
	If this->pIHttpReader Then
		IHttpReader_Release(this->pIHttpReader)
	End If
	
	If this->pIBuffer Then
		IAttributedStream_Release(this->pIBuffer)
	End If
	
	If this->pIHttpWriter Then
		IHttpWriter_Release(this->pIHttpWriter)
	End If
	
	If this->pIResponse Then
		IServerResponse_Release(this->pIResponse)
	End If
	
End Sub

Sub WriteErrorAsyncTaskCreated( _
		ByVal this As WriteErrorAsyncTask Ptr _
	)
	
End Sub

Function CreateWriteErrorAsyncTask( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Dim pIHttpWriter As IHttpWriter Ptr = Any
	Dim hrCreateWriter As HRESULT = CreateHttpWriter( _
		pIMemoryAllocator, _
		@IID_IHttpWriter, _
		@pIHttpWriter _
	)
	
	If SUCCEEDED(hrCreateWriter) Then
		
		Dim pIResponse As IServerResponse Ptr = Any
		Dim hrCreateResponse As HRESULT = CreateServerResponse( _
			pIMemoryAllocator, _
			@IID_IServerResponse, _
			@pIResponse _
		)
		
		If SUCCEEDED(hrCreateResponse) Then
			
			Dim this As WriteErrorAsyncTask Ptr = IMalloc_Alloc( _
				pIMemoryAllocator, _
				SizeOf(WriteErrorAsyncTask) _
			)
			
			If this Then
				InitializeWriteErrorAsyncTask( _
					this, _
					pIMemoryAllocator, _
					pIResponse, _
					pIHttpWriter _
				)
				WriteErrorAsyncTaskCreated(this)
				
				Dim hrQueryInterface As HRESULT = WriteErrorAsyncTaskQueryInterface( _
					this, _
					riid, _
					ppv _
				)
				If FAILED(hrQueryInterface) Then
					DestroyWriteErrorAsyncTask(this)
				End If
				
				Return hrQueryInterface
			End If
			
			IServerResponse_Release(pIResponse)
		End If
		
		IHttpWriter_Release(pIHttpWriter)
	End If
	
	*ppv = NULL
	Return E_OUTOFMEMORY
	
End Function

Sub WriteErrorAsyncTaskDestroyed( _
		ByVal this As WriteErrorAsyncTask Ptr _
	)
	
End Sub

Sub DestroyWriteErrorAsyncTask( _
		ByVal this As WriteErrorAsyncTask Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeWriteErrorAsyncTask(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	WriteErrorAsyncTaskDestroyed(this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function WriteErrorAsyncTaskQueryInterface( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IWriteErrorAsyncIoTask, riid) Then
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
	
	WriteErrorAsyncTaskAddRef(this)
	
	Return S_OK
	
End Function

Function WriteErrorAsyncTaskAddRef( _
		ByVal this As WriteErrorAsyncTask Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return 1
	
End Function

Function WriteErrorAsyncTaskRelease( _
		ByVal this As WriteErrorAsyncTask Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyWriteErrorAsyncTask(this)
	
	Return 0
	
End Function

Function WriteErrorAsyncTaskBeginExecute( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	' TODO Запросить интерфейс вместо конвертирования указателя
	Dim hrBeginWrite As HRESULT = IHttpWriter_BeginWrite( _
		this->pIHttpWriter, _
		CPtr(IUnknown Ptr, @this->lpVtbl), _
		ppIResult _
	)
	If FAILED(hrBeginWrite) Then
		Return hrBeginWrite
	End If
	
	' Ссылка на this сохранена в pIAsyncResult
	' Ссылка на pIAsyncResult сохранена в унаследованной от OVERLAPPED структуре
	' Ссылку на OVERLAPPED возвратит функция GetQueuedCompletionStatus бассейну потоков
	
	Return ASYNCTASK_S_IO_PENDING
	
End Function

Function WriteErrorAsyncTaskEndExecute( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
	)As HRESULT
	
	Dim hrEndWrite As HRESULT = IHttpWriter_EndWrite( _
		this->pIHttpWriter, _
		pIResult _
	)
	If FAILED(hrEndWrite) Then
		*ppNextTask = NULL
		Return hrEndWrite
	End If
	
	Select Case hrEndWrite
		
		Case S_OK
			
			Dim KeepAlive As Boolean = Any
			IServerResponse_GetKeepAlive(this->pIResponse, @KeepAlive)
			
			If KeepAlive = False Then
				*ppNextTask = NULL
				Return ASYNCTASK_S_KEEPALIVE_FALSE
			End If
			
			Dim pTask As IReadRequestAsyncIoTask Ptr = Any
			Dim hrCreateTask As HRESULT = CreateReadRequestAsyncTask( _
				this->pIMemoryAllocator, _
				@IID_IReadRequestAsyncIoTask, _
				@pTask _
			)
			If FAILED(hrCreateTask) Then
				' Мы не запускаем задачу отправки ошибки
				' Чтобы не войти в бесконечный цикл
				*ppNextTask = NULL
				Return hrCreateTask
			End If
			
			IHttpReader_Clear(this->pIHttpReader)
			
			IReadRequestAsyncIoTask_SetBaseStream(pTask, this->pIStream)
			IReadRequestAsyncIoTask_SetHttpReader(pTask, this->pIHttpReader)
			
			' Сейчас мы не уменьшаем счётчик ссылок на задачу
			' Счётчик ссылок уменьшим в пуле потоков после функции EndExecute
			*ppNextTask = CPtr(IAsyncIoTask Ptr, pTask)
			Return S_OK
			
		Case S_FALSE
			' Write 0 bytes
			*ppNextTask = NULL
			Return S_FALSE
			
		Case HTTPWRITER_S_IO_PENDING
			' Продолжить отправку ответа
			WriteErrorAsyncTaskAddRef(this)
			*ppNextTask = CPtr(IAsyncIoTask Ptr, @this->lpVtbl)
			Return S_OK
			
	End Select
	
	Return S_OK
	
End Function

Function WriteErrorAsyncTaskGetBaseStream( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	
	If this->pIStream Then
		IBaseStream_AddRef(this->pIStream)
	End If
	
	*ppStream = this->pIStream
	
	Return S_OK
	
End Function

Function WriteErrorAsyncTaskSetBaseStream( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal pStream As IBaseStream Ptr _
	)As HRESULT
	
	If this->pIStream Then
		IBaseStream_Release(this->pIStream)
	End If
	
	If pStream Then
		IBaseStream_AddRef(pStream)
	End If
	
	this->pIStream = pStream
	
	IHttpWriter_SetBaseStream(this->pIHttpWriter, pStream)
	
	Return S_OK
	
End Function

Function WriteErrorAsyncTaskGetHttpReader( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	If this->pIHttpReader Then
		IHttpReader_AddRef(this->pIHttpReader)
	End If
	
	*ppReader = this->pIHttpReader
	
	Return S_OK
	
End Function

Function WriteErrorAsyncTaskSetHttpReader( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	
	If this->pIHttpReader Then
		IHttpReader_Release(this->pIHttpReader)
	End If
	
	If pReader Then
		IHttpReader_AddRef(pReader)
	End If
	
	this->pIHttpReader = pReader
	
	Return S_OK
	
End Function

Function WriteErrorAsyncTaskGetClientRequest( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	
	If this->pIRequest Then
		IClientRequest_AddRef(this->pIRequest)
	End If
	
	*ppIRequest = this->pIRequest
	
	Return S_OK
	
End Function

Function WriteErrorAsyncTaskSetClientRequest( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT
	
	If pIRequest Then
		IClientRequest_AddRef(pIRequest)
	End If
	
	If this->pIRequest Then
		IClientRequest_Release(this->pIRequest)
	End If
	
	this->pIRequest = pIRequest
	
	Return S_OK
	
End Function

Function WriteErrorAsyncTaskPrepare( _
		ByVal this As WriteErrorAsyncTask Ptr _
	)As HRESULT
	
	Dim StatusCode As HttpStatusCodes = WriteErrorAsyncTaskGetStatusCode(this)
	IServerResponse_SetStatusCode( _
		this->pIResponse, _
		StatusCode _
	)
	
	Dim pIWebSiteWeakPtr As IWebSite Ptr = Any
	Scope
		Dim HeaderHost As HeapBSTR = Any
		IClientRequest_GetHttpHeader( _
			this->pIRequest, _
			HttpRequestHeaders.HeaderHost, _
			@HeaderHost _
		)
		
		Dim HeaderHostLength As Integer = SysStringLen(HeaderHost)
		If HeaderHostLength Then
			Dim hrFindSite As HRESULT = IWebSiteCollection_ItemWeakPtr( _
				pIWebSitesWeakPtr, _
				HeaderHost, _
				@pIWebSiteWeakPtr _
			)
			If FAILED(hrFindSite) Then
				IWebSiteCollection_GetDefaultWebSite( _
					pIWebSitesWeakPtr, _
					@pIWebSiteWeakPtr _
				)
			End If
		Else
			IWebSiteCollection_GetDefaultWebSite( _
				pIWebSitesWeakPtr, _
				@pIWebSiteWeakPtr _
			)
		End If
		
		HeapSysFreeString(HeaderHost)
		
	End Scope
	
	Dim SendBufferLength As LongInt = Any
	Scope
		Dim pIBuffer As IAttributedStream Ptr = Any
		Dim hrGetBuffer As HRESULT = IWebSite_GetErrorBuffer( _
			pIWebSiteWeakPtr, _
			this->pIMemoryAllocator, _
			this->HttpError, _
			this->hrErrorCode, _
			StatusCode, _
			@pIBuffer _
		)
		If FAILED(hrGetBuffer) Then
			Return hrGetBuffer
		End If
		
		IHttpWriter_SetBuffer(this->pIHttpWriter, pIBuffer)
		
		Dim Mime As MimeType = Any
		IAttributedStream_GetContentType(pIBuffer, @Mime)
		IServerResponse_SetMimeType(this->pIResponse, @Mime)
		
		IAttributedStream_GetLength(pIBuffer, @SendBufferLength)
		
		IAttributedStream_Release(pIBuffer)
	End Scope
	
	Scope
		Dim KeepAlive As Boolean = True
		IClientRequest_GetKeepAlive(this->pIRequest, @KeepAlive)
		IServerResponse_SetKeepAlive(this->pIResponse, KeepAlive)
		IHttpWriter_SetKeepAlive(this->pIHttpWriter, KeepAlive)
	End Scope
	
	Scope
		Dim HttpMethod As HeapBSTR = Any
		IClientRequest_GetHttpMethod(this->pIRequest, @HttpMethod)
		
		Dim CompareResult As Long = lstrcmpW(HttpMethod, WStr("HEAD"))
		If CompareResult = CompareResultEqual Then
			IServerResponse_SetSendOnlyHeaders(this->pIResponse, True)
		End If
		
		HeapSysFreeString(HttpMethod)
	End Scope
	
	/'
	Scope
		IServerResponse_AddKnownResponseHeaderWstrLen( _
			this->pIResponse, _
			HttpResponseHeaders.HeaderContentLanguage, _
			@DefaultContentLanguage, _
			Len(DefaultContentLanguage) _
		)
		IServerResponse_AddKnownResponseHeaderWstrLen( _
			this->pIResponse, _
			HttpResponseHeaders.HeaderCacheControl, _
			@DefaultCacheControlNoCache, _
			Len(DefaultCacheControlNoCache) _
		)
	End Scope
	'/
	
	Dim hrPrepareResponse As HRESULT = IHttpWriter_Prepare( _
		this->pIHttpWriter, _
		this->pIResponse, _
		SendBufferLength, _
		FileAccess.ReadAccess _
	)
	If FAILED(hrPrepareResponse) Then
		Return hrPrepareResponse
	End If
	
	Return S_OK
	
End Function

Function WriteErrorAsyncTaskSetErrorCode( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal HttpError As ResponseErrorCode, _
		ByVal hrCode As HRESULT _
	)As HRESULT
	
	this->HttpError = HttpError
	this->hrErrorCode = hrCode
	
	Return S_OK
	
End Function


Function IWriteErrorAsyncTaskQueryInterface( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskQueryInterface(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), riid, ppv)
End Function

Function IWriteErrorAsyncTaskAddRef( _
		ByVal this As IWriteErrorAsyncIoTask Ptr _
	)As ULONG
	Return WriteErrorAsyncTaskAddRef(ContainerOf(this, WriteErrorAsyncTask, lpVtbl))
End Function

Function IWriteErrorAsyncTaskRelease( _
		ByVal this As IWriteErrorAsyncIoTask Ptr _
	)As ULONG
	Return WriteErrorAsyncTaskRelease(ContainerOf(this, WriteErrorAsyncTask, lpVtbl))
End Function

Function IWriteErrorAsyncTaskBeginExecute( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As ULONG
	Return WriteErrorAsyncTaskBeginExecute(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), ppIResult)
End Function

Function IWriteErrorAsyncTaskEndExecute( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
	)As ULONG
	Return WriteErrorAsyncTaskEndExecute(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), pIResult, BytesTransferred, ppNextTask)
End Function

Function IWriteErrorAsyncTaskGetBaseStream( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskGetBaseStream(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), ppStream)
End Function

Function IWriteErrorAsyncTaskSetBaseStream( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		byVal pStream As IBaseStream Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskSetBaseStream(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), pStream)
End Function

Function IWriteErrorAsyncTaskGetHttpReader( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskGetHttpReader(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), ppReader)
End Function

Function IWriteErrorAsyncTaskSetHttpReader( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskSetHttpReader(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), pReader)
End Function

Function IWriteErrorAsyncTaskGetClientRequest( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskGetClientRequest(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), ppIRequest)
End Function

Function IWriteErrorAsyncTaskSetClientRequest( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskSetClientRequest(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), pIRequest)
End Function

Function IWriteErrorAsyncTaskSetErrorCode( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal HttpError As ResponseErrorCode, _
		ByVal hrCode As HRESULT _
	)As HRESULT
	Return WriteErrorAsyncTaskSetErrorCode(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), HttpError, hrCode)
End Function

Function IWriteErrorAsyncTaskPrepare( _
		ByVal this As IWriteErrorAsyncIoTask Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskPrepare(ContainerOf(this, WriteErrorAsyncTask, lpVtbl))
End Function

Dim GlobalWriteErrorAsyncIoTaskVirtualTable As Const IWriteErrorAsyncIoTaskVirtualTable = Type( _
	@IWriteErrorAsyncTaskQueryInterface, _
	@IWriteErrorAsyncTaskAddRef, _
	@IWriteErrorAsyncTaskRelease, _
	@IWriteErrorAsyncTaskBeginExecute, _
	@IWriteErrorAsyncTaskEndExecute, _
	@IWriteErrorAsyncTaskGetBaseStream, _
	@IWriteErrorAsyncTaskSetBaseStream, _
	@IWriteErrorAsyncTaskGetHttpReader, _
	@IWriteErrorAsyncTaskSetHttpReader, _
	@IWriteErrorAsyncTaskGetClientRequest, _
	@IWriteErrorAsyncTaskSetClientRequest, _
	@IWriteErrorAsyncTaskSetErrorCode, _
	@IWriteErrorAsyncTaskPrepare _
)
