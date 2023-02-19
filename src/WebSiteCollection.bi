#ifndef WEBSITECOLLECTION_BI
#define WEBSITECOLLECTION_BI

#include once "IWebSiteCollection.bi"

Extern CLSID_WEBSITECOLLECTION Alias "CLSID_WEBSITECOLLECTION" As Const CLSID

Extern pIWebSitesWeakPtr As IWebSiteCollection Ptr

Const RTTI_ID_WEBSITECOLLECTION       = !"\001Coll___WebSite\001"
Const RTTI_ID_WEBSITENODE             = !"\001Node___WebSite\001"

Type WebSiteCollection As _WebSiteCollection

Type LPWebSiteCollection As _WebSiteCollection Ptr

Declare Function CreateWebSiteCollection( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Sub DestroyWebSiteCollection( _
	ByVal this As WebSiteCollection Ptr _
)

Declare Function WebSiteCollectionQueryInterface( _
	ByVal this As WebSiteCollection Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function WebSiteCollectionAddRef( _
	ByVal this As WebSiteCollection Ptr _
)As ULONG

Declare Function WebSiteCollectionRelease( _
	ByVal this As WebSiteCollection Ptr _
)As ULONG

Declare Function WebSiteCollection_NewEnum( _
	ByVal this As WebSiteCollection Ptr, _
	ByVal ppIEnum As IEnumWebSite Ptr Ptr _
)As HRESULT

Declare Function WebSiteCollectionItem( _
	ByVal this As WebSiteCollection Ptr, _
	ByVal pKey As HeapBSTR, _
	ByVal ppIWebSite As IWebSite Ptr Ptr _
)As HRESULT

Declare Function WebSiteCollectionCount( _
	ByVal this As WebSiteCollection Ptr, _
	ByVal pCount As Integer Ptr _
)As HRESULT

Declare Function WebSiteCollectionAdd( _
	ByVal this As WebSiteCollection Ptr, _
	ByVal pKey As HeapBSTR, _
	ByVal pIWebSite As IWebSite Ptr _
)As HRESULT

Declare Function WebSiteCollectionItemWeakPtr( _
	ByVal this As WebSiteCollection Ptr, _
	ByVal pKey As HeapBSTR, _
	ByVal ppIWebSite As IWebSite Ptr Ptr _
)As HRESULT

Declare Function WebSiteCollectionSetDefaultWebSite( _
	ByVal this As WebSiteCollection Ptr, _
	ByVal pIWebSite As IWebSite Ptr _
)As HRESULT

Declare Function WebSiteCollectionGetDefaultWebSite( _
	ByVal this As WebSiteCollection Ptr, _
	ByVal ppIWebSite As IWebSite Ptr Ptr _
)As HRESULT

#endif
