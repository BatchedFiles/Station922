#ifndef IINICONFIGURATION_BI
#define IINICONFIGURATION_BI

#include once "IWebSite.bi"
#include once "IHttpAsyncProcessor.bi"

Const MaxWebSites As Integer = 64
Const MaxHttpProcessors As Integer = 64

Type IWebServerConfiguration As IWebServerConfiguration_

Type LPIWebServerConfiguration As IWebServerConfiguration Ptr

Extern IID_IIniConfiguration Alias "IID_IIniConfiguration" As Const IID

Type IWebServerConfigurationVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IWebServerConfiguration Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IWebServerConfiguration Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IWebServerConfiguration Ptr _
	)As ULONG
		
	GetWorkerThreadsCount As Function( _
		ByVal this As IWebServerConfiguration Ptr, _
		ByVal pWorkerThreadsCount As UInteger Ptr _
	)As HRESULT
	
	GetCachedClientMemoryContextCount As Function( _
		ByVal this As IWebServerConfiguration Ptr, _
		ByVal pCachedClientMemoryContextCount As UInteger Ptr _
	)As HRESULT
	
	GetWebSites As Function( _
		ByVal this As IWebServerConfiguration Ptr, _
		ByVal pWebSites As Integer Ptr, _
		ByVal ppIWebSites As IWebSite Ptr Ptr _
	)As HRESULT
	
	GetHttpProcessors As Function( _
		ByVal this As IWebServerConfiguration Ptr, _
		ByVal pHttpProcessors As Integer Ptr, _
		ByVal ppIHttpProcessors As IHttpAsyncProcessor Ptr Ptr _
	)As HRESULT
	
End Type

Type IWebServerConfiguration_
	lpVtbl As IWebServerConfigurationVirtualTable Ptr
End Type

#define IWebServerConfiguration_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IWebServerConfiguration_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IWebServerConfiguration_Release(this) (this)->lpVtbl->Release(this)
#define IWebServerConfiguration_GetWorkerThreadsCount(this, pWorkerThreadsCount) (this)->lpVtbl->GetWorkerThreadsCount(this, pWorkerThreadsCount)
#define IWebServerConfiguration_GetCachedClientMemoryContextCount(this, pCachedClientMemoryContext) (this)->lpVtbl->GetCachedClientMemoryContextCount(this, pCachedClientMemoryContext)
#define IWebServerConfiguration_GetWebSites(this, pWebSites, ppIWebSites) (this)->lpVtbl->GetWebSites(this, pWebSites, ppIWebSites)
#define IWebServerConfiguration_GetHttpProcessors(this, pHttpProcessors, ppIHttpProcessors) (this)->lpVtbl->GetHttpProcessors(this, pHttpProcessors, ppIHttpProcessors)

#endif
