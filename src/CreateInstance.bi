#ifndef CREATEINSTANCE_BI
#define CREATEINSTANCE_BI

#include once "IHeapMemoryAllocator.bi"

Declare Function CreateInstance( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal rclsid As REFCLSID, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function CreatePermanentInstance( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal rclsid As REFCLSID, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function GetHeapMemoryAllocatorInstance( _
)As IHeapMemoryAllocator Ptr

#endif
