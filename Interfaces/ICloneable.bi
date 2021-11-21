#ifndef ICLONEABLE_BI
#define ICLONEABLE_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Type ICloneable As ICloneable_

Type LPICLONEABLE As ICloneable Ptr

Extern IID_ICloneable Alias "IID_ICloneable" As Const IID

Type IHeapCloneableVirtualTable
	
	QueryInterface As Function( _
		ByVal this As ICloneable Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As ICloneable Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As ICloneable Ptr _
	)As ULONG
	
	Clone As Function( _
		ByVal this As ICloneable Ptr, _
		ByVal pMalloc As IMalloc Ptr, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
End Type

Type IHeapCloneable_
	lpVtbl As IHeapCloneableVirtualTable Ptr
End Type

#define ICloneable_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define ICloneable_AddRef(this) (this)->lpVtbl->AddRef(this)
#define ICloneable_Release(this) (this)->lpVtbl->Release(this)
#define ICloneable_Clone(this, pMalloc, ppv) (this)->lpVtbl->Clone(this, pMalloc, ppv)

#endif
