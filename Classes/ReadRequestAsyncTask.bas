#include once "ReadRequestAsyncTask.bi"
#include once "ClientRequest.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "ICloneable.bi"
#include once "Logger.bi"
#include once "PrepareErrorResponseAsyncTask.bi"

Extern GlobalReadRequestAsyncTaskVirtualTable As Const IReadRequestAsyncTaskVirtualTable
Extern GlobalReadRequestAsyncTaskCloneableVirtualTable As Const ICloneableVirtualTable

Type _ReadRequestAsyncTask
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IReadRequestAsyncTaskVirtualTable Ptr
	lpCloneableVtbl As Const ICloneableVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	pIWebSites As IWebSiteCollection Ptr
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
	Dim pTask As IPrepareErrorResponseAsyncTask Ptr = Any
	Dim hrCreateTask As HRESULT = CreateInstance( _
		this->pIMemoryAllocator, _
		@CLSID_PREPAREERRORRESPONSEASYNCTASK, _
		@IID_IPrepareErrorResponseAsyncTask, _
		@pTask _
	)
	If FAILED(hrCreateTask) Then
		Dim vtSCode As VARIANT = Any
		vtSCode.vt = VT_ERROR
		vtSCode.scode = hrCreateTask
		LogWriteEntry( _
			LogEntryType.Error, _
			WStr(!"CreateTask Error\t"), _
			@vtSCode _
		)
		Return hrCreateTask
	End If
	
	IPrepareErrorResponseAsyncTask_SetRemoteAddress( _
		pTask, _
		CPtr(SOCKADDR Ptr, @this->RemoteAddress), _
		this->RemoteAddressLength _
	)
	IPrepareErrorResponseAsyncTask_SetBaseStream(pTask, this->pIStream)
	IPrepareErrorResponseAsyncTask_SetHttpReader(pTask, this->pIHttpReader)
	IPrepareErrorResponseAsyncTask_SetClientRequest(pTask, this->pIRequest)
	
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
	
	IPrepareErrorResponseAsyncTask_SetErrorCode(pTask, HttpError, hrReadError)
	
	Dim pIResult As IAsyncResult Ptr = Any
	Dim hrBeginExecute As HRESULT = IPrepareErrorResponseAsyncTask_BeginExecute( _
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
			WStr(!"IPrepareErrorResponseAsyncTask_BeginExecute Error\t"), _
			@vtSCode _
		)
		
		' TODO Отправить клиенту Не могу начать асинхронное чтение
		IPrepareErrorResponseAsyncTask_Release(pTask)
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
	this->lpCloneableVtbl = @GlobalReadRequestAsyncTaskCloneableVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIWebSites = NULL
	ZeroMemory(@this->RemoteAddress, SizeOf(SOCKADDR_STORAGE))
	this->RemoteAddressLength = 0
	this->pIStream = NULL
	this->pIHttpReader = NULL
	this->pIRequest = pIRequest
	
End Sub

Sub InitializeCloneReadRequestAsyncTask( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pIStream As IBaseStream Ptr, _
		ByVal pIHttpReader As IHttpReader Ptr, _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pWebSites As IWebSiteCollection Ptr, _
		ByVal RemoteAddress As SOCKADDR Ptr, _
		ByVal RemoteAddressLength As Integer _
	)
	
	this->lpVtbl = @GlobalReadRequestAsyncTaskVirtualTable
	this->lpCloneableVtbl = @GlobalReadRequestAsyncTaskCloneableVirtualTable
	this->ReferenceCounter = 0
	
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	
	IWebSiteCollection_AddRef(pWebSites)
	this->pIWebSites = pWebSites
	
	this->RemoteAddressLength = RemoteAddressLength
	CopyMemory(@this->RemoteAddress, RemoteAddress, RemoteAddressLength)
	
	this->pIStream = pIStream
	this->pIHttpReader = pIHttpReader
	this->pIRequest = pIRequest
	' TODO Запросить интерфейс вместо конвертирования указателя
	IHttpReader_SetBaseStream( _
		pIHttpReader, _
		pIStream _
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
	
	If this->pIStream <> NULL Then
		IBaseStream_Release(this->pIStream)
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
		Dim vtSCode As VARIANT = Any
		vtSCode.vt = VT_ERROR
		vtSCode.scode = hrEndReadRequest
		LogWriteEntry( _
			LogEntryType.Error, _
			WStr(!"IClientRequest_EndReadRequest Error\t"), _
			@vtSCode _
		)
		' TODO Вывести байты запроса HttpReader в лог
		' DebugPrintHttpReader(pIHttpReader)
		
		Dim hrProcessReadError As HRESULT = ProcessReadError( _
			this, _
			pPool, _
			hrEndReadRequest _
		)
		
		Return hrProcessReadError
	End If
	
	Select Case hrEndReadRequest
		
		Case S_OK
			
			' TODO Вывести байты запроса в лог
			' DebugPrintHttpReader(pIHttpReader)
			
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
			
			/'
			' Создать и запустить задачу подготовки запроса к ответу
			Dim pTask As IPrepareSuccessResponseAsyncTask Ptr = Any
			Dim hrCreateTask As HRESULT = CreateInstance( _
				this->pIMemoryAllocator, _
				@CLSID_PREPARESUCCESSRESPONSEASYNCTASK, _
				@IID_IPrepareSuccessResponseAsyncTask, _
				@pTask _
			)
			If FAILED(hrCreateTask) Then
				Dim vtSCode As VARIANT = Any
				vtSCode.vt = VT_ERROR
				vtSCode.scode = hrCreateTask
				LogWriteEntry( _
					LogEntryType.Error, _
					WStr(!"CreateTask Error\t"), _
					@vtSCode _
				)
				Return hrCreateTask
			End If
			
			IPrepareResponseAsyncTask_SetBaseStream(pTask, this->pIStream)
			IPrepareResponseAsyncTask_SetHttpReader(pTask, this->pIHttpReader)
			IPrepareResponseAsyncTask_SetClientRequest(pTask, this->pIRequest)
			IPrepareResponseAsyncTask_SetWebSiteCollection(pTask, this->pIWebSites)
			IPrepareResponseAsyncTask_SetRemoteAddress( _
				pTask, _
				CPtr(SOCKADDR Ptr, @this->RemoteAddress), _
				this->RemoteAddressLength _
			)
			
			Dim hrBeginExecute As HRESULT = IPrepareResponseAsyncTask_BeginExecute( _
				pTask, _
				pPool _
			)
			If FAILED(hrBeginExecute) Then
				Dim vtSCode As VARIANT = Any
				vtSCode.vt = VT_ERROR
				vtSCode.scode = hrBeginExecute
				LogWriteEntry( _
					LogEntryType.Error, _
					WStr(!"IPrepareResponseAsyncTask_BeginExecute Error\t"), _
					@vtSCode _
				)
				
				' TODO Отправить клиенту Не могу начать асинхронное чтение
				IPrepareResponseAsyncTask_Release(pTask)
				Return hrBeginExecute
			End If
			'/
			
			ProcessReadError( _
				this, _
				pPool, _
				E_FAIL _
			)
			
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
	
	Dim pClone As ICloneable Ptr = Any
	IBaseStream_QueryInterface( _
		this->pIStream, _
		@IID_ICloneable, _
		@pClone _
	)
	Dim pIBaseStream As IBaseStream Ptr = Any
	Dim hrCreateNetworkStreamClone As HRESULT = ICloneable_Clone( _
		pClone, _
		pMalloc, _
		@IID_IBaseStream, _
		@pIBaseStream _
	)
	
	ICloneable_Release(pClone)
	
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
						pIBaseStream, _
						pReader, _
						pRequest, _
						this->pIWebSites, _
						CPtr(SOCKADDR Ptr, @this->RemoteAddress), _
						this->RemoteAddressLength _
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
		IBaseStream_Release(pIBaseStream)
		Return hrCreateHttpReaderClone
	End If
	
	*ppvObject = NULL
	Return hrCreateNetworkStreamClone
	
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
	@IReadRequestAsyncTaskSetHttpReader _
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
