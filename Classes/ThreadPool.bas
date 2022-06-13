#include once "ThreadPool.bi"
#include once "ContainerOf.bi"
#include once "Logger.bi"

Extern GlobalThreadPoolVirtualTable As Const IThreadPoolVirtualTable

Type _ThreadPool
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IThreadPoolVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	hIOCompletionPort As HANDLE
	WorkerThreadsCount As Integer
	hThreads As HANDLE Ptr
	CallBack As ThreadPoolCallBack
	param As Any Ptr
End Type

Function WorkerThread( _
		ByVal lpParam As LPVOID _
	)As DWORD
	
	Dim this As ThreadPool Ptr = lpParam
	
	Do
		
		Dim BytesTransferred As DWORD = Any
		Dim CompletionKey As ULONG_PTR = Any
		Dim pOverlap As OVERLAPPED Ptr = Any
		
		Dim resCompletionStatus As BOOL = GetQueuedCompletionStatus( _
			this->hIOCompletionPort, _
			@BytesTransferred, _
			@CompletionKey, _
			@pOverlap, _
			INFINITE _
		)
		If resCompletionStatus Then
			If CompletionKey = 0 Then
				Exit Do
			End If
			
			this->CallBack( _
				this->param, _
				BytesTransferred, _
				CompletionKey, _
				pOverlap _
			)
		Else
			If pOverlap = NULL Then
				#if __FB_DEBUG__
				Scope
					Dim dwError As DWORD = GetLastError()
					Dim vtErrorCode As VARIANT = Any
					vtErrorCode.vt = VT_UI4
					vtErrorCode.ulVal = dwError
					LogWriteEntry( _
						LogEntryType.Error, _
						WStr(!"Completion port error\t"), _
						@vtErrorCode _
					)
				End Scope
				#endif
				
				Exit Do
			End If
			
			#if __FB_DEBUG__
			Scope
				Dim dwError As DWORD = GetLastError()
				Dim vtErrorCode As VARIANT = Any
				vtErrorCode.vt = VT_UI4
				vtErrorCode.ulVal = dwError
				LogWriteEntry( _
					LogEntryType.Error, _
					WStr(!"Failed I/O operation\t"), _
					@vtErrorCode _
				)
			End Scope
			#endif
			
			this->CallBack( _
				this->param, _
				BytesTransferred, _
				CompletionKey, _
				pOverlap _
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
	this->ReferenceCounter = 1
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->hIOCompletionPort = NULL
	this->WorkerThreadsCount = 0
	this->hThreads = NULL
	
End Sub

Sub UnInitializeThreadPool( _
		ByVal this As ThreadPool Ptr _
	)
	
	If this->hIOCompletionPort <> NULL Then
		CloseHandle(this->hIOCompletionPort)
	End If
	
	If this->hThreads <> NULL Then
		IMalloc_Free(this->pIMemoryAllocator, this->hThreads)
	End If
	
End Sub

Function CreatePermanentThreadPool( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As ThreadPool Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(ThreadPool)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"ThreadPool creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim this As ThreadPool Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(ThreadPool) _
	)
	If this <> NULL Then
		InitializeThreadPool( _
			this, _
			pIMemoryAllocator _
		)
		
		#if __FB_DEBUG__
		Scope
			Dim vtEmpty As VARIANT = Any
			VariantInit(@vtEmpty)
			LogWriteEntry( _
				LogEntryType.Debug, _
				WStr("ThreadPool created"), _
				@vtEmpty _
			)
		End Scope
		#endif
		
		Return this
	End If
	
	Return NULL
	
End Function

Sub DestroyThreadPool( _
		ByVal this As ThreadPool Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("ThreadPool destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeThreadPool(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("ThreadPool destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
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
		ByVal pMaxThreads As Integer Ptr _
	)As HRESULT
	
	*pMaxThreads = this->WorkerThreadsCount
	
	Return S_OK
	
End Function

Function ThreadPoolSetMaxThreads( _
		ByVal this As ThreadPool Ptr, _
		ByVal MaxThreads As Integer _
	)As HRESULT
	
	this->WorkerThreadsCount = MaxThreads
	
	Return S_OK
	
End Function

Function ThreadPoolRun( _
		ByVal this As ThreadPool Ptr, _
		ByVal CallBack As ThreadPoolCallBack, _
		ByVal param As Any Ptr _
	)As HRESULT
	
	this->hIOCompletionPort = CreateIoCompletionPort( _
		INVALID_HANDLE_VALUE, _
		NULL, _
		Cast(ULONG_PTR, 0), _
		this->WorkerThreadsCount _
	)
	If this->hIOCompletionPort = NULL Then
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
	
	this->CallBack = CallBack
	this->param = param
	
	Const DefaultStackSize As SIZE_T_ = 0
	
	For i As Integer = 0 To this->WorkerThreadsCount - 1
		
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
			this->hIOCompletionPort, _
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

Function ThreadPoolAssociateTask( _
		ByVal this As ThreadPool Ptr, _
		ByVal pTask As IAsyncIoTask Ptr _
	)As HRESULT
	
	Dim FileHandle As HANDLE = Any
	IAsyncIoTask_GetFileHandle(pTask, @FileHandle)
	
	Dim hPort As HANDLE = CreateIoCompletionPort( _
		FileHandle, _
		this->hIOCompletionPort, _
		Cast(ULONG_PTR, FileHandle), _
		0 _
	)
	If hPort = NULL Then
		Dim dwError As DWORD = GetLastError()
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
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
		ByVal pMaxThreads As Integer Ptr _
	)As HRESULT
	Return ThreadPoolGetMaxThreads(ContainerOf(this, ThreadPool, lpVtbl), pMaxThreads)
End Function

Function IThreadPoolSetMaxThreads( _
		ByVal this As IThreadPool Ptr, _
		ByVal MaxThreads As Integer _
	)As HRESULT
	Return ThreadPoolSetMaxThreads(ContainerOf(this, ThreadPool, lpVtbl), MaxThreads)
End Function

Function IThreadPoolRun( _
		ByVal this As IThreadPool Ptr, _
		ByVal CallBack As ThreadPoolCallBack, _
		ByVal param As Any Ptr _
	)As HRESULT
	Return ThreadPoolRun(ContainerOf(this, ThreadPool, lpVtbl), CallBack, param)
End Function

Function IThreadPoolStop( _
		ByVal this As IThreadPool Ptr _
	)As HRESULT
	Return ThreadPoolStop(ContainerOf(this, ThreadPool, lpVtbl))
End Function

Function IThreadPoolAssociateTask( _
		ByVal this As IThreadPool Ptr, _
		ByVal pTask As IAsyncIoTask Ptr _
	)As HRESULT
	Return ThreadPoolAssociateTask(ContainerOf(this, ThreadPool, lpVtbl), pTask)
End Function

Dim GlobalThreadPoolVirtualTable As Const IThreadPoolVirtualTable = Type( _
	@IThreadPoolQueryInterface, _
	@IThreadPoolAddRef, _
	@IThreadPoolRelease, _
	@IThreadPoolGetMaxThreads, _
	@IThreadPoolSetMaxThreads, _
	@IThreadPoolRun, _
	@IThreadPoolStop, _
	@IThreadPoolAssociateTask _
)
