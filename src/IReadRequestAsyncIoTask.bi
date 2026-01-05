#ifndef IREADREQUESTASYNCIOTASK_BI
#define IREADREQUESTASYNCIOTASK_BI

#include once "IAsyncIoTask.bi"
#include once "IClientRequest.bi"
#include once "IHttpAsyncReader.bi"

Extern IID_IReadRequestAsyncIoTask Alias "IID_IReadRequestAsyncIoTask" As Const IID

' BeginExecute:
' ASYNCTASK_S_IO_PENDING
' Any E_FAIL

' EndExecute:
' S_OK
' S_FALSE
' READREQUESTASYNCIOTASK_S_IO_PENDING
' Any E_FAIL

Const READREQUESTASYNCIOTASK_S_IO_PENDING As HRESULT = MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0201)

Type IReadRequestAsyncIoTask As IReadRequestAsyncIoTask_

Type IReadRequestAsyncIoTaskVirtualTable

	QueryInterface As Function( _
		ByVal self As IReadRequestAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IReadRequestAsyncIoTask Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IReadRequestAsyncIoTask Ptr _
	)As ULONG

	BeginExecute As Function( _
		ByVal self As IReadRequestAsyncIoTask Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal state As Any Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	EndExecute As Function( _
		ByVal self As IReadRequestAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr _
	)As HRESULT

	GetHttpReader As Function( _
		ByVal self As IReadRequestAsyncIoTask Ptr, _
		ByVal ppReader As IHttpAsyncReader Ptr Ptr _
	)As HRESULT

	SetHttpReader As Function( _
		ByVal self As IReadRequestAsyncIoTask Ptr, _
		byVal pReader As IHttpAsyncReader Ptr _
	)As HRESULT

	Parse As Function( _
		ByVal self As IReadRequestAsyncIoTask Ptr, _
		ByVal ppRequest As IClientRequest Ptr Ptr _
	)As HRESULT

End Type

Type IReadRequestAsyncIoTask_
	lpVtbl As IReadRequestAsyncIoTaskVirtualTable Ptr
End Type

#define IReadRequestAsyncIoTask_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define IReadRequestAsyncIoTask_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IReadRequestAsyncIoTask_Release(self) (self)->lpVtbl->Release(self)
#define IReadRequestAsyncIoTask_BeginExecute(self, pcb, state, ppIResult) (self)->lpVtbl->BeginExecute(self, pcb, state, ppIResult)
#define IReadRequestAsyncIoTask_EndExecute(self, pIResult) (self)->lpVtbl->EndExecute(self, pIResult)
#define IReadRequestAsyncIoTask_GetHttpReader(self, ppReader) (self)->lpVtbl->GetHttpReader(self, ppReader)
#define IReadRequestAsyncIoTask_SetHttpReader(self, pReader) (self)->lpVtbl->SetHttpReader(self, pReader)
#define IReadRequestAsyncIoTask_Parse(self, ppRequest) (self)->lpVtbl->Parse(self, ppRequest)

#endif
