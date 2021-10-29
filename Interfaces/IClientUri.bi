#ifndef ICLIENTURI_BI
#define ICLIENTURI_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Type IClientUri As IClientUri_

Type LPICLIENTURI As IClientUri Ptr

Extern IID_IClientUri Alias "IID_IClientUri" As Const IID

Type IClientUriVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IClientUri Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IClientUri Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IClientUri Ptr _
	)As ULONG
	
	PathDecode As Function( _
		ByVal this As IClientUri Ptr, _
		ByVal Buffer As WString Ptr _
	)As HRESULT
End Type

Type IClientUri_
	lpVtbl As IClientUriVirtualTable Ptr
End Type

#define IClientUri_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IClientUri_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IClientUri_Release(this) (this)->lpVtbl->Release(this)

#endif
