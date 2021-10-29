#ifndef IMUTABLEWEBSITECOLLECTION_BI
#define IMUTABLEWEBSITECOLLECTION_BI

#include once "IWebSiteCollection.bi"

Type IMutableWebSiteCollection As IMutableWebSiteCollection_

Type LPIMUTABLEWEBSITECOLLECTION As IMutableWebSiteCollection Ptr

Extern IID_IMutableWebSiteCollection Alias "IID_IMutableWebSiteCollection" As Const IID

Type IMutableWebSiteCollectionVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IMutableWebSiteCollection Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IMutableWebSiteCollection Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IMutableWebSiteCollection Ptr _
	)As ULONG
	
	_NewEnum As Function( _
		ByVal this As IMutableWebSiteCollection Ptr, _
		ByVal ppIEnum As IEnumWebSite Ptr Ptr _
	)As HRESULT
	
	Item As Function( _
		ByVal this As IMutableWebSiteCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT
	
	Count As Function( _
		ByVal this As IMutableWebSiteCollection Ptr, _
		ByVal pCount As Integer Ptr _
	)As HRESULT
	
	Add As Function( _
		ByVal this As IMutableWebSiteCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT
	
	' Для коллекций:
	' Count()
	' Item()
	' _NewEnum()
	' Необязательно: Add, Remove, Clear, Move и методы поиска
	
End Type

Type IMutableWebSiteCollection_
	lpVtbl As IMutableWebSiteCollectionVirtualTable Ptr
End Type

#define IMutableWebSiteCollection_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IMutableWebSiteCollection_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IMutableWebSiteCollection_Release(this) (this)->lpVtbl->Release(this)
#define IMutableWebSiteCollection__NewEnum(this, ppIEnum) (this)->lpVtbl->_NewEnum(this, ppIEnum)
#define IMutableWebSiteCollection_Item(this, pKey, ppIWebSite) (this)->lpVtbl->Item(this, pKey, ppIWebSite)
#define IMutableWebSiteCollection_Count(this, pCount) (this)->lpVtbl->Count(this, pCount)
#define IMutableWebSiteCollection_Add(this, pKey, pIWebSite) (this)->lpVtbl->Add(this, pKey, pIWebSite)

#endif
