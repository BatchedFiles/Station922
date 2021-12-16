#include once "HeapMemoryAllocator.bi"
#include once "ContainerOf.bi"
#include once "Logger.bi"

Extern GlobalHeapMemoryAllocatorVirtualTable As Const IHeapMemoryAllocatorVirtualTable

Const MEMORY_ALLOCATION_GRANULARITY As DWORD = 64 * 1024
Const PRIVATEHEAP_INITIALSIZE As DWORD = 1 * MEMORY_ALLOCATION_GRANULARITY

Const PRIVATEHEAP_MAXIMUMSIZE As DWORD = PRIVATEHEAP_INITIALSIZE

' Const HEAP_NO_SERIALIZE_FLAG = HEAP_NO_SERIALIZE
Const HEAP_NO_SERIALIZE_FLAG = 0

Type _HeapMemoryAllocator
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IHeapMemoryAllocatorVirtualTable Ptr
	ReferenceCounter As Integer
	pISpyObject As IMallocSpy Ptr
	hHeap As HANDLE
End Type

Sub InitializeHeapMemoryAllocator( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal hHeap As HANDLE _
	)
	
	#if __FB_DEBUG__
		CopyMemory(@this->IdString, @Str("HMemoryAllocator"), 16)
	#endif
	this->lpVtbl = @GlobalHeapMemoryAllocatorVirtualTable
	this->ReferenceCounter = 0
	this->pISpyObject = NULL
	this->hHeap = hHeap
	
End Sub

Sub UnInitializeHeapMemoryAllocator( _
		ByVal this As HeapMemoryAllocator Ptr _
	)
	
	If this->pISpyObject <> NULL Then
		IMallocSpy_Release(this->pISpyObject)
	End If
	
End Sub

Function CreateHeapMemoryAllocator( _
	)As HeapMemoryAllocator Ptr
	
	Dim vtAllocatedBytes As VARIANT = Any
	vtAllocatedBytes.vt = VT_I4
	vtAllocatedBytes.lVal = SizeOf(HeapMemoryAllocator)
	
	#if __FB_DEBUG__
	Scope
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"HeapMemoryAllocator creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim hHeap As HANDLE = HeapCreate( _
		HEAP_NO_SERIALIZE_FLAG, _
		PRIVATEHEAP_INITIALSIZE, _
		PRIVATEHEAP_MAXIMUMSIZE _
	)
	
	If hHeap <> NULL Then
		
		#if __FB_DEBUG__
		Scope
			Dim vtHeapBytes As VARIANT = Any
			vtHeapBytes.vt = VT_I4
			vtHeapBytes.lVal = PRIVATEHEAP_MAXIMUMSIZE
			LogWriteEntry( _
				LogEntryType.Debug, _
				WStr(!"\t\t\t\tPrivateHeap created, maximum size:\t"), _
				@vtHeapBytes _
			)
		End Scope
		#endif
		
		Dim this As HeapMemoryAllocator Ptr = HeapAlloc( _
			hHeap, _
			HEAP_NO_SERIALIZE_FLAG, _
			SizeOf(HeapMemoryAllocator) _
		)
		
		If this <> NULL Then
			#if __FB_DEBUG__
				LogWriteEntry( _
					LogEntryType.Debug, _
					WStr(!"\t\t\t\tAllocMemory Succeeded\t"), _
					@vtAllocatedBytes _
				)
			#endif
			
			InitializeHeapMemoryAllocator(this, hHeap)
			
			#if __FB_DEBUG__
			Scope
				Dim vtEmpty As VARIANT = Any
				VariantInit(@vtEmpty)
				LogWriteEntry( _
					LogEntryType.Debug, _
					WStr("HeapMemoryAllocator created"), _
					@vtEmpty _
				)
			End Scope
			#endif
			
			Return this
		End If
		
		LogWriteEntry( _
			LogEntryType.Error, _
			WStr(!"\t\t\t\tAllocMemory Failed\t"), _
			@vtAllocatedBytes _
		)
		HeapDestroy(hHeap)
	End If
	
	Return NULL
	
End Function

Sub DestroyHeapMemoryAllocator( _
		ByVal this As HeapMemoryAllocator Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("HeapMemoryAllocator destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	Dim hHeap As HANDLE = this->hHeap
	
	UnInitializeHeapMemoryAllocator(this)
	
	If hHeap <> NULL Then
		HeapFree( _
			this->hHeap, _
			HEAP_NO_SERIALIZE_FLAG, _
			this _
		)
		
		Dim bLock As BOOL = HeapLock(hHeap)
		If bLock Then
			Dim phe As PROCESS_HEAP_ENTRY = Any
			phe.lpData = NULL
			' Dim res As Long = 0
			Do While HeapWalk(hHeap, @phe)
				Dim AllocatedFlag As Boolean = phe.wFlags And PROCESS_HEAP_ENTRY_BUSY
				If AllocatedFlag Then
					Dim vtMemoryLeaksSize As VARIANT = Any
					vtMemoryLeaksSize.vt = VT_I8
					vtMemoryLeaksSize.llVal = phe.cbData
					LogWriteEntry( _
						LogEntryType.Error, _
						WStr(!"\t\t\t\tMemoryLeak Bytes\t"), _
						@vtMemoryLeaksSize _
					)
				End If
			Loop
			
			HeapUnlock(hHeap)
		End If
		
		HeapDestroy(hHeap)
	End If
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("HeapMemoryAllocator destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
End Sub

Function HeapMemoryAllocatorQueryInterface( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IHeapMemoryAllocator, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IMalloc, riid) Then
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
	
	HeapMemoryAllocatorAddRef(this)
	
	Return S_OK
	
End Function

Function HeapMemoryAllocatorAddRef( _
		ByVal this As HeapMemoryAllocator Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		InterlockedIncrement64(@this->ReferenceCounter)
	#else
		InterlockedIncrement(@this->ReferenceCounter)
	#endif
	
	Return 1
	
End Function

Function HeapMemoryAllocatorRelease( _
		ByVal this As HeapMemoryAllocator Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		If InterlockedDecrement64(@this->ReferenceCounter) Then
			Return 1
		End If
	#else
		If InterlockedDecrement(@this->ReferenceCounter) Then
			Return 1
		End If
	#endif
	
	DestroyHeapMemoryAllocator(this)
	
	Return 0
	
End Function

Function HeapMemoryAllocatorAlloc( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal cb As SIZE_T_ _
	)As Any Ptr
	
	Dim BytesCount As SIZE_T_ = Any
	If this->pISpyObject = NULL Then
		BytesCount = cb
	Else
		BytesCount = IMallocSpy_PreAlloc(this->pISpyObject, cb)
	End If
	
	Dim vtAllocatedBytes As VARIANT = Any
	vtAllocatedBytes.vt = VT_I4
	vtAllocatedBytes.lVal = CLng(BytesCount)
	
	Dim pMemory As Any Ptr = HeapAlloc( _
		this->hHeap, _
		HEAP_NO_SERIALIZE_FLAG, _
		BytesCount _
	)
	If pMemory = NULL Then
		LogWriteEntry( _
			LogEntryType.Error, _
			WStr(!"\t\t\t\tAllocMemory Failed\t"), _
			@vtAllocatedBytes _
		)
	Else
		#if __FB_DEBUG__
			LogWriteEntry( _
				LogEntryType.Debug, _
				WStr(!"\t\t\t\tAllocMemory Succeeded\t"), _
				@vtAllocatedBytes _
			)
		#endif
		
	End If
	
	If this->pISpyObject <> NULL Then
		pMemory = IMallocSpy_PostAlloc(this->pISpyObject, pMemory)
	End If
	
	Return pMemory
	
End Function

Function HeapMemoryAllocatorRealloc( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr, _
		ByVal cb As SIZE_T_ _
	)As Any Ptr
	
	Dim ppNewRequest As Any Ptr Ptr = pv
	If this->pISpyObject <> NULL Then
		cb = IMallocSpy_PreRealloc(this->pISpyObject, pv, cb, ppNewRequest, True)
	End If
	
	Dim pMemory As Any Ptr = HeapReAlloc(this->hHeap, HEAP_NO_SERIALIZE_FLAG, ppNewRequest, cb)
	
	If this->pISpyObject <> NULL Then
		pMemory = IMallocSpy_PostRealloc(this->pISpyObject, pMemory, True)
	End If
	
	Return pMemory
	
End Function

Sub HeapMemoryAllocatorFree( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal pMemory As Any Ptr _
	)
	
	If this->pISpyObject <> NULL Then
		pMemory = IMallocSpy_PreFree(this->pISpyObject, pMemory, True)
	End If
	
	HeapFree( _
		this->hHeap, _
		HEAP_NO_SERIALIZE_FLAG, _
		pMemory _
	)
	
	If this->pISpyObject <> NULL Then
		IMallocSpy_PostFree(this->pISpyObject, True)
	End If
	
End Sub

Function HeapMemoryAllocatorGetSize( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal pMemory As Any Ptr _
	)As SIZE_T_
	
	If this->pISpyObject <> NULL Then
		pMemory = IMallocSpy_PreGetSize(this->pISpyObject, pMemory, True)
	End If
	
	Dim Size As SIZE_T_ = HeapSize( _
		this->hHeap, _
		HEAP_NO_SERIALIZE_FLAG, _
		pMemory _
	)
	
	If this->pISpyObject <> NULL Then
		Size = IMallocSpy_PostGetSize(this->pISpyObject, Size, True)
	End If
	
	Return Size
	
End Function

Function HeapMemoryAllocatorDidAlloc( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal pMemory As Any Ptr _
	)As Long
	
	If this->pISpyObject <> NULL Then
		pMemory = IMallocSpy_PreDidAlloc(this->pISpyObject, pMemory, True)
	End If
	
	Dim phe As PROCESS_HEAP_ENTRY = Any
	phe.lpData = NULL
	Dim res As Long = 0
	Do While HeapWalk(this->hHeap, @phe)
		If phe.lpData = pMemory Then
			res = 1
			Exit Do
		End If
	Loop
	
	If this->pISpyObject <> NULL Then
		res = IMallocSpy_PostDidAlloc(this->pISpyObject, pMemory, True, res)
	End If
	
	Return res
	
End Function

Sub HeapMemoryAllocatorHeapMinimize( _
		ByVal this As HeapMemoryAllocator Ptr _
	)
	
	If this->pISpyObject <> NULL Then
		IMallocSpy_PreHeapMinimize(this->pISpyObject)
	End If
	
	HeapCompact(this->hHeap, HEAP_NO_SERIALIZE_FLAG)
	
	If this->pISpyObject <> NULL Then
		IMallocSpy_PostHeapMinimize(this->pISpyObject)
	End If
	
End Sub

' Declare Function HeapMemoryAllocatorRegisterMallocSpy( _
	' ByVal this As HeapMemoryAllocator Ptr, _
	' ByVal pMallocSpy As LPMALLOCSPY _
' )As HRESULT

' Declare Function HeapMemoryAllocatorRevokeMallocSpy( _
	' ByVal this As HeapMemoryAllocator Ptr _
' )As HRESULT


Function IHeapMemoryAllocatorQueryInterface( _
		ByVal this As IHeapMemoryAllocator Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return HeapMemoryAllocatorQueryInterface(ContainerOf(this, HeapMemoryAllocator, lpVtbl), riid, ppvObject)
End Function

Function IHeapMemoryAllocatorAddRef( _
		ByVal this As IHeapMemoryAllocator Ptr _
	)As ULONG
	Return HeapMemoryAllocatorAddRef(ContainerOf(this, HeapMemoryAllocator, lpVtbl))
End Function

Function IHeapMemoryAllocatorRelease( _
		ByVal this As IHeapMemoryAllocator Ptr _
	)As ULONG
	Return HeapMemoryAllocatorRelease(ContainerOf(this, HeapMemoryAllocator, lpVtbl))
End Function

Function IHeapMemoryAllocatorAlloc( _
		ByVal this As IHeapMemoryAllocator Ptr, _
		ByVal cb As SIZE_T_ _
	)As Any Ptr
	Return HeapMemoryAllocatorAlloc(ContainerOf(this, HeapMemoryAllocator, lpVtbl), cb)
End Function

Function IHeapMemoryAllocatorRealloc( _
		ByVal this As IHeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr, _
		ByVal cb As SIZE_T_ _
	)As Any Ptr
	Return HeapMemoryAllocatorRealloc(ContainerOf(this, HeapMemoryAllocator, lpVtbl), pv, cb)
End Function

Sub IHeapMemoryAllocatorFree( _
		ByVal this As IHeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr _
	)
	HeapMemoryAllocatorFree(ContainerOf(this, HeapMemoryAllocator, lpVtbl), pv)
End Sub

Function IHeapMemoryAllocatorGetSize( _
		ByVal this As IHeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr _
	)As SIZE_T_
	Return HeapMemoryAllocatorGetSize(ContainerOf(this, HeapMemoryAllocator, lpVtbl), pv)
End Function

Function IHeapMemoryAllocatorDidAlloc( _
		ByVal this As IHeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr _
	)As Long
	Return HeapMemoryAllocatorDidAlloc(ContainerOf(this, HeapMemoryAllocator, lpVtbl), pv)
End Function

Sub IHeapMemoryAllocatorHeapMinimize( _
		ByVal this As IHeapMemoryAllocator Ptr _
	)
	HeapMemoryAllocatorHeapMinimize(ContainerOf(this, HeapMemoryAllocator, lpVtbl))
End Sub

Dim GlobalHeapMemoryAllocatorVirtualTable As Const IHeapMemoryAllocatorVirtualTable = Type( _
	@IHeapMemoryAllocatorQueryInterface, _
	@IHeapMemoryAllocatorAddRef, _
	@IHeapMemoryAllocatorRelease, _
	@IHeapMemoryAllocatorAlloc, _
	@IHeapMemoryAllocatorRealloc, _
	@IHeapMemoryAllocatorFree, _
	@IHeapMemoryAllocatorGetSize, _
	@IHeapMemoryAllocatorDidAlloc, _
	@IHeapMemoryAllocatorHeapMinimize, _
	NULL, _
	NULL _
)
