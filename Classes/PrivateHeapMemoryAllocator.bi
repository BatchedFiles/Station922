#ifndef PRIVATEHEAPMEMORYALLOCATOR_BI
#define PRIVATEHEAPMEMORYALLOCATOR_BI

#include once "IPrivateHeapMemoryAllocator.bi"

Extern CLSID_PRIVATEHEAPMEMORYALLOCATOR Alias "CLSID_PRIVATEHEAPMEMORYALLOCATOR" As Const CLSID

Type PrivateHeapMemoryAllocator As _PrivateHeapMemoryAllocator

Type LPPrivateHeapMemoryAllocator As _PrivateHeapMemoryAllocator Ptr

Declare Function CreatePrivateHeapMemoryAllocator( _
	ByVal pIMemoryAllocator As IMalloc Ptr _
)As PrivateHeapMemoryAllocator Ptr

Declare Sub DestroyPrivateHeapMemoryAllocator( _
	ByVal this As PrivateHeapMemoryAllocator Ptr _
)

Declare Function PrivateHeapMemoryAllocatorQueryInterface( _
	ByVal this As PrivateHeapMemoryAllocator Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function PrivateHeapMemoryAllocatorAddRef( _
	ByVal this As PrivateHeapMemoryAllocator Ptr _
)As ULONG

Declare Function PrivateHeapMemoryAllocatorRelease( _
	ByVal this As PrivateHeapMemoryAllocator Ptr _
)As ULONG

Declare Function PrivateHeapMemoryAllocatorAlloc( _
	ByVal this As PrivateHeapMemoryAllocator Ptr, _
	ByVal cb As SIZE_T_ _
)As Any Ptr

Declare Function PrivateHeapMemoryAllocatorRealloc( _
	ByVal this As PrivateHeapMemoryAllocator Ptr, _
	ByVal pv As Any Ptr, _
	ByVal cb As SIZE_T_ _
)As Any Ptr

Declare Sub PrivateHeapMemoryAllocatorFree( _
	ByVal this As PrivateHeapMemoryAllocator Ptr, _
	ByVal pv As Any Ptr _
)

Declare Function PrivateHeapMemoryAllocatorGetSize( _
	ByVal this As PrivateHeapMemoryAllocator Ptr, _
	ByVal pv As Any Ptr _
)As SIZE_T_

Declare Function PrivateHeapMemoryAllocatorDidAlloc( _
	ByVal this As PrivateHeapMemoryAllocator Ptr, _
	ByVal pv As Any Ptr _
)As Long

Declare Sub PrivateHeapMemoryAllocatorHeapMinimize( _
	ByVal this As PrivateHeapMemoryAllocator Ptr _
)

Declare Function PrivateHeapMemoryAllocatorRegisterMallocSpy( _
	ByVal this As PrivateHeapMemoryAllocator Ptr, _
	ByVal pMallocSpy As LPMALLOCSPY _
)As HRESULT

Declare Function PrivateHeapMemoryAllocatorRevokeMallocSpy( _
	ByVal this As PrivateHeapMemoryAllocator Ptr _
)As HRESULT

#endif
