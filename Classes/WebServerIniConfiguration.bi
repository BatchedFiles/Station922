#ifndef WEBSERVERINICONFIGURATION_BI
#define WEBSERVERINICONFIGURATION_BI

#include once "IWebServerConfiguration.bi"

Extern CLSID_WEBSERVERINICONFIGURATION Alias "CLSID_WEBSERVERINICONFIGURATION" As Const CLSID

Type WebServerIniConfiguration As _WebServerIniConfiguration

Type LPWebServerIniConfiguration As _WebServerIniConfiguration Ptr

Declare Function CreateWebServerIniConfiguration( _
	ByVal pIMemoryAllocator As IMalloc Ptr _
)As WebServerIniConfiguration Ptr

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

Declare Function WebServerIniConfigurationGetListenAddress( _
	ByVal this As WebServerIniConfiguration Ptr, _
	ByVal bstrListenAddress As BSTR Ptr _
)As HRESULT

Declare Function WebServerIniConfigurationGetListenPort( _
	ByVal this As WebServerIniConfiguration Ptr, _
	ByVal pListenPort As UINT Ptr _
)As HRESULT

Declare Function WebServerIniConfigurationGetConnectBindAddress( _
	ByVal this As WebServerIniConfiguration Ptr, _
	ByVal bstrConnectBindAddress As BSTR Ptr _
)As HRESULT

Declare Function WebServerIniConfigurationGetConnectBindPort( _
	ByVal this As WebServerIniConfiguration Ptr, _
	ByVal pConnectBindPort As UINT Ptr _
)As HRESULT

Declare Function WebServerIniConfigurationGetWorkerThreadsCount( _
	ByVal this As WebServerIniConfiguration Ptr, _
	ByVal pWorkerThreadsCount As Integer Ptr _
)As HRESULT

Declare Function WebServerIniConfigurationGetCachedClientMemoryContextCount( _
	ByVal this As WebServerIniConfiguration Ptr, _
	ByVal pCachedClientMemoryContextCount As Integer Ptr _
)As HRESULT

Declare Function WebServerIniConfigurationGetIsPasswordValid( _
	ByVal this As WebServerIniConfiguration Ptr, _
	ByVal pUserName As WString Ptr, _
	ByVal pPassword As WString Ptr, _
	ByVal pIsPasswordValid As Boolean Ptr _
)As HRESULT

Declare Function WebServerIniConfigurationGetWebSiteCollection( _
	ByVal this As WebServerIniConfiguration Ptr, _
	ByVal ppIWebSiteCollection As IWebSiteCollection Ptr Ptr _
)As HRESULT

Declare Function WebServerIniConfigurationGetHttpProcessorCollection( _
	ByVal this As WebServerIniConfiguration Ptr, _
	ByVal ppIHttpProcessorCollection As IHttpProcessorCollection Ptr Ptr _
)As HRESULT

#endif
