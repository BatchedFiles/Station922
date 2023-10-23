#include once "ThreadPool.bi"
#include once "ContainerOf.bi"
#include once "Logger.bi"
#include once "TaskExecutor.bi"

Extern GlobalThreadPoolVirtualTable As Const IThreadPoolVirtualTable

Type _ThreadPool
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IThreadPoolVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	WorkerThreadsCount As UInteger
End Type

Private Function FinishExecuteTaskSink( _
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
		
		Dim TaskId As AsyncIoTaskIDs = Any
		IAsyncIoTask_GetTaskId(pTask, @TaskId)
		
		Dim p As WString Ptr = Any
		Select Case TaskId
			
			Case AsyncIoTaskIDs.AcceptConnection
				p = @WStr("AcceptConnectionTask.EndExecute Error")
				
			Case AsyncIoTaskIDs.ReadRequest
				p = @WStr("ReadRequestTask.EndExecute Error")
				
			Case AsyncIoTaskIDs.WriteError
				p = @WStr("WriteErrorTask.EndExecute Error")
				
			Case Else ' AsyncIoTaskIDs.WriteResponse
				p = @WStr("WriteResponseTask.EndExecute Error")
				
		End Select
		
		LogWriteEntry( _
			LogEntryType.Error, _
			p, _
			@vtErrorCode _
		)
	End If
	
	' Releasing the references to the task and futura
	' beecause we haven't done this before
	IAsyncResult_Release(pIResult)
	IAsyncIoTask_Release(pTask)
	
	Return hrEndExecute
	
End Function

Private Sub ThreadPoolCallBack( _
		ByVal dwError As DWORD, _
		ByVal BytesTransferred As DWORD, _
		ByVal pOverlap As OVERLAPPED Ptr _
	)
	
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
	
End Sub

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
	this->WorkerThreadsCount = 0
	
End Sub

Private Sub UnInitializeThreadPool( _
		ByVal this As ThreadPool Ptr _
	)
	
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
	
	Return S_OK
	
End Function

Private Function ThreadPoolStop( _
		ByVal this As ThreadPool Ptr _
	)As HRESULT
	
	Return S_OK
	
End Function

Private Function ThreadPoolAssociateDevice( _
		ByVal this As ThreadPool Ptr, _
		ByVal hHandle As HANDLE, _
		ByVal pUserData As Any Ptr _
	)As HRESULT
	
	Const Reserved = 0
	Dim resBind As BOOL = BindIoCompletionCallback( _
		hHandle, _
		@ThreadPoolCallBack, _
		Reserved _
	)
	If resBind = 0 Then
		Dim dwError As DWORD = GetLastError()
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Return S_OK
	
End Function

Private Function UserThread( _
		ByVal lpParam As LPVOID _
	)As DWORD
	
	Dim pOverlap As OVERLAPPED Ptr = lpParam
	Dim BytesTransferred As DWORD = pOverlap->Offset
	
	ThreadPoolCallBack( _
		ERROR_SUCCESS, _
		BytesTransferred, _
		pOverlap _
	)
	
	Return 0
	
End Function

Private Function ThreadPoolPostPacket( _
		ByVal this As ThreadPool Ptr, _
		ByVal PacketSize As DWORD, _
		ByVal CompletionKey As ULONG_PTR, _
		ByVal pIResult As IAsyncResult Ptr _
	)As HRESULT
	
	Dim pOverlap As OVERLAPPED Ptr = Any
	IAsyncResult_GetWsaOverlapped(pIResult, @pOverlap)
	
	pOverlap->Offset = PacketSize
	
	Dim resQueueWorkItem As BOOL = QueueUserWorkItem( _
		@UserThread, _
		pOverlap, _
		WT_EXECUTEDEFAULT _
	)
	If resQueueWorkItem = 0 Then
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
	Return ThreadPoolQueryInterface(ContainerOf(this, ThreadPool, lpVtbl), riid, ppv)
End Function

Private Function IThreadPoolAddRef( _
		ByVal this As IThreadPool Ptr _
	)As ULONG
	Return ThreadPoolAddRef(ContainerOf(this, ThreadPool, lpVtbl))
End Function

Private Function IThreadPoolRelease( _
		ByVal this As IThreadPool Ptr _
	)As ULONG
	Return ThreadPoolRelease(ContainerOf(this, ThreadPool, lpVtbl))
End Function

Private Function IThreadPoolGetMaxThreads( _
		ByVal this As IThreadPool Ptr, _
		ByVal pMaxThreads As UInteger Ptr _
	)As HRESULT
	Return ThreadPoolGetMaxThreads(ContainerOf(this, ThreadPool, lpVtbl), pMaxThreads)
End Function

Private Function IThreadPoolSetMaxThreads( _
		ByVal this As IThreadPool Ptr, _
		ByVal MaxThreads As UInteger _
	)As HRESULT
	Return ThreadPoolSetMaxThreads(ContainerOf(this, ThreadPool, lpVtbl), MaxThreads)
End Function

Private Function IThreadPoolRun( _
		ByVal this As IThreadPool Ptr _
	)As HRESULT
	Return ThreadPoolRun(ContainerOf(this, ThreadPool, lpVtbl))
End Function

Private Function IThreadPoolStop( _
		ByVal this As IThreadPool Ptr _
	)As HRESULT
	Return ThreadPoolStop(ContainerOf(this, ThreadPool, lpVtbl))
End Function

Private Function IThreadPoolAssociateDevice( _
		ByVal this As IThreadPool Ptr, _
		ByVal hHandle As HANDLE, _
		ByVal pUserData As Any Ptr _
	)As HRESULT
	Return ThreadPoolAssociateDevice(ContainerOf(this, ThreadPool, lpVtbl), hHandle, pUserData)
End Function

Private Function IThreadPoolPostPacket( _
		ByVal this As IThreadPool Ptr, _
		ByVal PacketSize As DWORD, _
		ByVal CompletionKey As ULONG_PTR, _
		ByVal pIResult As IAsyncResult Ptr _
	)As HRESULT
	Return ThreadPoolPostPacket(ContainerOf(this, ThreadPool, lpVtbl), PacketSize, CompletionKey, pIResult)
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
