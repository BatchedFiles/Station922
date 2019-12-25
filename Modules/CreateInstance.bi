#ifndef CREATEINSTANCE_BI
#define CREATEINSTANCE_BI

#ifndef unicode
#define unicode
#endif
#include "windows.bi"
#include "win\ole2.bi"

Declare Function CreateInstance( _
	ByVal hHeap As HANDLE, _
	ByVal rclsid As REFCLSID, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
