#include once "AcceptConnectionAsyncTask.bi"
#include once "ContainerOf.bi"
#include once "HeapMemoryAllocator.bi"
#include once "HttpReader.bi"
#include once "NetworkStream.bi"
#include once "ReadRequestAsyncTask.bi"
#include once "TaskExecutor.bi"
#include once "TcpListener.bi"
#include once "WebUtils.bi"

Extern GlobalAcceptConnectionAsyncIoTaskVirtualTable As Const IAcceptConnectionAsyncIoTaskVirtualTable

Type _AcceptConnectionAsyncTask
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IAcceptConnectionAsyncIoTaskVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pListener As ITcpListener Ptr
	pIWebSitesWeakPtr As IWebSiteCollection Ptr
	ListenSocket As SOCKET
	pReadTask As IReadRequestAsyncIoTask Ptr
	pStream As INetworkStream Ptr
	pBuffer As ClientRequestBuffer Ptr
End Type

Function CreateReadTask( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal ppBuffer As ClientRequestBuffer Ptr Ptr, _
		ByVal ppStream As INetworkStream Ptr Ptr _
	)As IReadRequestAsyncIoTask Ptr
	
	Dim pIClientMemoryAllocator As IHeapMemoryAllocator Ptr = GetHeapMemoryAllocatorInstance()
	
	If pIClientMemoryAllocator Then
		
		Dim pIHttpReader As IHttpReader Ptr = Any
		Dim hrCreateHttpReader As HRESULT = CreateHttpReader( _
			CPtr(IMalloc Ptr, pIClientMemoryAllocator), _
			@IID_IHttpReader, _
			@pIHttpReader _
		)
		
		If SUCCEEDED(hrCreateHttpReader) Then
			
			Dim pBuffer As ClientRequestBuffer Ptr = Any
			IHeapMemoryAllocator_GetClientBuffer(pIClientMemoryAllocator, @pBuffer)
			IHttpReader_SetClientBuffer(pIHttpReader, pBuffer)
			*ppBuffer = pBuffer
			
			Dim pINetworkStream As INetworkStream Ptr = Any
			Dim hrCreateNetworkStream As HRESULT = CreateNetworkStream( _
				CPtr(IMalloc Ptr, pIClientMemoryAllocator), _
				@IID_INetworkStream, _
				@pINetworkStream _
			)
			
			If SUCCEEDED(hrCreateNetworkStream) Then
				
				*ppStream = pINetworkStream
				INetworkStream_SetRemoteAddress( _
					pINetworkStream, _
					CPtr(SOCKADDR Ptr, @this->pBuffer->RemoteAddress), _
					SOCKET_ADDRESS_STORAGE_LENGTH _
				)
				
				' TODO Запросить интерфейс вместо конвертирования указателя
				IHttpReader_SetBaseStream( _
					pIHttpReader, _
					CPtr(IBaseStream Ptr, pINetworkStream) _
				)
				
				Dim pTask As IReadRequestAsyncIoTask Ptr = Any
				Dim hrCreateTask As HRESULT = CreateReadRequestAsyncTask( _
					CPtr(IMalloc Ptr, pIClientMemoryAllocator), _
					@IID_IReadRequestAsyncIoTask, _
					@pTask _
				)
				
				If SUCCEEDED(hrCreateTask) Then
					IReadRequestAsyncIoTask_SetBaseStream(pTask, CPtr(IBaseStream Ptr, pINetworkStream))
					IReadRequestAsyncIoTask_SetHttpReader(pTask, pIHttpReader)
					IReadRequestAsyncIoTask_SetWebSiteCollectionWeakPtr(pTask, this->pIWebSitesWeakPtr)
					
					INetworkStream_Release(pINetworkStream)
					IHttpReader_Release(pIHttpReader)
					IHeapMemoryAllocator_Release(pIClientMemoryAllocator)
					
					Return pTask
					
				End If
				
				INetworkStream_Release(pINetworkStream)
			End If
			
			IHttpReader_Release(pIHttpReader)
		End If
		
		IHeapMemoryAllocator_Release(pIClientMemoryAllocator)
	End If
	
	Return NULL
	
End Function

Sub InitializeAcceptConnectionAsyncTask( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pListener As ITcpListener Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_ACCEPTCONNECTIONASYNCTASK), _
			Len(AcceptConnectionAsyncTask.IdString) _
		)
	#endif
	this->lpVtbl = @GlobalAcceptConnectionAsyncIoTaskVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIWebSitesWeakPtr = NULL
	this->ListenSocket = INVALID_SOCKET
	this->pListener = pListener
	this->pReadTask = NULL
	
End Sub

Sub UnInitializeAcceptConnectionAsyncTask( _
		ByVal this As AcceptConnectionAsyncTask Ptr _
	)
	
	If this->pReadTask Then
		IReadRequestAsyncIoTask_Release(this->pReadTask)
	End If
	
End Sub

Sub AcceptConnectionAsyncTaskCreated( _
		ByVal this As AcceptConnectionAsyncTask Ptr _
	)
	
End Sub

Function CreateAcceptConnectionAsyncTask( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Dim pListener As ITcpListener Ptr = Any
	Dim hrCreateListener As HRESULT = CreateTcpListener( _
		pIMemoryAllocator, _
		@IID_ITcpListener, _
		@pListener _
	)
	If FAILED(hrCreateListener) Then
		*ppv = NULL
		Return hrCreateListener
	End If
	
	Dim this As AcceptConnectionAsyncTask Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(AcceptConnectionAsyncTask) _
	)
	If this Then
		InitializeAcceptConnectionAsyncTask( _
			this, _
			pIMemoryAllocator, _
			pListener _
		)
		AcceptConnectionAsyncTaskCreated(this)
		
		Dim hrQueryInterface As HRESULT = AcceptConnectionAsyncTaskQueryInterface( _
			this, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyAcceptConnectionAsyncTask(this)
		End If
		
		Return hrQueryInterface
	End If
	
	*ppv = NULL
	Return E_OUTOFMEMORY
	
End Function

Sub AcceptConnectionAsyncTaskDestroyed( _
		ByVal this As AcceptConnectionAsyncTask Ptr _
	)
	
End Sub

Sub DestroyAcceptConnectionAsyncTask( _
		ByVal this As AcceptConnectionAsyncTask Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeAcceptConnectionAsyncTask(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	AcceptConnectionAsyncTaskDestroyed(this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function AcceptConnectionAsyncTaskQueryInterface( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IAcceptConnectionAsyncIoTask, riid) Then
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
	
	AcceptConnectionAsyncTaskAddRef(this)
	
	Return S_OK
	
End Function

Function AcceptConnectionAsyncTaskAddRef( _
		ByVal this As AcceptConnectionAsyncTask Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return 1
	
End Function

Function AcceptConnectionAsyncTaskRelease( _
		ByVal this As AcceptConnectionAsyncTask Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyAcceptConnectionAsyncTask(this)
	
	Return 0
	
End Function

Function AcceptConnectionAsyncTaskBeginExecute( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	this->pReadTask = CreateReadTask( _
		this, _
		@this->pBuffer, _
		@this->pStream _
	)
	If this->pReadTask = NULL Then
		*ppIResult = NULL
		Return E_OUTOFMEMORY
	End If
	
	Dim hrBeginAccept As HRESULT = ITcpListener_BeginAccept( _
		this->pListener, _
		this->pBuffer, _
		CPtr(IUnknown Ptr, @this->lpVtbl), _
		ppIResult _
	)
	If FAILED(hrBeginAccept) Then
		IReadRequestAsyncIoTask_Release(this->pReadTask)
		this->pReadTask = NULL
		*ppIResult = NULL
		Return hrBeginAccept
	End If
	
	Return ASYNCTASK_S_IO_PENDING
	
End Function

Function AcceptConnectionAsyncTaskEndExecute( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
	)As HRESULT
	
	Dim ClientSocket As SOCKET = Any
	Dim hrEndAccept As HRESULT = ITcpListener_EndAccept( _
		this->pListener, _
		pIResult, _
		BytesTransferred, _
		@ClientSocket _
	)
	If FAILED(hrEndAccept) Then
		*ppNextTask = NULL
		IReadRequestAsyncIoTask_Release(this->pReadTask)
		this->pReadTask = NULL
		Return hrEndAccept
	End If
	
	INetworkStream_SetSocket( _
		this->pStream, _
		ClientSocket _
	)
	
	Dim pIPool As IThreadPool Ptr = GetThreadPoolWeakPtr()
	Dim hrBind As HRESULT = IThreadPool_AssociateDevice( _
		pIPool, _
		Cast(HANDLE, ClientSocket), _
		this->pReadTask _
	)
	If FAILED(hrBind) Then
		*ppNextTask = NULL
		IReadRequestAsyncIoTask_Release(this->pReadTask)
		this->pReadTask = NULL
		Return hrBind
	End If
	
	Dim hrBeginExecute As HRESULT = StartExecuteTask( _
		CPtr(IAsyncIoTask Ptr, this->pReadTask) _
	)
	If FAILED(hrBeginExecute) Then
		IReadRequestAsyncIoTask_Release(this->pReadTask)
	End If
	
	this->pReadTask = NULL
	AcceptConnectionAsyncTaskAddRef(this)
	*ppNextTask = CPtr(IAsyncIoTask Ptr, @this->lpVtbl)
	
	Return S_OK
	
End Function

Function AcceptConnectionAsyncTaskGetBaseStream( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	
	*ppStream = NULL
	
	Return E_NOTIMPL
	
End Function

Function AcceptConnectionAsyncTaskSetBaseStream( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pStream As IBaseStream Ptr _
	)As HRESULT
	
	Return E_NOTIMPL
	
End Function

Function AcceptConnectionAsyncTaskGetHttpReader( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	*ppReader = NULL
	
	Return E_NOTIMPL
	
End Function

Function AcceptConnectionAsyncTaskSetHttpReader( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pReader As IHttpReader Ptr _
	)As HRESULT
	
	Return E_NOTIMPL
	
End Function

Function AcceptConnectionAsyncTaskSetWebSiteCollectionWeakPtr( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pCollection As IWebSiteCollection Ptr _
	)As HRESULT
	
	this->pIWebSitesWeakPtr = pCollection
	
	Return S_OK
	
End Function

Function AcceptConnectionAsyncTaskGetListenSocket( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pListenSocket As SOCKET Ptr _
	)As HRESULT
	
	*pListenSocket = this->ListenSocket
	
	Return S_OK
	
End Function

Function AcceptConnectionAsyncTaskSetListenSocket( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal ListenSocket As SOCKET _
	)As HRESULT
	
	this->ListenSocket = ListenSocket
	
	ITcpListener_SetListenSocket(this->pListener, ListenSocket)
	
	Return S_OK
	
End Function


Function IAcceptConnectionAsyncTaskQueryInterface( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskQueryInterface(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), riid, ppv)
End Function

Function IAcceptConnectionAsyncTaskAddRef( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr _
	)As ULONG
	Return AcceptConnectionAsyncTaskAddRef(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl))
End Function

Function IAcceptConnectionAsyncTaskRelease( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr _
	)As ULONG
	Return AcceptConnectionAsyncTaskRelease(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl))
End Function

Function IAcceptConnectionAsyncTaskBeginExecute( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As ULONG
	Return AcceptConnectionAsyncTaskBeginExecute(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), ppIResult)
End Function

Function IAcceptConnectionAsyncTaskEndExecute( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
	)As ULONG
	Return AcceptConnectionAsyncTaskEndExecute(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pIResult, BytesTransferred, ppNextTask)
End Function

Function IAcceptConnectionAsyncTaskGetBaseStream( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskGetBaseStream(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), ppStream)
End Function

Function IAcceptConnectionAsyncTaskSetBaseStream( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		byVal pStream As IBaseStream Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskSetBaseStream(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pStream)
End Function

Function IAcceptConnectionAsyncTaskGetHttpReader( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskGetHttpReader(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), ppReader)
End Function

Function IAcceptConnectionAsyncTaskSetHttpReader( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskSetHttpReader(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pReader)
End Function

Function IAcceptConnectionAsyncTaskSetWebSiteCollectionWeakPtr( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pCollection As IWebSiteCollection Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskSetWebSiteCollectionWeakPtr(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pCollection)
End Function

Function IAcceptConnectionAsyncTaskGetListenSocket( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pListenSocket As SOCKET Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskGetListenSocket(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pListenSocket)
End Function

Function IAcceptConnectionAsyncTaskSetListenSocket( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal ListenSocket As SOCKET _
	)As HRESULT
	Return AcceptConnectionAsyncTaskSetListenSocket(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), ListenSocket)
End Function

Dim GlobalAcceptConnectionAsyncIoTaskVirtualTable As Const IAcceptConnectionAsyncIoTaskVirtualTable = Type( _
	@IAcceptConnectionAsyncTaskQueryInterface, _
	@IAcceptConnectionAsyncTaskAddRef, _
	@IAcceptConnectionAsyncTaskRelease, _
	@IAcceptConnectionAsyncTaskBeginExecute, _
	@IAcceptConnectionAsyncTaskEndExecute, _
	@IAcceptConnectionAsyncTaskGetBaseStream, _
	@IAcceptConnectionAsyncTaskSetBaseStream, _
	@IAcceptConnectionAsyncTaskGetHttpReader, _
	@IAcceptConnectionAsyncTaskSetHttpReader, _
	@IAcceptConnectionAsyncTaskSetWebSiteCollectionWeakPtr, _
	@IAcceptConnectionAsyncTaskGetListenSocket, _
	@IAcceptConnectionAsyncTaskSetListenSocket _
)
