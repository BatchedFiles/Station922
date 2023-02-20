#ifndef ICLIENTURI_BI
#define ICLIENTURI_BI

#include once "IString.bi"

Extern IID_IClientUri Alias "IID_IClientUri" As Const IID

Type IClientUri As IClientUri_

/'
URI
        userinfo       host      port
        [??????] [?????????????] [?]
https://john.doe@www.example.com:123/forum/questions/?tag=networking&order=newest#top
[???]   [??????????????????????????](???????????????) [?????????????????????????] [?]
scheme          authority                  path                 query           fragment

'/

Type IClientUriVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IClientUri Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IClientUri Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IClientUri Ptr _
	)As ULONG
	
	UriFromString As Function( _
		ByVal this As IClientUri Ptr, _
		ByVal bstrUri As HeapBSTR _
	)As HRESULT
	
	GetOriginalString As Function( _
		ByVal this As IClientUri Ptr, _
		ByVal ppOriginalString As HeapBSTR Ptr _
	)As HRESULT
	
	GetUserName As Function( _
		ByVal this As IClientUri Ptr, _
		ByVal ppUserName As HeapBSTR Ptr _
	)As HRESULT
	
	GetPassword As Function( _
		ByVal this As IClientUri Ptr, _
		ByVal ppPassword As HeapBSTR Ptr _
	)As HRESULT
	
	GetHost As Function( _
		ByVal this As IClientUri Ptr, _
		ByVal ppHost As HeapBSTR Ptr _
	)As HRESULT
	
	GetPort As Function( _
		ByVal this As IClientUri Ptr, _
		ByVal ppPort As HeapBSTR Ptr _
	)As HRESULT
	
	GetScheme As Function( _
		ByVal this As IClientUri Ptr, _
		ByVal ppScheme As HeapBSTR Ptr _
	)As HRESULT
	
	GetPath As Function( _
		ByVal this As IClientUri Ptr, _
		ByVal ppPath As HeapBSTR Ptr _
	)As HRESULT
	
	GetQuery As Function( _
		ByVal this As IClientUri Ptr, _
		ByVal ppQuery As HeapBSTR Ptr _
	)As HRESULT
	
	GetFragment As Function( _
		ByVal this As IClientUri Ptr, _
		ByVal ppFragment As HeapBSTR Ptr _
	)As HRESULT
	
End Type

Type IClientUri_
	lpVtbl As IClientUriVirtualTable Ptr
End Type

#define IClientUri_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IClientUri_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IClientUri_Release(this) (this)->lpVtbl->Release(this)
#define IClientUri_UriFromString(this, bstrUri) (this)->lpVtbl->UriFromString(this, bstrUri)
#define IClientUri_GetOriginalString(this, ppOriginalString) (this)->lpVtbl->GetOriginalString(this, ppOriginalString)
#define IClientUri_GetUserName(this, ppUserName) (this)->lpVtbl->GetUserName(this, ppUserName)
#define IClientUri_GetPassword(this, ppPassword) (this)->lpVtbl->GetPassword(this, ppPassword)
#define IClientUri_GetHost(this, ppHost) (this)->lpVtbl->GetHost(this, ppHost)
#define IClientUri_GetPort(this, ppPort) (this)->lpVtbl->GetPort(this, ppPort)
#define IClientUri_GetScheme(this, ppScheme) (this)->lpVtbl->GetScheme(this, ppScheme)
#define IClientUri_GetPath(this, ppPath) (this)->lpVtbl->GetPath(this, ppPath)
#define IClientUri_GetQuery(this, ppQuery) (this)->lpVtbl->GetQuery(this, ppQuery)
#define IClientUri_GetFragment(this, ppFragment) (this)->lpVtbl->GetFragment(this, ppFragment)

#endif
