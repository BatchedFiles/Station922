#ifndef IWRITERESPONSEASYNCIOTASK_BI
#define IWRITERESPONSEASYNCIOTASK_BI

#include once "IAsyncIoTask.bi"
#include once "IClientRequest.bi"
#include once "IWebSiteCollection.bi"

Extern IID_IWriteResponseAsyncIoTask Alias "IID_IWriteResponseAsyncIoTask" As Const IID

' BeginExecute:
' ASYNCTASK_S_IO_PENDING
' Any E_FAIL

' EndExecute:
' S_OK
' S_FALSE
' WRITERESPONSEASYNCIOTASK_S_IO_PENDING
' WRITERESPONSEASYNCIOTASK_S_KEEPALIVE_FALSE
' Any E_FAIL
Const WRITERESPONSEASYNCIOTASK_S_IO_PENDING As HRESULT = MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0201)

Type IWriteResponseAsyncIoTask As IWriteResponseAsyncIoTask_

Type IWriteResponseAsyncIoTaskVirtualTable

	QueryInterface As Function( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal this As IWriteResponseAsyncIoTask Ptr _
	)As ULONG

	Release As Function( _
		ByVal this As IWriteResponseAsyncIoTask Ptr _
	)As ULONG

	BeginExecute As Function( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal state As Any Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	EndExecute As Function( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr _
	)As HRESULT

	GetBaseStream As Function( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal ppStream As IBaseAsyncStream Ptr Ptr _
	)As HRESULT

	SetBaseStream As Function( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		byVal pStream As IBaseAsyncStream Ptr _
	)As HRESULT

	GetHttpReader As Function( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal ppReader As IHttpAsyncReader Ptr Ptr _
	)As HRESULT

	SetHttpReader As Function( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		byVal pReader As IHttpAsyncReader Ptr _
	)As HRESULT

	GetClientRequest As Function( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT

	SetClientRequest As Function( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT

	Prepare As Function( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT

End Type

Type IWriteResponseAsyncIoTask_
	lpVtbl As IWriteResponseAsyncIoTaskVirtualTable Ptr
End Type

#define IWriteResponseAsyncIoTask_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IWriteResponseAsyncIoTask_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IWriteResponseAsyncIoTask_Release(this) (this)->lpVtbl->Release(this)
#define IWriteResponseAsyncIoTask_BeginExecute(this, pcb, state, ppIResult) (this)->lpVtbl->BeginExecute(this, pcb, state, ppIResult)
#define IWriteResponseAsyncIoTask_EndExecute(this, pIResult) (this)->lpVtbl->EndExecute(this, pIResult)
#define IWriteResponseAsyncIoTask_GetBaseStream(this, ppStream) (this)->lpVtbl->GetBaseStream(this, ppStream)
#define IWriteResponseAsyncIoTask_SetBaseStream(this, pStream) (this)->lpVtbl->SetBaseStream(this, pStream)
#define IWriteResponseAsyncIoTask_GetHttpReader(this, ppReader) (this)->lpVtbl->GetHttpReader(this, ppReader)
#define IWriteResponseAsyncIoTask_SetHttpReader(this, pReader) (this)->lpVtbl->SetHttpReader(this, pReader)
#define IWriteResponseAsyncIoTask_GetClientRequest(this, ppIRequest) (this)->lpVtbl->GetClientRequest(this, ppIRequest)
#define IWriteResponseAsyncIoTask_SetClientRequest(this, pIRequest) (this)->lpVtbl->SetClientRequest(this, pIRequest)
#define IWriteResponseAsyncIoTask_Prepare(this, pIWebSites) (this)->lpVtbl->Prepare(this, pIWebSites)

#endif
