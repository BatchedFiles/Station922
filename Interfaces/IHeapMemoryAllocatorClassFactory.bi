#ifndef IPRIVATEHEAPMEMORYALLOCATORCLASSFACTORY_BI
#define IPRIVATEHEAPMEMORYALLOCATORCLASSFACTORY_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Type IPrivateHeapMemoryAllocatorClassFactory As IPrivateHeapMemoryAllocatorClassFactory_

Type LPIPRIVATEHEAPMEMORYALLOCATORCLASSFACTORY As IPrivateHeapMemoryAllocatorClassFactory Ptr

Extern IID_IPrivateHeapMemoryAllocatorClassFactory Alias "IID_IPrivateHeapMemoryAllocatorClassFactory" As Const IID

Type IPrivateHeapMemoryAllocatorClassFactoryVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IPrivateHeapMemoryAllocatorClassFactory Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this as IPrivateHeapMemoryAllocatorClassFactory Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IPrivateHeapMemoryAllocatorClassFactory Ptr _
	)As ULONG
	
	CreateInstance As Function( _
		ByVal this As IPrivateHeapMemoryAllocatorClassFactory Ptr, _
		ByVal pUnkOuter As IUnknown Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	LockServer As Function( _
		ByVal this As IPrivateHeapMemoryAllocatorClassFactory Ptr, _
		ByVal fLock As WINBOOL _
	)As HRESULT
	
	SetHeapInitialSize As Function( _
		ByVal this As IPrivateHeapMemoryAllocatorClassFactory Ptr, _
		ByVal dwInitialSize As DWORD _
	)As HRESULT
	
	SetHeapMaximumSize As Function( _
		ByVal this As IPrivateHeapMemoryAllocatorClassFactory Ptr, _
		ByVal dwMaximumSize As DWORD _
	)As HRESULT
	
	SetHeapFlags As Function( _
		ByVal this As IPrivateHeapMemoryAllocatorClassFactory Ptr, _
		ByVal dwFlags As DWORD _
	)As HRESULT
	
End Type

Type IPrivateHeapMemoryAllocatorClassFactoryVirtualTable_
	lpVtbl As IPrivateHeapMemoryAllocatorClassFactoryVirtualTable Ptr
End Type

#define IPrivateHeapMemoryAllocatorClassFactory_QueryInterface(This, riid, ppvObject) (This)->lpVtbl->QueryInterface(This, riid, ppvObject)
#define IPrivateHeapMemoryAllocatorClassFactory_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IPrivateHeapMemoryAllocatorClassFactory_Release(This) (This)->lpVtbl->Release(This)
#define IPrivateHeapMemoryAllocatorClassFactory_CreateInstance(This, pUnkOuter, riid, ppvObject) (This)->lpVtbl->CreateInstance(This, pUnkOuter, riid, ppvObject)
#define IPrivateHeapMemoryAllocatorClassFactory_LockServer(This, fLock) (This)->lpVtbl->LockServer(This, fLock)
#define IPrivateHeapMemoryAllocatorClassFactory_SetHeapInitialSize(This, dwInitialSize) (This)->lpVtbl->SetHeapInitialSize(This, dwInitialSize)
#define IPrivateHeapMemoryAllocatorClassFactory_SetHeapMaximumSize(This, dwMaximumSize) (This)->lpVtbl->SetHeapMaximumSize(This, dwMaximumSize)
#define IPrivateHeapMemoryAllocatorClassFactory_SetHeapFlags(This, dwFlags) (This)->lpVtbl->SetHeapFlags(This, dwFlags)

#endif
