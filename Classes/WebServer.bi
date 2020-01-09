#ifndef WEBSERVER_BI
#define WEBSERVER_BI

#include "IRunnable.bi"
#include "Network.bi"

Const ListenAddressLengthMaximum As Integer = 255
Const ListenPortLengthMaximum As Integer = 15

Extern CLSID_WEBSERVER Alias "CLSID_WEBSERVER" As Const CLSID

Type WebServer
	Dim pVirtualTable As IRunnableVirtualTable Ptr
	Dim ReferenceCounter As ULONG
	
	Dim hThreadContextHeap As HANDLE
	' Dim pExeDir As WString Ptr
	Dim LogDir As WString * (MAX_PATH + 1)
	Dim SettingsFileName As WString * (MAX_PATH + 1)
	
	Dim ListenAddress As WString * (ListenAddressLengthMaximum + 1)
	Dim ListenPort As WString * (ListenPortLengthMaximum + 1)
	
	Dim ListenSocket As SOCKET
	Dim ReListenSocket As Boolean
	
	Dim Frequency As LARGE_INTEGER
	
End Type

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

#define WebServer_NonVirtualQueryInterface(pIWebServer, riid, ppv) WebServerQueryInterface(CPtr(WebServer Ptr, pIWebServer), riid, ppv)
#define WebServer_NonVirtualAddRef(pIWebServer) WebServerAddRef(CPtr(WebServer Ptr, pIWebServer))
#define WebServer_NonVirtualRelease(pIWebServer) WebServerRelease(CPtr(WebServer Ptr, pIWebServer))
#define WebServer_NonVirtualRun(pIWebServer) WebServerRun(CPtr(WebServer Ptr, pIWebServer))
#define WebServer_NonVirtualStop(pIWebServer) WebServerStop(CPtr(WebServer Ptr, pIWebServer))

#endif
