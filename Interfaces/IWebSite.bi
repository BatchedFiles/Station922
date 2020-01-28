#ifndef IWEBSITE_BI
#define IWEBSITE_BI

#include "IRequestedFile.bi"

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
	Dim InheritedTable As IUnknownVtbl
	
	Dim GetHostName As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal ppHost As WString Ptr Ptr _
	)As HRESULT
	
	Dim GetExecutableDirectory As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal ppExecutableDirectory As WString Ptr Ptr _
	)As HRESULT
	
	Dim GetSitePhysicalDirectory As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal ppPhysicalDirectory As WString Ptr Ptr _
	)As HRESULT
	
	Dim GetVirtualPath As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal ppVirtualPath As WString Ptr Ptr _
	)As HRESULT
	
	Dim GetIsMoved As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal pIsMoved As Boolean Ptr _
	)As HRESULT
	
	Dim GetMovedUrl As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal ppMovedUrl As WString Ptr Ptr _
	)As HRESULT
	
	Dim MapPath As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal Path As WString Ptr, _
		ByVal pResult As WString Ptr _
	)As HRESULT
	
	Dim OpenRequestedFile As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal pRequestedFile As IRequestedFile Ptr, _
		ByVal FilePath As WString Ptr, _
		ByVal fAccess As FileAccess _
	)As HRESULT
	
	Dim NeedCgiProcessing As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal path As WString Ptr, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
	Dim NeedDllProcessing As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal path As WString Ptr, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
End Type

Type IWebSite_
	Dim pVirtualTable As IWebSiteVirtualTable Ptr
End Type

#define IWebSite_QueryInterface(this, riid, ppv) (this)->pVirtualTable->InheritedTable.QueryInterface(CPtr(IUnknown Ptr, this), riid, ppv)
#define IWebSite_AddRef(this) (this)->pVirtualTable->InheritedTable.AddRef(CPtr(IUnknown Ptr, this))
#define IWebSite_Release(this) (this)->pVirtualTable->InheritedTable.Release(CPtr(IUnknown Ptr, this))
#define IWebSite_GetHostName(this, ppHost) (this)->pVirtualTable->GetHostName(this, ppHost)
#define IWebSite_GetExecutableDirectory(this, ppExecutableDirectory) (this)->pVirtualTable->GetExecutableDirectory(this, ppExecutableDirectory)
#define IWebSite_GetSitePhysicalDirectory(this, ppPhysicalDirectory) (this)->pVirtualTable->GetSitePhysicalDirectory(this, ppPhysicalDirectory)
#define IWebSite_GetVirtualPath(this, ppVirtualPath) (this)->pVirtualTable->GetVirtualPath(this, ppVirtualPath)
#define IWebSite_GetIsMoved(this, pIsMoved) (this)->pVirtualTable->GetIsMoved(this, pIsMoved)
#define IWebSite_GetMovedUrl(this, ppMovedUrl) (this)->pVirtualTable->GetMovedUrl(this, ppMovedUrl)
#define IWebSite_MapPath(this, Path, pResult) (this)->pVirtualTable->MapPath(this, Path, pResult)
#define IWebSite_OpenRequestedFile(this, pRequestedFile, FilePath, fAccess) (this)->pVirtualTable->OpenRequestedFile(this, pRequestedFile, FilePath, fAccess)
#define IWebSite_NeedCgiProcessing(this, Path, pResult) (this)->pVirtualTable->NeedCgiProcessing(this, Path, pResult)
#define IWebSite_NeedDllProcessing(this, Path, pResult) (this)->pVirtualTable->NeedDllProcessing(this, Path, pResult)

#endif
