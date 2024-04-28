#include once "AcceptConnectionAsyncTask.bi"
#include once "ContainerOf.bi"
#include once "TcpAsyncListener.bi"

Extern GlobalAcceptConnectionAsyncIoTaskVirtualTable As Const IAcceptConnectionAsyncIoTaskVirtualTable

Type AcceptConnectionAsyncTask
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IAcceptConnectionAsyncIoTaskVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pListener As ITcpListener Ptr
	ListenSocket As SOCKET
	ClientSocket As SOCKET
End Type

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
	
	AcceptConnectionAsyncTaskAddRef(this)
	
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
		ByVal pcb As AsyncCallback, _
		ByVal state As Any Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Dim hrBeginAccept As HRESULT = ITcpListener_BeginAccept( _
		this->pListener, _
		pcb, _
		state, _
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
		ByVal pIResult As IAsyncResult Ptr _
	)As HRESULT
	
	Dim hrEndAccept As HRESULT = ITcpListener_EndAccept( _
		this->pListener, _
		pIResult, _
		@this->ClientSocket _
	)
	If FAILED(hrEndAccept) Then
		Return hrEndAccept
	End If
	
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

Private Function AcceptConnectionAsyncTaskGetClientSocket( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pClientSocket As SOCKET Ptr _
	)As HRESULT
	
	*pClientSocket = this->ClientSocket
	
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

Private Function IAcceptConnectionAsyncTaskBeginExecute( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal state As Any Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As ULONG
	Return AcceptConnectionAsyncTaskBeginExecute(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pcb, state, ppIResult)
End Function

Private Function IAcceptConnectionAsyncTaskEndExecute( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr _
	)As ULONG
	Return AcceptConnectionAsyncTaskEndExecute(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pIResult)
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

Private Function IAcceptConnectionAsyncTaskGetClientSocket( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pClientSocket As SOCKET Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskGetClientSocket(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pClientSocket)
End Function

Dim GlobalAcceptConnectionAsyncIoTaskVirtualTable As Const IAcceptConnectionAsyncIoTaskVirtualTable = Type( _
	@IAcceptConnectionAsyncTaskQueryInterface, _
	@IAcceptConnectionAsyncTaskAddRef, _
	@IAcceptConnectionAsyncTaskRelease, _
	@IAcceptConnectionAsyncTaskBeginExecute, _
	@IAcceptConnectionAsyncTaskEndExecute, _
	@IAcceptConnectionAsyncTaskGetListenSocket, _
	@IAcceptConnectionAsyncTaskSetListenSocket, _
	@IAcceptConnectionAsyncTaskGetClientSocket _
)
