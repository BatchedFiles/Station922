#ifndef IWRITERESPONSEASYNCIOTASK_BI
#define IWRITERESPONSEASYNCIOTASK_BI

#include once "IClientRequest.bi"
#include once "IHttpAsyncIoTask.bi"

' BeginExecute:
' ASYNCTASK_S_IO_PENDING
' Any E_FAIL

' EndExecute:
' S_OK
' S_FALSE
' Any E_FAIL

Type IWriteResponseAsyncIoTask As IWriteResponseAsyncIoTask_

Type LPIWRITERESPONSEASYNCIOTASK As IWriteResponseAsyncIoTask Ptr

Extern IID_IWriteResponseAsyncIoTask Alias "IID_IWriteResponseAsyncIoTask" As Const IID

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
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndExecute As Function( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
	)As HRESULT
	
	GetFileHandle As Function( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal pFileHandle As HANDLE Ptr _
	)As HRESULT
	
	GetWebSiteCollectionWeakPtr As Function( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	
	SetWebSiteCollectionWeakPtr As Function( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	
	GetHttpProcessorCollectionWeakPtr As Function( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	
	SetHttpProcessorCollectionWeakPtr As Function( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal pIProcessors As IHttpProcessorCollection Ptr _
	)As HRESULT
	
	GetBaseStream As Function( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	
	SetBaseStream As Function( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		byVal pStream As IBaseStream Ptr _
	)As HRESULT
	
	GetHttpReader As Function( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	SetHttpReader As Function( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		byVal pReader As IHttpReader Ptr _
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
		ByVal this As IWriteResponseAsyncIoTask Ptr _
	)As HRESULT
	
End Type

Type IWriteResponseAsyncIoTask_
	lpVtbl As IWriteResponseAsyncIoTaskVirtualTable Ptr
End Type

#define IWriteResponseAsyncIoTask_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IWriteResponseAsyncIoTask_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IWriteResponseAsyncIoTask_Release(this) (this)->lpVtbl->Release(this)
#define IWriteResponseAsyncIoTask_BeginExecute(this, ppIResult) (this)->lpVtbl->BeginExecute(this, ppIResult)
#define IWriteResponseAsyncIoTask_EndExecute(this, pIResult, BytesTransferred, ppNextTask) (this)->lpVtbl->EndExecute(this, pIResult, BytesTransferred, ppNextTask)
#define IWriteResponseAsyncIoTask_GetFileHandle(this, pFileHandle) (this)->lpVtbl->GetFileHandle(this, pFileHandle)
#define IWriteResponseAsyncIoTask_GetWebSiteCollectionWeakPtr(this, ppIWebSites) (this)->lpVtbl->GetWebSiteCollectionWeakPtr(this, ppIWebSites)
#define IWriteResponseAsyncIoTask_SetWebSiteCollectionWeakPtr(this, pIWebSites) (this)->lpVtbl->SetWebSiteCollectionWeakPtr(this, pIWebSites)
#define IWriteResponseAsyncIoTask_GetHttpProcessorCollectionWeakPtr(this, ppIProcessors) (this)->lpVtbl->GetHttpProcessorCollectionWeakPtr(this, ppIProcessors)
#define IWriteResponseAsyncIoTask_SetHttpProcessorCollectionWeakPtr(this, pIProcessors) (this)->lpVtbl->SetHttpProcessorCollectionWeakPtr(this, pIProcessors)
#define IWriteResponseAsyncIoTask_GetBaseStream(this, ppStream) (this)->lpVtbl->GetBaseStream(this, ppStream)
#define IWriteResponseAsyncIoTask_SetBaseStream(this, pStream) (this)->lpVtbl->SetBaseStream(this, pStream)
#define IWriteResponseAsyncIoTask_GetHttpReader(this, ppReader) (this)->lpVtbl->GetHttpReader(this, ppReader)
#define IWriteResponseAsyncIoTask_SetHttpReader(this, pReader) (this)->lpVtbl->SetHttpReader(this, pReader)
#define IWriteResponseAsyncIoTask_GetClientRequest(this, ppIRequest) (this)->lpVtbl->GetClientRequest(this, ppIRequest)
#define IWriteResponseAsyncIoTask_SetClientRequest(this, pIRequest) (this)->lpVtbl->SetClientRequest(this, pIRequest)
#define IWriteResponseAsyncIoTask_Prepare(this) (this)->lpVtbl->Prepare(this)

#endif
