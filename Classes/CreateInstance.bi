#ifndef CREATEINSTANCE_BI
#define CREATEINSTANCE_BI

#include once "ILogger.bi"

Declare Function CreateInstance( _
	ByVal pILogger As ILogger Ptr, _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal rclsid As REFCLSID, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function CreateMemoryAllocatorInstance( _
	ByVal pILogger As ILogger Ptr, _
	ByVal rclsid As REFCLSID, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function CreateLoggerInstance( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal rclsid As REFCLSID, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
