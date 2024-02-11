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

Type AcceptConnectionAsyncTask
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IAcceptConnectionAsyncIoTaskVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pListener As ITcpListener Ptr
	pIWebSitesWeakPtr As IWebSiteCollection Ptr
	ListenSocket As SOCKET
End Type

Private Function CreateReadTask( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
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
			
			Dim pINetworkStream As INetworkStream Ptr = Any
			Dim hrCreateNetworkStream As HRESULT = CreateNetworkStream( _
				CPtr(IMalloc Ptr, pIClientMemoryAllocator), _
				@IID_INetworkStream, _
				@pINetworkStream _
			)
			
			If SUCCEEDED(hrCreateNetworkStream) Then
				
				*ppStream = pINetworkStream
				
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

Private Sub InitializeAcceptConnectionAsyncTask( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pListener As ITcpListener Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->RttiClassName(0), _
			@Str(RTTI_ID_ACCEPTCONNECTIONASYNCTASK), _
			UBound(this->RttiClassName) - LBound(this->RttiClassName) + 1 _
		)
	#endif
	this->lpVtbl = @GlobalAcceptConnectionAsyncIoTaskVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIWebSitesWeakPtr = NULL
	this->ListenSocket = INVALID_SOCKET
	' Do not need AddRef pListener
	this->pListener = pListener
	
End Sub

Private Sub UnInitializeAcceptConnectionAsyncTask( _
		ByVal this As AcceptConnectionAsyncTask Ptr _
	)
	
End Sub

Private Sub AcceptConnectionAsyncTaskCreated( _
		ByVal this As AcceptConnectionAsyncTask Ptr _
	)
	
End Sub

Private Sub AcceptConnectionAsyncTaskDestroyed( _
		ByVal this As AcceptConnectionAsyncTask Ptr _
	)
	
End Sub

Private Sub DestroyAcceptConnectionAsyncTask( _
		ByVal this As AcceptConnectionAsyncTask Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeAcceptConnectionAsyncTask(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	AcceptConnectionAsyncTaskDestroyed(this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Private Function AcceptConnectionAsyncTaskAddRef( _
		ByVal this As AcceptConnectionAsyncTask Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return 1
	
End Function

Private Function AcceptConnectionAsyncTaskRelease( _
		ByVal this As AcceptConnectionAsyncTask Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyAcceptConnectionAsyncTask(this)
	
	Return 0
	
End Function

Private Function AcceptConnectionAsyncTaskQueryInterface( _
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

Private Function AcceptConnectionAsyncTaskGetTaskId( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pId As AsyncIoTaskIDs Ptr _
	)As HRESULT
	
	*pId = AsyncIoTaskIDs.AcceptConnection
	
	Return S_OK
	
End Function

Public Function CreateAcceptConnectionAsyncTask( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Dim this As AcceptConnectionAsyncTask Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(AcceptConnectionAsyncTask) _
	)
	
	If this Then
		Dim pListener As ITcpListener Ptr = Any
		Dim hrCreateListener As HRESULT = CreateTcpListener( _
			pIMemoryAllocator, _
			@IID_ITcpListener, _
			@pListener _
		)
		
		If SUCCEEDED(hrCreateListener) Then
			
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
		
		IMalloc_Free( _
			pIMemoryAllocator, _
			this _
		)
	End If
	
	*ppv = NULL
	Return E_OUTOFMEMORY
	
End Function

Private Function AcceptConnectionAsyncTaskBeginExecute( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Dim hrBeginAccept As HRESULT = ITcpListener_BeginAccept( _
		this->pListener, _
		CPtr(IUnknown Ptr, @this->lpVtbl), _
		ppIResult _
	)
	If FAILED(hrBeginAccept) Then
		*ppIResult = NULL
		Return hrBeginAccept
	End If
	
	Return S_OK
	
End Function

Private Function AcceptConnectionAsyncTaskEndExecute( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
	)As HRESULT
	
	Dim ClientSocket As SOCKET = Any
	Dim hrEndAccept As HRESULT = ITcpListener_EndAccept( _
		this->pListener, _
		pIResult, _
		@ClientSocket _
	)
	If FAILED(hrEndAccept) Then
		*ppNextTask = NULL
		Return hrEndAccept
	End If
	
	Dim pStream As INetworkStream Ptr = Any
	Dim pReadTask As IReadRequestAsyncIoTask Ptr = CreateReadTask( _
		this, _
		@pStream _
	)
	If pReadTask = NULL Then
		*ppNextTask = NULL
		Return E_OUTOFMEMORY
	End If
	
	INetworkStream_SetSocket( _
		pStream, _
		ClientSocket _
	)
	
	Dim pIPool As IThreadPool Ptr = GetThreadPoolWeakPtr()
	Dim hrBind As HRESULT = IThreadPool_AssociateDevice( _
		pIPool, _
		Cast(HANDLE, ClientSocket), _
		pReadTask _
	)
	If FAILED(hrBind) Then
		*ppNextTask = NULL
		IReadRequestAsyncIoTask_Release(pReadTask)
		Return hrBind
	End If
	
	Dim hrBeginExecute As HRESULT = StartExecuteTask( _
		CPtr(IAsyncIoTask Ptr, pReadTask) _
	)
	If FAILED(hrBeginExecute) Then
		*ppNextTask = NULL
		IReadRequestAsyncIoTask_Release(pReadTask)
	End If
	
	AcceptConnectionAsyncTaskAddRef(this)
	*ppNextTask = CPtr(IAsyncIoTask Ptr, @this->lpVtbl)
	
	Return S_OK
	
End Function

Private Function AcceptConnectionAsyncTaskGetBaseStream( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	
	*ppStream = NULL
	
	Return E_NOTIMPL
	
End Function

Private Function AcceptConnectionAsyncTaskSetBaseStream( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pStream As IBaseStream Ptr _
	)As HRESULT
	
	Return E_NOTIMPL
	
End Function

Private Function AcceptConnectionAsyncTaskGetHttpReader( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	*ppReader = NULL
	
	Return E_NOTIMPL
	
End Function

Private Function AcceptConnectionAsyncTaskSetHttpReader( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pReader As IHttpReader Ptr _
	)As HRESULT
	
	Return E_NOTIMPL
	
End Function

Private Function AcceptConnectionAsyncTaskSetWebSiteCollectionWeakPtr( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pCollection As IWebSiteCollection Ptr _
	)As HRESULT
	
	this->pIWebSitesWeakPtr = pCollection
	
	Return S_OK
	
End Function

Private Function AcceptConnectionAsyncTaskGetListenSocket( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pListenSocket As SOCKET Ptr _
	)As HRESULT
	
	*pListenSocket = this->ListenSocket
	
	Return S_OK
	
End Function

Private Function AcceptConnectionAsyncTaskSetListenSocket( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal ListenSocket As SOCKET _
	)As HRESULT
	
	this->ListenSocket = ListenSocket
	
	ITcpListener_SetListenSocket(this->pListener, ListenSocket)
	
	Return S_OK
	
End Function


Private Function IAcceptConnectionAsyncTaskQueryInterface( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskQueryInterface(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), riid, ppv)
End Function

Private Function IAcceptConnectionAsyncTaskAddRef( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr _
	)As ULONG
	Return AcceptConnectionAsyncTaskAddRef(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl))
End Function

Private Function IAcceptConnectionAsyncTaskRelease( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr _
	)As ULONG
	Return AcceptConnectionAsyncTaskRelease(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl))
End Function

Private Function IAcceptConnectionAsyncTaskGetTaskId( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pId As AsyncIoTaskIDs Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskGetTaskId(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pId)
End Function

Private Function IAcceptConnectionAsyncTaskBeginExecute( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As ULONG
	Return AcceptConnectionAsyncTaskBeginExecute(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), ppIResult)
End Function

Private Function IAcceptConnectionAsyncTaskEndExecute( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
	)As ULONG
	Return AcceptConnectionAsyncTaskEndExecute(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pIResult, ppNextTask)
End Function

Private Function IAcceptConnectionAsyncTaskGetBaseStream( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskGetBaseStream(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), ppStream)
End Function

Private Function IAcceptConnectionAsyncTaskSetBaseStream( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		byVal pStream As IBaseStream Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskSetBaseStream(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pStream)
End Function

Private Function IAcceptConnectionAsyncTaskGetHttpReader( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskGetHttpReader(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), ppReader)
End Function

Private Function IAcceptConnectionAsyncTaskSetHttpReader( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskSetHttpReader(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pReader)
End Function

Private Function IAcceptConnectionAsyncTaskSetWebSiteCollectionWeakPtr( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pCollection As IWebSiteCollection Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskSetWebSiteCollectionWeakPtr(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pCollection)
End Function

Private Function IAcceptConnectionAsyncTaskGetListenSocket( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pListenSocket As SOCKET Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskGetListenSocket(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pListenSocket)
End Function

Private Function IAcceptConnectionAsyncTaskSetListenSocket( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal ListenSocket As SOCKET _
	)As HRESULT
	Return AcceptConnectionAsyncTaskSetListenSocket(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), ListenSocket)
End Function

Dim GlobalAcceptConnectionAsyncIoTaskVirtualTable As Const IAcceptConnectionAsyncIoTaskVirtualTable = Type( _
	@IAcceptConnectionAsyncTaskQueryInterface, _
	@IAcceptConnectionAsyncTaskAddRef, _
	@IAcceptConnectionAsyncTaskRelease, _
	@IAcceptConnectionAsyncTaskGetTaskId, _
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
