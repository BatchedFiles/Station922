#ifndef IWEBSITE_BI
#define IWEBSITE_BI

#include once "IString.bi"

Enum FileAccess
	CreateAccess
	ReadAccess
	UpdateAccess
	DeleteAccess
End Enum

Type IWebSite As IWebSite_

Type LPIWEBSITE As IWebSite Ptr

Extern IID_IWebSite Alias "IID_IWebSite" As Const IID

Type IWebSiteVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IWebSite Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IWebSite Ptr _
	)As ULONG
	
	GetHostName As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal ppHost As HeapBSTR Ptr _
	)As HRESULT
	
	GetSitePhysicalDirectory As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal ppPhysicalDirectory As HeapBSTR Ptr _
	)As HRESULT
	
	GetVirtualPath As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal ppVirtualPath As HeapBSTR Ptr _
	)As HRESULT
	
	GetIsMoved As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal pIsMoved As Boolean Ptr _
	)As HRESULT
	
	GetMovedUrl As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal ppMovedUrl As HeapBSTR Ptr _
	)As HRESULT
	
	MapPath As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal Path As HeapBSTR, _
		ByVal pResult As HeapBSTR Ptr _
	)As HRESULT
	
	NeedCgiProcessing As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal path As HeapBSTR, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
	NeedDllProcessing As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal path As HeapBSTR, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
End Type

Type IWebSite_
	lpVtbl As IWebSiteVirtualTable Ptr
End Type

#define IWebSite_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IWebSite_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IWebSite_Release(this) (this)->lpVtbl->Release(this)
#define IWebSite_GetHostName(this, ppHost) (this)->lpVtbl->GetHostName(this, ppHost)
#define IWebSite_GetSitePhysicalDirectory(this, ppPhysicalDirectory) (this)->lpVtbl->GetSitePhysicalDirectory(this, ppPhysicalDirectory)
#define IWebSite_GetVirtualPath(this, ppVirtualPath) (this)->lpVtbl->GetVirtualPath(this, ppVirtualPath)
#define IWebSite_GetIsMoved(this, pIsMoved) (this)->lpVtbl->GetIsMoved(this, pIsMoved)
#define IWebSite_GetMovedUrl(this, ppMovedUrl) (this)->lpVtbl->GetMovedUrl(this, ppMovedUrl)
#define IWebSite_MapPath(this, Path, pResult) (this)->lpVtbl->MapPath(this, Path, pResult)
#define IWebSite_NeedCgiProcessing(this, Path, pResult) (this)->lpVtbl->NeedCgiProcessing(this, Path, pResult)
#define IWebSite_NeedDllProcessing(this, Path, pResult) (this)->lpVtbl->NeedDllProcessing(this, Path, pResult)

#endif
