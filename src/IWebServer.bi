#ifndef IWEBSERVER_BI
#define IWEBSERVER_BI

#include once "IWebSite.bi"

Extern IID_IWebServer Alias "IID_IWebServer" As Const IID

Type IWebServer As IWebServer_

Type IWebServerVirtualTable

	QueryInterface As Function( _
		ByVal self As IWebServer Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IWebServer Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IWebServer Ptr _
	)As ULONG

	AddWebSite As Function( _
		ByVal self As IWebServer Ptr, _
		ByVal pKey As HeapBSTR, _
		ByVal Port As HeapBSTR, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT

	AddDefaultWebSite As Function( _
		ByVal self As IWebServer Ptr, _
		ByVal pIDefaultWebSite As IWebSite Ptr _
	)As HRESULT

	SetEndPoint As Function( _
		ByVal self As IWebServer Ptr, _
		ByVal ListenAddress As HeapBSTR, _
		ByVal ListenPort As HeapBSTR _
	)As HRESULT

	Run As Function( _
		ByVal self As IWebServer Ptr _
	)As HRESULT

	Stop As Function( _
		ByVal self As IWebServer Ptr _
	)As HRESULT

End Type

Type IWebServer_
	lpVtbl As IWebServerVirtualTable Ptr
End Type

#define IWebServer_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define IWebServer_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IWebServer_Release(self) (self)->lpVtbl->Release(self)
#define IWebServer_AddWebSite(self, pKey, Port, pIWebSite) (self)->lpVtbl->AddWebSite(self, pKey, Port, pIWebSite)
#define IWebServer_AddDefaultWebSite(self, pIDefaultWebSite) (self)->lpVtbl->AddDefaultWebSite(self, pIDefaultWebSite)
#define IWebServer_SetEndPoint(self, ListenAddress, ListenPort) (self)->lpVtbl->SetEndPoint(self, ListenAddress, ListenPort)
#define IWebServer_Run(self) (self)->lpVtbl->Run(self)
#define IWebServer_Stop(self) (self)->lpVtbl->Stop(self)

#endif
