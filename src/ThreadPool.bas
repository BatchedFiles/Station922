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

	Dim this As ThreadPool Ptr = lpParam

	Do

		Dim BytesTransferred As DWORD = Any
		Dim CompletionKey As ULONG_PTR = Any
		Dim pOverlap As OVERLAPPED Ptr = Any
		Dim dwError As DWORD = Any

		Dim resCompletionStatus As BOOL = GetQueuedCompletionStatus( _
			this->CompletionPort, _
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
		ByVal this As ThreadPool Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@this->RttiClassName(0), _
			@Str(RTTI_ID_THREADPOOL), _
			UBound(this->RttiClassName) - LBound(this->RttiClassName) + 1 _
		)
	#endif
	this->lpVtbl = @GlobalThreadPoolVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->CompletionPort = NULL
	this->WorkerThreadsCount = 0
	this->hThreads = NULL

End Sub

Private Sub UnInitializeThreadPool( _
		ByVal this As ThreadPool Ptr _
	)

	If this->CompletionPort Then
		CloseHandle(this->CompletionPort)
	End If

	If this->hThreads Then
		IMalloc_Free(this->pIMemoryAllocator, this->hThreads)
	End If

End Sub

Private Sub ThreadPoolCreated( _
		ByVal this As ThreadPool Ptr _
	)

End Sub

Private Sub ThreadPoolDestroyed( _
		ByVal this As ThreadPool Ptr _
	)

End Sub

Private Sub DestroyThreadPool( _
		ByVal this As ThreadPool Ptr _
	)

	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator

	UnInitializeThreadPool(this)

	IMalloc_Free(pIMemoryAllocator, this)

	ThreadPoolDestroyed(this)

	IMalloc_Release(pIMemoryAllocator)

End Sub

Private Function ThreadPoolAddRef( _
		ByVal this As ThreadPool Ptr _
	)As ULONG

	this->ReferenceCounter += 1

	Return 1

End Function

Private Function ThreadPoolRelease( _
		ByVal this As ThreadPool Ptr _
	)As ULONG

	this->ReferenceCounter -= 1

	If this->ReferenceCounter Then
		Return 1
	End If

	DestroyThreadPool(this)

	Return 0

End Function

Private Function ThreadPoolQueryInterface( _
		ByVal this As ThreadPool Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_IThreadPool, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If

	ThreadPoolAddRef(this)

	Return S_OK

End Function

Public Function CreateThreadPool( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	Dim this As ThreadPool Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(ThreadPool) _
	)

	If this Then
		InitializeThreadPool(this, pIMemoryAllocator)
		ThreadPoolCreated(this)

		Dim hrQueryInterface As HRESULT = ThreadPoolQueryInterface( _
			this, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyThreadPool(this)
		End If

		Return hrQueryInterface
	End If

	*ppv = NULL
	Return E_OUTOFMEMORY

End Function

Private Function ThreadPoolGetMaxThreads( _
		ByVal this As ThreadPool Ptr, _
		ByVal pMaxThreads As UInteger Ptr _
	)As HRESULT

	*pMaxThreads = this->WorkerThreadsCount

	Return S_OK

End Function

Private Function ThreadPoolSetMaxThreads( _
		ByVal this As ThreadPool Ptr, _
		ByVal MaxThreads As UInteger _
	)As HRESULT

	this->WorkerThreadsCount = MaxThreads

	Return S_OK

End Function

Private Function ThreadPoolRun( _
		ByVal this As ThreadPool Ptr _
	)As HRESULT

	this->CompletionPort = CreateNewCompletionPort( _
		this->WorkerThreadsCount _
	)
	If this->CompletionPort = NULL Then
		Dim dwError As DWORD = GetLastError()
		Return HRESULT_FROM_WIN32(dwError)
	End If

	this->hThreads = IMalloc_Alloc( _
		this->pIMemoryAllocator, _
		SizeOf(HANDLE) * this->WorkerThreadsCount _
	)
	If this = NULL Then
		Return E_OUTOFMEMORY
	End If

	Const DefaultStackSize As SIZE_T_ = 0

	For i As UInteger = 0 To this->WorkerThreadsCount - 1

		Dim ThreadId As DWORD = Any
		this->hThreads[i] = CreateThread( _
			NULL, _
			DefaultStackSize, _
			@WorkerThread, _
			this, _
			0, _
			@ThreadId _
		)
		If this->hThreads[i] = NULL Then
			Dim dwError As DWORD = GetLastError()
			Return HRESULT_FROM_WIN32(dwError)
		End If

	Next

	Return S_OK

End Function

Private Function ThreadPoolStop( _
		ByVal this As ThreadPool Ptr _
	)As HRESULT

	For i As Integer = 0 To this->WorkerThreadsCount - 1
		PostQueuedCompletionStatus( _
			this->CompletionPort, _
			0, _
			0, _
			NULL _
		)
	Next

	Dim resWaitThreads As DWORD = WaitForMultipleObjects( _
		this->WorkerThreadsCount, _
		this->hThreads, _
		TRUE, _
		10 * 1000 _
	)
	If resWaitThreads <> WAIT_OBJECT_0 Then
		Return HRESULT_FROM_WIN32(GetLastError())
	End If

	For i As Integer = 0 To this->WorkerThreadsCount - 1
		CloseHandle(this->hThreads[i])
	Next

	Return S_OK

End Function

Private Function ThreadPoolAssociateDevice( _
		ByVal this As ThreadPool Ptr, _
		ByVal hHandle As HANDLE, _
		ByVal pUserData As Any Ptr _
	)As HRESULT

	Dim NewPort As HANDLE = CreateIoCompletionPort( _
		hHandle, _
		this->CompletionPort, _
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
		ByVal this As ThreadPool Ptr, _
		ByVal PacketSize As DWORD, _
		ByVal CompletionKey As ULONG_PTR, _
		ByVal pIResult As IAsyncResult Ptr _
	)As HRESULT

	Dim pOverlap As OVERLAPPED Ptr = Any
	IAsyncResult_GetWsaOverlapped(pIResult, @pOverlap)

	Dim resStatus As BOOL = PostQueuedCompletionStatus( _
		this->CompletionPort, _
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
		ByVal this As IThreadPool Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return ThreadPoolQueryInterface(CONTAINING_RECORD(this, ThreadPool, lpVtbl), riid, ppv)
End Function

Private Function IThreadPoolAddRef( _
		ByVal this As IThreadPool Ptr _
	)As ULONG
	Return ThreadPoolAddRef(CONTAINING_RECORD(this, ThreadPool, lpVtbl))
End Function

Private Function IThreadPoolRelease( _
		ByVal this As IThreadPool Ptr _
	)As ULONG
	Return ThreadPoolRelease(CONTAINING_RECORD(this, ThreadPool, lpVtbl))
End Function

Private Function IThreadPoolGetMaxThreads( _
		ByVal this As IThreadPool Ptr, _
		ByVal pMaxThreads As UInteger Ptr _
	)As HRESULT
	Return ThreadPoolGetMaxThreads(CONTAINING_RECORD(this, ThreadPool, lpVtbl), pMaxThreads)
End Function

Private Function IThreadPoolSetMaxThreads( _
		ByVal this As IThreadPool Ptr, _
		ByVal MaxThreads As UInteger _
	)As HRESULT
	Return ThreadPoolSetMaxThreads(CONTAINING_RECORD(this, ThreadPool, lpVtbl), MaxThreads)
End Function

Private Function IThreadPoolRun( _
		ByVal this As IThreadPool Ptr _
	)As HRESULT
	Return ThreadPoolRun(CONTAINING_RECORD(this, ThreadPool, lpVtbl))
End Function

Private Function IThreadPoolStop( _
		ByVal this As IThreadPool Ptr _
	)As HRESULT
	Return ThreadPoolStop(CONTAINING_RECORD(this, ThreadPool, lpVtbl))
End Function

Private Function IThreadPoolAssociateDevice( _
		ByVal this As IThreadPool Ptr, _
		ByVal hHandle As HANDLE, _
		ByVal pUserData As Any Ptr _
	)As HRESULT
	Return ThreadPoolAssociateDevice(CONTAINING_RECORD(this, ThreadPool, lpVtbl), hHandle, pUserData)
End Function

Private Function IThreadPoolPostPacket( _
		ByVal this As IThreadPool Ptr, _
		ByVal PacketSize As DWORD, _
		ByVal CompletionKey As ULONG_PTR, _
		ByVal pIResult As IAsyncResult Ptr _
	)As HRESULT
	Return ThreadPoolPostPacket(CONTAINING_RECORD(this, ThreadPool, lpVtbl), PacketSize, CompletionKey, pIResult)
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
