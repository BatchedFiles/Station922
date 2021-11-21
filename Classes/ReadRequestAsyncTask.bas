#include once "ReadRequestAsyncTask.bi"
#include once "ClientRequest.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "HttpReader.bi"
#include once "Logger.bi"
#include once "NetworkStream.bi"

Extern GlobalReadRequestAsyncTaskVirtualTable As Const IReadRequestAsyncTaskVirtualTable

Type _ReadRequestAsyncTask
	lpVtbl As Const IReadRequestAsyncTaskVirtualTable Ptr
	crSection As CRITICAL_SECTION
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	pIWebSites As IWebSiteCollection Ptr
	ClientSocket As SOCKET
	pINetworkStream As INetworkStream Ptr
	pIHttpReader As IHttpReader Ptr
	pIRequest As IClientRequest Ptr
End Type

/'
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
	this->pINetworkStream = pINetworkStream
	this->pIHttpReader = pIHttpReader
	this->pIRequest = pIRequest
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
	
	/'
	IClientContext_SetRemoteAddress( _
		CachedContext.pIClientContext, _
		CPtr(SOCKADDR Ptr, @RemoteAddress), _
		RemoteAddressLength _
	)
	'/
	
	Dim hrAssociateWithIOCP As HRESULT = AssociateWithIOCP( _
		pPool, _
		this->ClientSocket, _
		Cast(ULONG_PTR, 0) _
	)
	If FAILED(hrAssociateWithIOCP) Then
		Return hrAssociateWithIOCP
	End If
	
	INetworkStream_SetSocket(this->pINetworkStream, this->ClientSocket)
	
	' TODO Запросить интерфейс вместо конвертирования указателя
	Dim pIAsyncResult As IAsyncResult Ptr = Any
	Dim hrBeginReadRequest As HRESULT = IClientRequest_BeginReadRequest( _
		this->pIRequest, _
		CPtr(IUnknown Ptr, @this->lpVtbl), _
		@pIAsyncResult _
	)
	If FAILED(hrBeginReadRequest) Then
		Return hrBeginReadRequest
	End If
	
	' Ссылка на this сохранена в pIAsyncResult
	' Ссылка на pIAsyncResult сохранена в унаследованной от OVERLAPPED структуре
	' OVERLAPPED будет возвращена функцией GetQueuedCompletionStatus в пуле потоков
	
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
