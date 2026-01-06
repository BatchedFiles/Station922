#include once "ThreadPool.bi"

Extern GlobalThreadPoolVirtualTable As Const IThreadPoolVirtualTable

Type ThreadPool
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IThreadPoolVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	CompletionPort As HANDLE
	WorkerThreadsCount As UInteger
	hThreads As HANDLE Ptr
End Type

Private Function CreateNewCompletionPort( _
		ByVal dwNumberOfConcurrentThreads As DWORD _
	)As HANDLE

	Dim hPort As HANDLE = CreateIoCompletionPort( _
		INVALID_HANDLE_VALUE, _
		NULL, _
		0, _
		dwNumberOfConcurrentThreads _
	)

	Return hPort

End Function

Private Function WorkerThread( _
		ByVal lpParam As LPVOID _
	)As DWORD

	Dim self As ThreadPool Ptr = lpParam

	Do

		Dim BytesTransferred As DWORD = Any
		Dim CompletionKey As ULONG_PTR = Any
		Dim pOverlap As OVERLAPPED Ptr = Any
		Dim dwError As DWORD = Any

		Dim resCompletionStatus As BOOL = GetQueuedCompletionStatus( _
			self->CompletionPort, _
			@BytesTransferred, _
			@CompletionKey, _
			@pOverlap, _
			INFINITE _
		)

		If resCompletionStatus Then
			If CompletionKey = 0 Then
				Exit Do
			End If

			dwError = ERROR_SUCCESS
		Else
			If pOverlap = NULL Then
				Exit Do
			End If

			dwError = GetLastError()
		End If

		Dim pIResult As IAsyncResult Ptr = GetAsyncResultFromOverlappedWeakPtr(pOverlap)

		IAsyncResult_SetCompleted( _
			pIResult, _
			BytesTransferred, _
			True, _
			dwError _
		)

		Dim pcb As AsyncCallback = Any
		IAsyncResult_GetAsyncCallback(pIResult, @pcb)

		If pcb Then
			pcb(pIResult)
		End If
	Loop

	Return 0

End Function

Private Sub InitializeThreadPool( _
		ByVal self As ThreadPool Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@self->RttiClassName(0), _
			@Str(RTTI_ID_THREADPOOL), _
			UBound(self->RttiClassName) - LBound(self->RttiClassName) + 1 _
		)
	#endif
	self->lpVtbl = @GlobalThreadPoolVirtualTable
	self->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	self->pIMemoryAllocator = pIMemoryAllocator
	self->CompletionPort = NULL
	self->WorkerThreadsCount = 0
	self->hThreads = NULL

End Sub

Private Sub UnInitializeThreadPool( _
		ByVal self As ThreadPool Ptr _
	)

	If self->CompletionPort Then
		CloseHandle(self->CompletionPort)
	End If

	If self->hThreads Then
		IMalloc_Free(self->pIMemoryAllocator, self->hThreads)
	End If

End Sub

Private Sub DestroyThreadPool( _
		ByVal self As ThreadPool Ptr _
	)

	Dim pIMemoryAllocator As IMalloc Ptr = self->pIMemoryAllocator

	UnInitializeThreadPool(self)

	IMalloc_Free(pIMemoryAllocator, self)

	IMalloc_Release(pIMemoryAllocator)

End Sub

Private Function ThreadPoolAddRef( _
		ByVal self As ThreadPool Ptr _
	)As ULONG

	self->ReferenceCounter += 1

	Return 1

End Function

Private Function ThreadPoolRelease( _
		ByVal self As ThreadPool Ptr _
	)As ULONG

	self->ReferenceCounter -= 1

	If self->ReferenceCounter Then
		Return 1
	End If

	DestroyThreadPool(self)

	Return 0

End Function

Private Function ThreadPoolQueryInterface( _
		ByVal self As ThreadPool Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_IThreadPool, riid) Then
		*ppv = @self->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @self->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If

	ThreadPoolAddRef(self)

	Return S_OK

End Function

Public Function CreateThreadPool( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	Dim self As ThreadPool Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(ThreadPool) _
	)

	If self Then
		InitializeThreadPool(self, pIMemoryAllocator)

		Dim hrQueryInterface As HRESULT = ThreadPoolQueryInterface( _
			self, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyThreadPool(self)
		End If

		Return hrQueryInterface
	End If

	*ppv = NULL
	Return E_OUTOFMEMORY

End Function

Private Function ThreadPoolGetMaxThreads( _
		ByVal self As ThreadPool Ptr, _
		ByVal pMaxThreads As UInteger Ptr _
	)As HRESULT

	*pMaxThreads = self->WorkerThreadsCount

	Return S_OK

End Function

Private Function ThreadPoolSetMaxThreads( _
		ByVal self As ThreadPool Ptr, _
		ByVal MaxThreads As UInteger _
	)As HRESULT

	self->WorkerThreadsCount = MaxThreads

	Return S_OK

End Function

Private Function ThreadPoolRun( _
		ByVal self As ThreadPool Ptr _
	)As HRESULT

	self->CompletionPort = CreateNewCompletionPort( _
		self->WorkerThreadsCount _
	)
	If self->CompletionPort = NULL Then
		Dim dwError As DWORD = GetLastError()
		Return HRESULT_FROM_WIN32(dwError)
	End If

	self->hThreads = IMalloc_Alloc( _
		self->pIMemoryAllocator, _
		SizeOf(HANDLE) * self->WorkerThreadsCount _
	)
	If self = NULL Then
		Return E_OUTOFMEMORY
	End If

	Const DefaultStackSize As SIZE_T_ = 0

	For i As UInteger = 0 To self->WorkerThreadsCount - 1

		Dim ThreadId As DWORD = Any
		self->hThreads[i] = CreateThread( _
			NULL, _
			DefaultStackSize, _
			@WorkerThread, _
			self, _
			0, _
			@ThreadId _
		)
		If self->hThreads[i] = NULL Then
			Dim dwError As DWORD = GetLastError()
			Return HRESULT_FROM_WIN32(dwError)
		End If

	Next

	Return S_OK

End Function

Private Function ThreadPoolStop( _
		ByVal self As ThreadPool Ptr _
	)As HRESULT

	For i As Integer = 0 To self->WorkerThreadsCount - 1
		PostQueuedCompletionStatus( _
			self->CompletionPort, _
			0, _
			0, _
			NULL _
		)
	Next

	Dim resWaitThreads As DWORD = WaitForMultipleObjects( _
		self->WorkerThreadsCount, _
		self->hThreads, _
		TRUE, _
		10 * 1000 _
	)
	If resWaitThreads <> WAIT_OBJECT_0 Then
		Return HRESULT_FROM_WIN32(GetLastError())
	End If

	For i As Integer = 0 To self->WorkerThreadsCount - 1
		CloseHandle(self->hThreads[i])
	Next

	Return S_OK

End Function

Private Function ThreadPoolAssociateDevice( _
		ByVal self As ThreadPool Ptr, _
		ByVal hHandle As HANDLE, _
		ByVal pUserData As Any Ptr _
	)As HRESULT

	Dim NewPort As HANDLE = CreateIoCompletionPort( _
		hHandle, _
		self->CompletionPort, _
		Cast(ULONG_PTR, pUserData), _
		0 _
	)
	If NewPort = NULL Then
		Dim dwError As DWORD = GetLastError()
		Return HRESULT_FROM_WIN32(dwError)
	End If

	Return S_OK

End Function

Private Function ThreadPoolPostPacket( _
		ByVal self As ThreadPool Ptr, _
		ByVal PacketSize As DWORD, _
		ByVal CompletionKey As ULONG_PTR, _
		ByVal pIResult As IAsyncResult Ptr _
	)As HRESULT

	Dim pOverlap As OVERLAPPED Ptr = Any
	IAsyncResult_GetWsaOverlapped(pIResult, @pOverlap)

	Dim resStatus As BOOL = PostQueuedCompletionStatus( _
		self->CompletionPort, _
		PacketSize, _
		CompletionKey, _
		pOverlap _
	)
	If resStatus = 0 Then
		Dim dwError As DWORD = GetLastError()
		Return HRESULT_FROM_WIN32(dwError)
	End If

	Return S_OK

End Function


Private Function IThreadPoolQueryInterface( _
		ByVal self As IThreadPool Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return ThreadPoolQueryInterface(CONTAINING_RECORD(self, ThreadPool, lpVtbl), riid, ppv)
End Function

Private Function IThreadPoolAddRef( _
		ByVal self As IThreadPool Ptr _
	)As ULONG
	Return ThreadPoolAddRef(CONTAINING_RECORD(self, ThreadPool, lpVtbl))
End Function

Private Function IThreadPoolRelease( _
		ByVal self As IThreadPool Ptr _
	)As ULONG
	Return ThreadPoolRelease(CONTAINING_RECORD(self, ThreadPool, lpVtbl))
End Function

Private Function IThreadPoolGetMaxThreads( _
		ByVal self As IThreadPool Ptr, _
		ByVal pMaxThreads As UInteger Ptr _
	)As HRESULT
	Return ThreadPoolGetMaxThreads(CONTAINING_RECORD(self, ThreadPool, lpVtbl), pMaxThreads)
End Function

Private Function IThreadPoolSetMaxThreads( _
		ByVal self As IThreadPool Ptr, _
		ByVal MaxThreads As UInteger _
	)As HRESULT
	Return ThreadPoolSetMaxThreads(CONTAINING_RECORD(self, ThreadPool, lpVtbl), MaxThreads)
End Function

Private Function IThreadPoolRun( _
		ByVal self As IThreadPool Ptr _
	)As HRESULT
	Return ThreadPoolRun(CONTAINING_RECORD(self, ThreadPool, lpVtbl))
End Function

Private Function IThreadPoolStop( _
		ByVal self As IThreadPool Ptr _
	)As HRESULT
	Return ThreadPoolStop(CONTAINING_RECORD(self, ThreadPool, lpVtbl))
End Function

Private Function IThreadPoolAssociateDevice( _
		ByVal self As IThreadPool Ptr, _
		ByVal hHandle As HANDLE, _
		ByVal pUserData As Any Ptr _
	)As HRESULT
	Return ThreadPoolAssociateDevice(CONTAINING_RECORD(self, ThreadPool, lpVtbl), hHandle, pUserData)
End Function

Private Function IThreadPoolPostPacket( _
		ByVal self As IThreadPool Ptr, _
		ByVal PacketSize As DWORD, _
		ByVal CompletionKey As ULONG_PTR, _
		ByVal pIResult As IAsyncResult Ptr _
	)As HRESULT
	Return ThreadPoolPostPacket(CONTAINING_RECORD(self, ThreadPool, lpVtbl), PacketSize, CompletionKey, pIResult)
End Function

Dim GlobalThreadPoolVirtualTable As Const IThreadPoolVirtualTable = Type( _
	@IThreadPoolQueryInterface, _
	@IThreadPoolAddRef, _
	@IThreadPoolRelease, _
	@IThreadPoolGetMaxThreads, _
	@IThreadPoolSetMaxThreads, _
	@IThreadPoolRun, _
	@IThreadPoolStop, _
	@IThreadPoolAssociateDevice, _
	@IThreadPoolPostPacket _
)
