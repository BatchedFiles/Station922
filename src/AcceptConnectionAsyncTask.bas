#include once "AcceptConnectionAsyncTask.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "HeapMemoryAllocator.bi"
#include once "HttpReader.bi"
#include once "Logger.bi"
#include once "NetworkStream.bi"
#include once "ReadRequestAsyncTask.bi"
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
	pIWebSitesWeakPtr As IWebSiteCollection Ptr
	pIProcessorsWeakPtr As IHttpProcessorCollection Ptr
	pIPoolWeakPtr As IThreadPool Ptr
	pListener As ITcpListener Ptr
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
		Dim hrCreateHttpReader As HRESULT = CreateInstance( _
			CPtr(IMalloc Ptr, pIClientMemoryAllocator), _
			@CLSID_HTTPREADER, _
			@IID_IHttpReader, _
			@pIHttpReader _
		)
		
		If SUCCEEDED(hrCreateHttpReader) Then
			
			Dim pBuffer As ClientRequestBuffer Ptr = Any
			IHeapMemoryAllocator_GetClientBuffer(pIClientMemoryAllocator, @pBuffer)
			IHttpReader_SetClientBuffer(pIHttpReader, pBuffer)
			*ppBuffer = pBuffer
			
			Dim pINetworkStream As INetworkStream Ptr = Any
			Dim hrCreateNetworkStream As HRESULT = CreateInstance( _
				CPtr(IMalloc Ptr, pIClientMemoryAllocator), _
				@CLSID_NETWORKSTREAM, _
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
				Dim hrCreateTask As HRESULT = CreateInstance( _
					CPtr(IMalloc Ptr, pIClientMemoryAllocator), _
					@CLSID_READREQUESTASYNCTASK, _
					@IID_IReadRequestAsyncIoTask, _
					@pTask _
				)
				
				If SUCCEEDED(hrCreateTask) Then
					IReadRequestAsyncIoTask_SetWebSiteCollectionWeakPtr(pTask, this->pIWebSitesWeakPtr)
					IReadRequestAsyncIoTask_SetHttpProcessorCollectionWeakPtr(pTask, this->pIProcessorsWeakPtr)
					IReadRequestAsyncIoTask_SetBaseStream(pTask, CPtr(IBaseStream Ptr, pINetworkStream))
					IReadRequestAsyncIoTask_SetHttpReader(pTask, pIHttpReader)
					
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
	this->ReferenceCounter = CUInt(-1)
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIWebSitesWeakPtr = NULL
	this->pIProcessorsWeakPtr = NULL
	this->pIPoolWeakPtr = NULL
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

Function CreatePermanentAcceptConnectionAsyncTask( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As AcceptConnectionAsyncTask Ptr
	
	Dim pListener As ITcpListener Ptr = Any
	Dim hrCreateListener As HRESULT = CreatePermanentInstance( _
		pIMemoryAllocator, _
		@CLSID_TCPLISTENER, _
		@IID_ITcpListener, _
		@pListener _
	)
	
	If SUCCEEDED(hrCreateListener) Then
		
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
			
			Return this
		End If
		
		ITcpListener_Release(pListener)
	End If
	
	Return NULL
	
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
	
	Return 1
	
End Function

Function AcceptConnectionAsyncTaskRelease( _
		ByVal this As AcceptConnectionAsyncTask Ptr _
	)As ULONG
	
	Return 0
	
End Function

Function AcceptConnectionAsyncTaskBindToThreadPool( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr _
	)As HRESULT
	
	this->pIPoolWeakPtr = pPool
	
	Dim Port As HANDLE = Any
	IThreadPool_GetIOCompletionPort(pPool, @Port)
	
	Dim NewPort As HANDLE = CreateIoCompletionPort( _
		Cast(HANDLE, this->ListenSocket), _
		Port, _
		Cast(ULONG_PTR, this), _
		0 _
	)
	If NewPort = NULL Then
		Dim dwError As DWORD = GetLastError()
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Return S_OK
	
End Function

Function AcceptConnectionAsyncTaskBeginExecute( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Do
		this->pReadTask = CreateReadTask( _
			this, _
			@this->pBuffer, _
			@this->pStream _
		)
		
		If this->pReadTask Then
			
			Dim hrBeginAccept As HRESULT = ITcpListener_BeginAccept( _
				this->pListener, _
				this->pBuffer, _
				CPtr(IUnknown Ptr, @this->lpVtbl), _
				ppIResult _
			)
			
			If SUCCEEDED(hrBeginAccept) Then
				Return ASYNCTASK_S_IO_PENDING
			End If
			
			IReadRequestAsyncIoTask_Release(this->pReadTask)
			this->pReadTask = NULL
			*ppIResult = NULL
		End If
	Loop
	
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
	
	If SUCCEEDED(hrEndAccept) Then
		INetworkStream_SetSocket( _
			this->pStream, _
			ClientSocket _
		)
		
		Dim hrAssociate As HRESULT = IReadRequestAsyncIoTask_BindToThreadPool( _
			this->pReadTask, _
			this->pIPoolWeakPtr _
		)
		
		If SUCCEEDED(hrAssociate) Then
			
			Dim hrBeginExecute As HRESULT = StartExecuteTask( _
				CPtr(IAsyncIoTask Ptr, this->pReadTask) _
			)
			If FAILED(hrBeginExecute) Then
				IReadRequestAsyncIoTask_Release(this->pReadTask)
			End If
			
		Else
			IReadRequestAsyncIoTask_Release(this->pReadTask)
		End If
	Else
		IReadRequestAsyncIoTask_Release(this->pReadTask)
	End If
	
	this->pReadTask = NULL
	
	AcceptConnectionAsyncTaskAddRef(this)
	*ppNextTask = CPtr(IAsyncIoTask Ptr, @this->lpVtbl)
	
	Return S_OK
	
End Function

Function AcceptConnectionAsyncTaskGetWebSiteCollectionWeakPtr( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	
	*ppIWebSites = this->pIWebSitesWeakPtr
	
	Return S_OK
	
End Function

Function AcceptConnectionAsyncTaskSetWebSiteCollectionWeakPtr( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	
	this->pIWebSitesWeakPtr = pIWebSites
	
	Return S_OK
	
End Function

Function AcceptConnectionAsyncTaskGetHttpProcessorCollectionWeakPtr( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	
	*ppIProcessors = this->pIProcessorsWeakPtr
	
	Return S_OK
	
End Function

Function AcceptConnectionAsyncTaskSetHttpProcessorCollectionWeakPtr( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pIProcessors As IHttpProcessorCollection Ptr _
	)As HRESULT
	
	this->pIProcessorsWeakPtr = pIProcessors
	
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
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	
	Return E_NOTIMPL
	
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

Function IAcceptConnectionAsyncTaskBindToThreadPool( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pPool As IThreadPool Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskBindToThreadPool(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pPool)
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

Function IAcceptConnectionAsyncTaskGetWebSiteCollectionWeakPtr( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskGetWebSiteCollectionWeakPtr(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), ppIWebSites)
End Function

Function IAcceptConnectionAsyncTaskSetWebSiteCollectionWeakPtr( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskSetWebSiteCollectionWeakPtr(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pIWebSites)
End Function

Function IAcceptConnectionAsyncTaskGetHttpProcessorCollectionWeakPtr( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskGetHttpProcessorCollectionWeakPtr(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), ppIProcessors)
End Function

Function IAcceptConnectionAsyncTaskSetHttpProcessorCollectionWeakPtr( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pIProcessors As IHttpProcessorCollection Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskSetHttpProcessorCollectionWeakPtr(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pIProcessors)
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
	@IAcceptConnectionAsyncTaskBindToThreadPool, _
	@IAcceptConnectionAsyncTaskBeginExecute, _
	@IAcceptConnectionAsyncTaskEndExecute, _
	@IAcceptConnectionAsyncTaskGetWebSiteCollectionWeakPtr, _
	@IAcceptConnectionAsyncTaskSetWebSiteCollectionWeakPtr, _
	@IAcceptConnectionAsyncTaskGetHttpProcessorCollectionWeakPtr, _
	@IAcceptConnectionAsyncTaskSetHttpProcessorCollectionWeakPtr, _
	@IAcceptConnectionAsyncTaskGetBaseStream, _
	@IAcceptConnectionAsyncTaskSetBaseStream, _
	@IAcceptConnectionAsyncTaskGetHttpReader, _
	@IAcceptConnectionAsyncTaskSetHttpReader, _
	@IAcceptConnectionAsyncTaskGetListenSocket, _
	@IAcceptConnectionAsyncTaskSetListenSocket _
)
