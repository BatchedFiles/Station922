#include once "PrivateHeapMemoryAllocator.bi"
#include once "ContainerOf.bi"
#include once "PrintDebugInfo.bi"
#include once "ReferenceCounter.bi"

Extern GlobalPrivateHeapMemoryAllocatorVirtualTable As Const IPrivateHeapMemoryAllocatorVirtualTable

Const PRIVATEHEAP_INITIALSIZE As DWORD = 80 * 4096
Const PRIVATEHEAP_MAXIMUMSIZE As DWORD = PRIVATEHEAP_INITIALSIZE

Type MemoryRegion
	Dim pMemory As Any Ptr
	Dim Size As Integer
End Type

Type _PrivateHeapMemoryAllocator
	Dim lpVtbl As Const IPrivateHeapMemoryAllocatorVirtualTable Ptr
	Dim RefCounter As ReferenceCounter
	Dim pIMemoryAllocator As IMalloc Ptr
	Dim pISpyObject As IMallocSpy Ptr
	Dim MemoryAllocations As Integer
	Dim hHeap As HANDLE
	Dim Memoryes(19) As MemoryRegion
	Dim cbMemoryUsed As Integer
End Type

Sub InitializePrivateHeapMemoryAllocator( _
		ByVal this As PrivateHeapMemoryAllocator Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal hHeap As HANDLE _
	)
	
	this->lpVtbl = @GlobalPrivateHeapMemoryAllocatorVirtualTable
	ReferenceCounterInitialize(@this->RefCounter)
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pISpyObject = NULL
	this->MemoryAllocations = 0
	this->hHeap = hHeap
	ZeroMemory(@this->Memoryes(0), SizeOf(MemoryRegion) * 20)
	this->cbMemoryUsed = 0
	
End Sub

Sub UnInitializePrivateHeapMemoryAllocator( _
		ByVal this As PrivateHeapMemoryAllocator Ptr _
	)
	If this->pISpyObject <> NULL Then
		IMallocSpy_Release(this->pISpyObject)
	End If
	
	ReferenceCounterUnInitialize(@this->RefCounter)
	IMalloc_Release(this->pIMemoryAllocator)
	
End Sub

Function CreatePrivateHeapMemoryAllocator( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As PrivateHeapMemoryAllocator Ptr
	
	DebugPrintInteger(WStr(!"PrivateHeapMemoryAllocator creating\t"), SizeOf(PrivateHeapMemoryAllocator))
	
	Dim hHeap As HANDLE = HeapCreate( _
		HEAP_NO_SERIALIZE, _
		PRIVATEHEAP_INITIALSIZE, _
		PRIVATEHEAP_MAXIMUMSIZE _
	)
	If hHeap = NULL Then
		Return NULL
	End If
	
	Dim this As PrivateHeapMemoryAllocator Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(PrivateHeapMemoryAllocator) _
	)
	If this = NULL Then
		HeapDestroy(hHeap)
		Return NULL
	End If
	
	InitializePrivateHeapMemoryAllocator(this, pIMemoryAllocator, hHeap)
	
	DebugPrintWString(WStr("PrivateHeapMemoryAllocator created"))
	
	Return this
	
End Function

Sub DestroyPrivateHeapMemoryAllocator( _
		ByVal this As PrivateHeapMemoryAllocator Ptr _
	)
	
	DebugPrintWString(WStr("PrivateHeapMemoryAllocator destroying"))
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
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
	
	UnInitializePrivateHeapMemoryAllocator(this)
	
	If hHeap <> NULL Then
		HeapDestroy(hHeap)
	End If
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	IMalloc_Release(pIMemoryAllocator)
	
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

Function PrivateHeapMemoryAllocatorRealloc( _
		ByVal this As PrivateHeapMemoryAllocator Ptr, _
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

Sub PrivateHeapMemoryAllocatorFree( _
		ByVal this As PrivateHeapMemoryAllocator Ptr, _
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

Function PrivateHeapMemoryAllocatorGetSize( _
		ByVal this As PrivateHeapMemoryAllocator Ptr, _
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

Function PrivateHeapMemoryAllocatorDidAlloc( _
		ByVal this As PrivateHeapMemoryAllocator Ptr, _
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

Sub PrivateHeapMemoryAllocatorHeapMinimize( _
		ByVal this As PrivateHeapMemoryAllocator Ptr _
	)
	
	If this->pISpyObject <> NULL Then
		IMallocSpy_PreHeapMinimize(this->pISpyObject)
	End If
	
	HeapCompact(this->hHeap, HEAP_NO_SERIALIZE)
	
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
