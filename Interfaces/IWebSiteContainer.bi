#ifndef IWEBSITECONTAINER_BI
#define IWEBSITECONTAINER_BI

#include "IWebSite.bi"

Type IWebSiteContainer As IWebSiteContainer_

Type LPIWEBSITECONTAINER As IWebSiteContainer Ptr

Extern IID_IWebSiteContainer Alias "IID_IWebSiteContainer" As Const IID

Type IWebSiteContainerVirtualTable
	Dim InheritedTable As IUnknownVtbl
	
	Dim FindWebSite As Function( _
		ByVal this As IWebSiteContainer Ptr, _
		ByVal Host As WString Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT
	
	Dim GetDefaultWebSite As Function( _
		ByVal this As IWebSiteContainer Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT
	
	Dim LoadWebSites As Function( _
		ByVal this As IWebSiteContainer Ptr, _
		ByVal ExecutableDirectory As WString Ptr _
	)As HRESULT
	
End Type

Type IWebSiteContainer_
	Dim pVirtualTable As IWebSiteContainerVirtualTable Ptr
End Type

#define IWebSiteContainer_QueryInterface(this, riid, ppv) (this)->pVirtualTable->InheritedTable.QueryInterface(CPtr(IUnknown Ptr, this), riid, ppv)
#define IWebSiteContainer_AddRef(this) (this)->pVirtualTable->InheritedTable.AddRef(CPtr(IUnknown Ptr, this))
#define IWebSiteContainer_Release(this) (this)->pVirtualTable->InheritedTable.Release(CPtr(IUnknown Ptr, this))
#define IWebSiteContainer_FindWebSite(this, Host, pIWebSite) (this)->pVirtualTable->FindWebSite(this, Host, pIWebSite)
#define IWebSiteContainer_GetDefaultWebSite(this, pIWebSite) (this)->pVirtualTable->GetDefaultWebSite(this, pIWebSite)
#define IWebSiteContainer_LoadWebSites(this, ExecutableDirectory) (this)->pVirtualTable->LoadWebSites(this, ExecutableDirectory)

#endif
