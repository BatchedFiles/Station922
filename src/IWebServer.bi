#ifndef IWEBSERVER_BI
#define IWEBSERVER_BI

#include once "IWebSite.bi"

Extern IID_IWebServer Alias "IID_IWebServer" As Const IID

Type IWebServer As IWebServer_

Type IWebServerVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IWebServer Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IWebServer Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IWebServer Ptr _
	)As ULONG
	
	AddWebSite As Function( _
		ByVal this As IWebServer Ptr, _
		ByVal pKey As HeapBSTR, _
		ByVal Port As HeapBSTR, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT
	
	AddDefaultWebSite As Function( _
		ByVal this As IWebServer Ptr, _
		ByVal pIDefaultWebSite As IWebSite Ptr _
	)As HRESULT
	
	SetEndPoint As Function( _
		ByVal this As IWebServer Ptr, _
		ByVal ListenAddress As HeapBSTR, _
		ByVal ListenPort As HeapBSTR _
	)As HRESULT
	
	Run As Function( _
		ByVal this As IWebServer Ptr _
	)As HRESULT
	
	Stop As Function( _
		ByVal this As IWebServer Ptr _
	)As HRESULT
	
End Type

Type IWebServer_
	lpVtbl As IWebServerVirtualTable Ptr
End Type

#define IWebServer_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IWebServer_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IWebServer_Release(this) (this)->lpVtbl->Release(this)
#define IWebServer_AddWebSite(this, pKey, Port, pIWebSite) (this)->lpVtbl->AddWebSite(this, pKey, Port, pIWebSite)
#define IWebServer_AddDefaultWebSite(this, pIDefaultWebSite) (this)->lpVtbl->AddDefaultWebSite(this, pIDefaultWebSite)
#define IWebServer_SetEndPoint(this, ListenAddress, ListenPort) (this)->lpVtbl->SetEndPoint(this, ListenAddress, ListenPort)
#define IWebServer_Run(this) (this)->lpVtbl->Run(this)
#define IWebServer_Stop(this) (this)->lpVtbl->Stop(this)

#endif
