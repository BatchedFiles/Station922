#ifndef IHEAPMEMORYALLOCATOR_BI
#define IHEAPMEMORYALLOCATOR_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Type IHeapMemoryAllocator As IHeapMemoryAllocator_

Type LPIHeapMemoryAllocator As IHeapMemoryAllocator Ptr

Extern IID_IHeapMemoryAllocator Alias "IID_IHeapMemoryAllocator" As Const IID

Type IHeapMemoryAllocatorVirtualTable
	
	Dim QueryInterface As Function( _
		ByVal this As IHeapMemoryAllocator Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	Dim AddRef As Function( _
		ByVal this As IHeapMemoryAllocator Ptr _
	)As ULONG
	
	Dim Release As Function( _
		ByVal this As IHeapMemoryAllocator Ptr _
	)As ULONG
	
	Dim Alloc As Function( _
		ByVal this As IHeapMemoryAllocator Ptr, _
		ByVal cb As SIZE_T_ _
	)As Any Ptr
	
	Dim Realloc As Function( _
		ByVal this As IHeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr, _
		ByVal cb As SIZE_T_ _
	)As Any Ptr
	
	Dim Free As Sub( _
		ByVal this As IHeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr _
	)
	
	Dim GetSize As Function( _
		ByVal this As IHeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr _
	)As SIZE_T_
	
	Dim DidAlloc As Function( _
		ByVal this As IHeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr _
	)As Long
	
	Dim HeapMinimize As Sub( _
		ByVal this As IHeapMemoryAllocator Ptr _
	)
	
	Dim RegisterMallocSpy As Function( _
		ByVal this As IHeapMemoryAllocator Ptr, _
		ByVal pMallocSpy As LPMALLOCSPY _
	)As HRESULT
	
	Dim RevokeMallocSpy As Function( _
		ByVal this As IHeapMemoryAllocator Ptr _
	)As HRESULT
	
End Type

Type IHeapMemoryAllocatorVirtualTable_
	Dim lpVtbl As IHeapMemoryAllocatorVirtualTable Ptr
End Type

#define IHeapMemoryAllocator_QueryInterface(This, riid, ppvObject) (This)->lpVtbl->QueryInterface(This, riid, ppvObject)
#define IHeapMemoryAllocator_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IHeapMemoryAllocator_Release(This) (This)->lpVtbl->Release(This)
#define IHeapMemoryAllocator_Alloc(This, cb) (This)->lpVtbl->Alloc(This, cb)
#define IHeapMemoryAllocator_Realloc(This, pv, cb) (This)->lpVtbl->Realloc(This, pv, cb)
#define IHeapMemoryAllocator_Free(This, pv) (This)->lpVtbl->Free(This, pv)
#define IHeapMemoryAllocator_GetSize(This, pv) (This)->lpVtbl->GetSize(This, pv)
#define IHeapMemoryAllocator_DidAlloc(This, pv) (This)->lpVtbl->DidAlloc(This, pv)
#define IHeapMemoryAllocator_HeapMinimize(This) (This)->lpVtbl->HeapMinimize(This)
#define IHeapMemoryAllocator_RegisterMallocSpy(This, pMallocSpy) (This)->lpVtbl->RegisterMallocSpy(This, pMallocSpy)
#define IHeapMemoryAllocator_RevokeMallocSpy(This) (This)->lpVtbl->RevokeMallocSpy(This)

#endif
