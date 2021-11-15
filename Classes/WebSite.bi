#ifndef WEBSITE_BI
#define WEBSITE_BI

#include once "IWebSite.bi"

Extern CLSID_WEBSITE Alias "CLSID_WEBSITE" As Const CLSID

Type WebSite As _WebSite

Type LPWebSite As _WebSite Ptr

Declare Function CreateWebSite( _
	ByVal pIMemoryAllocator As IMalloc Ptr _
)As WebSite Ptr

Declare Sub DestroyWebSite( _
	ByVal this As WebSite Ptr _
)

Declare Function WebSiteQueryInterface( _
	ByVal this As WebSite Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function WebSiteAddRef( _
	ByVal this As WebSite Ptr _
)As ULONG

Declare Function WebSiteRelease( _
	ByVal this As WebSite Ptr _
)As ULONG

Declare Function WebSiteGetHostName( _
	ByVal this As WebSite Ptr, _
	ByVal ppHost As WString Ptr Ptr _
)As HRESULT

Declare Function WebSiteGetSitePhysicalDirectory( _
	ByVal this As WebSite Ptr, _
	ByVal ppPhysicalDirectory As WString Ptr Ptr _
)As HRESULT

Declare Function WebSiteGetVirtualPath( _
	ByVal this As WebSite Ptr, _
	ByVal ppVirtualPath As WString Ptr Ptr _
)As HRESULT

Declare Function WebSiteGetIsMoved( _
	ByVal this As WebSite Ptr, _
	ByVal pIsMoved As Boolean Ptr _
)As HRESULT

Declare Function WebSiteGetMovedUrl( _
	ByVal this As WebSite Ptr, _
	ByVal ppMovedUrl As WString Ptr Ptr _
)As HRESULT

Declare Function WebSiteMapPath( _
	ByVal this As WebSite Ptr, _
	ByVal Path As WString Ptr, _
	ByVal pResult As WString Ptr _
)As HRESULT

Declare Function WebSiteOpenRequestedFile( _
	ByVal this As WebSite Ptr, _
	ByVal pRequestedFile As IRequestedFile Ptr, _
	ByVal FilePath As WString Ptr, _
	ByVal fAccess As FileAccess _
)As HRESULT

Declare Function WebSiteNeedCgiProcessing( _
	ByVal this As WebSite Ptr, _
	ByVal path As WString Ptr, _
	ByVal pResult As Boolean Ptr _
)As HRESULT

Declare Function WebSiteNeedDllProcessing( _
	ByVal this As WebSite Ptr, _
	ByVal path As WString Ptr, _
	ByVal pResult As Boolean Ptr _
)As HRESULT

Declare Function WebSiteSetHostName( _
	ByVal this As WebSite Ptr, _
	ByVal pHost As WString Ptr _
)As HRESULT

Declare Function WebSiteSetSitePhysicalDirectory( _
	ByVal this As WebSite Ptr, _
	ByVal pPhysicalDirectory As WString Ptr _
)As HRESULT

Declare Function WebSiteSetVirtualPath( _
	ByVal this As WebSite Ptr, _
	ByVal pVirtualPath As WString Ptr _
)As HRESULT

Declare Function WebSiteSetIsMoved( _
	ByVal this As WebSite Ptr, _
	ByVal IsMoved As Boolean _
)As HRESULT

Declare Function WebSiteSetMovedUrl( _
	ByVal this As WebSite Ptr, _
	ByVal pMovedUrl As WString Ptr _
)As HRESULT

#endif
