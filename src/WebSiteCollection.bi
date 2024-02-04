#ifndef WEBSITECOLLECTION_BI
#define WEBSITECOLLECTION_BI

#include once "IWebSiteCollection.bi"

Extern CLSID_WEBSITECOLLECTION Alias "CLSID_WEBSITECOLLECTION" As Const CLSID

Const RTTI_ID_WEBSITECOLLECTION       = !"\001Coll___WebSite\001"
Const RTTI_ID_WEBSITENODE             = !"\001Node___WebSite\001"

Declare Function CreateWebSiteCollection( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
