#ifndef HTTPOPTIONSPROCESSOR_BI
#define HTTPOPTIONSPROCESSOR_BI

#include once "IHttpOptionsAsyncProcessor.bi"

Extern CLSID_HTTPOPTIONSASYNCPROCESSOR Alias "CLSID_HTTPOPTIONSASYNCPROCESSOR" As Const CLSID

Const RTTI_ID_HTTPOPTIONSPROCESSOR        = !"\001Options___Proc\001"

Type HttpOptionsProcessor As _HttpOptionsProcessor

Type LPHttpOptionsProcessor As _HttpOptionsProcessor Ptr

Declare Function CreateHttpOptionsProcessor( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Sub DestroyHttpOptionsProcessor( _
	ByVal this As HttpOptionsProcessor Ptr _
)

Declare Function HttpOptionsProcessorQueryInterface( _
	ByVal this As HttpOptionsProcessor Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function HttpOptionsProcessorAddRef( _
	ByVal this As HttpOptionsProcessor Ptr _
)As ULONG

Declare Function HttpOptionsProcessorRelease( _
	ByVal this As HttpOptionsProcessor Ptr _
)As ULONG

Declare Function HttpOptionsProcessorPrepare( _
	ByVal this As HttpOptionsProcessor Ptr, _
	ByVal pContext As ProcessorContext Ptr, _
	ByVal ppIBuffer As IAttributedStream Ptr Ptr _
)As HRESULT

Declare Function HttpOptionsProcessorBeginProcess( _
	ByVal this As HttpOptionsProcessor Ptr, _
	ByVal pContext As ProcessorContext Ptr, _
	ByVal StateObject As IUnknown Ptr, _
	ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
)As HRESULT

Declare Function HttpOptionsProcessorEndProcess( _
	ByVal this As HttpOptionsProcessor Ptr, _
	ByVal pContext As ProcessorContext Ptr, _
	ByVal pIAsyncResult As IAsyncResult Ptr _
)As HRESULT

#endif
