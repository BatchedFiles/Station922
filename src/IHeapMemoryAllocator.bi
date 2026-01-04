#ifndef IHEAPMEMORYALLOCATOR_BI
#define IHEAPMEMORYALLOCATOR_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Extern IID_IHeapMemoryAllocator Alias "IID_IHeapMemoryAllocator" As Const IID

Type IHeapMemoryAllocator As IHeapMemoryAllocator_

Type IHeapMemoryAllocatorVirtualTable

	QueryInterface As Function( _
		ByVal self As IHeapMemoryAllocator Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IHeapMemoryAllocator Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IHeapMemoryAllocator Ptr _
	)As ULONG

	Alloc As Function( _
		ByVal self As IHeapMemoryAllocator Ptr, _
		ByVal cb As SIZE_T_ _
	)As Any Ptr

	Realloc As Function( _
		ByVal self As IHeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr, _
		ByVal cb As SIZE_T_ _
	)As Any Ptr

	Free As Sub( _
		ByVal self As IHeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr _
	)

	GetSize As Function( _
		ByVal self As IHeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr _
	)As SIZE_T_

	DidAlloc As Function( _
		ByVal self As IHeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr _
	)As Long

	HeapMinimize As Sub( _
		ByVal self As IHeapMemoryAllocator Ptr _
	)

	RegisterMallocSpy As Function( _
		ByVal self As IHeapMemoryAllocator Ptr, _
		ByVal pMallocSpy As LPMALLOCSPY _
	)As HRESULT

	RevokeMallocSpy As Function( _
		ByVal self As IHeapMemoryAllocator Ptr _
	)As HRESULT

End Type

Type IHeapMemoryAllocator_
	lpVtbl As IHeapMemoryAllocatorVirtualTable Ptr
End Type

#define IHeapMemoryAllocator_QueryInterface(self, riid, ppvObject) (self)->lpVtbl->QueryInterface(self, riid, ppvObject)
#define IHeapMemoryAllocator_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IHeapMemoryAllocator_Release(self) (self)->lpVtbl->Release(self)
#define IHeapMemoryAllocator_Alloc(self, cb) (self)->lpVtbl->Alloc(self, cb)
#define IHeapMemoryAllocator_Realloc(self, pv, cb) (self)->lpVtbl->Realloc(self, pv, cb)
#define IHeapMemoryAllocator_Free(self, pv) (self)->lpVtbl->Free(self, pv)
#define IHeapMemoryAllocator_GetSize(self, pv) (self)->lpVtbl->GetSize(self, pv)
#define IHeapMemoryAllocator_DidAlloc(self, pv) (self)->lpVtbl->DidAlloc(self, pv)
#define IHeapMemoryAllocator_HeapMinimize(self) (self)->lpVtbl->HeapMinimize(self)
#define IHeapMemoryAllocator_RegisterMallocSpy(self, pMallocSpy) (self)->lpVtbl->RegisterMallocSpy(self, pMallocSpy)
#define IHeapMemoryAllocator_RevokeMallocSpy(self) (self)->lpVtbl->RevokeMallocSpy(self)

#endif
