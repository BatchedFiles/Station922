#ifndef IWEBSITECOLLECTION_BI
#define IWEBSITECOLLECTION_BI

#include once "IEnumWebSite.bi"

Type IWebSiteCollection As IWebSiteCollection_

Type LPIWEBSITECOLLECTION As IWebSiteCollection Ptr

Extern IID_IWebSiteCollection Alias "IID_IWebSiteCollection" As Const IID

Type IWebSiteCollectionVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IWebSiteCollection Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IWebSiteCollection Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IWebSiteCollection Ptr _
	)As ULONG
	
	_NewEnum As Function( _
		ByVal this As IWebSiteCollection Ptr, _
		ByVal ppIEnum As IEnumWebSite Ptr Ptr _
	)As HRESULT
	
	Item As Function( _
		ByVal this As IWebSiteCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT
	
	Count As Function( _
		ByVal this As IWebSiteCollection Ptr, _
		ByVal pCount As Integer Ptr _
	)As HRESULT
	
	Add As Function( _
		ByVal this As IWebSiteCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT
	
	ItemWeakPtr As Function( _
		ByVal this As IWebSiteCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
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

#define IWebSiteCollection_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IWebSiteCollection_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IWebSiteCollection_Release(this) (this)->lpVtbl->Release(this)
#define IWebSiteCollection__NewEnum(this, ppIEnum) (this)->lpVtbl->_NewEnum(this, ppIEnum)
' #define IWebSiteCollection_Item(this, pKey, ppIWebSite) (this)->lpVtbl->Item(this, pKey, ppIWebSite)
#define IWebSiteCollection_Count(this, pCount) (this)->lpVtbl->Count(this, pCount)
#define IWebSiteCollection_Add(this, pKey, pIWebSite) (this)->lpVtbl->Add(this, pKey, pIWebSite)
#define IWebSiteCollection_ItemWeakPtr(this, pKey, ppIWebSite) (this)->lpVtbl->ItemWeakPtr(this, pKey, ppIWebSite)

#endif
