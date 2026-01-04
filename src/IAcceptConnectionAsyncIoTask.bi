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
		ByVal self As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IAcceptConnectionAsyncIoTask Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IAcceptConnectionAsyncIoTask Ptr _
	)As ULONG

	BeginExecute As Function( _
		ByVal self As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal state As Any Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	EndExecute As Function( _
		ByVal self As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr _
	)As HRESULT

	GetListenSocket As Function( _
		ByVal self As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pListenSocket As SOCKET Ptr _
	)As HRESULT

	SetListenSocket As Function( _
		ByVal self As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal ListenSocket As SOCKET _
	)As HRESULT

	GetClientSocket As Function( _
		ByVal self As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pClientSocket As SOCKET Ptr _
	)As HRESULT

End Type

Type IAcceptConnectionAsyncIoTask_
	lpVtbl As IAcceptConnectionAsyncIoTaskVirtualTable Ptr
End Type

#define IAcceptConnectionAsyncIoTask_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define IAcceptConnectionAsyncIoTask_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IAcceptConnectionAsyncIoTask_Release(self) (self)->lpVtbl->Release(self)
#define IAcceptConnectionAsyncIoTask_BeginExecute(self, pcb, state, ppIResult) (self)->lpVtbl->BeginExecute(self, pcb, state, ppIResult)
#define IAcceptConnectionAsyncIoTask_EndExecute(self, pIResult) (self)->lpVtbl->EndExecute(self, pIResult)
#define IAcceptConnectionAsyncIoTask_GetListenSocket(self, pListenSocket) (self)->lpVtbl->GetListenSocket(self, pListenSocket)
#define IAcceptConnectionAsyncIoTask_SetListenSocket(self, ListenSocket) (self)->lpVtbl->SetListenSocket(self, ListenSocket)
#define IAcceptConnectionAsyncIoTask_GetClientSocket(self, pClientSocket) (self)->lpVtbl->GetClientSocket(self, pClientSocket)

#endif
