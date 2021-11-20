#include once "ReadRequestAsyncTask.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "Logger.bi"

Extern GlobalReadRequestAsyncTaskVirtualTable As Const IReadRequestAsyncTaskVirtualTable

/'
Sub InitializeClientMemoryContext( _
		ByVal pCachedContext As CachedClientContext Ptr _
	)
	
	ZeroMemory(pCachedContext, SizeOf(CachedClientContext))
	
	pCachedContext->hrClientContex = CreateInstance( _
		pCachedContext->pIClientMemoryAllocator, _
		@CLSID_CLIENTCONTEXT, _
		@IID_IClientContext, _
		@pCachedContext->pIClientContext _
	)
	
	If SUCCEEDED(pCachedContext->hrClientContex) Then
		IClientContext_SetOperationCode(pCachedContext->pIClientContext, OperationCodes.ReadRequest)
		
		Dim pIReader As IHttpReader Ptr = Any
		IClientContext_GetHttpReader(pCachedContext->pIClientContext, @pIReader)
		
		Scope
			Dim pINetworkStream As INetworkStream Ptr = Any
			IClientContext_GetNetworkStream(pCachedContext->pIClientContext, @pINetworkStream)
			
			' TODO Запросить интерфейс вместо конвертирования указателя
			IHttpReader_SetBaseStream(pIReader, CPtr(IBaseStream Ptr, pINetworkStream))
			
			INetworkStream_Release(pINetworkStream)
		End Scope
		
		Scope
			Dim pIRequest As IClientRequest Ptr = Any
			IClientContext_GetClientRequest(pCachedContext->pIClientContext, @pIRequest)
			
			' TODO Запросить интерфейс вместо конвертирования указателя
			IClientRequest_SetTextReader(pIRequest, CPtr(ITextReader Ptr, pIReader))
			
			IClientRequest_Release(pIRequest)
		End Scope
		
		IHttpReader_Release(pIReader)
		
	End If
	
End Sub

Function ProcessErrorAssociateWithIOCP( _
		ByVal this As WebServer Ptr, _
		ByVal ClientSocket As SOCKET, _
		ByVal pCachedContext As CachedClientContext Ptr _
	)As HRESULT
	
	If FAILED(pCachedContext->hrMemoryAllocator) Then
		' TODO Отправить клиенту Не могу создать кучу памяти
		' INetworkStream_SetSocket(this->pINetworkStream, ClientSocket)
		' WriteHttpNotEnoughMemory(pCachedContext->pIClientContext, NULL)
		Return pCachedContext->hrMemoryAllocator
	End If
	
	If FAILED(pCachedContext->hrClientContex) Then
		' TODO Отправить клиенту Не могу выделить память в куче
		' INetworkStream_SetSocket(this->pINetworkStream, ClientSocket)
		' WriteHttpNotEnoughMemory(pCachedContext->pIClientContext, NULL)
		Return pCachedContext->hrClientContex
	End If
	
	' Dim hrAssociate As HRESULT = AssociateWithIOCP( _
		' this, _
		' ClientSocket, _
		' 0 _
	' )
	' If FAILED(hrAssociate) Then
		' TODO Отправить клиенту Не могу ассоциировать с портом завершения
		' INetworkStream_SetSocket(this->pINetworkStream, ClientSocket)
		' WriteHttpNotEnoughMemory(pCachedContext->pIClientContext, NULL)
		' IClientContext_Release(pCachedContext->pIClientContext)
		' Return hrAssociate
	' End If
	
	Return S_OK
	
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
'/

Type _ReadRequestAsyncTask
	lpVtbl As Const IReadRequestAsyncTaskVirtualTable Ptr
	crSection As CRITICAL_SECTION
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	pIWebSites As IWebSiteCollection Ptr
	ClientSocket As SOCKET
End Type

Sub InitializeReadRequestAsyncTask( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	this->lpVtbl = @GlobalReadRequestAsyncTaskVirtualTable
	this->ReferenceCounter = 0
	
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIWebSites = NULL
	this->ClientSocket = INVALID_SOCKET
	
End Sub

Sub UnInitializeReadRequestAsyncTask( _
		ByVal this As ReadRequestAsyncTask Ptr _
	)
	
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
	
	Dim this As ReadRequestAsyncTask Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(ReadRequestAsyncTask) _
	)
	If this <> NULL Then
		InitializeReadRequestAsyncTask( _
			this, _
			pIMemoryAllocator _
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
	
	/'
	Scope
		' Dim hrAssociateWithIOCP As HRESULT = ProcessErrorAssociateWithIOCP( _
			' this, _
			' ClientSocket, _
			' @CachedContext _
		' )
		' If FAILED(hrAssociateWithIOCP) Then
			' IClientContext_Release(CachedContext.pIClientContext)
			' CloseSocketConnection(ClientSocket)
			' Return E_FAIL
		' End If
	End Scope
	
	IClientContext_SetRemoteAddress( _
		CachedContext.pIClientContext, _
		CPtr(SOCKADDR Ptr, @RemoteAddress), _
		RemoteAddressLength _
	)
	
	Scope
		Dim pINetworkStream As INetworkStream Ptr = Any
		IClientContext_GetNetworkStream(CachedContext.pIClientContext, @pINetworkStream)
		INetworkStream_SetSocket(pINetworkStream, ClientSocket)
		INetworkStream_Release(pINetworkStream)
	End Scope
	
	Scope
		Dim pIRequest As IClientRequest Ptr = Any
		IClientContext_GetClientRequest(CachedContext.pIClientContext, @pIRequest)
		
		' TODO Запросить интерфейс вместо конвертирования указателя
		Dim pIAsyncResult As IAsyncResult Ptr = Any
		Dim hrBeginReadRequest As HRESULT = IClientRequest_BeginReadRequest( _
			pIRequest, _
			CPtr(IUnknown Ptr, CachedContext.pIClientContext), _
			@pIAsyncResult _
		)
		IClientRequest_Release(pIRequest)
		
		If FAILED(hrBeginReadRequest) Then
			Dim vtSCode As VARIANT = Any
			vtSCode.vt = VT_ERROR
			vtSCode.scode = hrBeginReadRequest
			LogWriteEntry( _
				LogEntryType.Error, _
				WStr(!"IClientRequest_BeginReadRequest\t"), _
				@vtSCode _
			)
			
			' TODO Отправить клиенту Не могу начать асинхронное чтение
			' Return S_FALSE
		End If
		
	End Scope
	
	IClientContext_Release(CachedContext.pIClientContext)
	
	' Ссылка на pIContext сохранена в pIAsyncResult
	' Указатель на pIAsyncResult сохранён в структуре OVERLAPPED
	'/
	Return S_OK
	
End Function

Function ReadRequestAsyncTaskEndExecute( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal CompletionKey As ULONG_PTR _
	)As HRESULT
	
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
		ByVal BytesTransferred As DWORD, _
		ByVal CompletionKey As ULONG_PTR _
	)As ULONG
	Return ReadRequestAsyncTaskEndExecute(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pPool, BytesTransferred, CompletionKey)
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

Dim GlobalReadRequestAsyncTaskVirtualTable As Const IReadRequestAsyncTaskVirtualTable = Type( _
	@IReadRequestAsyncTaskQueryInterface, _
	@IReadRequestAsyncTaskAddRef, _
	@IReadRequestAsyncTaskRelease, _
	@IReadRequestAsyncTaskBeginExecute, _
	@IReadRequestAsyncTaskEndExecute, _
	@IReadRequestAsyncTaskGetWebSiteCollection, _
	@IReadRequestAsyncTaskSetWebSiteCollection, _
	@IReadRequestAsyncTaskGetSocket, _
	@IReadRequestAsyncTaskSetSocket _
)

