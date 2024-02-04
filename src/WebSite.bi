#ifndef WEBSITE_BI
#define WEBSITE_BI

#include once "IWebSite.bi"

Extern CLSID_WEBSITE Alias "CLSID_WEBSITE" As Const CLSID

Const RTTI_ID_WEBSITE                 = !"\001Web_______Site\001"

Declare Function CreateWebSite( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
