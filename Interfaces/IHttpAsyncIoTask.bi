#ifndef IHTTPASYNCIOTASK_BI
#define IHTTPASYNCIOTASK_BI

#include once "IAsyncIoTask.bi"
#include once "IBaseStream.bi"
#include once "IHttpProcessorCollection.bi"
#include once "IHttpReader.bi"
#include once "IWebSiteCollection.bi"

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
	
	BeginExecute As Function( _
		ByVal this As IHttpAsyncIoTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndExecute As Function( _
		ByVal this As IHttpAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD _
	)As HRESULT
	
	GetFileHandle As Function( _
		ByVal this As IHttpAsyncIoTask Ptr, _
		ByVal pFileHandle As HANDLE Ptr _
	)As HRESULT
	
	GetWebSiteCollection As Function( _
		ByVal this As IHttpAsyncIoTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	
	SetWebSiteCollection As Function( _
		ByVal this As IHttpAsyncIoTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
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
	
	GetHttpProcessorCollection As Function( _
		ByVal this As IHttpAsyncIoTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	
	SetHttpProcessorCollection As Function( _
		ByVal this As IHttpAsyncIoTask Ptr, _
		ByVal pIProcessors As IHttpProcessorCollection Ptr _
	)As HRESULT
	
End Type

Type IHttpAsyncIoTask_
	lpVtbl As IHttpAsyncIoTaskVirtualTable Ptr
End Type

#define IHttpAsyncIoTask_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IHttpAsyncIoTask_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IHttpAsyncIoTask_Release(this) (this)->lpVtbl->Release(this)
#define IHttpAsyncIoTask_BeginExecute(this, ppIResult) (this)->lpVtbl->BeginExecute(this, ppIResult)
#define IHttpAsyncIoTask_EndExecute(this, pIResult, BytesTransferred) (this)->lpVtbl->EndExecute(this, pIResult, BytesTransferred)
#define IHttpAsyncIoTask_GetFileHandle(this, pFileHandle) (this)->lpVtbl->GetFileHandle(this, pFileHandle)
#define IHttpAsyncIoTask_GetWebSiteCollection(this, ppIWebSites) (this)->lpVtbl->GetWebSiteCollection(this, ppIWebSites)
#define IHttpAsyncIoTask_SetWebSiteCollection(this, pIWebSites) (this)->lpVtbl->SetWebSiteCollection(this, pIWebSites)
#define IHttpAsyncIoTask_GetBaseStream(this, ppStream) (this)->lpVtbl->GetBaseStream(this, ppStream)
#define IHttpAsyncIoTask_SetBaseStream(this, pStream) (this)->lpVtbl->SetBaseStream(this, pStream)
#define IHttpAsyncIoTask_GetHttpReader(this, ppReader) (this)->lpVtbl->GetHttpReader(this, ppReader)
#define IHttpAsyncIoTask_SetHttpReader(this, pReader) (this)->lpVtbl->SetHttpReader(this, pReader)
#define IHttpAsyncIoTask_GetHttpProcessorCollection(this, ppIProcessors) (this)->lpVtbl->GetHttpProcessorCollection(this, ppIProcessors)
#define IHttpAsyncIoTask_SetHttpProcessorCollection(this, pIProcessors) (this)->lpVtbl->SetHttpProcessorCollection(this, pIProcessors)

#endif
