#include once "ReadRequestAsyncTask.bi"
#include once "ClientRequest.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "Logger.bi"
#include once "WriteErrorAsyncTask.bi"
#include once "WriteResponseAsyncTask.bi"

Extern GlobalReadRequestAsyncTaskVirtualTable As Const IReadRequestAsyncTaskVirtualTable

Type _ReadRequestAsyncTask
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IReadRequestAsyncTaskVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	pIWebSites As IWebSiteCollection Ptr
	pIProcessors As IHttpProcessorCollection Ptr
	RemoteAddress As SOCKADDR_STORAGE
	RemoteAddressLength As Integer
	pIStream As IBaseStream Ptr
	pIHttpReader As IHttpReader Ptr
	pIRequest As IClientRequest Ptr
End Type

Function ProcessReadError( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr, _
		ByVal hrReadError As HRESULT _
	)As HRESULT
	
	' Создать и запустить задачу подготовки ответа ошибки
	Dim pTask As IWriteErrorAsyncTask Ptr = Any
	Dim hrCreateTask As HRESULT = CreateInstance( _
		this->pIMemoryAllocator, _
		@CLSID_WRITEERRORASYNCTASK, _
		@IID_IWriteErrorAsyncTask, _
		@pTask _
	)
	If FAILED(hrCreateTask) Then
		Return hrCreateTask
	End If
	
	IWriteErrorAsyncTask_SetRemoteAddress( _
		pTask, _
		CPtr(SOCKADDR Ptr, @this->RemoteAddress), _
		this->RemoteAddressLength _
	)
	
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
		IWriteErrorAsyncTask_SetHttpReader(pTask, this->pIHttpReader)
		IWriteErrorAsyncTask_SetClientRequest(pTask, this->pIRequest)
		IWriteErrorAsyncTask_SetWebSiteCollection(pTask, this->pIWebSites)
		IWriteErrorAsyncTask_SetHttpProcessorCollection(pTask, this->pIProcessors)
	End If
	
	IWriteErrorAsyncTask_SetBaseStream(pTask, this->pIStream)
	IWriteErrorAsyncTask_SetErrorCode(pTask, HttpError, hrReadError)
	
	Dim pIResult As IAsyncResult Ptr = Any
	Dim hrBeginExecute As HRESULT = IWriteErrorAsyncTask_BeginExecute( _
		pTask, _
		pPool, _
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
		IWriteErrorAsyncTask_Release(pTask)
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
	this->lpVtbl = @GlobalReadRequestAsyncTaskVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIWebSites = NULL
	this->pIProcessors = NULL
	this->RemoteAddressLength = 0
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
	
	If IsEqualIID(@IID_IReadRequestAsyncTask, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IAsyncTask, riid) Then
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
		ByVal pPool As IThreadPool Ptr, _
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
		ByVal pPool As IThreadPool Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal CompletionKey As ULONG_PTR _
	)As HRESULT
	
	Dim hrEndReadRequest As HRESULT = IClientRequest_EndReadRequest( _
		this->pIRequest, _
		pIResult _
	)
	If FAILED(hrEndReadRequest) Then
		
		Dim hrProcessReadError As HRESULT = ProcessReadError( _
			this, _
			pPool, _
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
					pPool, _
					hrPrepare _
				)
				
				Return hrProcessReadError
			End If
			
			' Создать и запустить задачу подготовки запроса к ответу
			Dim pTask As IWriteResponseAsyncTask Ptr = Any
			Dim hrCreateTask As HRESULT = CreateInstance( _
				this->pIMemoryAllocator, _
				@CLSID_WRITERESPONSEASYNCTASK, _
				@IID_IWriteResponseAsyncTask, _
				@pTask _
			)
			If FAILED(hrCreateTask) Then
				Dim hrProcessReadError As HRESULT = ProcessReadError( _
					this, _
					pPool, _
					hrCreateTask _
				)
				
				Return hrProcessReadError
			End If
			/'
			IWriteResponseAsyncTask_SetBaseStream(pTask, this->pIStream)
			IWriteResponseAsyncTask_SetHttpReader(pTask, this->pIHttpReader)
			IWriteResponseAsyncTask_SetClientRequest(pTask, this->pIRequest)
			IWriteResponseAsyncTask_SetWebSiteCollection(pTask, this->pIWebSites)
			IWriteResponseAsyncTask_SetRemoteAddress( _
				pTask, _
				CPtr(SOCKADDR Ptr, @this->RemoteAddress), _
				this->RemoteAddressLength _
			)
			
			Dim pIResult As IAsyncResult Ptr = Any
			Dim hrBeginExecute As HRESULT = IWriteResponseAsyncTask_BeginExecute( _
				pTask, _
				pPool, _
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
				IWriteResponseAsyncTask_Release(pTask)
				Return hrBeginExecute
			End If
			'/
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
		ByVal pPool As IThreadPool Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskBeginExecute(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pPool, ppIResult)
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

Function IReadRequestAsyncTaskGetBaseStream( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskGetBaseStream(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), ppStream)
End Function

Function IReadRequestAsyncTaskSetBaseStream( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		byVal pStream As IBaseStream Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskSetBaseStream(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pStream)
End Function

Function IReadRequestAsyncTaskGetHttpReader( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskGetHttpReader(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), ppReader)
End Function

Function IReadRequestAsyncTaskSetHttpReader( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskSetHttpReader(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pReader)
End Function

Function IReadRequestAsyncTaskGetHttpProcessorCollection( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskGetHttpProcessorCollection(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), ppIProcessors)
End Function

Function IReadRequestAsyncTaskSetHttpProcessorCollection( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		ByVal pIProcessors As IHttpProcessorCollection Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskSetHttpProcessorCollection(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pIProcessors)
End Function

Dim GlobalReadRequestAsyncTaskVirtualTable As Const IReadRequestAsyncTaskVirtualTable = Type( _
	@IReadRequestAsyncTaskQueryInterface, _
	@IReadRequestAsyncTaskAddRef, _
	@IReadRequestAsyncTaskRelease, _
	@IReadRequestAsyncTaskBeginExecute, _
	@IReadRequestAsyncTaskEndExecute, _
	@IReadRequestAsyncTaskGetWebSiteCollection, _
	@IReadRequestAsyncTaskSetWebSiteCollection, _
	@IReadRequestAsyncTaskGetRemoteAddress, _
	@IReadRequestAsyncTaskSetRemoteAddress, _
	@IReadRequestAsyncTaskGetBaseStream, _
	@IReadRequestAsyncTaskSetBaseStream, _
	@IReadRequestAsyncTaskGetHttpReader, _
	@IReadRequestAsyncTaskSetHttpReader, _
	@IReadRequestAsyncTaskGetHttpProcessorCollection, _
	@IReadRequestAsyncTaskSetHttpProcessorCollection _
)
