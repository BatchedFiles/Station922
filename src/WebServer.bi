#ifndef WEBSERVER_BI
#define WEBSERVER_BI

#include once "IWebServer.bi"

Extern CLSID_WEBSERVER Alias "CLSID_WEBSERVER" As Const CLSID

Const RTTI_ID_WEBSERVER               = !"\001Web_____Server\001"

Declare Function CreateWebServer( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
