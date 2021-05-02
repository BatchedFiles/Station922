#include once "HeapMemoryAllocator.bi"
#include once "ContainerOf.bi"
#include once "PrintDebugInfo.bi"
#include once "ReferenceCounter.bi"

Extern GlobalHeapMemoryAllocatorVirtualTable As Const IHeapMemoryAllocatorVirtualTable

Const PRIVATEHEAP_INITIALSIZE As DWORD = 80 * 4096
Const PRIVATEHEAP_MAXIMUMSIZE As DWORD = PRIVATEHEAP_INITIALSIZE

Type MemoryRegion
	Dim pMemory As Any Ptr
	Dim Size As Integer
End Type

Type _HeapMemoryAllocator
	Dim lpVtbl As Const IHeapMemoryAllocatorVirtualTable Ptr
	Dim RefCounter As ReferenceCounter
	Dim pISpyObject As IMallocSpy Ptr
	Dim MemoryAllocations As Integer
	Dim hHeap As HANDLE
	Dim Memoryes(19) As MemoryRegion
	Dim cbMemoryUsed As Integer
End Type

Sub InitializeHeapMemoryAllocator( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal hHeap As HANDLE _
	)
	
	this->lpVtbl = @GlobalHeapMemoryAllocatorVirtualTable
	ReferenceCounterInitialize(@this->RefCounter)
	this->pISpyObject = NULL
	this->MemoryAllocations = 0
	this->hHeap = hHeap
	ZeroMemory(@this->Memoryes(0), SizeOf(MemoryRegion) * 20)
	this->cbMemoryUsed = 0
	
End Sub

Sub UnInitializeHeapMemoryAllocator( _
		ByVal this As HeapMemoryAllocator Ptr _
	)
	If this->pISpyObject <> NULL Then
		IMallocSpy_Release(this->pISpyObject)
	End If
	
	ReferenceCounterUnInitialize(@this->RefCounter)
	
End Sub

Function CreateHeapMemoryAllocator( _
	)As HeapMemoryAllocator Ptr
	
	DebugPrintInteger(WStr(!"HeapMemoryAllocator creating\t"), SizeOf(HeapMemoryAllocator))
	
	Dim hHeap As HANDLE = HeapCreate( _
		HEAP_NO_SERIALIZE, _
		PRIVATEHEAP_INITIALSIZE, _
		PRIVATEHEAP_MAXIMUMSIZE _
	)
	If hHeap = NULL Then
		Return NULL
	End If
	
	Dim this As HeapMemoryAllocator Ptr = HeapAlloc( _
		hHeap, _
		HEAP_NO_SERIALIZE, _
		SizeOf(HeapMemoryAllocator) _
	)
	If this = NULL Then
		HeapDestroy(hHeap)
		Return NULL
	End If
	
	InitializeHeapMemoryAllocator(this, hHeap)
	
	DebugPrintWString(WStr("HeapMemoryAllocator created"))
	
	Return this
	
End Function

Sub DestroyHeapMemoryAllocator( _
		ByVal this As HeapMemoryAllocator Ptr _
	)
	
	DebugPrintWString(WStr("HeapMemoryAllocator destroying"))
	
	If this->MemoryAllocations <> 0 Then
		DebugPrintInteger(WStr(!"\t\t\t\t\tMemoryLeak\t"), this->MemoryAllocations)
		DebugPrintInteger(WStr(!"\t\t\t\t\tMemoryLeak Size\t"), this->cbMemoryUsed)
		For i As Integer = 0 To 19
			If this->Memoryes(i).pMemory <> 0 Then
				DebugPrintInteger(WStr(!"\t\t\t\tMemory Size  "), this->Memoryes(i).Size)
			End If
		Next
	End If
	
	Dim hHeap As HANDLE = this->hHeap
	
	UnInitializeHeapMemoryAllocator(this)
	
	If hHeap <> NULL Then
		HeapDestroy(hHeap)
	End If
	
	DebugPrintWString(WStr("HeapMemoryAllocator destroyed"))
	
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
	
	ReferenceCounterIncrement(@this->RefCounter)
	
	Return 1
	
End Function

Function HeapMemoryAllocatorRelease( _
		ByVal this As HeapMemoryAllocator Ptr _
	)As ULONG
	
	ReferenceCounterDecrement(@this->RefCounter)
	
	If this->RefCounter.Counter = 0 Then
		
		DestroyHeapMemoryAllocator(this)
		
		Return 0
	End If
	
	Return 1
	
End Function

Function HeapMemoryAllocatorAlloc( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal cb As SIZE_T_ _
	)As Any Ptr
	
	If this->pISpyObject <> NULL Then
		cb = IMallocSpy_PreAlloc(this->pISpyObject, cb)
	End If
	
	Dim pMemory As Any Ptr = Any
	
	' EnterCriticalSection(@this->crSection)
	Scope
		pMemory = HeapAlloc( _
			this->hHeap, _
			HEAP_NO_SERIALIZE, _
			cb _
		)
	End Scope
	' LeaveCriticalSection(@this->crSection)
	
	If pMemory = NULL Then
		DebugPrintInteger(WStr(!"\t\t\t\tAlloc Memory Failed\t"), cb)
	Else
		DebugPrintInteger(WStr(!"\t\t\t\tAlloc Memory Size\t"), cb)
		For i As Integer = 0 To 19
			If this->Memoryes(i).pMemory = 0 Then
				this->Memoryes(i).pMemory = pMemory
				this->Memoryes(i).Size = cb
				Exit For
			End If
		Next
		this->MemoryAllocations += 1
		this->cbMemoryUsed += cb
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
	
	Dim pMemory As Any Ptr = HeapReAlloc(this->hHeap, HEAP_NO_SERIALIZE, ppNewRequest, cb)
	
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
	
	' EnterCriticalSection(@this->crSection)
	Scope
		HeapFree( _
			this->hHeap, _
			HEAP_NO_SERIALIZE, _
			pMemory _
		)
	End Scope
	' LeaveCriticalSection(@this->crSection)
	For i As Integer = 0 To 19
		If this->Memoryes(i).pMemory = pMemory Then
			this->Memoryes(i).pMemory = 0
			this->cbMemoryUsed -= this->Memoryes(i).Size
			Exit For
		End If
	Next
	this->MemoryAllocations -= 1
	
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
	
	Dim Size As SIZE_T_ = Any
	' EnterCriticalSection(@this->crSection)
	Scope
		Size = HeapSize( _
			this->hHeap, _
			HEAP_NO_SERIALIZE, _
			pMemory _
		)
	End Scope
	' LeaveCriticalSection(@this->crSection)
	
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
	
	HeapCompact(this->hHeap, HEAP_NO_SERIALIZE)
	
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
