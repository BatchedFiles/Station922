#ifndef IHTTPPROCESSORCOLLECTION_BI
#define IHTTPPROCESSORCOLLECTION_BI

Type IHttpProcessorCollection As IHttpProcessorCollection_

#include once "IEnumHttpProcessor.bi"
#include once "IString.bi"

Extern IID_IHttpProcessorCollection Alias "IID_IHttpProcessorCollection" As Const IID

Type IHttpProcessorCollectionVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IHttpProcessorCollection Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IHttpProcessorCollection Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IHttpProcessorCollection Ptr _
	)As ULONG
	
	_NewEnum As Function( _
		ByVal this As IHttpProcessorCollection Ptr, _
		ByVal ppIEnum As IEnumHttpProcessor Ptr Ptr _
	)As HRESULT
	
	Item As Function( _
		ByVal this As IHttpProcessorCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal ppIProcessor As IHttpAsyncProcessor Ptr Ptr _
	)As HRESULT
	
	Count As Function( _
		ByVal this As IHttpProcessorCollection Ptr, _
		ByVal pCount As Integer Ptr _
	)As HRESULT
	
	GetAllMethods As Function( _
		ByVal this As IHttpProcessorCollection Ptr, _
		ByVal ppMethods As HeapBSTR Ptr _
	)As HRESULT
	
	Add As Function( _
		ByVal this As IHttpProcessorCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal pIProcessor As IHttpAsyncProcessor Ptr _
	)As HRESULT
	
	ItemWeakPtr As Function( _
		ByVal this As IHttpProcessorCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal ppIProcessor As IHttpAsyncProcessor Ptr Ptr _
	)As HRESULT
	
	SetAllMethods As Function( _
		ByVal this As IHttpProcessorCollection Ptr, _
		ByVal pMethods As HeapBSTR _
	)As HRESULT
	
	' ��� ���������:
	' Count()
	' Item()
	' _NewEnum()
	' �������������: Add, Remove, Clear, Move � ������ ������
	
End Type

Type IHttpProcessorCollection_
	lpVtbl As IHttpProcessorCollectionVirtualTable Ptr
End Type

#define IHttpProcessorCollection_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IHttpProcessorCollection_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IHttpProcessorCollection_Release(this) (this)->lpVtbl->Release(this)
#define IHttpProcessorCollection__NewEnum(this, ppIEnum) (this)->lpVtbl->_NewEnum(this, ppIEnum)
' #define IHttpProcessorCollection_Item(this, pKey, ppIProcessor) (this)->lpVtbl->Item(this, pKey, ppIProcessor)
#define IHttpProcessorCollection_Count(this, pCount) (this)->lpVtbl->Count(this, pCount)
#define IHttpProcessorCollection_GetAllMethods(this, ppMethods) (this)->lpVtbl->GetAllMethods(this, ppMethods)
#define IHttpProcessorCollection_Add(this, pKey, pIProcessor) (this)->lpVtbl->Add(this, pKey, pIProcessor)
#define IHttpProcessorCollection_ItemWeakPtr(this, pKey, ppIProcessor) (this)->lpVtbl->ItemWeakPtr(this, pKey, ppIProcessor)
#define IHttpProcessorCollection_SetAllMethods(this, pMethods) (this)->lpVtbl->SetAllMethods(this, pMethods)

#endif
