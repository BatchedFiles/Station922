#ifndef IWEBSITECOLLECTION_BI
#define IWEBSITECOLLECTION_BI

#include once "IString.bi"
#include once "IEnumWebSite.bi"

Extern IID_IWebSiteCollection Alias "IID_IWebSiteCollection" As Const IID

Type IWebSiteCollection As IWebSiteCollection_

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
		ByVal pKey As HeapBSTR, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT
	
	Count As Function( _
		ByVal this As IWebSiteCollection Ptr, _
		ByVal pCount As Integer Ptr _
	)As HRESULT
	
	Add As Function( _
		ByVal this As IWebSiteCollection Ptr, _
		ByVal pKey As HeapBSTR, _
		ByVal Port As HeapBSTR, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT
	
	ItemWeakPtr As Function( _
		ByVal this As IWebSiteCollection Ptr, _
		ByVal pKey As HeapBSTR, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT
	
	GetDefaultWebSite As Function( _
		ByVal this As IWebSiteCollection Ptr, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT
	
	SetDefaultWebSite As Function( _
		ByVal this As IWebSiteCollection Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT
	
	' ��� ���������:
	' Count()
	' Item()
	' _NewEnum()
	' �������������: Add, Remove, Clear, Move � ������ ������
	
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
#define IWebSiteCollection_Add(this, pKey, Port, pIWebSite) (this)->lpVtbl->Add(this, pKey, Port, pIWebSite)
#define IWebSiteCollection_ItemWeakPtr(this, pKey, ppIWebSite) (this)->lpVtbl->ItemWeakPtr(this, pKey, ppIWebSite)
#define IWebSiteCollection_GetDefaultWebSite(this, ppIWebSite) (this)->lpVtbl->GetDefaultWebSite(this, ppIWebSite)
#define IWebSiteCollection_SetDefaultWebSite(this, pIWebSite) (this)->lpVtbl->SetDefaultWebSite(this, pIWebSite)

#endif
