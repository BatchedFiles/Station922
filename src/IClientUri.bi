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
		ByVal self As IClientUri Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IClientUri Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IClientUri Ptr _
	)As ULONG

	UriFromString As Function( _
		ByVal self As IClientUri Ptr, _
		ByVal bstrUri As HeapBSTR _
	)As HRESULT

	GetOriginalString As Function( _
		ByVal self As IClientUri Ptr, _
		ByVal ppOriginalString As HeapBSTR Ptr _
	)As HRESULT

	GetUserName As Function( _
		ByVal self As IClientUri Ptr, _
		ByVal ppUserName As HeapBSTR Ptr _
	)As HRESULT

	GetPassword As Function( _
		ByVal self As IClientUri Ptr, _
		ByVal ppPassword As HeapBSTR Ptr _
	)As HRESULT

	GetHost As Function( _
		ByVal self As IClientUri Ptr, _
		ByVal ppHost As HeapBSTR Ptr _
	)As HRESULT

	GetPort As Function( _
		ByVal self As IClientUri Ptr, _
		ByVal ppPort As HeapBSTR Ptr _
	)As HRESULT

	GetScheme As Function( _
		ByVal self As IClientUri Ptr, _
		ByVal ppScheme As HeapBSTR Ptr _
	)As HRESULT

	GetPath As Function( _
		ByVal self As IClientUri Ptr, _
		ByVal ppPath As HeapBSTR Ptr _
	)As HRESULT

	GetQuery As Function( _
		ByVal self As IClientUri Ptr, _
		ByVal ppQuery As HeapBSTR Ptr _
	)As HRESULT

	GetFragment As Function( _
		ByVal self As IClientUri Ptr, _
		ByVal ppFragment As HeapBSTR Ptr _
	)As HRESULT

End Type

Type IClientUri_
	lpVtbl As IClientUriVirtualTable Ptr
End Type

#define IClientUri_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define IClientUri_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IClientUri_Release(self) (self)->lpVtbl->Release(self)
#define IClientUri_UriFromString(self, bstrUri) (self)->lpVtbl->UriFromString(self, bstrUri)
#define IClientUri_GetOriginalString(self, ppOriginalString) (self)->lpVtbl->GetOriginalString(self, ppOriginalString)
#define IClientUri_GetUserName(self, ppUserName) (self)->lpVtbl->GetUserName(self, ppUserName)
#define IClientUri_GetPassword(self, ppPassword) (self)->lpVtbl->GetPassword(self, ppPassword)
#define IClientUri_GetHost(self, ppHost) (self)->lpVtbl->GetHost(self, ppHost)
#define IClientUri_GetPort(self, ppPort) (self)->lpVtbl->GetPort(self, ppPort)
#define IClientUri_GetScheme(self, ppScheme) (self)->lpVtbl->GetScheme(self, ppScheme)
#define IClientUri_GetPath(self, ppPath) (self)->lpVtbl->GetPath(self, ppPath)
#define IClientUri_GetQuery(self, ppQuery) (self)->lpVtbl->GetQuery(self, ppQuery)
#define IClientUri_GetFragment(self, ppFragment) (self)->lpVtbl->GetFragment(self, ppFragment)

#endif
