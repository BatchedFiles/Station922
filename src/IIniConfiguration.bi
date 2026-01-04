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
	UtfBomFileOffset As UInteger
	ReservedFileBytes As UInteger
	IsMoved As Boolean
	UseSsl As Boolean
	EnableDirectoryListing As Boolean
	EnableGetAllFiles As Boolean
End Type

Type IWebServerConfiguration As IWebServerConfiguration_

Type IWebServerConfigurationVirtualTable

	QueryInterface As Function( _
		ByVal self As IWebServerConfiguration Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IWebServerConfiguration Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IWebServerConfiguration Ptr _
	)As ULONG

	GetWorkerThreadsCount As Function( _
		ByVal self As IWebServerConfiguration Ptr, _
		ByVal pWorkerThreadsCount As UInteger Ptr _
	)As HRESULT

	GetMemoryPoolCapacity As Function( _
		ByVal self As IWebServerConfiguration Ptr, _
		ByVal pCachedClientMemoryContextCount As UInteger Ptr _
	)As HRESULT

	GetKeepAliveInterval As Function( _
		ByVal self As IWebServerConfiguration Ptr, _
		ByVal pKeepAliveInterval As ULongInt Ptr _
	)As HRESULT

	GetWebSites As Function( _
		ByVal self As IWebServerConfiguration Ptr, _
		ByVal pCount As Integer Ptr, _
		ByVal pWebSites As WebSiteConfiguration Ptr _
	)As HRESULT

	GetDefaultWebSite As Function( _
		ByVal self As IWebServerConfiguration Ptr, _
		ByVal pWebSite As WebSiteConfiguration Ptr _
	)As HRESULT

End Type

Type IWebServerConfiguration_
	lpVtbl As IWebServerConfigurationVirtualTable Ptr
End Type

#define IWebServerConfiguration_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define IWebServerConfiguration_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IWebServerConfiguration_Release(self) (self)->lpVtbl->Release(self)
#define IWebServerConfiguration_GetWorkerThreadsCount(self, pWorkerThreadsCount) (self)->lpVtbl->GetWorkerThreadsCount(self, pWorkerThreadsCount)
#define IWebServerConfiguration_GetMemoryPoolCapacity(self, pCachedClientMemoryContext) (self)->lpVtbl->GetMemoryPoolCapacity(self, pCachedClientMemoryContext)
#define IWebServerConfiguration_GetKeepAliveInterval(self, pKeepAliveInterval) (self)->lpVtbl->GetKeepAliveInterval(self, pKeepAliveInterval)
#define IWebServerConfiguration_GetWebSites(self, pCount, pWebSites) (self)->lpVtbl->GetWebSites(self, pCount, pWebSites)
#define IWebServerConfiguration_GetDefaultWebSite(self, pWebSite) (self)->lpVtbl->GetDefaultWebSite(self, pWebSite)

#endif
