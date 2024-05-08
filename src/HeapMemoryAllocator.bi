#ifndef HEAPMEMORYALLOCATOR_BI
#define HEAPMEMORYALLOCATOR_BI

#include once "IHeapMemoryAllocator.bi"
#include once "win\winsock2.bi"

Extern CLSID_HEAPMEMORYALLOCATOR Alias "CLSID_HEAPMEMORYALLOCATOR" As Const CLSID
Extern CLSID_SERVERHEAPMEMORYALLOCATOR Alias "CLSID_SERVERHEAPMEMORYALLOCATOR" As Const CLSID

Const RTTI_ID_HEAPMEMORYALLOCATOR     = !"\001Mem__Allocator\001"

Declare Function CreateMemoryPool( _
	ByVal Capacity As UInteger, _
	ByVal KeepAliveInterval As Integer _
)As HRESULT

Declare Sub DeleteMemoryPool( _
)

Declare Function GetHeapMemoryAllocatorInstance( _
	ByVal ClientSocket As SOCKET _
)As IHeapMemoryAllocator Ptr

#endif
