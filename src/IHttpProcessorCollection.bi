#ifndef IHTTPPROCESSORCOLLECTION_BI
#define IHTTPPROCESSORCOLLECTION_BI

Type IHttpProcessorCollection As IHttpProcessorCollection_

#include once "IEnumHttpProcessor.bi"
#include once "IString.bi"

Extern IID_IHttpProcessorCollection Alias "IID_IHttpProcessorCollection" As Const IID

Type IHttpProcessorCollectionVirtualTable

	QueryInterface As Function( _
		ByVal self As IHttpProcessorCollection Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IHttpProcessorCollection Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IHttpProcessorCollection Ptr _
	)As ULONG

	_NewEnum As Function( _
		ByVal self As IHttpProcessorCollection Ptr, _
		ByVal ppIEnum As IEnumHttpProcessor Ptr Ptr _
	)As HRESULT

	Item As Function( _
		ByVal self As IHttpProcessorCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal ppIProcessor As IHttpAsyncProcessor Ptr Ptr _
	)As HRESULT

	Count As Function( _
		ByVal self As IHttpProcessorCollection Ptr, _
		ByVal pCount As Integer Ptr _
	)As HRESULT

	GetAllMethods As Function( _
		ByVal self As IHttpProcessorCollection Ptr, _
		ByVal ppMethods As HeapBSTR Ptr _
	)As HRESULT

	Add As Function( _
		ByVal self As IHttpProcessorCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal pIProcessor As IHttpAsyncProcessor Ptr _
	)As HRESULT

	ItemWeakPtr As Function( _
		ByVal self As IHttpProcessorCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal ppIProcessor As IHttpAsyncProcessor Ptr Ptr _
	)As HRESULT

	SetAllMethods As Function( _
		ByVal self As IHttpProcessorCollection Ptr, _
		ByVal pMethods As HeapBSTR _
	)As HRESULT

	' Для коллекций:
	' Count()
	' Item()
	' _NewEnum()
	' Необязательно: Add, Remove, Clear, Move и методы поиска

End Type

Type IHttpProcessorCollection_
	lpVtbl As IHttpProcessorCollectionVirtualTable Ptr
End Type

#define IHttpProcessorCollection_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define IHttpProcessorCollection_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IHttpProcessorCollection_Release(self) (self)->lpVtbl->Release(self)
#define IHttpProcessorCollection__NewEnum(self, ppIEnum) (self)->lpVtbl->_NewEnum(self, ppIEnum)
' #define IHttpProcessorCollection_Item(self, pKey, ppIProcessor) (self)->lpVtbl->Item(self, pKey, ppIProcessor)
#define IHttpProcessorCollection_Count(self, pCount) (self)->lpVtbl->Count(self, pCount)
#define IHttpProcessorCollection_GetAllMethods(self, ppMethods) (self)->lpVtbl->GetAllMethods(self, ppMethods)
#define IHttpProcessorCollection_Add(self, pKey, pIProcessor) (self)->lpVtbl->Add(self, pKey, pIProcessor)
#define IHttpProcessorCollection_ItemWeakPtr(self, pKey, ppIProcessor) (self)->lpVtbl->ItemWeakPtr(self, pKey, ppIProcessor)
#define IHttpProcessorCollection_SetAllMethods(self, pMethods) (self)->lpVtbl->SetAllMethods(self, pMethods)

#endif
