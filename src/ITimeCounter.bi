#ifndef ITIMECOUNTER_BI
#define ITIMECOUNTER_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Extern IID_ITimeCounter Alias "IID_ITimeCounter" As Const IID

Type ITimeCounter As ITimeCounter_

Type ITimeCounterVirtualTable
	
	QueryInterface As Function( _
		ByVal this As ITimeCounter Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As ITimeCounter Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As ITimeCounter Ptr _
	)As ULONG
	
	StartWatch As Function( _
		ByVal this As ITimeCounter Ptr _
	)As ULONG
	
	StopWatch As Function( _
		ByVal this As ITimeCounter Ptr _
	)As ULONG
	
End Type

Type ITimeCounter_
	lpVtbl As ITimeCounterVirtualTable Ptr
End Type

#define ITimeCounter_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define ITimeCounter_AddRef(this) (this)->lpVtbl->AddRef(this)
#define ITimeCounter_Release(this) (this)->lpVtbl->Release(this)
#define ITimeCounter_StartWatch(this) (this)->lpVtbl->StartWatch(this)
#define ITimeCounter_StopWatch(this) (this)->lpVtbl->StopWatch(this)

#endif
