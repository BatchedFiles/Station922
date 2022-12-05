#ifndef IACCEPTCONNECTIONASYNCIOTASK_BI
#define IACCEPTCONNECTIONASYNCIOTASK_BI

#include once "windows.bi"
#include once "win\winsock2.bi"
#include once "IHttpAsyncIoTask.bi"

' BeginExecute:
' ASYNCTASK_S_IO_PENDING
' Any E_FAIL

' EndExecute:
' S_OK
' Any E_FAIL

Type IAcceptConnectionAsyncIoTask As IAcceptConnectionAsyncIoTask_

Type LPIACCEPTCONNECTIONASYNCIOTASK As IAcceptConnectionAsyncIoTask Ptr

Extern IID_IAcceptConnectionAsyncIoTask Alias "IID_IAcceptConnectionAsyncIoTask" As Const IID

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
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndExecute As Function( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
	)As HRESULT
	
	GetBaseStream As Function( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	
	SetBaseStream As Function( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		byVal pStream As IBaseStream Ptr _
	)As HRESULT
	
	GetHttpReader As Function( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	SetHttpReader As Function( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	
	GetListenSocket As Function( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pListenSocket As SOCKET Ptr _
	)As HRESULT
	
	SetListenSocket As Function( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal ListenSocket As SOCKET _
	)As HRESULT
	
End Type

Type IAcceptConnectionAsyncIoTask_
	lpVtbl As IAcceptConnectionAsyncIoTaskVirtualTable Ptr
End Type

#define IAcceptConnectionAsyncIoTask_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IAcceptConnectionAsyncIoTask_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IAcceptConnectionAsyncIoTask_Release(this) (this)->lpVtbl->Release(this)
#define IAcceptConnectionAsyncIoTask_BeginExecute(this, ppIResult) (this)->lpVtbl->BeginExecute(this, ppIResult)
#define IAcceptConnectionAsyncIoTask_EndExecute(this, pIResult, BytesTransferred, ppNextTask) (this)->lpVtbl->EndExecute(this, pIResult, BytesTransferred, ppNextTask)
#define IAcceptConnectionAsyncIoTask_GetBaseStream(this, ppStream) (this)->lpVtbl->GetBaseStream(this, ppStream)
#define IAcceptConnectionAsyncIoTask_SetBaseStream(this, pStream) (this)->lpVtbl->SetBaseStream(this, pStream)
#define IAcceptConnectionAsyncIoTask_GetHttpReader(this, ppReader) (this)->lpVtbl->GetHttpReader(this, ppReader)
#define IAcceptConnectionAsyncIoTask_SetHttpReader(this, pReader) (this)->lpVtbl->SetHttpReader(this, pReader)
#define IAcceptConnectionAsyncIoTask_GetListenSocket(this, pListenSocket) (this)->lpVtbl->GetListenSocket(this, pListenSocket)
#define IAcceptConnectionAsyncIoTask_SetListenSocket(this, ListenSocket) (this)->lpVtbl->SetListenSocket(this, ListenSocket)

#endif
