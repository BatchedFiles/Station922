#ifndef IHTTPASYNCIOTASK_BI
#define IHTTPASYNCIOTASK_BI

#include once "IAsyncIoTask.bi"
#include once "IBaseStream.bi"
#include once "IHttpProcessorCollection.bi"
#include once "IHttpReader.bi"
#include once "IWebSiteCollection.bi"

' BeginExecute:
' ASYNCTASK_S_IO_PENDING
' Any E_FAIL

' EndExecute:
' S_OK
' S_FALSE
' S_KEEPALIVE_FALSE
' Any E_FAIL

Const ASYNCTASK_S_KEEPALIVE_FALSE As HRESULT = MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0202)

Type IHttpAsyncIoTask As IHttpAsyncIoTask_

Type LPIHTTPASYNCIOTASK As IHttpAsyncIoTask Ptr

Extern IID_IHttpAsyncIoTask Alias "IID_IHttpAsyncIoTask" As Const IID

Type IHttpAsyncIoTaskVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IHttpAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IHttpAsyncIoTask Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IHttpAsyncIoTask Ptr _
	)As ULONG
	
	BindToThreadPool As Function( _
		ByVal this As IHttpAsyncIoTask Ptr, _
		ByVal pPool As IThreadPool Ptr _
	)As HRESULT
	
	BeginExecute As Function( _
		ByVal this As IHttpAsyncIoTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndExecute As Function( _
		ByVal this As IHttpAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
	)As HRESULT
	
	GetWebSiteCollectionWeakPtr As Function( _
		ByVal this As IHttpAsyncIoTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	
	SetWebSiteCollectionWeakPtr As Function( _
		ByVal this As IHttpAsyncIoTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	
	GetHttpProcessorCollectionWeakPtr As Function( _
		ByVal this As IHttpAsyncIoTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	
	SetHttpProcessorCollectionWeakPtr As Function( _
		ByVal this As IHttpAsyncIoTask Ptr, _
		ByVal pIProcessors As IHttpProcessorCollection Ptr _
	)As HRESULT
	
	GetBaseStream As Function( _
		ByVal this As IHttpAsyncIoTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	
	SetBaseStream As Function( _
		ByVal this As IHttpAsyncIoTask Ptr, _
		byVal pStream As IBaseStream Ptr _
	)As HRESULT
	
	GetHttpReader As Function( _
		ByVal this As IHttpAsyncIoTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	SetHttpReader As Function( _
		ByVal this As IHttpAsyncIoTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	
End Type

Type IHttpAsyncIoTask_
	lpVtbl As IHttpAsyncIoTaskVirtualTable Ptr
End Type

#define IHttpAsyncIoTask_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IHttpAsyncIoTask_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IHttpAsyncIoTask_Release(this) (this)->lpVtbl->Release(this)
#define IHttpAsyncIoTask_BindToThreadPool(this, pPool) (this)->lpVtbl->BindToThreadPool(this, pPool)
#define IHttpAsyncIoTask_BeginExecute(this, ppIResult) (this)->lpVtbl->BeginExecute(this, ppIResult)
#define IHttpAsyncIoTask_EndExecute(this, pIResult, BytesTransferred, ppNextTask) (this)->lpVtbl->EndExecute(this, pIResult, BytesTransferred, ppNextTask)
#define IHttpAsyncIoTask_GetWebSiteCollectionWeakPtr(this, ppIWebSites) (this)->lpVtbl->GetWebSiteCollectionWeakPtr(this, ppIWebSites)
#define IHttpAsyncIoTask_SetWebSiteCollectionWeakPtr(this, pIWebSites) (this)->lpVtbl->SetWebSiteCollectionWeakPtr(this, pIWebSites)
#define IHttpAsyncIoTask_GetHttpProcessorCollectionWeakPtr(this, ppIProcessors) (this)->lpVtbl->GetHttpProcessorCollectionWeakPtr(this, ppIProcessors)
#define IHttpAsyncIoTask_SetHttpProcessorCollectionWeakPtr(this, pIProcessors) (this)->lpVtbl->SetHttpProcessorCollectionWeakPtr(this, pIProcessors)
#define IHttpAsyncIoTask_GetBaseStream(this, ppStream) (this)->lpVtbl->GetBaseStream(this, ppStream)
#define IHttpAsyncIoTask_SetBaseStream(this, pStream) (this)->lpVtbl->SetBaseStream(this, pStream)
#define IHttpAsyncIoTask_GetHttpReader(this, ppReader) (this)->lpVtbl->GetHttpReader(this, ppReader)
#define IHttpAsyncIoTask_SetHttpReader(this, pReader) (this)->lpVtbl->SetHttpReader(this, pReader)

#endif