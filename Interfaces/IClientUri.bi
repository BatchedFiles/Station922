#ifndef ICLIENTURI_BI
#define ICLIENTURI_BI

#ifndef unicode
#define unicode
#endif
#include "windows.bi"
#include "win\ole2.bi"

Type IClientUri As IClientUri_

Type LPICLIENTURI As IClientUri Ptr

Extern IID_IClientUri Alias "IID_IClientUri" As Const IID

Type IClientUriVirtualTable
	Dim InheritedTable As IUnknownVtbl
	
	Dim PathDecode As Function( _
		ByVal this As IClientUri Ptr, _
		ByVal Buffer As WString Ptr _
	)As HRESULT
End Type

Type IClientUri_
	Dim pVirtualTable As IClientUriVirtualTable Ptr
End Type

#define IClientUri_QueryInterface(this, riid, ppv) (this)->pVirtualTable->InheritedTable.QueryInterface(CPtr(IUnknown Ptr, this), riid, ppv)
#define IClientUri_AddRef(this) (this)->pVirtualTable->InheritedTable.AddRef(CPtr(IUnknown Ptr, this))
#define IClientUri_Release(this) (this)->pVirtualTable->InheritedTable.Release(CPtr(IUnknown Ptr, this))

#endif
