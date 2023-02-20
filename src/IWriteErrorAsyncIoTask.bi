#ifndef IWRITEERRORASYNCIOTASK_BI
#define IWRITEERRORASYNCIOTASK_BI

#include once "IClientRequest.bi"
#include once "IHttpAsyncIoTask.bi"

Extern IID_IWriteErrorAsyncIoTask Alias "IID_IWriteErrorAsyncIoTask" As Const IID

' BeginExecute:
' ASYNCTASK_S_IO_PENDING
' Any E_FAIL

' EndExecute:
' S_OK
' S_FALSE
' Any E_FAIL

Type IWriteErrorAsyncIoTask As IWriteErrorAsyncIoTask_

Type IWriteErrorAsyncIoTaskVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr _
	)As ULONG
	
	BeginExecute As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndExecute As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
	)As HRESULT
	
	GetBaseStream As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	
	SetBaseStream As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		byVal pStream As IBaseStream Ptr _
	)As HRESULT
	
	GetHttpReader As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	SetHttpReader As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	
	GetClientRequest As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	
	SetClientRequest As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT
	
	SetErrorCode As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal HttpError As ResponseErrorCode, _
		ByVal hrCode As HRESULT _
	)As HRESULT
	
	Prepare As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr _
	)As HRESULT
	
End Type

Type IWriteErrorAsyncIoTask_
	lpVtbl As IWriteErrorAsyncIoTaskVirtualTable Ptr
End Type

#define IWriteErrorAsyncIoTask_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IWriteErrorAsyncIoTask_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IWriteErrorAsyncIoTask_Release(this) (this)->lpVtbl->Release(this)
#define IWriteErrorAsyncIoTask_BeginExecute(this, ppIResult) (this)->lpVtbl->BeginExecute(this, ppIResult)
#define IWriteErrorAsyncIoTask_EndExecute(this, pIResult, BytesTransferred, ppNextTask) (this)->lpVtbl->EndExecute(this, pIResult, BytesTransferred, ppNextTask)
#define IWriteErrorAsyncIoTask_GetBaseStream(this, ppStream) (this)->lpVtbl->GetBaseStream(this, ppStream)
#define IWriteErrorAsyncIoTask_SetBaseStream(this, pStream) (this)->lpVtbl->SetBaseStream(this, pStream)
#define IWriteErrorAsyncIoTask_GetHttpReader(this, ppIHttpReader) (this)->lpVtbl->GetHttpReader(this, ppIHttpReader)
#define IWriteErrorAsyncIoTask_SetHttpReader(this, pIHttpReader) (this)->lpVtbl->SetHttpReader(this, pIHttpReader)
#define IWriteErrorAsyncIoTask_GetClientRequest(this, ppIRequest) (this)->lpVtbl->GetClientRequest(this, ppIRequest)
#define IWriteErrorAsyncIoTask_SetClientRequest(this, pIRequest) (this)->lpVtbl->SetClientRequest(this, pIRequest)
#define IWriteErrorAsyncIoTask_SetErrorCode(this, HttpError, hrCode) (this)->lpVtbl->SetErrorCode(this, HttpError, hrCode)
#define IWriteErrorAsyncIoTask_Prepare(this) (this)->lpVtbl->Prepare(this)

#endif
