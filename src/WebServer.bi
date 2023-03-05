#ifndef WEBSERVER_BI
#define WEBSERVER_BI

#include once "IWebServer.bi"

Extern CLSID_WEBSERVER Alias "CLSID_WEBSERVER" As Const CLSID

Const RTTI_ID_WEBSERVER               = !"\001Web_____Server\001"

Type WebServer As _WebServer

Type LPWebServer As _WebServer Ptr

Declare Function CreateWebServer( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Sub DestroyWebServer( _
	ByVal this As WebServer Ptr _
)

Declare Function WebServerQueryInterface( _
	ByVal this As WebServer Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function WebServerAddRef( _
	ByVal this As WebServer Ptr _
)As ULONG

Declare Function WebServerRelease( _
	ByVal this As WebServer Ptr _
)As ULONG

Declare Function WebServerAddWebSite( _
	ByVal this As WebServer Ptr, _
	ByVal pKey As HeapBSTR, _
	ByVal pIWebSite As IWebSite Ptr _
)As HRESULT

Declare Function WebServerAddDefaultWebSite( _
	ByVal this As WebServer Ptr, _
	ByVal pIDefaultWebSite As IWebSite Ptr _
)As HRESULT

Declare Function WebServerSetEndPoint( _
	ByVal this As WebServer Ptr, _
	ByVal ListenAddress As HeapBSTR, _
	ByVal ListenPort As HeapBSTR _
)As HRESULT

Declare Function WebServerRun( _
	ByVal this As WebServer Ptr _
)As HRESULT

Declare Function WebServerStop( _
	ByVal this As WebServer Ptr _
)As HRESULT

#endif
