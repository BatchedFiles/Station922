#ifndef IWRITERESPONSEASYNCTASK_BI
#define IWRITERESPONSEASYNCTASK_BI

#include once "IClientRequest.bi"
#include once "IHttpAsyncTask.bi"

Type IWriteResponseAsyncTask As IWriteResponseAsyncTask_

Type LPIWRITERESPONSEASYNCTASK As IWriteResponseAsyncTask Ptr

Extern IID_IWriteResponseAsyncTask Alias "IID_IWriteResponseAsyncTask" As Const IID

Type IWriteResponseAsyncTaskVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IWriteResponseAsyncTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IWriteResponseAsyncTask Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IWriteResponseAsyncTask Ptr _
	)As ULONG
	
	BeginExecute As Function( _
		ByVal this As IWriteResponseAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndExecute As Function( _
		ByVal this As IWriteResponseAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal CompletionKey As ULONG_PTR _
	)As HRESULT
	
	GetWebSiteCollection As Function( _
		ByVal this As IWriteResponseAsyncTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	
	SetWebSiteCollection As Function( _
		ByVal this As IWriteResponseAsyncTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	
	GetBaseStream As Function( _
		ByVal this As IWriteResponseAsyncTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	
	SetBaseStream As Function( _
		ByVal this As IWriteResponseAsyncTask Ptr, _
		byVal pStream As IBaseStream Ptr _
	)As HRESULT
	
	GetHttpReader As Function( _
		ByVal this As IWriteResponseAsyncTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	SetHttpReader As Function( _
		ByVal this As IWriteResponseAsyncTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	
	GetHttpProcessorCollection As Function( _
		ByVal this As IWriteResponseAsyncTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	
	SetHttpProcessorCollection As Function( _
		ByVal this As IWriteResponseAsyncTask Ptr, _
		ByVal pIProcessors As IHttpProcessorCollection Ptr _
	)As HRESULT
	
	GetClientRequest As Function( _
		ByVal this As IWriteResponseAsyncTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	
	SetClientRequest As Function( _
		ByVal this As IWriteResponseAsyncTask Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT
	
End Type

Type IWriteResponseAsyncTask_
	lpVtbl As IWriteResponseAsyncTaskVirtualTable Ptr
End Type

#define IWriteResponseAsyncTask_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IWriteResponseAsyncTask_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IWriteResponseAsyncTask_Release(this) (this)->lpVtbl->Release(this)
#define IWriteResponseAsyncTask_BeginExecute(this, pPool, ppIResult) (this)->lpVtbl->BeginExecute(this, pPool, ppIResult)
#define IWriteResponseAsyncTask_EndExecute(this, pPool, pIResult, BytesTransferred, CompletionKey) (this)->lpVtbl->EndExecute(this, pPool, pIResult, BytesTransferred, CompletionKey)
#define IWriteResponseAsyncTask_GetWebSiteCollection(this, ppIWebSites) (this)->lpVtbl->GetWebSiteCollection(this, ppIWebSites)
#define IWriteResponseAsyncTask_SetWebSiteCollection(this, pIWebSites) (this)->lpVtbl->SetWebSiteCollection(this, pIWebSites)
#define IWriteResponseAsyncTask_GetBaseStream(this, ppStream) (this)->lpVtbl->GetBaseStream(this, ppStream)
#define IWriteResponseAsyncTask_SetBaseStream(this, pStream) (this)->lpVtbl->SetBaseStream(this, pStream)
#define IWriteResponseAsyncTask_GetHttpReader(this, ppReader) (this)->lpVtbl->GetHttpReader(this, ppReader)
#define IWriteResponseAsyncTask_SetHttpReader(this, pReader) (this)->lpVtbl->SetHttpReader(this, pReader)
#define IWriteResponseAsyncTask_GetHttpProcessorCollection(this, ppIProcessors) (this)->lpVtbl->GetHttpProcessorCollection(this, ppIProcessors)
#define IWriteResponseAsyncTask_SetHttpProcessorCollection(this, pIProcessors) (this)->lpVtbl->SetHttpProcessorCollection(this, pIProcessors)
#define IWriteResponseAsyncTask_GetClientRequest(this, ppIRequest) (this)->lpVtbl->GetClientRequest(this, ppIRequest)
#define IWriteResponseAsyncTask_SetClientRequest(this, pIRequest) (this)->lpVtbl->SetClientRequest(this, pIRequest)

#endif
