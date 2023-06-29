#include once "ThreadPool.bi"
#include once "ContainerOf.bi"
#include once "Logger.bi"
#include once "WebUtils.bi"

Extern GlobalThreadPoolVirtualTable As Const IThreadPoolVirtualTable

Type _ThreadPool
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IThreadPoolVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	WorkerThreadsCount As UInteger
	hThreads As HANDLE Ptr
End Type

Function FinishExecuteTaskSink( _
		ByVal BytesTransferred As DWORD, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr, _
		ByVal dwError As DWORD _
	)As HRESULT
	
	IAsyncResult_SetCompleted( _
		pIResult, _
		BytesTransferred, _
		True, _
		dwError _
	)
	
	Dim pTask As IAsyncIoTask Ptr = Any
	IAsyncResult_GetAsyncStateWeakPtr(pIResult, @pTask)
	
	Dim hrEndExecute As HRESULT = IAsyncIoTask_EndExecute( _
		pTask, _
		pIResult, _
		BytesTransferred, _
		ppNextTask _
	)
	If FAILED(hrEndExecute) Then
		Dim vtErrorCode As VARIANT = Any
		vtErrorCode.vt = VT_ERROR
		vtErrorCode.scode = hrEndExecute
		LogWriteEntry( _
			LogEntryType.Error, _
			WStr(!"IAsyncIoTask_EndExecute Error"), _
			@vtErrorCode _
		)
	End If
	
	' Releasing the references to the task and futura
	' beecause we haven't done this before
	IAsyncResult_Release(pIResult)
	IAsyncIoTask_Release(pTask)
	
	Return hrEndExecute
	
End Function

Function ThreadPoolCallBack( _
		ByVal BytesTransferred As DWORD, _
		ByVal CompletionKey As ULONG_PTR, _
		ByVal pOverlap As OVERLAPPED Ptr, _
		ByVal dwError As DWORD _
	)As Integer
	
	Dim hrFinishExecute As HRESULT = Any
	Dim pNextTask As IAsyncIoTask Ptr = Any
	Scope
		Dim pIResult As IAsyncResult Ptr = GetAsyncResultFromOverlappedWeakPtr(pOverlap)
		
		hrFinishExecute = FinishExecuteTaskSink( _
			BytesTransferred, _
			pIResult, _
			@pNextTask, _
			dwError _
		)
	End Scope
	
	If SUCCEEDED(hrFinishExecute) Then
		
		Select Case hrFinishExecute
			
			Case S_OK
				Dim hrStart As HRESULT = StartExecuteTask(pNextTask)
				If FAILED(hrStart) Then
					IAsyncIoTask_Release(pNextTask)
				End If
				
			Case S_FALSE
				
			Case ASYNCTASK_S_KEEPALIVE_FALSE
				
		End Select
	End If
	
	Return 0
	
End Function

Function WorkerThread( _
		ByVal lpParam As LPVOID _
	)As DWORD
	
	Dim this As ThreadPool Ptr = lpParam
	
	Do
		
		Dim BytesTransferred As DWORD = Any
		Dim CompletionKey As ULONG_PTR = Any
		Dim pOverlap As OVERLAPPED Ptr = Any
		
		Dim resCompletionStatus As BOOL = GetQueuedCompletionStatus( _
			ThreadPoolCompletionPort, _
			@BytesTransferred, _
			@CompletionKey, _
			@pOverlap, _
			INFINITE _
		)
		If resCompletionStatus Then
			If CompletionKey = 0 Then
				Exit Do
			End If
			
			ThreadPoolCallBack( _
				BytesTransferred, _
				CompletionKey, _
				pOverlap, _
				ERROR_SUCCESS _
			)
		Else
			If pOverlap = NULL Then
				Exit Do
			End If
			
			Dim dwError As DWORD = GetLastError()
			
			ThreadPoolCallBack( _
				BytesTransferred, _
				CompletionKey, _
				pOverlap, _
				dwError _
			)
		End If
		
	Loop
	
	ThreadPoolRelease(this)
	
	Return 0
	
End Function

Sub InitializeThreadPool( _
		ByVal this As ThreadPool Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_THREADPOOL), _
			Len(ThreadPool.IdString) _
		)
	#endif
	this->lpVtbl = @GlobalThreadPoolVirtualTable
	this->ReferenceCounter = CUInt(-1)
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->WorkerThreadsCount = 0
	this->hThreads = NULL
	
End Sub

Sub UnInitializeThreadPool( _
		ByVal this As ThreadPool Ptr _
	)
	
	If ThreadPoolCompletionPort Then
		CloseHandle(ThreadPoolCompletionPort)
	End If
	
	If this->hThreads Then
		IMalloc_Free(this->pIMemoryAllocator, this->hThreads)
	End If
	
End Sub

Sub ThreadPoolCreated( _
		ByVal this As ThreadPool Ptr _
	)
	
End Sub

Function CreateThreadPool( _
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

Sub ThreadPoolDestroyed( _
		ByVal this As ThreadPool Ptr _
	)
	
End Sub

Sub DestroyThreadPool( _
		ByVal this As ThreadPool Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeThreadPool(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	ThreadPoolDestroyed(this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function ThreadPoolQueryInterface( _
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

Function ThreadPoolAddRef( _
		ByVal this As ThreadPool Ptr _
	)As ULONG
	
	Return 1
	
End Function

Function ThreadPoolRelease( _
		ByVal this As ThreadPool Ptr _
	)As ULONG
	
	Return 0
	
End Function

Function ThreadPoolGetMaxThreads( _
		ByVal this As ThreadPool Ptr, _
		ByVal pMaxThreads As UInteger Ptr _
	)As HRESULT
	
	*pMaxThreads = this->WorkerThreadsCount
	
	Return S_OK
	
End Function

Function ThreadPoolSetMaxThreads( _
		ByVal this As ThreadPool Ptr, _
		ByVal MaxThreads As UInteger _
	)As HRESULT
	
	this->WorkerThreadsCount = MaxThreads
	
	Return S_OK
	
End Function

Function ThreadPoolRun( _
		ByVal this As ThreadPool Ptr _
	)As HRESULT
	
	ThreadPoolCompletionPort = CreateIoCompletionPort( _
		INVALID_HANDLE_VALUE, _
		NULL, _
		Cast(ULONG_PTR, 0), _
		this->WorkerThreadsCount _
	)
	If ThreadPoolCompletionPort = NULL Then
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
		
		ThreadPoolAddRef(this)
		
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

Function ThreadPoolStop( _
		ByVal this As ThreadPool Ptr _
	)As HRESULT
	
	For i As Integer = 0 To this->WorkerThreadsCount - 1
		PostQueuedCompletionStatus( _
			ThreadPoolCompletionPort, _
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


Function IThreadPoolQueryInterface( _
		ByVal this As IThreadPool Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return ThreadPoolQueryInterface(ContainerOf(this, ThreadPool, lpVtbl), riid, ppv)
End Function

Function IThreadPoolAddRef( _
		ByVal this As IThreadPool Ptr _
	)As ULONG
	Return ThreadPoolAddRef(ContainerOf(this, ThreadPool, lpVtbl))
End Function

Function IThreadPoolRelease( _
		ByVal this As IThreadPool Ptr _
	)As ULONG
	Return ThreadPoolRelease(ContainerOf(this, ThreadPool, lpVtbl))
End Function

Function IThreadPoolGetMaxThreads( _
		ByVal this As IThreadPool Ptr, _
		ByVal pMaxThreads As UInteger Ptr _
	)As HRESULT
	Return ThreadPoolGetMaxThreads(ContainerOf(this, ThreadPool, lpVtbl), pMaxThreads)
End Function

Function IThreadPoolSetMaxThreads( _
		ByVal this As IThreadPool Ptr, _
		ByVal MaxThreads As UInteger _
	)As HRESULT
	Return ThreadPoolSetMaxThreads(ContainerOf(this, ThreadPool, lpVtbl), MaxThreads)
End Function

Function IThreadPoolRun( _
		ByVal this As IThreadPool Ptr _
	)As HRESULT
	Return ThreadPoolRun(ContainerOf(this, ThreadPool, lpVtbl))
End Function

Function IThreadPoolStop( _
		ByVal this As IThreadPool Ptr _
	)As HRESULT
	Return ThreadPoolStop(ContainerOf(this, ThreadPool, lpVtbl))
End Function

Dim GlobalThreadPoolVirtualTable As Const IThreadPoolVirtualTable = Type( _
	@IThreadPoolQueryInterface, _
	@IThreadPoolAddRef, _
	@IThreadPoolRelease, _
	@IThreadPoolGetMaxThreads, _
	@IThreadPoolSetMaxThreads, _
	@IThreadPoolRun, _
	@IThreadPoolStop _
)

Dim ThreadPoolCompletionPort As HANDLE
