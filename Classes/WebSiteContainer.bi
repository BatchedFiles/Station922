#ifndef WEBSITECONTAINER_BI
#define WEBSITECONTAINER_BI

#include "IWebSiteContainer.bi"

Extern CLSID_WEBSITECONTAINER Alias "CLSID_WEBSITECONTAINER" As Const CLSID

Type WebSiteContainer As _WebSiteContainer

Type LPWebSiteContainer As _WebSiteContainer Ptr

Declare Function CreateWebSiteContainer( _
)As WebSiteContainer Ptr

Declare Sub DestroyWebSiteContainer( _
	ByVal this As WebSiteContainer Ptr _
)

Declare Function WebSiteContainerQueryInterface( _
	ByVal this As WebSiteContainer Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function WebSiteContainerAddRef( _
	ByVal this As WebSiteContainer Ptr _
)As ULONG

Declare Function WebSiteContainerRelease( _
	ByVal this As WebSiteContainer Ptr _
)As ULONG

Declare Function WebSiteContainerGetDefaultWebSite( _
	ByVal this As WebSiteContainer Ptr, _
	ByVal ppIWebSite As IWebSite Ptr Ptr _
)As HRESULT

Declare Function WebSiteContainerFindWebSite( _
	ByVal this As WebSiteContainer Ptr, _
	ByVal Host As WString Ptr, _
	ByVal ppIWebSite As IWebSite Ptr Ptr _
)As HRESULT

Declare Function WebSiteContainerLoadWebSites( _
	ByVal this As WebSiteContainer Ptr, _
	ByVal ExecutableDirectory As WString Ptr _
)As HRESULT

#endif
