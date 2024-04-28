#ifndef IREADREQUESTASYNCIOTASK_BI
#define IREADREQUESTASYNCIOTASK_BI

#include once "IAsyncIoTask.bi"
#include once "IBaseAsyncStream.bi"
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
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal this As IReadRequestAsyncIoTask Ptr _
	)As ULONG

	Release As Function( _
		ByVal this As IReadRequestAsyncIoTask Ptr _
	)As ULONG

	BeginExecute As Function( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal state As Any Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	EndExecute As Function( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr _
	)As HRESULT

	GetBaseStream As Function( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal ppStream As IBaseAsyncStream Ptr Ptr _
	)As HRESULT

	SetBaseStream As Function( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		byVal pStream As IBaseAsyncStream Ptr _
	)As HRESULT

	GetHttpReader As Function( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal ppReader As IHttpAsyncReader Ptr Ptr _
	)As HRESULT

	SetHttpReader As Function( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		byVal pReader As IHttpAsyncReader Ptr _
	)As HRESULT

	Parse As Function( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal ppRequest As IClientRequest Ptr Ptr _
	)As HRESULT

End Type

Type IReadRequestAsyncIoTask_
	lpVtbl As IReadRequestAsyncIoTaskVirtualTable Ptr
End Type

#define IReadRequestAsyncIoTask_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IReadRequestAsyncIoTask_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IReadRequestAsyncIoTask_Release(this) (this)->lpVtbl->Release(this)
#define IReadRequestAsyncIoTask_BeginExecute(this, pcb, state, ppIResult) (this)->lpVtbl->BeginExecute(this, pcb, state, ppIResult)
#define IReadRequestAsyncIoTask_EndExecute(this, pIResult) (this)->lpVtbl->EndExecute(this, pIResult)
#define IReadRequestAsyncIoTask_GetBaseStream(this, ppStream) (this)->lpVtbl->GetBaseStream(this, ppStream)
#define IReadRequestAsyncIoTask_SetBaseStream(this, pStream) (this)->lpVtbl->SetBaseStream(this, pStream)
#define IReadRequestAsyncIoTask_GetHttpReader(this, ppReader) (this)->lpVtbl->GetHttpReader(this, ppReader)
#define IReadRequestAsyncIoTask_SetHttpReader(this, pReader) (this)->lpVtbl->SetHttpReader(this, pReader)
#define IReadRequestAsyncIoTask_Parse(this, ppRequest) (this)->lpVtbl->Parse(this, ppRequest)

#endif
