#ifndef IWEBSERVER_BI
#define IWEBSERVER_BI

#include once "windows.bi"
#include once "win\ole2.bi"

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
#define IWebServer_Run(this) (this)->lpVtbl->Run(this)
#define IWebServer_Stop(this) (this)->lpVtbl->Stop(this)

#endif
