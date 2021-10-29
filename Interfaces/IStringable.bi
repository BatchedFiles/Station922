#ifndef ISTRINGABLE_BI
#define ISTRINGABLE_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Type LPISTRINGABLE As IStringable Ptr

Type IStringable As IStringable_

Extern IID_IStringable Alias "IID_IStringable" As Const IID

Type IStringableVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IStringable Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IStringable Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IStringable Ptr _
	)As ULONG
	
	ToString As Function( _
		ByVal this As IStringable Ptr, _
		ByVal pLength As Integer Ptr, _
		ByVal ppResult As WString Ptr Ptr _
	)As HRESULT
	
End Type

Type IStringable_
	lpVtbl As IStringableVirtualTable Ptr
End Type

#define IStringable_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IStringable_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IStringable_Release(this) (this)->lpVtbl->Release(this)
#define IStringable_ToString(this, pLength, ppResult) (this)->lpVtbl->ToString(this, pLength, ppResult)

#endif
