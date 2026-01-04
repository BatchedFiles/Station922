#ifndef IWEBSITECOLLECTION_BI
#define IWEBSITECOLLECTION_BI

#include once "IString.bi"
#include once "IEnumWebSite.bi"

Extern IID_IWebSiteCollection Alias "IID_IWebSiteCollection" As Const IID

Type IWebSiteCollection As IWebSiteCollection_

Type IWebSiteCollectionVirtualTable

	QueryInterface As Function( _
		ByVal self As IWebSiteCollection Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IWebSiteCollection Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IWebSiteCollection Ptr _
	)As ULONG

	_NewEnum As Function( _
		ByVal self As IWebSiteCollection Ptr, _
		ByVal ppIEnum As IEnumWebSite Ptr Ptr _
	)As HRESULT

	Item As Function( _
		ByVal self As IWebSiteCollection Ptr, _
		ByVal pKey As HeapBSTR, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT

	Count As Function( _
		ByVal self As IWebSiteCollection Ptr, _
		ByVal pCount As Integer Ptr _
	)As HRESULT

	Add As Function( _
		ByVal self As IWebSiteCollection Ptr, _
		ByVal pKey As HeapBSTR, _
		ByVal Port As HeapBSTR, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT

	ItemWeakPtr As Function( _
		ByVal self As IWebSiteCollection Ptr, _
		ByVal pKey As HeapBSTR, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT

	GetDefaultWebSite As Function( _
		ByVal self As IWebSiteCollection Ptr, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT

	SetDefaultWebSite As Function( _
		ByVal self As IWebSiteCollection Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT

	' Для коллекций:
	' Count()
	' Item()
	' _NewEnum()
	' Необязательно: Add, Remove, Clear, Move и методы поиска

End Type

Type IWebSiteCollection_
	lpVtbl As IWebSiteCollectionVirtualTable Ptr
End Type

#define IWebSiteCollection_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define IWebSiteCollection_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IWebSiteCollection_Release(self) (self)->lpVtbl->Release(self)
#define IWebSiteCollection__NewEnum(self, ppIEnum) (self)->lpVtbl->_NewEnum(self, ppIEnum)
' #define IWebSiteCollection_Item(self, pKey, ppIWebSite) (self)->lpVtbl->Item(self, pKey, ppIWebSite)
#define IWebSiteCollection_Count(self, pCount) (self)->lpVtbl->Count(self, pCount)
#define IWebSiteCollection_Add(self, pKey, Port, pIWebSite) (self)->lpVtbl->Add(self, pKey, Port, pIWebSite)
#define IWebSiteCollection_ItemWeakPtr(self, pKey, ppIWebSite) (self)->lpVtbl->ItemWeakPtr(self, pKey, ppIWebSite)
#define IWebSiteCollection_GetDefaultWebSite(self, ppIWebSite) (self)->lpVtbl->GetDefaultWebSite(self, ppIWebSite)
#define IWebSiteCollection_SetDefaultWebSite(self, pIWebSite) (self)->lpVtbl->SetDefaultWebSite(self, pIWebSite)

#endif
