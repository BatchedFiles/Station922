#ifndef HTTPPROCESSORCOLLECTION_BI
#define HTTPPROCESSORCOLLECTION_BI

#include once "IHttpProcessorCollection.bi"

Const RTTI_ID_HTTPPROCESSORCOLLECTION = !"\001Coll_Processor\001"

Extern CLSID_HTTPPROCESSORCOLLECTION Alias "CLSID_HTTPPROCESSORCOLLECTION" As Const CLSID

Type HttpProcessorCollection As _HttpProcessorCollection

Type LPHttpProcessorCollection As _HttpProcessorCollection Ptr

Declare Function CreateHttpProcessorCollection( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Sub DestroyHttpProcessorCollection( _
	ByVal this As HttpProcessorCollection Ptr _
)

Declare Function HttpProcessorCollectionQueryInterface( _
	ByVal this As HttpProcessorCollection Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function HttpProcessorCollectionAddRef( _
	ByVal this As HttpProcessorCollection Ptr _
)As ULONG

Declare Function HttpProcessorCollectionRelease( _
	ByVal this As HttpProcessorCollection Ptr _
)As ULONG

Declare Function HttpProcessorCollection_NewEnum( _
	ByVal this As HttpProcessorCollection Ptr, _
	ByVal ppIEnum As IEnumHttpProcessor Ptr Ptr _
)As HRESULT

Declare Function HttpProcessorCollectionItem( _
	ByVal this As HttpProcessorCollection Ptr, _
	ByVal pKey As WString Ptr, _
	ByVal ppIProcessor As IHttpAsyncProcessor Ptr Ptr _
)As HRESULT

Declare Function HttpProcessorCollectionCount( _
	ByVal this As HttpProcessorCollection Ptr, _
	ByVal pCount As Integer Ptr _
)As HRESULT

Declare Function HttpProcessorCollectionGetAllMethods( _
	ByVal this As HttpProcessorCollection Ptr, _
	ByVal ppMethods As HeapBSTR Ptr _
)As HRESULT

Declare Function HttpProcessorCollectionAdd( _
	ByVal this As HttpProcessorCollection Ptr, _
	ByVal pKey As WString Ptr, _
	ByVal pIProcessor As IHttpAsyncProcessor Ptr _
)As HRESULT

Declare Function HttpProcessorCollectionItemWeakPtr( _
	ByVal this As HttpProcessorCollection Ptr, _
	ByVal pKey As WString Ptr, _
	ByVal ppIProcessor As IHttpAsyncProcessor Ptr Ptr _
)As HRESULT

Declare Function HttpProcessorCollectionSetAllMethods( _
	ByVal this As HttpProcessorCollection Ptr, _
	ByVal pMethods As HeapBSTR _
)As HRESULT

#endif
