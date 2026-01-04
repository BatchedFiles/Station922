#include once "AcceptConnectionAsyncTask.bi"
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
		ByVal self As AcceptConnectionAsyncTask Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pListener As ITcpListener Ptr _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@self->RttiClassName(0), _
			@Str(RTTI_ID_ACCEPTCONNECTIONASYNCTASK), _
			UBound(self->RttiClassName) - LBound(self->RttiClassName) + 1 _
		)
	#endif
	self->lpVtbl = @GlobalAcceptConnectionAsyncIoTaskVirtualTable
	self->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	self->pIMemoryAllocator = pIMemoryAllocator
	self->ListenSocket = INVALID_SOCKET
	' Do not need AddRef pListener
	self->pListener = pListener

End Sub

Private Sub UnInitializeAcceptConnectionAsyncTask( _
		ByVal self As AcceptConnectionAsyncTask Ptr _
	)

End Sub

Private Sub AcceptConnectionAsyncTaskCreated( _
		ByVal self As AcceptConnectionAsyncTask Ptr _
	)

End Sub

Private Sub AcceptConnectionAsyncTaskDestroyed( _
		ByVal self As AcceptConnectionAsyncTask Ptr _
	)

End Sub

Private Sub DestroyAcceptConnectionAsyncTask( _
		ByVal self As AcceptConnectionAsyncTask Ptr _
	)

	Dim pIMemoryAllocator As IMalloc Ptr = self->pIMemoryAllocator

	UnInitializeAcceptConnectionAsyncTask(self)

	IMalloc_Free(pIMemoryAllocator, self)

	AcceptConnectionAsyncTaskDestroyed(self)

	IMalloc_Release(pIMemoryAllocator)

End Sub

Private Function AcceptConnectionAsyncTaskAddRef( _
		ByVal self As AcceptConnectionAsyncTask Ptr _
	)As ULONG

	self->ReferenceCounter += 1

	Return 1

End Function

Private Function AcceptConnectionAsyncTaskRelease( _
		ByVal self As AcceptConnectionAsyncTask Ptr _
	)As ULONG

	self->ReferenceCounter -= 1

	If self->ReferenceCounter Then
		Return 1
	End If

	DestroyAcceptConnectionAsyncTask(self)

	Return 0

End Function

Private Function AcceptConnectionAsyncTaskQueryInterface( _
		ByVal self As AcceptConnectionAsyncTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_IAcceptConnectionAsyncIoTask, riid) Then
		*ppv = @self->lpVtbl
	Else
		If IsEqualIID(@IID_IAsyncIoTask, riid) Then
			*ppv = @self->lpVtbl
		Else
			If IsEqualIID(@IID_IUnknown, riid) Then
				*ppv = @self->lpVtbl
			Else
				*ppv = NULL
				Return E_NOINTERFACE
			End If
		End If
	End If

	AcceptConnectionAsyncTaskAddRef(self)

	Return S_OK

End Function

Public Function CreateAcceptConnectionAsyncTask( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	Dim self As AcceptConnectionAsyncTask Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(AcceptConnectionAsyncTask) _
	)

	If self Then
		Dim pListener As ITcpListener Ptr = Any
		Dim hrCreateListener As HRESULT = CreateTcpListener( _
			pIMemoryAllocator, _
			@IID_ITcpListener, _
			@pListener _
		)

		If SUCCEEDED(hrCreateListener) Then

			InitializeAcceptConnectionAsyncTask( _
				self, _
				pIMemoryAllocator, _
				pListener _
			)
			AcceptConnectionAsyncTaskCreated(self)

			Dim hrQueryInterface As HRESULT = AcceptConnectionAsyncTaskQueryInterface( _
				self, _
				riid, _
				ppv _
			)
			If FAILED(hrQueryInterface) Then
				DestroyAcceptConnectionAsyncTask(self)
			End If

			Return hrQueryInterface
		End If

		IMalloc_Free( _
			pIMemoryAllocator, _
			self _
		)
	End If

	*ppv = NULL
	Return E_OUTOFMEMORY

End Function

Private Function AcceptConnectionAsyncTaskBeginExecute( _
		ByVal self As AcceptConnectionAsyncTask Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal state As Any Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	Dim hrBeginAccept As HRESULT = ITcpListener_BeginAccept( _
		self->pListener, _
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
		ByVal self As AcceptConnectionAsyncTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr _
	)As HRESULT

	Dim hrEndAccept As HRESULT = ITcpListener_EndAccept( _
		self->pListener, _
		pIResult, _
		@self->ClientSocket _
	)
	If FAILED(hrEndAccept) Then
		Return hrEndAccept
	End If

	Return S_OK

End Function

Private Function AcceptConnectionAsyncTaskGetListenSocket( _
		ByVal self As AcceptConnectionAsyncTask Ptr, _
		ByVal pListenSocket As SOCKET Ptr _
	)As HRESULT

	*pListenSocket = self->ListenSocket

	Return S_OK

End Function

Private Function AcceptConnectionAsyncTaskSetListenSocket( _
		ByVal self As AcceptConnectionAsyncTask Ptr, _
		ByVal ListenSocket As SOCKET _
	)As HRESULT

	self->ListenSocket = ListenSocket

	ITcpListener_SetListenSocket(self->pListener, ListenSocket)

	Return S_OK

End Function

Private Function AcceptConnectionAsyncTaskGetClientSocket( _
		ByVal self As AcceptConnectionAsyncTask Ptr, _
		ByVal pClientSocket As SOCKET Ptr _
	)As HRESULT

	*pClientSocket = self->ClientSocket

	Return S_OK

End Function


Private Function IAcceptConnectionAsyncTaskQueryInterface( _
		ByVal self As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskQueryInterface(CONTAINING_RECORD(self, AcceptConnectionAsyncTask, lpVtbl), riid, ppv)
End Function

Private Function IAcceptConnectionAsyncTaskAddRef( _
		ByVal self As IAcceptConnectionAsyncIoTask Ptr _
	)As ULONG
	Return AcceptConnectionAsyncTaskAddRef(CONTAINING_RECORD(self, AcceptConnectionAsyncTask, lpVtbl))
End Function

Private Function IAcceptConnectionAsyncTaskRelease( _
		ByVal self As IAcceptConnectionAsyncIoTask Ptr _
	)As ULONG
	Return AcceptConnectionAsyncTaskRelease(CONTAINING_RECORD(self, AcceptConnectionAsyncTask, lpVtbl))
End Function

Private Function IAcceptConnectionAsyncTaskBeginExecute( _
		ByVal self As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal state As Any Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As ULONG
	Return AcceptConnectionAsyncTaskBeginExecute(CONTAINING_RECORD(self, AcceptConnectionAsyncTask, lpVtbl), pcb, state, ppIResult)
End Function

Private Function IAcceptConnectionAsyncTaskEndExecute( _
		ByVal self As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr _
	)As ULONG
	Return AcceptConnectionAsyncTaskEndExecute(CONTAINING_RECORD(self, AcceptConnectionAsyncTask, lpVtbl), pIResult)
End Function

Private Function IAcceptConnectionAsyncTaskGetListenSocket( _
		ByVal self As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pListenSocket As SOCKET Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskGetListenSocket(CONTAINING_RECORD(self, AcceptConnectionAsyncTask, lpVtbl), pListenSocket)
End Function

Private Function IAcceptConnectionAsyncTaskSetListenSocket( _
		ByVal self As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal ListenSocket As SOCKET _
	)As HRESULT
	Return AcceptConnectionAsyncTaskSetListenSocket(CONTAINING_RECORD(self, AcceptConnectionAsyncTask, lpVtbl), ListenSocket)
End Function

Private Function IAcceptConnectionAsyncTaskGetClientSocket( _
		ByVal self As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pClientSocket As SOCKET Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskGetClientSocket(CONTAINING_RECORD(self, AcceptConnectionAsyncTask, lpVtbl), pClientSocket)
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
