#include once "ReadRequestAsyncTask.bi"
#include once "ClientRequest.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "HeapMemoryAllocator.bi"
#include once "HttpReader.bi"
#include once "Logger.bi"
#include once "Network.bi"
#include once "NetworkStream.bi"

Extern GlobalReadRequestAsyncTaskVirtualTable As Const IReadRequestAsyncTaskVirtualTable

Type _ReadRequestAsyncTask
	lpVtbl As Const IReadRequestAsyncTaskVirtualTable Ptr
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
		' TODO Вывести байты запроса HttpReader в лог
		' DebugPrintHttpReader(pIHttpReader)
		
		' ProcessEndReadError(pIContext, hrEndReadRequest)
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
			Return S_FALSE
			
		Case CLIENTREQUEST_S_IO_PENDING
			' Создать задачу чтения
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
				
				Dim hrCreateTask As HRESULT = CreateInstance( _
					pIClientMemoryAllocator, _
					@CLSID_READREQUESTASYNCTASK, _
					@IID_IReadRequestAsyncTask, _
					@pTask _
				)
				If FAILED(hrCreateTask) Then
					CloseSocketConnection(this->ClientSocket)
					IMalloc_Release(pIClientMemoryAllocator)
					Return hrCreateTask
				End If
				IMalloc_Release(pIClientMemoryAllocator)
				
			End Scope
			
			' Настроить задачу текущими параметрами
			Scope
				IReadRequestAsyncTask_SetWebSiteCollection(pTask, this->pIWebSites)
				IReadRequestAsyncTask_SetSocket(pTask, this->ClientSocket)
				IReadRequestAsyncTask_SetRemoteAddress( _
					pTask, _
					CPtr(SOCKADDR Ptr, @this->RemoteAddress), _
					this->RemoteAddressLength _
				)
				IReadRequestAsyncTask_SetAssociatedWithIOCP( _
					pTask, _
					True _
				)
				' TODO Клонировать HttpReader и ClientRequest
			End Scope
			
			' Запустить задачу
			Scope
				/'
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
				'/
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
