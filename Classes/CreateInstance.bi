#ifndef CREATEINSTANCE_BI
#define CREATEINSTANCE_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Declare Function CreateInstance( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal rclsid As REFCLSID, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function CreateMemoryAllocator( _
	ByVal ppMalloc As LPMALLOC Ptr _
)As HRESULT

Declare Function CreateClassFactoryInstance Alias "DllGetClassObject"( _
	ByVal rclsid As REFCLSID, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
