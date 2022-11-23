#include once "HeapMemoryAllocator.bi"
#include once "ContainerOf.bi"
#include once "Logger.bi"

Extern GlobalHeapMemoryAllocatorVirtualTable As Const IHeapMemoryAllocatorVirtualTable

Const MEMORY_ALLOCATION_GRANULARITY As DWORD = 64 * 1024
Const PRIVATEHEAP_INITIALSIZE As DWORD = MEMORY_ALLOCATION_GRANULARITY

Const PRIVATEHEAP_MAXIMUMSIZE As DWORD = PRIVATEHEAP_INITIALSIZE

Const HEAP_NO_SERIALIZE_FLAG = HEAP_NO_SERIALIZE

Type _HeapMemoryAllocator
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IHeapMemoryAllocatorVirtualTable Ptr
	ReferenceCounter As UInteger
	hHeap As HANDLE
	pReadedData As ClientRequestBuffer Ptr
End Type

Sub InitializeHeapMemoryAllocator( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal hHeap As HANDLE, _
		ByVal pReadedData As ClientRequestBuffer Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_HEAPMEMORYALLOCATOR), _
			Len(HeapMemoryAllocator.IdString) _
		)
	#endif
	this->lpVtbl = @GlobalHeapMemoryAllocatorVirtualTable
	this->ReferenceCounter = 0
	this->hHeap = hHeap
	this->pReadedData = pReadedData
	
End Sub

Sub UnInitializeHeapMemoryAllocator( _
		ByVal this As HeapMemoryAllocator Ptr _
	)
	
	If this->pReadedData Then
		HeapFree( _
			this->hHeap, _
			HEAP_NO_SERIALIZE_FLAG, _
			this->pReadedData _
		)
	End If
	
End Sub

Sub HeapMemoryAllocatorCreated( _
		ByVal this As HeapMemoryAllocator Ptr _
	)
	
End Sub

Function CreateHeapMemoryAllocator( _
	)As HeapMemoryAllocator Ptr
	
	Dim hHeap As HANDLE = HeapCreate( _
		HEAP_NO_SERIALIZE_FLAG, _
		PRIVATEHEAP_INITIALSIZE, _
		PRIVATEHEAP_MAXIMUMSIZE _
	)
	
	If hHeap Then
		
		Dim pReadedData As ClientRequestBuffer Ptr = HeapAlloc( _
			hHeap, _
			HEAP_NO_SERIALIZE_FLAG, _
			SizeOf(ClientRequestBuffer) _
		)
		
		If pReadedData Then
			InitializeClientRequestBuffer(pReadedData)
			
			Dim this As HeapMemoryAllocator Ptr = HeapAlloc( _
				hHeap, _
				HEAP_NO_SERIALIZE_FLAG, _
				SizeOf(HeapMemoryAllocator) _
			)
			
			If this Then
				InitializeHeapMemoryAllocator(this, hHeap, pReadedData)
				
				HeapMemoryAllocatorCreated(this)
				
				Return this
			End If
			
			' No need to HeapFree(pReadedData)
		End If
		
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(HeapMemoryAllocator)
		LogWriteEntry( _
			LogEntryType.Error, _
			WStr(!"AllocMemory Failed\t"), _
			@vtAllocatedBytes _
		)
		
		HeapDestroy(hHeap)
	End If
	
	Return NULL
	
End Function

Sub HeapMemoryAllocatorDestroyed( _
		ByVal this As HeapMemoryAllocator Ptr _
	)
	
End Sub

Sub DestroyHeapMemoryAllocator( _
		ByVal this As HeapMemoryAllocator Ptr _
	)
	
	Dim hHeap As HANDLE = this->hHeap
	
	UnInitializeHeapMemoryAllocator(this)
	
	If hHeap Then
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
						WStr(!"MemoryLeak Bytes\t"), _
						@vtMemoryLeaksSize _
					)
				End If
			Loop
			
			HeapUnlock(hHeap)
		End If
		
		Dim resHeapDestroy As BOOL = HeapDestroy(hHeap)
		If resHeapDestroy = 0 Then
		End If
	End If
	
	HeapMemoryAllocatorDestroyed(this)
	
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
	
	this->ReferenceCounter += 1
	
	Return 1
	
End Function

Function HeapMemoryAllocatorRelease( _
		ByVal this As HeapMemoryAllocator Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyHeapMemoryAllocator(this)
	
	Return 0
	
End Function

Function HeapMemoryAllocatorAlloc( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal BytesCount As SIZE_T_ _
	)As Any Ptr
	
	Dim pMemory As Any Ptr = HeapAlloc( _
		this->hHeap, _
		HEAP_NO_SERIALIZE_FLAG, _
		BytesCount _
	)
	If pMemory = NULL Then
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = CLng(BytesCount)
		LogWriteEntry( _
			LogEntryType.Error, _
			WStr(!"\t\t\t\tAllocMemory Failed\t"), _
			@vtAllocatedBytes _
		)
	End If
	
	Return pMemory
	
End Function

Function HeapMemoryAllocatorRealloc( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal pMemory As Any Ptr, _
		ByVal BytesCount As SIZE_T_ _
	)As Any Ptr
	
	Dim pReallocMemory As Any Ptr = HeapReAlloc( _
		this->hHeap, _
		HEAP_NO_SERIALIZE_FLAG, _
		pMemory, _
		BytesCount _
	)
	If pReallocMemory = NULL Then
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = CLng(BytesCount)
		LogWriteEntry( _
			LogEntryType.Error, _
			WStr(!"\t\t\t\tReAllocMemory Failed\t"), _
			@vtAllocatedBytes _
		)
	End If
	
	Return pReallocMemory
	
End Function

Sub HeapMemoryAllocatorFree( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal pMemory As Any Ptr _
	)
	
	HeapFree( _
		this->hHeap, _
		HEAP_NO_SERIALIZE_FLAG, _
		pMemory _
	)
	
End Sub

Function HeapMemoryAllocatorGetSize( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal pMemory As Any Ptr _
	)As SIZE_T_
	
	Dim Size As SIZE_T_ = HeapSize( _
		this->hHeap, _
		HEAP_NO_SERIALIZE_FLAG, _
		pMemory _
	)
	
	Return Size
	
End Function

Function HeapMemoryAllocatorDidAlloc( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal pMemory As Any Ptr _
	)As Long
	
	Dim phe As PROCESS_HEAP_ENTRY = Any
	phe.lpData = NULL
	Dim resHeapWalk As BOOL = HeapWalk(this->hHeap, @phe)
	Do
		If phe.lpData = pMemory Then
			Return 1
		End If
		resHeapWalk = HeapWalk(this->hHeap, @phe)
	Loop While resHeapWalk
	
	Return 0
	
End Function

Sub HeapMemoryAllocatorHeapMinimize( _
		ByVal this As HeapMemoryAllocator Ptr _
	)
	
	HeapCompact(this->hHeap, HEAP_NO_SERIALIZE_FLAG)
	
End Sub

' Declare Function HeapMemoryAllocatorRegisterMallocSpy( _
	' ByVal this As HeapMemoryAllocator Ptr, _
	' ByVal pMallocSpy As LPMALLOCSPY _
' )As HRESULT

' Declare Function HeapMemoryAllocatorRevokeMallocSpy( _
	' ByVal this As HeapMemoryAllocator Ptr _
' )As HRESULT

Function HeapMemoryAllocatorGetClientBuffer( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal ppBuffer As ClientRequestBuffer Ptr Ptr _
	)As HRESULT
	
	*ppBuffer = this->pReadedData
	
	Return S_OK
	
End Function


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

Function IHeapMemoryAllocatorGetClientBuffer( _
		ByVal this As IHeapMemoryAllocator Ptr, _
		ByVal ppBuffer As ClientRequestBuffer Ptr Ptr _
	)As HRESULT
	Return HeapMemoryAllocatorGetClientBuffer(ContainerOf(this, HeapMemoryAllocator, lpVtbl), ppBuffer)
End Function

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
	NULL, _ /' RegisterMallocSpy '/
	NULL, _ /' RevokeMallocSpy '/
	@IHeapMemoryAllocatorGetClientBuffer _
)
