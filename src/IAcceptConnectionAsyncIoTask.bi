#ifndef IACCEPTCONNECTIONASYNCIOTASK_BI
#define IACCEPTCONNECTIONASYNCIOTASK_BI

#include once "windows.bi"
#include once "win\winsock2.bi"
#include once "IAsyncIoTask.bi"

Extern IID_IAcceptConnectionAsyncIoTask Alias "IID_IAcceptConnectionAsyncIoTask" As Const IID

' BeginExecute:
' S_OK
' Any E_FAIL

' EndExecute:
' S_OK
' Any E_FAIL

Type IAcceptConnectionAsyncIoTask As IAcceptConnectionAsyncIoTask_

Type IAcceptConnectionAsyncIoTaskVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr _
	)As ULONG
	
	BeginExecute As Function( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal state As Any Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndExecute As Function( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr _
	)As HRESULT
	
	GetListenSocket As Function( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pListenSocket As SOCKET Ptr _
	)As HRESULT
	
	SetListenSocket As Function( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal ListenSocket As SOCKET _
	)As HRESULT
	
	GetClientSocket As Function( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pClientSocket As SOCKET Ptr _
	)As HRESULT
	
End Type

Type IAcceptConnectionAsyncIoTask_
	lpVtbl As IAcceptConnectionAsyncIoTaskVirtualTable Ptr
End Type

#define IAcceptConnectionAsyncIoTask_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IAcceptConnectionAsyncIoTask_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IAcceptConnectionAsyncIoTask_Release(this) (this)->lpVtbl->Release(this)
#define IAcceptConnectionAsyncIoTask_BeginExecute(this, pcb, state, ppIResult) (this)->lpVtbl->BeginExecute(this, pcb, state, ppIResult)
#define IAcceptConnectionAsyncIoTask_EndExecute(this, pIResult) (this)->lpVtbl->EndExecute(this, pIResult)
#define IAcceptConnectionAsyncIoTask_GetListenSocket(this, pListenSocket) (this)->lpVtbl->GetListenSocket(this, pListenSocket)
#define IAcceptConnectionAsyncIoTask_SetListenSocket(this, ListenSocket) (this)->lpVtbl->SetListenSocket(this, ListenSocket)
#define IAcceptConnectionAsyncIoTask_GetClientSocket(this, pClientSocket) (this)->lpVtbl->GetClientSocket(this, pClientSocket)

#endif
