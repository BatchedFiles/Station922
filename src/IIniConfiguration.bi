#ifndef IINICONFIGURATION_BI
#define IINICONFIGURATION_BI

#include once "IString.bi"

Extern IID_IIniConfiguration Alias "IID_IIniConfiguration" As Const IID

Const MaxWebSites As Integer = 64
Const MaxHttpProcessors As Integer = 64

Type WebSiteConfiguration
	HostName As HeapBSTR
	VirtualPath As HeapBSTR
	PhysicalDirectory As HeapBSTR
	CanonicalUrl As HeapBSTR
	ListenAddress As HeapBSTR
	ListenPort As HeapBSTR
	ConnectBindAddress As HeapBSTR
	ConnectBindPort As HeapBSTR
	CodePage As HeapBSTR
	Methods As HeapBSTR
	DefaultFileName As HeapBSTR
	UserName As HeapBSTR
	Password As HeapBSTR
	UtfBomFileOffset As Integer
	ReservedFileBytes As Integer
	IsMoved As Boolean
	UseSsl As Boolean
	EnableDirectoryListing As Boolean
	EnableGetAllFiles As Boolean
End Type

Type IWebServerConfiguration As IWebServerConfiguration_

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
		ByVal pCount As Integer Ptr, _
		ByVal pWebSites As WebSiteConfiguration Ptr _
	)As HRESULT
	
	GetDefaultWebSite As Function( _
		ByVal this As IWebServerConfiguration Ptr, _
		ByVal pWebSite As WebSiteConfiguration Ptr _
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
#define IWebServerConfiguration_GetWebSites(this, pCount, pWebSites) (this)->lpVtbl->GetWebSites(this, pCount, pWebSites)
#define IWebServerConfiguration_GetDefaultWebSite(this, pWebSite) (this)->lpVtbl->GetDefaultWebSite(this, pWebSite)

#endif
