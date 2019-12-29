#ifndef WEBSITE_BI
#define WEBSITE_BI

#include "IWebSite.bi"

Extern CLSID_WEBSITE Alias "CLSID_WEBSITE" As Const CLSID

Type WebSite
	
	Dim pVirtualTable As IWebSiteVirtualTable Ptr
	Dim ReferenceCounter As ULONG
	Dim ExistsInStack As Boolean
	
	Dim pHostName As WString Ptr
	Dim pPhysicalDirectory As WString Ptr
	Dim pExecutableDirectory As WString Ptr
	Dim pVirtualPath As WString Ptr
	Dim IsMoved As Boolean
	Dim pMovedUrl As WString Ptr
	
End Type

Declare Function InitializeWebSiteOfIWebSite( _
	ByVal pWebSite As WebSite Ptr _
)As IWebSite Ptr

Declare Function WebSiteQueryInterface( _
	ByVal pWebSite As WebSite Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function WebSiteAddRef( _
	ByVal pWebSite As WebSite Ptr _
)As ULONG

Declare Function WebSiteRelease( _
	ByVal pWebSite As WebSite Ptr _
)As ULONG

Declare Function WebSiteGetHostName( _
	ByVal pWebSite As WebSite Ptr, _
	ByVal ppHost As WString Ptr Ptr _
)As HRESULT

Declare Function WebSiteGetExecutableDirectory( _
	ByVal pWebSite As WebSite Ptr, _
	ByVal ppExecutableDirectory As WString Ptr Ptr _
)As HRESULT

Declare Function WebSiteGetSitePhysicalDirectory( _
	ByVal pWebSite As WebSite Ptr, _
	ByVal ppPhysicalDirectory As WString Ptr Ptr _
)As HRESULT

Declare Function WebSiteGetVirtualPath( _
	ByVal pWebSite As WebSite Ptr, _
	ByVal ppVirtualPath As WString Ptr Ptr _
)As HRESULT

Declare Function WebSiteGetIsMoved( _
	ByVal pWebSite As WebSite Ptr, _
	ByVal pIsMoved As Boolean Ptr _
)As HRESULT

Declare Function WebSiteGetMovedUrl( _
	ByVal pWebSite As WebSite Ptr, _
	ByVal ppMovedUrl As WString Ptr Ptr _
)As HRESULT

Declare Function WebSiteMapPath( _
	ByVal pWebSite As WebSite Ptr, _
	ByVal Path As WString Ptr, _
	ByVal pResult As WString Ptr _
)As HRESULT

Declare Function WebSiteGetRequestedFile( _
	ByVal pWebSite As WebSite Ptr, _
	ByVal FilePath As WString Ptr, _
	ByVal ForReading As FileAccess, _
	ByVal ppRequestedFile As IRequestedFile Ptr Ptr _
)As HRESULT

Declare Function WebSiteNeedCgiProcessing( _
	ByVal pWebSite As WebSite Ptr, _
	ByVal path As WString Ptr, _
	ByVal pResult As Boolean Ptr _
)As HRESULT

Declare Function WebSiteNeedDllProcessing( _
	ByVal pWebSite As WebSite Ptr, _
	ByVal path As WString Ptr, _
	ByVal pResult As Boolean Ptr _
)As HRESULT

#endif
