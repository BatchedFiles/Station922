#include once "ThreadPool.bi"
#include once "IAsyncResult.bi"
#include once "IAsyncTask.bi"
#include once "ContainerOf.bi"
#include once "Logger.bi"

Extern GlobalThreadPoolVirtualTable As Const IThreadPoolVirtualTable

Const MAX_CRITICAL_SECTION_SPIN_COUNT As DWORD = 4000

Type _ThreadPool
	lpVtbl As Const IThreadPoolVirtualTable Ptr
	crSection As CRITICAL_SECTION
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	hIOCompletionPort As HANDLE
	WorkerThreadsCount As Integer
End Type

Function WorkerThread( _
		ByVal lpParam As LPVOID _
	)As DWORD
	
	Dim this As ThreadPool Ptr = lpParam
	
	Do
		
		Dim BytesTransferred As DWORD = Any
		Dim CompletionKey As ULONG_PTR = Any
		Dim pOverlap As ASYNCRESULTOVERLAPPED Ptr = Any
		
		Dim res As Integer = GetQueuedCompletionStatus( _
			this->hIOCompletionPort, _
			@BytesTransferred, _
			@CompletionKey, _
			CPtr(LPOVERLAPPED Ptr, @pOverlap), _
			INFINITE _
		)
		If res = 0 Then
			Dim dwError As DWORD = GetLastError()
			Dim vtErrorCode As VARIANT = Any
			vtErrorCode.vt = VT_UI4
			vtErrorCode.ulVal = dwError
			LogWriteEntry( _
				LogEntryType.Error, _
				WStr(!"GetQueuedCompletionStatus Error\t"), _
				@vtErrorCode _
			)
			
			If pOverlap = NULL Then
				' fprintf(stderr, "GetQueuedCompletionStatus завершилась ошибкой
				' (ошибка %d)\n", GetLastError());
				' exit(1);
				Exit Do
			Else
				' fprintf(stderr, "GetQueuedCompletionStatus переместила 
				' испорченный пакет I/O (ошибка %d)\n", GetLastError());
				' // Не смотря на то, что вы можете здесь завершить работу
				' // по ошибке этот пример продолжается.
				
			End If
			
		Else
			#if __FB_DEBUG__
			Scope
				Dim vtBytesTransferred As VARIANT = Any
				vtBytesTransferred.vt = VT_UI4
				vtBytesTransferred.ulVal = BytesTransferred
				LogWriteEntry( _
					LogEntryType.Debug, _
					WStr(!"\t\t\t\tBytesTransferred\t"), _
					@vtBytesTransferred _
				)
			End Scope
			#endif
			
			Dim pIAsync As IAsyncResult Ptr = pOverlap->pIAsync
			IAsyncResult_SetCompleted( _
				pIAsync, _
				BytesTransferred, _
				True _
			)
			
			Dim pTask As IAsyncTask Ptr = Any
			IAsyncResult_GetAsyncState( _
				pIAsync, _
				CPtr(IUnknown Ptr Ptr, @pTask) _
			)
			
			IAsyncTask_EndExecute( _
				pTask, _
				CPtr(IThreadPool Ptr, @this->lpVtbl), _
				pIAsync, _
				BytesTransferred, _
				CompletionKey _
			)
			
			IAsyncTask_Release(pTask)
			
			IAsyncResult_Release(pIAsync)
			
			' Уменьшаем счётчик ссылок на задачу
			' Так как мы не сделали это при запуске задачи
			IAsyncTask_Release(pTask)
			
		End If
		
	Loop
	
	ThreadPoolRelease(this)
	
	Return 0
	
End Function

Sub InitializeThreadPool( _
		ByVal this As ThreadPool Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	this->lpVtbl = @GlobalThreadPoolVirtualTable
	InitializeCriticalSectionAndSpinCount( _
		@this->crSection, _
		MAX_CRITICAL_SECTION_SPIN_COUNT _
	)
	this->ReferenceCounter = 0
	
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	
	this->hIOCompletionPort = NULL
	this->WorkerThreadsCount = 0
	
End Sub

Sub UnInitializeThreadPool( _
		ByVal this As ThreadPool Ptr _
	)
	
	If this->hIOCompletionPort <> NULL Then
		CloseHandle(this->hIOCompletionPort)
	End If
	
	IMalloc_Release(this->pIMemoryAllocator)
	DeleteCriticalSection(@this->crSection)
	
End Sub

Function CreateThreadPool( _
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
	
	IMalloc_AddRef(this->pIMemoryAllocator)
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
	
	EnterCriticalSection(@this->crSection)
	Scope
		this->ReferenceCounter += 1
	End Scope
	LeaveCriticalSection(@this->crSection)
	
	Return this->ReferenceCounter
	
End Function

Function ThreadPoolRelease( _
		ByVal this As ThreadPool Ptr _
	)As ULONG
	
	EnterCriticalSection(@this->crSection)
	Scope
		this->ReferenceCounter -= 1
	End Scope
	LeaveCriticalSection(@this->crSection)
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyThreadPool(this)
	
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
		ByVal this As ThreadPool Ptr _
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
	
	Const DefaultStackSize As SIZE_T_ = 0
	
	For i As Integer = 0 To this->WorkerThreadsCount - 1
		
		ThreadPoolAddRef(this)
		
		Dim ThreadId As DWORD = Any
		Dim hThread As HANDLE = CreateThread( _
			NULL, _
			DefaultStackSize, _
			@WorkerThread, _
			this, _
			0, _
			@ThreadId _
		)
		If hThread = NULL Then
			Dim dwError As DWORD = GetLastError()
			Return HRESULT_FROM_WIN32(dwError)
		End If
		
		CloseHandle(hThread)
		
	Next
	
	Return S_OK
	
End Function

Function ThreadPoolStop( _
		ByVal this As ThreadPool Ptr _
	)As HRESULT
	
	If this->hIOCompletionPort <> NULL Then
		CloseHandle(this->hIOCompletionPort)
		this->hIOCompletionPort = NULL
	End If
	
	Return S_OK
	
End Function

Function ThreadPoolGetCompletionPort( _
		ByVal this As ThreadPool Ptr, _
		ByVal pPort As HANDLE Ptr _
	)As HRESULT
	
	*pPort = this->hIOCompletionPort
	
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
		ByVal this As IThreadPool Ptr _
	)As HRESULT
	Return ThreadPoolRun(ContainerOf(this, ThreadPool, lpVtbl))
End Function

Function IThreadPoolStop( _
		ByVal this As IThreadPool Ptr _
	)As HRESULT
	Return ThreadPoolStop(ContainerOf(this, ThreadPool, lpVtbl))
End Function

Function IThreadPoolGetCompletionPort( _
		ByVal this As IThreadPool Ptr, _
		ByVal pPort As HANDLE Ptr _
	)As HRESULT
	Return ThreadPoolGetCompletionPort(ContainerOf(this, ThreadPool, lpVtbl), pPort)
End Function

Dim GlobalThreadPoolVirtualTable As Const IThreadPoolVirtualTable = Type( _
	@IThreadPoolQueryInterface, _
	@IThreadPoolAddRef, _
	@IThreadPoolRelease, _
	@IThreadPoolGetMaxThreads, _
	@IThreadPoolSetMaxThreads, _
	@IThreadPoolRun, _
	@IThreadPoolStop, _
	@IThreadPoolGetCompletionPort _
)
