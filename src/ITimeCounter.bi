#ifndef ITIMECOUNTER_BI
#define ITIMECOUNTER_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Extern IID_ITimeCounter Alias "IID_ITimeCounter" As Const IID

Type ITimeCounter As ITimeCounter_

Type ITimeCounterVirtualTable

	QueryInterface As Function( _
		ByVal self As ITimeCounter Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As ITimeCounter Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As ITimeCounter Ptr _
	)As ULONG

	StartWatch As Function( _
		ByVal self As ITimeCounter Ptr _
	)As HRESULT

	StopWatch As Function( _
		ByVal self As ITimeCounter Ptr _
	)As HRESULT

End Type

Type ITimeCounter_
	lpVtbl As ITimeCounterVirtualTable Ptr
End Type

#define ITimeCounter_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define ITimeCounter_AddRef(self) (self)->lpVtbl->AddRef(self)
#define ITimeCounter_Release(self) (self)->lpVtbl->Release(self)
#define ITimeCounter_StartWatch(self) (self)->lpVtbl->StartWatch(self)
#define ITimeCounter_StopWatch(self) (self)->lpVtbl->StopWatch(self)

#endif
