#ifndef IREADREQUESTASYNCIOTASK_BI
#define IREADREQUESTASYNCIOTASK_BI

#include once "IHttpAsyncIoTask.bi"

' BeginExecute:
' ASYNCTASK_S_IO_PENDING
' Any E_FAIL

' EndExecute:
' S_OK
' S_FALSE
' Any E_FAIL

Type IReadRequestAsyncIoTask As IReadRequestAsyncIoTask_

Type LPIREADREQUESTASYNCIOTASK As IReadRequestAsyncIoTask Ptr

Extern IID_IReadRequestAsyncIoTask Alias "IID_IReadRequestAsyncIoTask" As Const IID

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
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndExecute As Function( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
	)As HRESULT
	
	GetFileHandle As Function( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal pFileHandle As HANDLE Ptr _
	)As HRESULT
	
	GetWebSiteCollectionWeakPtr As Function( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	
	SetWebSiteCollectionWeakPtr As Function( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	
	GetHttpProcessorCollectionWeakPtr As Function( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	
	SetHttpProcessorCollectionWeakPtr As Function( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal pIProcessors As IHttpProcessorCollection Ptr _
	)As HRESULT
	
	GetBaseStream As Function( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	
	SetBaseStream As Function( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		byVal pStream As IBaseStream Ptr _
	)As HRESULT
	
	GetHttpReader As Function( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	SetHttpReader As Function( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	
End Type

Type IReadRequestAsyncIoTask_
	lpVtbl As IReadRequestAsyncIoTaskVirtualTable Ptr
End Type

#define IReadRequestAsyncIoTask_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IReadRequestAsyncIoTask_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IReadRequestAsyncIoTask_Release(this) (this)->lpVtbl->Release(this)
#define IReadRequestAsyncIoTask_BeginExecute(this, ppIResult) (this)->lpVtbl->BeginExecute(this, ppIResult)
#define IReadRequestAsyncIoTask_EndExecute(this, pIResult, BytesTransferred, ppNextTask) (this)->lpVtbl->EndExecute(this, pIResult, BytesTransferred, ppNextTask)
#define IReadRequestAsyncIoTask_GetFileHandle(this, pFileHandle) (this)->lpVtbl->GetFileHandle(this, pFileHandle)
#define IReadRequestAsyncIoTask_GetWebSiteCollectionWeakPtr(this, ppIWebSites) (this)->lpVtbl->GetWebSiteCollectionWeakPtr(this, ppIWebSites)
#define IReadRequestAsyncIoTask_SetWebSiteCollectionWeakPtr(this, pIWebSites) (this)->lpVtbl->SetWebSiteCollectionWeakPtr(this, pIWebSites)
#define IReadRequestAsyncIoTask_GetHttpProcessorCollectionWeakPtr(this, ppIProcessors) (this)->lpVtbl->GetHttpProcessorCollectionWeakPtr(this, ppIProcessors)
#define IReadRequestAsyncIoTask_SetHttpProcessorCollectionWeakPtr(this, pIProcessors) (this)->lpVtbl->SetHttpProcessorCollectionWeakPtr(this, pIProcessors)
#define IReadRequestAsyncIoTask_GetBaseStream(this, ppStream) (this)->lpVtbl->GetBaseStream(this, ppStream)
#define IReadRequestAsyncIoTask_SetBaseStream(this, pStream) (this)->lpVtbl->SetBaseStream(this, pStream)
#define IReadRequestAsyncIoTask_GetHttpReader(this, ppReader) (this)->lpVtbl->GetHttpReader(this, ppReader)
#define IReadRequestAsyncIoTask_SetHttpReader(this, pReader) (this)->lpVtbl->SetHttpReader(this, pReader)

#endif
