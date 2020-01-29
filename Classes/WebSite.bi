#ifndef WEBSITE_BI
#define WEBSITE_BI

#include "IWebSite.bi"

Extern CLSID_WEBSITE Alias "CLSID_WEBSITE" As Const CLSID

Type WebSite As _WebSite

Type LPWebSite As _WebSite Ptr

Declare Function CreateWebSite( _
	ByVal hHeap As HANDLE _
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

Declare Function WebSiteGetExecutableDirectory( _
	ByVal this As WebSite Ptr, _
	ByVal ppExecutableDirectory As WString Ptr Ptr _
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

Declare Function MutableWebSiteQueryInterface( _
	ByVal this As WebSite Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function MutableWebSiteAddRef( _
	ByVal this As WebSite Ptr _
)As ULONG

Declare Function MutableWebSiteRelease( _
	ByVal this As WebSite Ptr _
)As ULONG

Declare Function MutableWebSiteSetHostName( _
	ByVal this As WebSite Ptr, _
	ByVal pHost As WString Ptr _
)As HRESULT

Declare Function MutableWebSiteSetExecutableDirectory( _
	ByVal this As WebSite Ptr, _
	ByVal pExecutableDirectory As WString Ptr _
)As HRESULT

Declare Function MutableWebSiteSetSitePhysicalDirectory( _
	ByVal this As WebSite Ptr, _
	ByVal pPhysicalDirectory As WString Ptr _
)As HRESULT

Declare Function MutableWebSiteSetVirtualPath( _
	ByVal this As WebSite Ptr, _
	ByVal pVirtualPath As WString Ptr _
)As HRESULT

Declare Function MutableWebSiteSetIsMoved( _
	ByVal this As WebSite Ptr, _
	ByVal IsMoved As Boolean _
)As HRESULT

Declare Function MutableWebSiteSetMovedUrl( _
	ByVal this As WebSite Ptr, _
	ByVal pMovedUrl As WString Ptr _
)As HRESULT

#endif
