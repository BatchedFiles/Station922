#ifndef IMUTABLEWEBSITE_BI
#define IMUTABLEWEBSITE_BI

Type IMutableWebSite As IMutableWebSite_

Type LPIMUTABLEWEBSITE As IMutableWebSite Ptr

Extern IID_IMutableWebSite Alias "IID_IMutableWebSite" As Const IID

Type IMutableWebSiteVirtualTable
	Dim InheritedTable As IUnknownVtbl
	
	Dim SetHostName As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal pHost As WString Ptr _
	)As HRESULT
	
	Dim SetExecutableDirectory As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal pExecutableDirectory As WString Ptr _
	)As HRESULT
	
	Dim SetSitePhysicalDirectory As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal pPhysicalDirectory As WString Ptr _
	)As HRESULT
	
	Dim SetVirtualPath As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal pVirtualPath As WString Ptr _
	)As HRESULT
	
	Dim SetIsMoved As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal IsMoved As Boolean _
	)As HRESULT
	
	Dim SetMovedUrl As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal pMovedUrl As WString Ptr _
	)As HRESULT
	
End Type

Type IMutableWebSite_
	Dim pVirtualTable As IMutableWebSiteVirtualTable Ptr
End Type

#define IMutableWebSite_QueryInterface(this, riid, ppv) (this)->pVirtualTable->InheritedTable.QueryInterface(CPtr(IUnknown Ptr, this), riid, ppv)
#define IMutableWebSite_AddRef(this) (this)->pVirtualTable->InheritedTable.AddRef(CPtr(IUnknown Ptr, this))
#define IMutableWebSite_Release(this) (this)->pVirtualTable->InheritedTable.Release(CPtr(IUnknown Ptr, this))
#define IMutableWebSite_SetHostName(this, pHost) (this)->pVirtualTable->SetHostName(this, pHost)
#define IMutableWebSite_SetExecutableDirectory(this, pExecutableDirectory) (this)->pVirtualTable->SetExecutableDirectory(this, pExecutableDirectory)
#define IMutableWebSite_SetSitePhysicalDirectory(this, pPhysicalDirectory) (this)->pVirtualTable->SetSitePhysicalDirectory(this, pPhysicalDirectory)
#define IMutableWebSite_SetVirtualPath(this, pVirtualPath) (this)->pVirtualTable->SetVirtualPath(this, pVirtualPath)
#define IMutableWebSite_SetIsMoved(this, IsMoved) (this)->pVirtualTable->SetIsMoved(this, IsMoved)
#define IMutableWebSite_SetMovedUrl(this, pMovedUrl) (this)->pVirtualTable->SetMovedUrl(this, pMovedUrl)

#endif
