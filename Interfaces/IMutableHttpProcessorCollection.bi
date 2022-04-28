#ifndef IMUTABLEHTTPPROCESSORCOLLECTION_BI
#define IMUTABLEHTTPPROCESSORCOLLECTION_BI

#include once "IHttpProcessorCollection.bi"

Type IMutableHttpProcessorCollection As IMutableHttpProcessorCollection_

Type LPIMUTABLEHTTPPROCESSORCOLLECTION As IMutableHttpProcessorCollection Ptr

Extern IID_IMutableHttpProcessorCollection Alias "IID_IMutableHttpProcessorCollection" As Const IID

Type IMutableHttpProcessorCollectionVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IMutableHttpProcessorCollection Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IMutableHttpProcessorCollection Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IMutableHttpProcessorCollection Ptr _
	)As ULONG
	
	_NewEnum As Function( _
		ByVal this As IMutableHttpProcessorCollection Ptr, _
		ByVal ppIEnum As IEnumHttpProcessor Ptr Ptr _
	)As HRESULT
	
	Item As Function( _
		ByVal this As IMutableHttpProcessorCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal ppIProcessor As IHttpProcessor Ptr Ptr _
	)As HRESULT
	
	Count As Function( _
		ByVal this As IMutableHttpProcessorCollection Ptr, _
		ByVal pCount As Integer Ptr _
	)As HRESULT
	
	GetAllMethods As Function( _
		ByVal this As IMutableHttpProcessorCollection Ptr, _
		ByVal ppMethods As HeapBSTR Ptr _
	)As HRESULT
	
	Add As Function( _
		ByVal this As IMutableHttpProcessorCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal pIProcessor As IHttpProcessor Ptr _
	)As HRESULT
	
	' Для коллекций:
	' Count()
	' Item()
	' _NewEnum()
	' Необязательно: Add, Remove, Clear, Move и методы поиска
	
End Type

Type IMutableHttpProcessorCollection_
	lpVtbl As IMutableHttpProcessorCollectionVirtualTable Ptr
End Type

#define IMutableHttpProcessorCollection_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IMutableHttpProcessorCollection_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IMutableHttpProcessorCollection_Release(this) (this)->lpVtbl->Release(this)
#define IMutableHttpProcessorCollection__NewEnum(this, ppIEnum) (this)->lpVtbl->_NewEnum(this, ppIEnum)
#define IMutableHttpProcessorCollection_Item(this, pKey, ppIWebSite) (this)->lpVtbl->Item(this, pKey, ppIWebSite)
#define IMutableHttpProcessorCollection_Count(this, pCount) (this)->lpVtbl->Count(this, pCount)
#define IMutableHttpProcessorCollection_GetAllMethods(this, ppMethods) (this)->lpVtbl->GetAllMethods(this, ppMethods)
#define IMutableHttpProcessorCollection_Add(this, pKey, pIWebSite) (this)->lpVtbl->Add(this, pKey, pIWebSite)

#endif
