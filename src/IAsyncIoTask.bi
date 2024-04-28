#ifndef IASYNCIOTASK_BI
#define IASYNCIOTASK_BI

#include once "IAsyncResult.bi"

Extern IID_IAsyncIoTask Alias "IID_IAsyncIoTask" As Const IID

' BeginExecute:
' S_OK
' Any E_FAIL

' EndExecute:
' S_OK, S_FALSE, ASYNCTASK_S_IO_PENDING, ASYNCTASK_S_KEEPALIVE_FALSE
' Any E_FAIL

Const ASYNCTASK_S_IO_PENDING As HRESULT = MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0201)
Const ASYNCTASK_S_KEEPALIVE_FALSE As HRESULT = MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0202)

Type IAsyncIoTask As IAsyncIoTask_

Type IAsyncIoTaskVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IAsyncIoTask Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IAsyncIoTask Ptr _
	)As ULONG
	
	BeginExecute As Function( _
		ByVal this As IAsyncIoTask Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal state As Any Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndExecute As Function( _
		ByVal this As IAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr _
	)As HRESULT
	
End Type

Type IAsyncIoTask_
	lpVtbl As IAsyncIoTaskVirtualTable Ptr
End Type

#define IAsyncIoTask_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IAsyncIoTask_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IAsyncIoTask_Release(this) (this)->lpVtbl->Release(this)
#define IAsyncIoTask_BeginExecute(this, pcb, state, ppIResult) (this)->lpVtbl->BeginExecute(this, pcb, state, ppIResult)
#define IAsyncIoTask_EndExecute(this, pIResult) (this)->lpVtbl->EndExecute(this, pIResult)

#endif
