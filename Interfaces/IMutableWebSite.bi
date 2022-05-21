#ifndef IMUTABLEWEBSITE_BI
#define IMUTABLEWEBSITE_BI

#include once "IWebSite.bi"

Type IMutableWebSite As IMutableWebSite_

Type LPIMUTABLEWEBSITE As IMutableWebSite Ptr

Extern IID_IMutableWebSite Alias "IID_IMutableWebSite" As Const IID

Type IMutableWebSiteVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IMutableWebSite Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IMutableWebSite Ptr _
	)As ULONG
	
	GetHostName As Function( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal ppHost As HeapBSTR Ptr _
	)As HRESULT
	
	GetSitePhysicalDirectory As Function( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal ppPhysicalDirectory As HeapBSTR Ptr _
	)As HRESULT
	
	GetVirtualPath As Function( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal ppVirtualPath As HeapBSTR Ptr _
	)As HRESULT
	
	GetIsMoved As Function( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal pIsMoved As Boolean Ptr _
	)As HRESULT
	
	GetMovedUrl As Function( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal ppMovedUrl As HeapBSTR Ptr _
	)As HRESULT
	
	GetBuffer As Function( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal pIMalloc As IMalloc Ptr, _
		ByVal Path As HeapBSTR, _
		ByVal fAccess As FileAccess, _
		ByVal pNegotiation As ContentNegotiationContext Ptr, _
		ByVal pFileContext As FileContentInfo Ptr, _
		ByVal pFlags As ContentNegotiationFlags Ptr, _
		ByVal ppResult As IBuffer Ptr Ptr _
	)As HRESULT
	
	NeedCgiProcessing As Function( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal path As HeapBSTR, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
	NeedDllProcessing As Function( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal path As HeapBSTR, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
	SetHostName As Function( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal pHost As HeapBSTR _
	)As HRESULT
	
	SetSitePhysicalDirectory As Function( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal pPhysicalDirectory As HeapBSTR _
	)As HRESULT
	
	SetVirtualPath As Function( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal pVirtualPath As HeapBSTR _
	)As HRESULT
	
	SetIsMoved As Function( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal IsMoved As Boolean _
	)As HRESULT
	
	SetMovedUrl As Function( _
		ByVal this As IMutableWebSite Ptr, _
		ByVal pMovedUrl As HeapBSTR _
	)As HRESULT
	
End Type

Type IMutableWebSite_
	lpVtbl As IMutableWebSiteVirtualTable Ptr
End Type

#define IMutableWebSite_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IMutableWebSite_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IMutableWebSite_Release(this) (this)->lpVtbl->Release(this)
#define IMutableWebSite_GetHostName(this, ppHost) (this)->lpVtbl->GetHostName(this, ppHost)
#define IMutableWebSite_GetSitePhysicalDirectory(this, ppPhysicalDirectory) (this)->lpVtbl->GetSitePhysicalDirectory(this, ppPhysicalDirectory)
#define IMutableWebSite_GetVirtualPath(this, ppVirtualPath) (this)->lpVtbl->GetVirtualPath(this, ppVirtualPath)
#define IMutableWebSite_GetIsMoved(this, pIsMoved) (this)->lpVtbl->GetIsMoved(this, pIsMoved)
#define IMutableWebSite_GetMovedUrl(this, ppMovedUrl) (this)->lpVtbl->GetMovedUrl(this, ppMovedUrl)
#define IMutableWebSite_GetBuffer(this, pIMalloc, Path, fAccess, pNegotiation, pFileContext, pFlags, ppResult) (this)->lpVtbl->GetBuffer(this, pIMalloc, Path, fAccess, pNegotiation, pFileContext, pFlags, ppResult)
#define IMutableWebSite_NeedCgiProcessing(this, Path, pResult) (this)->lpVtbl->NeedCgiProcessing(this, Path, pResult)
#define IMutableWebSite_NeedDllProcessing(this, Path, pResult) (this)->lpVtbl->NeedDllProcessing(this, Path, pResult)
#define IMutableWebSite_SetHostName(this, pHost) (this)->lpVtbl->SetHostName(this, pHost)
#define IMutableWebSite_SetSitePhysicalDirectory(this, pPhysicalDirectory) (this)->lpVtbl->SetSitePhysicalDirectory(this, pPhysicalDirectory)
#define IMutableWebSite_SetVirtualPath(this, pVirtualPath) (this)->lpVtbl->SetVirtualPath(this, pVirtualPath)
#define IMutableWebSite_SetIsMoved(this, IsMoved) (this)->lpVtbl->SetIsMoved(this, IsMoved)
#define IMutableWebSite_SetMovedUrl(this, pMovedUrl) (this)->lpVtbl->SetMovedUrl(this, pMovedUrl)

#endif
