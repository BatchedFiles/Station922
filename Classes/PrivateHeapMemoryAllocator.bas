#include once "PrivateHeapMemoryAllocator.bi"
#include once "ContainerOf.bi"
#include once "PrintDebugInfo.bi"
#include once "ReferenceCounter.bi"

Extern GlobalPrivateHeapMemoryAllocatorVirtualTable As Const IPrivateHeapMemoryAllocatorVirtualTable

Const PRIVATEHEAP_INITIALSIZE As DWORD = 96 * 4096
Const PRIVATEHEAP_MAXIMUMSIZE As DWORD = PRIVATEHEAP_INITIALSIZE

Type _PrivateHeapMemoryAllocator
	Dim lpVtbl As Const IPrivateHeapMemoryAllocatorVirtualTable Ptr
	Dim RefCounter As ReferenceCounter
	Dim pISpyObject As IMallocSpy Ptr
	Dim MemoryAllocations As Integer
	Dim hHeap As HANDLE
	Dim HeapFlags As DWORD
End Type

Sub InitializePrivateHeapMemoryAllocator( _
		ByVal this As PrivateHeapMemoryAllocator Ptr, _
		ByVal hHeap As HANDLE, _
		ByVal HeapFlags As DWORD _
	)
	
	this->lpVtbl = @GlobalPrivateHeapMemoryAllocatorVirtualTable
	ReferenceCounterInitialize(@this->RefCounter)
	this->pISpyObject = NULL
	this->MemoryAllocations = 0
	this->hHeap = hHeap
	this->HeapFlags = HeapFlags
	
End Sub

Sub UnInitializePrivateHeapMemoryAllocator( _
		ByVal this As PrivateHeapMemoryAllocator Ptr _
	)
	If this->pISpyObject <> NULL Then
		IMallocSpy_Release(this->pISpyObject)
	End If
	
	ReferenceCounterUnInitialize(@this->RefCounter)
	
End Sub

Function CreatePrivateHeapMemoryAllocator( _
	)As PrivateHeapMemoryAllocator Ptr
	
	DebugPrintWString(WStr("PrivateHeapMemoryAllocator creating"))
	
	Dim hHeap As HANDLE = HeapCreate( _
		HEAP_NO_SERIALIZE, _
		PRIVATEHEAP_INITIALSIZE, _
		PRIVATEHEAP_MAXIMUMSIZE _
	)
	If hHeap = NULL Then
		Return NULL
	End If
	
	Dim this As PrivateHeapMemoryAllocator Ptr = HeapAlloc( _
		hHeap, _
		HEAP_NO_SERIALIZE, _
		SizeOf(PrivateHeapMemoryAllocator) _
	)
	If this = NULL Then
		HeapDestroy(hHeap)
		Return NULL
	End If
	
	InitializePrivateHeapMemoryAllocator(this, hHeap, HEAP_NO_SERIALIZE)
	
	DebugPrintWString(WStr("PrivateHeapMemoryAllocator created"))
	
	Return this
	
End Function

Sub DestroyPrivateHeapMemoryAllocator( _
		ByVal this As PrivateHeapMemoryAllocator Ptr _
	)
	
	DebugPrintWString(WStr("PrivateHeapMemoryAllocator destroying"))
	
	If this->MemoryAllocations <> 0 Then
		DebugPrintInteger(WStr(!"\t\t\t\t\tMemoryLeak\t"), this->MemoryAllocations)
	End If
	
	Dim hHeap As HANDLE = this->hHeap
	
	UnInitializePrivateHeapMemoryAllocator(this)
	
	If hHeap <> NULL Then
		HeapDestroy(hHeap)
	End If
	
	DebugPrintWString(WStr("PrivateHeapMemoryAllocator destroyed"))
	
End Sub

Function PrivateHeapMemoryAllocatorQueryInterface( _
		ByVal this As PrivateHeapMemoryAllocator Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IPrivateHeapMemoryAllocator, riid) Then
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
	
	PrivateHeapMemoryAllocatorAddRef(this)
	
	Return S_OK
	
End Function

Function PrivateHeapMemoryAllocatorAddRef( _
		ByVal this As PrivateHeapMemoryAllocator Ptr _
	)As ULONG
	
	ReferenceCounterIncrement(@this->RefCounter)
	
	Return 1
	
End Function

Function PrivateHeapMemoryAllocatorRelease( _
		ByVal this As PrivateHeapMemoryAllocator Ptr _
	)As ULONG
	
	ReferenceCounterDecrement(@this->RefCounter)
	
	If this->RefCounter.Counter = 0 Then
		
		DestroyPrivateHeapMemoryAllocator(this)
		
		Return 0
	End If
	
	Return 1
	
End Function

Function PrivateHeapMemoryAllocatorAlloc( _
		ByVal this As PrivateHeapMemoryAllocator Ptr, _
		ByVal cb As SIZE_T_ _
	)As Any Ptr
	
	this->MemoryAllocations += 1
	
	If this->pISpyObject <> NULL Then
		cb = IMallocSpy_PreAlloc(this->pISpyObject, cb)
	End If
	
	Dim pMemory As Any Ptr = Any
	' EnterCriticalSection(@this->crSection)
	Scope
		pMemory = HeapAlloc( _
			this->hHeap, _
			this->HeapFlags, _
			cb _
		)
	End Scope
	' LeaveCriticalSection(@this->crSection)
	
	If this->pISpyObject <> NULL Then
		pMemory = IMallocSpy_PostAlloc(this->pISpyObject, pMemory)
	End If
	
	Return pMemory
	
End Function

Function PrivateHeapMemoryAllocatorRealloc( _
		ByVal this As PrivateHeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr, _
		ByVal cb As SIZE_T_ _
	)As Any Ptr
	
	Dim ppNewRequest As Any Ptr Ptr = pv
	If this->pISpyObject <> NULL Then
		cb = IMallocSpy_PreRealloc(this->pISpyObject, pv, cb, ppNewRequest, True)
	End If
	
	Dim pMemory As Any Ptr = HeapReAlloc(this->hHeap, this->HeapFlags, ppNewRequest, cb)
	
	If this->pISpyObject <> NULL Then
		pMemory = IMallocSpy_PostRealloc(this->pISpyObject, pMemory, True)
	End If
	
	Return pMemory
	
End Function

Sub PrivateHeapMemoryAllocatorFree( _
		ByVal this As PrivateHeapMemoryAllocator Ptr, _
		ByVal pMemory As Any Ptr _
	)
	
	this->MemoryAllocations -= 1
	
	If this->pISpyObject <> NULL Then
		pMemory = IMallocSpy_PreFree(this->pISpyObject, pMemory, True)
	End If
	
	' EnterCriticalSection(@this->crSection)
	Scope
		HeapFree( _
			this->hHeap, _
			this->HeapFlags, _
			pMemory _
		)
	End Scope
	' LeaveCriticalSection(@this->crSection)
	
	If this->pISpyObject <> NULL Then
		IMallocSpy_PostFree(this->pISpyObject, True)
	End If
	
End Sub

Function PrivateHeapMemoryAllocatorGetSize( _
		ByVal this As PrivateHeapMemoryAllocator Ptr, _
		ByVal pMemory As Any Ptr _
	)As SIZE_T_
	
	Dim Size As SIZE_T_ = Any
	
	If this->pISpyObject <> NULL Then
		pMemory = IMallocSpy_PreGetSize(this->pISpyObject, pMemory, True)
	End If
	
	' EnterCriticalSection(@this->crSection)
	Scope
		Size = HeapSize( _
			this->hHeap, _
			this->HeapFlags, _
			pMemory _
		)
	End Scope
	' LeaveCriticalSection(@this->crSection)
	
	If this->pISpyObject <> NULL Then
		Size = IMallocSpy_PostGetSize(this->pISpyObject, Size, True)
	End If
	
	Return Size
	
End Function

Function PrivateHeapMemoryAllocatorDidAlloc( _
		ByVal this As PrivateHeapMemoryAllocator Ptr, _
		ByVal pMemory As Any Ptr _
	)As Long
	
	Dim phe As PROCESS_HEAP_ENTRY = Any
	phe.lpData = NULL
	
	If this->pISpyObject <> NULL Then
		pMemory = IMallocSpy_PreDidAlloc(this->pISpyObject, pMemory, True)
	End If
	
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

Sub PrivateHeapMemoryAllocatorHeapMinimize( _
		ByVal this As PrivateHeapMemoryAllocator Ptr _
	)
	
	If this->pISpyObject <> NULL Then
		IMallocSpy_PreHeapMinimize(this->pISpyObject)
	End If
	
	HeapCompact(this->hHeap, this->HeapFlags)
	
	If this->pISpyObject <> NULL Then
		IMallocSpy_PostHeapMinimize(this->pISpyObject)
	End If
	
End Sub

' Declare Function PrivateHeapMemoryAllocatorRegisterMallocSpy( _
	' ByVal this As PrivateHeapMemoryAllocator Ptr, _
	' ByVal pMallocSpy As LPMALLOCSPY _
' )As HRESULT

' Declare Function PrivateHeapMemoryAllocatorRevokeMallocSpy( _
	' ByVal this As PrivateHeapMemoryAllocator Ptr _
' )As HRESULT


Function IPrivateHeapMemoryAllocatorQueryInterface( _
		ByVal this As IPrivateHeapMemoryAllocator Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return PrivateHeapMemoryAllocatorQueryInterface(ContainerOf(this, PrivateHeapMemoryAllocator, lpVtbl), riid, ppvObject)
End Function

Function IPrivateHeapMemoryAllocatorAddRef( _
		ByVal this As IPrivateHeapMemoryAllocator Ptr _
	)As ULONG
	Return PrivateHeapMemoryAllocatorAddRef(ContainerOf(this, PrivateHeapMemoryAllocator, lpVtbl))
End Function

Function IPrivateHeapMemoryAllocatorRelease( _
		ByVal this As IPrivateHeapMemoryAllocator Ptr _
	)As ULONG
	Return PrivateHeapMemoryAllocatorRelease(ContainerOf(this, PrivateHeapMemoryAllocator, lpVtbl))
End Function

Function IPrivateHeapMemoryAllocatorAlloc( _
		ByVal this As IPrivateHeapMemoryAllocator Ptr, _
		ByVal cb As SIZE_T_ _
	)As Any Ptr
	Return PrivateHeapMemoryAllocatorAlloc(ContainerOf(this, PrivateHeapMemoryAllocator, lpVtbl), cb)
End Function

Function IPrivateHeapMemoryAllocatorRealloc( _
		ByVal this As IPrivateHeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr, _
		ByVal cb As SIZE_T_ _
	)As Any Ptr
	Return PrivateHeapMemoryAllocatorRealloc(ContainerOf(this, PrivateHeapMemoryAllocator, lpVtbl), pv, cb)
End Function

Sub IPrivateHeapMemoryAllocatorFree( _
		ByVal this As IPrivateHeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr _
	)
	PrivateHeapMemoryAllocatorFree(ContainerOf(this, PrivateHeapMemoryAllocator, lpVtbl), pv)
End Sub

Function IPrivateHeapMemoryAllocatorGetSize( _
		ByVal this As IPrivateHeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr _
	)As SIZE_T_
	Return PrivateHeapMemoryAllocatorGetSize(ContainerOf(this, PrivateHeapMemoryAllocator, lpVtbl), pv)
End Function

Function IPrivateHeapMemoryAllocatorDidAlloc( _
		ByVal this As IPrivateHeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr _
	)As Long
	Return PrivateHeapMemoryAllocatorDidAlloc(ContainerOf(this, PrivateHeapMemoryAllocator, lpVtbl), pv)
End Function

Sub IPrivateHeapMemoryAllocatorHeapMinimize( _
		ByVal this As IPrivateHeapMemoryAllocator Ptr _
	)
	PrivateHeapMemoryAllocatorHeapMinimize(ContainerOf(this, PrivateHeapMemoryAllocator, lpVtbl))
End Sub

Dim GlobalPrivateHeapMemoryAllocatorVirtualTable As Const IPrivateHeapMemoryAllocatorVirtualTable = Type( _
	@IPrivateHeapMemoryAllocatorQueryInterface, _
	@IPrivateHeapMemoryAllocatorAddRef, _
	@IPrivateHeapMemoryAllocatorRelease, _
	@IPrivateHeapMemoryAllocatorAlloc, _
	@IPrivateHeapMemoryAllocatorRealloc, _
	@IPrivateHeapMemoryAllocatorFree, _
	@IPrivateHeapMemoryAllocatorGetSize, _
	@IPrivateHeapMemoryAllocatorDidAlloc, _
	@IPrivateHeapMemoryAllocatorHeapMinimize, _
	NULL, _
	NULL _
)
