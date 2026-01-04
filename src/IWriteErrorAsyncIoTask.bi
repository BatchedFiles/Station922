#ifndef IWRITEERRORASYNCIOTASK_BI
#define IWRITEERRORASYNCIOTASK_BI

#include once "IAsyncIoTask.bi"
#include once "IBaseAsyncStream.bi"
#include once "IClientRequest.bi"
#include once "IWebSiteCollection.bi"

Extern IID_IWriteErrorAsyncIoTask Alias "IID_IWriteErrorAsyncIoTask" As Const IID

' BeginExecute:
' ASYNCTASK_S_IO_PENDING
' Any E_FAIL

' EndExecute:
' S_OK
' WRITEERRORASYNCIOTASK_S_IO_PENDING
' Any E_FAIL
Const WRITEERRORASYNCIOTASK_S_IO_PENDING As HRESULT = MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0201)

Type IWriteErrorAsyncIoTask As IWriteErrorAsyncIoTask_

Type IWriteErrorAsyncIoTaskVirtualTable

	QueryInterface As Function( _
		ByVal self As IWriteErrorAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IWriteErrorAsyncIoTask Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IWriteErrorAsyncIoTask Ptr _
	)As ULONG

	BeginExecute As Function( _
		ByVal self As IWriteErrorAsyncIoTask Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal state As Any Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	EndExecute As Function( _
		ByVal self As IWriteErrorAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr _
	)As HRESULT

	GetBaseStream As Function( _
		ByVal self As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppStream As IBaseAsyncStream Ptr Ptr _
	)As HRESULT

	SetBaseStream As Function( _
		ByVal self As IWriteErrorAsyncIoTask Ptr, _
		byVal pStream As IBaseAsyncStream Ptr _
	)As HRESULT

	SetWebSiteCollectionWeakPtr As Function( _
		ByVal self As IWriteErrorAsyncIoTask Ptr, _
		byVal pCollection As IWebSiteCollection Ptr _
	)As HRESULT

	GetClientRequest As Function( _
		ByVal self As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT

	SetClientRequest As Function( _
		ByVal self As IWriteErrorAsyncIoTask Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT

	SetErrorCode As Function( _
		ByVal self As IWriteErrorAsyncIoTask Ptr, _
		ByVal HttpError As ResponseErrorCode, _
		ByVal hrCode As HRESULT _
	)As HRESULT

	Prepare As Function( _
		ByVal self As IWriteErrorAsyncIoTask Ptr _
	)As HRESULT

End Type

Type IWriteErrorAsyncIoTask_
	lpVtbl As IWriteErrorAsyncIoTaskVirtualTable Ptr
End Type

#define IWriteErrorAsyncIoTask_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define IWriteErrorAsyncIoTask_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IWriteErrorAsyncIoTask_Release(self) (self)->lpVtbl->Release(self)
#define IWriteErrorAsyncIoTask_BeginExecute(self, pcb, state, ppIResult) (self)->lpVtbl->BeginExecute(self, pcb, state, ppIResult)
#define IWriteErrorAsyncIoTask_EndExecute(self, pIResult) (self)->lpVtbl->EndExecute(self, pIResult)
#define IWriteErrorAsyncIoTask_GetBaseStream(self, ppStream) (self)->lpVtbl->GetBaseStream(self, ppStream)
#define IWriteErrorAsyncIoTask_SetBaseStream(self, pStream) (self)->lpVtbl->SetBaseStream(self, pStream)
#define IWriteErrorAsyncIoTask_SetWebSiteCollectionWeakPtr(self, pCollection) (self)->lpVtbl->SetWebSiteCollectionWeakPtr(self, pCollection)
#define IWriteErrorAsyncIoTask_GetClientRequest(self, ppIRequest) (self)->lpVtbl->GetClientRequest(self, ppIRequest)
#define IWriteErrorAsyncIoTask_SetClientRequest(self, pIRequest) (self)->lpVtbl->SetClientRequest(self, pIRequest)
#define IWriteErrorAsyncIoTask_SetErrorCode(self, HttpError, hrCode) (self)->lpVtbl->SetErrorCode(self, HttpError, hrCode)
#define IWriteErrorAsyncIoTask_Prepare(self) (self)->lpVtbl->Prepare(self)

#endif
