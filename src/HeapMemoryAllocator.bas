#include once "HeapMemoryAllocator.bi"
#include once "ContainerOf.bi"
#include once "Logger.bi"

Extern GlobalHeapMemoryAllocatorVirtualTable As Const IHeapMemoryAllocatorVirtualTable

Const MEMORY_ALLOCATION_GRANULARITY As DWORD = 64 * 1024

Const PRIVATEHEAP_INITIALSIZE As DWORD = 0
Const PRIVATEHEAP_MAXIMUMSIZE As DWORD = MEMORY_ALLOCATION_GRANULARITY

Const HEAP_NO_SERIALIZE_FLAG = HEAP_NO_SERIALIZE

Type MemoryPoolItem
	pMalloc As IHeapMemoryAllocator Ptr
	IsUsed As Boolean
End Type

Type _HeapMemoryAllocator
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IHeapMemoryAllocatorVirtualTable Ptr
	ReferenceCounter As UInteger
	hHeap As HANDLE
	Padding As Integer
	ReadedData As ClientRequestBuffer
End Type

Dim Shared MemoryPoolCapacity As UInteger
Dim Shared MemoryPoolLength As UInteger
Dim Shared pMemoryPoolCollection As MemoryPoolItem Ptr
Dim Shared MemoryPoolSection As CRITICAL_SECTION

Sub ReleaseHeapMemoryAllocatorInstance( _
		ByVal pMalloc As IHeapMemoryAllocator Ptr _
	)
	
	Dim Finded As Boolean = False
	
	If MemoryPoolCapacity Then
		EnterCriticalSection(@MemoryPoolSection)
		
		For i As UInteger = 0 To MemoryPoolCapacity - 1
			If pMemoryPoolCollection[i].pMalloc = pMalloc Then
				
				Dim this As HeapMemoryAllocator Ptr = ContainerOf(pMalloc, HeapMemoryAllocator, lpVtbl)
				this->ReferenceCounter = 1
				InitializeClientRequestBuffer(@this->ReadedData)
				
				pMemoryPoolCollection[i].IsUsed = False
				Finded = True
				
				Exit For
			End If
		Next
		
		LeaveCriticalSection(@MemoryPoolSection)
	End If
	
	If Finded = False Then
		Dim this As HeapMemoryAllocator Ptr = ContainerOf(pMalloc, HeapMemoryAllocator, lpVtbl)
		DestroyHeapMemoryAllocator(this)
	End If
	
End Sub

Function GetHeapMemoryAllocatorInstance( _
	)As IHeapMemoryAllocator Ptr
	
	If MemoryPoolCapacity Then
		Dim pMalloc As IHeapMemoryAllocator Ptr = NULL
		EnterCriticalSection(@MemoryPoolSection)
		
		For i As UInteger = 0 To MemoryPoolCapacity - 1
			If pMemoryPoolCollection[i].IsUsed = False Then
				
				pMemoryPoolCollection[i].IsUsed = True
				pMalloc = pMemoryPoolCollection[i].pMalloc
				
				Exit For
			End If
		Next
		
		LeaveCriticalSection(@MemoryPoolSection)
		
		If pMalloc Then
			Return pMalloc
		End If
	End If
	
	Scope
		Dim pMalloc As IHeapMemoryAllocator Ptr = Any
		Dim hrCreateMalloc As HRESULT = CreateHeapMemoryAllocator( _
			@IID_IHeapMemoryAllocator, _
			@pMalloc _
		)
		If FAILED(hrCreateMalloc) Then
			Return NULL
		End If
		
		Return pMalloc
	End Scope
	
End Function

Function CreateMemoryPool( _
		ByVal Capacity As UInteger _
	)As HRESULT
	
	MemoryPoolCapacity = Capacity
	MemoryPoolLength = Capacity
	
	If Capacity Then
		Const dwSpinCount As DWORD = 4000
		Dim resInitialize As BOOL = InitializeCriticalSectionAndSpinCount( _
			@MemoryPoolSection, _
			dwSpinCount _
		)
		If resInitialize = 0 Then
			Dim dwError As DWORD =  GetLastError()
			Return HRESULT_FROM_WIN32(dwError)
		End If
		
		Dim hHeap As HANDLE = GetProcessHeap()
		pMemoryPoolCollection = HeapAlloc( _
			hHeap, _
			0, _
			SizeOf(MemoryPoolItem) * Capacity _
		)
		If pMemoryPoolCollection = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		For i As UInteger = 0 To Capacity - 1
			Dim pMalloc As IHeapMemoryAllocator Ptr = Any
			Dim hrCreateMalloc As HRESULT = CreateHeapMemoryAllocator( _
				@IID_IHeapMemoryAllocator, _
				@pMalloc _
			)
			If FAILED(hrCreateMalloc) Then
				Return E_OUTOFMEMORY
			End If
			
			pMemoryPoolCollection[i].pMalloc = pMalloc
			pMemoryPoolCollection[i].IsUsed = False
		Next
	End If
	
	Return S_OK
	
End Function

Sub AllocationFailed( _
		ByVal BytesCount As SIZE_T_ _
	)
	
	Dim vtAllocatedBytes As VARIANT = Any
	vtAllocatedBytes.vt = VT_I4
	vtAllocatedBytes.lVal = CLng(BytesCount)
	LogWriteEntry( _
		LogEntryType.Error, _
		WStr(!"AllocMemory Failed"), _
		@vtAllocatedBytes _
	)
	
End Sub

Sub InitializeHeapMemoryAllocator( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal hHeap As HANDLE _
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
	InitializeClientRequestBuffer(@this->ReadedData)
	
End Sub

Sub UnInitializeHeapMemoryAllocator( _
		ByVal this As HeapMemoryAllocator Ptr _
	)
	
End Sub

Sub HeapMemoryAllocatorCreated( _
		ByVal this As HeapMemoryAllocator Ptr _
	)
	
End Sub

Function CreateHeapMemoryAllocator( _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Dim hHeap As HANDLE = HeapCreate( _
		HEAP_NO_SERIALIZE_FLAG, _
		PRIVATEHEAP_INITIALSIZE, _
		PRIVATEHEAP_MAXIMUMSIZE _
	)
	If hHeap = NULL Then
		Dim dwError As DWORD = GetLastError()
		*ppv = NULL
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Dim this As HeapMemoryAllocator Ptr = HeapAlloc( _
		hHeap, _
		HEAP_NO_SERIALIZE_FLAG, _
		SizeOf(HeapMemoryAllocator) _
	)
	
	If this Then
		InitializeHeapMemoryAllocator(this, hHeap)
		HeapMemoryAllocatorCreated(this)
		
		Dim hrQueryInterface As HRESULT = HeapMemoryAllocatorQueryInterface( _
			this, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyHeapMemoryAllocator(this)
		End If
		
		Return hrQueryInterface
	End If
	
	AllocationFailed(SizeOf(HeapMemoryAllocator))
	
	HeapDestroy(hHeap)
	
	*ppv = NULL
	Return E_OUTOFMEMORY
	
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
	
	Dim pInterface As IHeapMemoryAllocator Ptr = CPtr(IHeapMemoryAllocator Ptr, @this->lpVtbl)
	ReleaseHeapMemoryAllocatorInstance(pInterface)
	
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
		AllocationFailed(BytesCount)
	End If
	
	Return pMemory
	
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

Function HeapMemoryAllocatorGetClientBuffer( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal ppBuffer As ClientRequestBuffer Ptr Ptr _
	)As HRESULT
	
	*ppBuffer = @this->ReadedData
	
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

Sub IHeapMemoryAllocatorFree( _
		ByVal this As IHeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr _
	)
	HeapMemoryAllocatorFree(ContainerOf(this, HeapMemoryAllocator, lpVtbl), pv)
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
	NULL, _ /' @IHeapMemoryAllocatorRealloc, _ '/
	@IHeapMemoryAllocatorFree, _
	NULL, _ /' @IHeapMemoryAllocatorGetSize, _ '/
	NULL, _ /' @IHeapMemoryAllocatorDidAlloc, _ '/
	NULL, _ /' @IHeapMemoryAllocatorHeapMinimize, _ '/
	NULL, _ /' RegisterMallocSpy '/
	NULL, _ /' RevokeMallocSpy '/
	@IHeapMemoryAllocatorGetClientBuffer _
)
