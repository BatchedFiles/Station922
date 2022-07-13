#ifndef ISTRING_BI
#define ISTRING_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Type _HeapBSTR As OLECHAR Ptr

Type HeapBSTR As _HeapBSTR

Type LPHEAPBSTR As _HeapBSTR Ptr

Type IString As IString_

Type LPISTRING As IString Ptr

Extern IID_IString Alias "IID_IString" As Const IID

Type IStringVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IString Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IString Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IString Ptr _
	)As ULONG
	
	GetHeapBSTR As Function( _
		ByVal this As IString Ptr, _
		ByVal pcHeapBSTR As HeapBSTR Const Ptr _
	)As HRESULT
	
End Type

Type IString_
	lpVtbl As IStringVirtualTable Ptr
End Type

#define IString_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IString_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IString_Release(this) (this)->lpVtbl->Release(this)
#define IString_GetHeapBSTR(this, pcHeapBSTR) (this)->lpVtbl->GetHeapBSTR(this, pcHeapBSTR)

#endif
