#ifndef ISTRING_BI
#define ISTRING_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Extern IID_IString Alias "IID_IString" As Const IID

Type _HeapBSTR As OLECHAR Ptr

Type HeapBSTR As _HeapBSTR

Type IString As IString_

Type IStringVirtualTable

	QueryInterface As Function( _
		ByVal self As IString Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IString Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IString Ptr _
	)As ULONG

	GetHeapBSTR As Function( _
		ByVal self As IString Ptr, _
		ByVal pcHeapBSTR As HeapBSTR Const Ptr _
	)As HRESULT

End Type

Type IString_
	lpVtbl As IStringVirtualTable Ptr
End Type

#define IString_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define IString_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IString_Release(self) (self)->lpVtbl->Release(self)
#define IString_GetHeapBSTR(self, pcHeapBSTR) (self)->lpVtbl->GetHeapBSTR(self, pcHeapBSTR)

#endif
