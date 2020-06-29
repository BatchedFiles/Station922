#include "PrivateHeapMemoryAllocator.bi"
#include "ContainerOf.bi"
#include "PrintDebugInfo.bi"

Extern GlobalPrivateHeapMemoryAllocatorVirtualTable As Const IPrivateHeapMemoryAllocatorVirtualTable

Const MAX_CRITICAL_SECTION_SPIN_COUNT As DWORD = 4000

Type _PrivateHeapMemoryAllocator
	Dim lpVtbl As Const IPrivateHeapMemoryAllocatorVirtualTable Ptr
	Dim ReferenceCounter As Integer
	Dim crSection As CRITICAL_SECTION
	Dim pIMemoryAllocator As IMalloc Ptr
	Dim hHeap As HANDLE
	Dim HeapFlags As DWORD
End Type

Sub InitializePrivateHeapMemoryAllocator( _
		ByVal this As PrivateHeapMemoryAllocator Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	this->lpVtbl = @GlobalPrivateHeapMemoryAllocatorVirtualTable
	this->ReferenceCounter = 0
	InitializeCriticalSectionAndSpinCount( _
		@this->crSection, _
		MAX_CRITICAL_SECTION_SPIN_COUNT _
	)
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->hHeap = NULL
	this->HeapFlags = 0
	
End Sub

Sub UnInitializePrivateHeapMemoryAllocator( _
		ByVal this As PrivateHeapMemoryAllocator Ptr _
	)
	
	DeleteCriticalSection(@this->crSection)
	IMalloc_Release(this->pIMemoryAllocator)
	
End Sub

Function CreatePrivateHeapMemoryAllocator( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As PrivateHeapMemoryAllocator Ptr
	
	Dim this As PrivateHeapMemoryAllocator Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(PrivateHeapMemoryAllocator) _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializePrivateHeapMemoryAllocator(this, pIMemoryAllocator)
	
	Return this
	
End Function

Sub DestroyPrivateHeapMemoryAllocator( _
		ByVal this As PrivateHeapMemoryAllocator Ptr _
	)
	
	Dim hHeap As HANDLE = this->hHeap
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializePrivateHeapMemoryAllocator(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	IMalloc_Release(pIMemoryAllocator)
	
	HeapDestroy(hHeap)
	
	#ifndef WINDOWS_SERVICE
		PrintErrorCode(!"PrivateHeapMemoryAllocator destroyed\t", 0)
	#endif
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
	
	EnterCriticalSection(@this->crSection)
	Scope
		this->ReferenceCounter += 1
	End Scope
	LeaveCriticalSection(@this->crSection)
	
	' #ifndef WINDOWS_SERVICE
		' PrintErrorCode(!"\tPrivateHeapMemoryAllocatorAddRef->ReferenceCounter += 1\t", Cast(DWORD, this->ReferenceCounter))
	' #endif
	
	Return 1
	
End Function

Function PrivateHeapMemoryAllocatorRelease( _
		ByVal this As PrivateHeapMemoryAllocator Ptr _
	)As ULONG
	
	EnterCriticalSection(@this->crSection)
	Scope
		this->ReferenceCounter -= 1
	End Scope
	LeaveCriticalSection(@this->crSection)
	
	' #ifndef WINDOWS_SERVICE
		' PrintErrorCode(!"\tPrivateHeapMemoryAllocatorAddRef->ReferenceCounter -= 1\t", Cast(DWORD, this->ReferenceCounter))
	' #endif
	
	If this->ReferenceCounter = 0 Then
		
		DestroyPrivateHeapMemoryAllocator(this)
		
		Return 0
	End If
	
	Return 1
	
End Function

Function PrivateHeapMemoryAllocatorAlloc( _
		ByVal this As PrivateHeapMemoryAllocator Ptr, _
		ByVal cb As SIZE_T_ _
	)As Any Ptr
	
	Dim pMemory As Any Ptr = Any
	EnterCriticalSection(@this->crSection)
	Scope
		pMemory = HeapAlloc( _
			this->hHeap, _
			this->HeapFlags, _
			cb _
		)
	End Scope
	LeaveCriticalSection(@this->crSection)
	
	Return pMemory
	
End Function

' Declare Function PrivateHeapMemoryAllocatorRealloc( _
	' ByVal this As PrivateHeapMemoryAllocator Ptr, _
	' ByVal pv As Any Ptr, _
	' ByVal cb As SIZE_T_ _
' )As Any Ptr

Sub PrivateHeapMemoryAllocatorFree( _
		ByVal this As PrivateHeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr _
	)
	
	EnterCriticalSection(@this->crSection)
	Scope
		HeapFree( _
			this->hHeap, _
			this->HeapFlags, _
			pv _
		)
	End Scope
	LeaveCriticalSection(@this->crSection)
	
End Sub

' Declare Function PrivateHeapMemoryAllocatorGetSize( _
	' ByVal this As PrivateHeapMemoryAllocator Ptr, _
	' ByVal pv As Any Ptr _
' )As SIZE_T_

' Declare Function PrivateHeapMemoryAllocatorDidAlloc( _
	' ByVal this As PrivateHeapMemoryAllocator Ptr, _
	' ByVal pv As Any Ptr _
' )As Long

' Declare Sub PrivateHeapMemoryAllocatorHeapMinimize( _
	' ByVal this As PrivateHeapMemoryAllocator Ptr _
' )

Function PrivateHeapMemoryAllocatorSetHeap( _
		ByVal this As PrivateHeapMemoryAllocator Ptr, _
		ByVal hHeap As HANDLE, _
		ByVal dwFlags As DWORD _
	)As HRESULT
	
	this->hHeap = hHeap
	this->HeapFlags = dwFlags
	
	Return S_OK
	
End Function


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

' Function IPrivateHeapMemoryAllocatorRealloc( _
	' ByVal this As IPrivateHeapMemoryAllocator Ptr, _
	' ByVal pv As Any Ptr, _
	' ByVal cb As SIZE_T_ _
' )As Any Ptr

Sub IPrivateHeapMemoryAllocatorFree( _
		ByVal this As IPrivateHeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr _
	)
	PrivateHeapMemoryAllocatorFree(ContainerOf(this, PrivateHeapMemoryAllocator, lpVtbl), pv)
End Sub

' Dim GetSize As Function( _
	' ByVal this As IPrivateHeapMemoryAllocator Ptr, _
	' ByVal pv As Any Ptr _
' )As SIZE_T_

' Dim DidAlloc As Function( _
	' ByVal this As IPrivateHeapMemoryAllocator Ptr, _
	' ByVal pv As Any Ptr _
' )As Long

' Dim HeapMinimize As Sub( _
	' ByVal this As IPrivateHeapMemoryAllocator Ptr _
' )

Function IPrivateHeapMemoryAllocatorSetHeap( _
		ByVal this As IPrivateHeapMemoryAllocator Ptr, _
		ByVal hHeap As HANDLE, _
		ByVal dwFlags As DWORD _
	)As HRESULT
	Return PrivateHeapMemoryAllocatorSetHeap(ContainerOf(this, PrivateHeapMemoryAllocator, lpVtbl), hHeap, dwFlags)
End Function

Dim GlobalPrivateHeapMemoryAllocatorVirtualTable As Const IPrivateHeapMemoryAllocatorVirtualTable = Type( _
	@IPrivateHeapMemoryAllocatorQueryInterface, _
	@IPrivateHeapMemoryAllocatorAddRef, _
	@IPrivateHeapMemoryAllocatorRelease, _
	@IPrivateHeapMemoryAllocatorAlloc, _
	NULL, _ /' @IPrivateHeapMemoryAllocatorRealloc, _ '/
	@IPrivateHeapMemoryAllocatorFree, _
	NULL, _ /' @IPrivateHeapMemoryAllocatorGetSize, _ '/
	NULL, _ /' @IPrivateHeapMemoryAllocatorDidAlloc, _ '/
	NULL, _ /' @IPrivateHeapMemoryAllocatorHeapMinimize, _ '/
	@IPrivateHeapMemoryAllocatorSetHeap _
)
