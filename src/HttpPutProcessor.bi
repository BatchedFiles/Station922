#ifndef HTTPPUTPROCESSOR_BI
#define HTTPPUTPROCESSOR_BI

#include once "IHttpPutAsyncProcessor.bi"

Extern CLSID_HTTPPUTASYNCPROCESSOR Alias "CLSID_HTTPPUTASYNCPROCESSOR" As Const CLSID

Const RTTI_ID_HTTPPUTPROCESSOR        = !"\001Put_______Proc\001"

Type HttpPutProcessor As _HttpPutProcessor

Type LPHttpPutProcessor As _HttpPutProcessor Ptr

Declare Function CreatePermanentHttpPutProcessor( _
	ByVal pIMemoryAllocator As IMalloc Ptr _
)As HttpPutProcessor Ptr

Declare Sub DestroyHttpPutProcessor( _
	ByVal this As HttpPutProcessor Ptr _
)

Declare Function HttpPutProcessorQueryInterface( _
	ByVal this As HttpPutProcessor Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function HttpPutProcessorAddRef( _
	ByVal this As HttpPutProcessor Ptr _
)As ULONG

Declare Function HttpPutProcessorRelease( _
	ByVal this As HttpPutProcessor Ptr _
)As ULONG

Declare Function HttpPutProcessorPrepare( _
	ByVal this As HttpPutProcessor Ptr, _
	ByVal pContext As ProcessorContext Ptr, _
	ByVal ppIBuffer As IAttributedStream Ptr Ptr _
)As HRESULT

Declare Function HttpPutProcessorBeginProcess( _
	ByVal this As HttpPutProcessor Ptr, _
	ByVal pContext As ProcessorContext Ptr, _
	ByVal StateObject As IUnknown Ptr, _
	ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
)As HRESULT

Declare Function HttpPutProcessorEndProcess( _
	ByVal this As HttpPutProcessor Ptr, _
	ByVal pContext As ProcessorContext Ptr, _
	ByVal pIAsyncResult As IAsyncResult Ptr _
)As HRESULT

#endif
