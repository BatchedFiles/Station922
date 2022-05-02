#ifndef IHTTPASYNCTASK_BI
#define IHTTPASYNCTASK_BI

#include once "IAsyncTask.bi"
#include once "IAsyncResult.bi"
#include once "IBaseStream.bi"
#include once "IHttpProcessorCollection.bi"
#include once "IHttpReader.bi"
#include once "IWebSiteCollection.bi"

Type IHttpAsyncTask As IHttpAsyncTask_

Type LPIHTTPASYNCTASK As IHttpAsyncTask Ptr

Extern IID_IHttpAsyncTask Alias "IID_IHttpAsyncTask" As Const IID

Type IHttpAsyncTaskVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IHttpAsyncTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IHttpAsyncTask Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IHttpAsyncTask Ptr _
	)As ULONG
	
	BeginExecute As Function( _
		ByVal this As IHttpAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndExecute As Function( _
		ByVal this As IHttpAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal CompletionKey As ULONG_PTR _
	)As HRESULT
	
	GetWebSiteCollection As Function( _
		ByVal this As IHttpAsyncTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	
	SetWebSiteCollection As Function( _
		ByVal this As IHttpAsyncTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	
	GetBaseStream As Function( _
		ByVal this As IHttpAsyncTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	
	SetBaseStream As Function( _
		ByVal this As IHttpAsyncTask Ptr, _
		byVal pStream As IBaseStream Ptr _
	)As HRESULT
	
	GetHttpReader As Function( _
		ByVal this As IHttpAsyncTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	SetHttpReader As Function( _
		ByVal this As IHttpAsyncTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	
	GetHttpProcessorCollection As Function( _
		ByVal this As IHttpAsyncTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	
	SetHttpProcessorCollection As Function( _
		ByVal this As IHttpAsyncTask Ptr, _
		ByVal pIProcessors As IHttpProcessorCollection Ptr _
	)As HRESULT
	
End Type

Type IHttpAsyncTask_
	lpVtbl As IHttpAsyncTaskVirtualTable Ptr
End Type

#define IHttpAsyncTask_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IHttpAsyncTask_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IHttpAsyncTask_Release(this) (this)->lpVtbl->Release(this)
#define IHttpAsyncTask_BeginExecute(this, pPool, ppIResult) (this)->lpVtbl->BeginExecute(this, pPool, ppIResult)
#define IHttpAsyncTask_EndExecute(this, pPool, pIResult, BytesTransferred, CompletionKey) (this)->lpVtbl->EndExecute(this, pPool, pIResult, BytesTransferred, CompletionKey)
#define IHttpAsyncTask_GetWebSiteCollection(this, ppIWebSites) (this)->lpVtbl->GetWebSiteCollection(this, ppIWebSites)
#define IHttpAsyncTask_SetWebSiteCollection(this, pIWebSites) (this)->lpVtbl->SetWebSiteCollection(this, pIWebSites)
#define IHttpAsyncTask_GetBaseStream(this, ppStream) (this)->lpVtbl->GetBaseStream(this, ppStream)
#define IHttpAsyncTask_SetBaseStream(this, pStream) (this)->lpVtbl->SetBaseStream(this, pStream)
#define IHttpAsyncTask_GetHttpReader(this, ppReader) (this)->lpVtbl->GetHttpReader(this, ppReader)
#define IHttpAsyncTask_SetHttpReader(this, pReader) (this)->lpVtbl->SetHttpReader(this, pReader)
#define IHttpAsyncTask_GetHttpProcessorCollection(this, ppIProcessors) (this)->lpVtbl->GetHttpProcessorCollection(this, ppIProcessors)
#define IHttpAsyncTask_SetHttpProcessorCollection(this, pIProcessors) (this)->lpVtbl->SetHttpProcessorCollection(this, pIProcessors)

#endif
