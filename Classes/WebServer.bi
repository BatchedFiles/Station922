#ifndef WEBSERVER_BI
#define WEBSERVER_BI

#include "IRunnable.bi"

Extern CLSID_WEBSERVER Alias "CLSID_WEBSERVER" As Const CLSID

Type WebServer As _WebServer

Type LPWebServer As _WebServer Ptr

Declare Function CreateWebServer( _
)As WebServer Ptr

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

Declare Function WebServerRun( _
	ByVal this As WebServer Ptr _
)As HRESULT

Declare Function WebServerStop( _
	ByVal this As WebServer Ptr _
)As HRESULT

#endif
