#ifndef HEAPMEMORYALLOCATOR_BI
#define HEAPMEMORYALLOCATOR_BI

#include once "IHeapMemoryAllocator.bi"

Extern CLSID_HEAPMEMORYALLOCATOR Alias "CLSID_HEAPMEMORYALLOCATOR" As Const CLSID
Extern CLSID_SERVERHEAPMEMORYALLOCATOR Alias "CLSID_SERVERHEAPMEMORYALLOCATOR" As Const CLSID

Const RTTI_ID_HEAPMEMORYALLOCATOR     = !"\001Mem__Allocator\001"

Type HeapMemoryAllocator As _HeapMemoryAllocator

Type ServerHeapMemoryAllocator As _ServerHeapMemoryAllocator

Type LPHeapMemoryAllocator As _HeapMemoryAllocator Ptr

Declare Function CreateMemoryPool( _
	ByVal Length As UInteger, _
	ByVal KeepAliveInterval As Integer _
)As HRESULT

Declare Sub DeleteMemoryPool( _
)

Declare Function GetHeapMemoryAllocatorInstance( _
)As IHeapMemoryAllocator Ptr

#endif
