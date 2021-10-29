#ifndef IRUNNABLE_BI
#define IRUNNABLE_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Const RUNNABLE_S_STOPPED As HRESULT = MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0201)
Const RUNNABLE_S_START_PENDING As HRESULT = MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0202)
Const RUNNABLE_S_RUNNING As HRESULT = MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0204)
Const RUNNABLE_S_STOP_PENDING As HRESULT = MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0203)

Type RunnableStatusHandler As Function(ByVal Context As Any Ptr, ByVal Status As HRESULT)As HRESULT

Type IRunnable As IRunnable_

Type LPIRUNNABLE As IRunnable Ptr

Extern IID_IRunnable Alias "IID_IRunnable" As Const IID

Type IRunnableVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IRunnable Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IRunnable Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IRunnable Ptr _
	)As ULONG
	
	Run As Function( _
		ByVal this As IRunnable Ptr _
	)As HRESULT
	
	Stop As Function( _
		ByVal this As IRunnable Ptr _
	)As HRESULT
	
	IsRunning As Function( _
		ByVal this As IRunnable Ptr _
	)As HRESULT
	
	RegisterStatusHandler As Function( _
		ByVal this As IRunnable Ptr, _
		ByVal Context As Any Ptr, _
		ByVal StatusHandler As RunnableStatusHandler _
	)As HRESULT
	
End Type

Type IRunnable_
	lpVtbl As IRunnableVirtualTable Ptr
End Type

#define IRunnable_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IRunnable_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IRunnable_Release(this) (this)->lpVtbl->Release(this)
#define IRunnable_Run(this) (this)->lpVtbl->Run(this)
#define IRunnable_Stop(this) (this)->lpVtbl->Stop(this)
#define IRunnable_IsRunning(this) (this)->lpVtbl->IsRunning(this)
#define IRunnable_RegisterStatusHandler(this, Context, StatusHandler) (this)->lpVtbl->RegisterStatusHandler(this, Context, StatusHandler)

#endif
