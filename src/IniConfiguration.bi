#ifndef INICONFIGURATION_BI
#define INICONFIGURATION_BI

#include once "IIniConfiguration.bi"

Extern CLSID_INICONFIGURATION Alias "CLSID_INICONFIGURATION" As Const CLSID

Const RTTI_ID_INICONFIGURATION        = !"\001INI_____Config\001"

Type WebServerIniConfiguration As _WebServerIniConfiguration

Type LPWebServerIniConfiguration As _WebServerIniConfiguration Ptr

Declare Function CreateWebServerIniConfiguration( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Sub DestroyWebServerIniConfiguration( _
	ByVal this As WebServerIniConfiguration Ptr _
)

Declare Function WebServerIniConfigurationQueryInterface( _
	ByVal this As WebServerIniConfiguration Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function WebServerIniConfigurationAddRef( _
	ByVal this As WebServerIniConfiguration Ptr _
)As ULONG

Declare Function WebServerIniConfigurationRelease( _
	ByVal this As WebServerIniConfiguration Ptr _
)As ULONG

Declare Function WebServerIniConfigurationGetWorkerThreadsCount( _
	ByVal this As WebServerIniConfiguration Ptr, _
	ByVal pWorkerThreadsCount As UInteger Ptr _
)As HRESULT

Declare Function WebServerIniConfigurationGetCachedClientMemoryContextCount( _
	ByVal this As WebServerIniConfiguration Ptr, _
	ByVal pCachedClientMemoryContextCount As UInteger Ptr _
)As HRESULT

Declare Function WebServerIniConfigurationGetWebSites( _
	ByVal this As WebServerIniConfiguration Ptr, _
	ByVal pWebSites As Integer Ptr, _
	ByVal ppIWebSites As IWebSite Ptr Ptr _
)As HRESULT

Declare Function WebServerIniConfigurationGetHttpProcessors( _
	ByVal this As WebServerIniConfiguration Ptr, _
	ByVal pHttpProcessors As Integer Ptr, _
	ByVal ppIHttpProcessors As IHttpAsyncProcessor Ptr Ptr _
)As HRESULT

#endif
