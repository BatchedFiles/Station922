#ifndef WEBSITECONTAINER_BI
#define WEBSITECONTAINER_BI

#include "IWebSiteContainer.bi"
#include "WebSite.bi"

Extern CLSID_WEBSITECONTAINER Alias "CLSID_WEBSITECONTAINER" As Const CLSID

Type WebSiteNode
	Const MaxHostNameLength As Integer = 1024 - 1
	
	Dim HostName As WString * (MaxHostNameLength + 1)
	Dim pExecutableDirectory As WString Ptr
	Dim PhysicalDirectory As WString * (MAX_PATH + 1)
	Dim VirtualPath As WString * (MaxHostNameLength + 1)
	Dim MovedUrl As WString * (MaxHostNameLength + 1)
	Dim IsMoved As Boolean
	
	Dim LeftNode As WebSiteNode Ptr
	Dim RightNode As WebSiteNode Ptr
	Dim objWebSite As WebSite
	Dim pIWebSite As IWebSite Ptr
End Type

Type WebSiteContainer
	
	Dim pVirtualTable As IWebSiteContainerVirtualTable Ptr
	Dim ReferenceCounter As ULONG
	
	Dim ExecutableDirectory As WString * (MAX_PATH + 1)
	Dim hTreeHeap As Handle
	Dim pDefaultNode As WebSiteNode Ptr
	Dim pTree As WebSiteNode Ptr
	
End Type

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
