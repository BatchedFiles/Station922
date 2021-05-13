#ifndef HEAPMEMORYALLOCATOR_BI
#define HEAPMEMORYALLOCATOR_BI

#include once "IHeapMemoryAllocator.bi"
#include once "ILogger.bi"

Extern CLSID_HEAPMEMORYALLOCATOR Alias "CLSID_HEAPMEMORYALLOCATOR" As Const CLSID

Type HeapMemoryAllocator As _HeapMemoryAllocator

Type LPHeapMemoryAllocator As _HeapMemoryAllocator Ptr

Declare Function CreateHeapMemoryAllocator( _
	ByVal pILogger As ILogger Ptr _
)As HeapMemoryAllocator Ptr

Declare Sub DestroyHeapMemoryAllocator( _
	ByVal this As HeapMemoryAllocator Ptr _
)

Declare Function HeapMemoryAllocatorQueryInterface( _
	ByVal this As HeapMemoryAllocator Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function HeapMemoryAllocatorAddRef( _
	ByVal this As HeapMemoryAllocator Ptr _
)As ULONG

Declare Function HeapMemoryAllocatorRelease( _
	ByVal this As HeapMemoryAllocator Ptr _
)As ULONG

Declare Function HeapMemoryAllocatorAlloc( _
	ByVal this As HeapMemoryAllocator Ptr, _
	ByVal cb As SIZE_T_ _
)As Any Ptr

Declare Function HeapMemoryAllocatorRealloc( _
	ByVal this As HeapMemoryAllocator Ptr, _
	ByVal pv As Any Ptr, _
	ByVal cb As SIZE_T_ _
)As Any Ptr

Declare Sub HeapMemoryAllocatorFree( _
	ByVal this As HeapMemoryAllocator Ptr, _
	ByVal pv As Any Ptr _
)

Declare Function HeapMemoryAllocatorGetSize( _
	ByVal this As HeapMemoryAllocator Ptr, _
	ByVal pv As Any Ptr _
)As SIZE_T_

Declare Function HeapMemoryAllocatorDidAlloc( _
	ByVal this As HeapMemoryAllocator Ptr, _
	ByVal pv As Any Ptr _
)As Long

Declare Sub HeapMemoryAllocatorHeapMinimize( _
	ByVal this As HeapMemoryAllocator Ptr _
)

Declare Function HeapMemoryAllocatorRegisterMallocSpy( _
	ByVal this As HeapMemoryAllocator Ptr, _
	ByVal pMallocSpy As LPMALLOCSPY _
)As HRESULT

Declare Function HeapMemoryAllocatorRevokeMallocSpy( _
	ByVal this As HeapMemoryAllocator Ptr _
)As HRESULT

#endif
