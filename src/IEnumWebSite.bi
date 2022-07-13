#ifndef IENUMWEBSITE_BI
#define IENUMWEBSITE_BI

#include once "IWebSite.bi"

Type IEnumWebSite As IEnumWebSite_

Type LPIENUMWEBSITE As IEnumWebSite Ptr

Extern IID_IEnumWebSite Alias "IID_IEnumWebSite" As Const IID

Type IEnumWebSiteVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IEnumWebSite Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IEnumWebSite Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IEnumWebSite Ptr _
	)As ULONG
	
	Next As Function( _
		ByVal this As IEnumWebSite Ptr, _
		ByVal celt As ULONG, _
		ByVal rgelt As IWebSite Ptr Ptr, _
		ByVal pceltFetched As ULONG Ptr _
	)As HRESULT
	
	Skip As Function( _
		ByVal this As IEnumWebSite Ptr, _
		ByVal celt As ULONG _
	)As HRESULT
	
	Reset As Function( _
		ByVal this As IEnumWebSite Ptr _
	)As HRESULT
	
	Clone As Function( _
		ByVal this As IEnumWebSite Ptr, _
		ByVal ppenum As IEnumWebSite Ptr Ptr _
	)As HRESULT
	
End Type

Type IEnumWebSite_
	lpVtbl As IEnumWebSiteVirtualTable Ptr
End Type

#define IEnumWebSite_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IEnumWebSite_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IEnumWebSite_Release(this) (this)->lpVtbl->Release(this)

#endif
