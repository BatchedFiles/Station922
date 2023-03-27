#ifndef HTTPDELETEPROCESSOR_BI
#define HTTPDELETEPROCESSOR_BI

#include once "IHttpDeleteAsyncProcessor.bi"

Extern CLSID_HTTPDELETEASYNCPROCESSOR Alias "CLSID_HTTPDELETEASYNCPROCESSOR" As Const CLSID

Const RTTI_ID_HTTPDELETEPROCESSOR        = !"\001Delete____Proc\001"

Type HttpDeleteProcessor As _HttpDeleteProcessor

Type LPHttpDeleteProcessor As _HttpDeleteProcessor Ptr

Declare Function CreateHttpDeleteProcessor( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Sub DestroyHttpDeleteProcessor( _
	ByVal this As HttpDeleteProcessor Ptr _
)

Declare Function HttpDeleteProcessorQueryInterface( _
	ByVal this As HttpDeleteProcessor Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function HttpDeleteProcessorAddRef( _
	ByVal this As HttpDeleteProcessor Ptr _
)As ULONG

Declare Function HttpDeleteProcessorRelease( _
	ByVal this As HttpDeleteProcessor Ptr _
)As ULONG

Declare Function HttpDeleteProcessorPrepare( _
	ByVal this As HttpDeleteProcessor Ptr, _
	ByVal pContext As ProcessorContext Ptr, _
	ByVal ppIBuffer As IAttributedStream Ptr Ptr _
)As HRESULT

Declare Function HttpDeleteProcessorBeginProcess( _
	ByVal this As HttpDeleteProcessor Ptr, _
	ByVal pContext As ProcessorContext Ptr, _
	ByVal StateObject As IUnknown Ptr, _
	ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
)As HRESULT

Declare Function HttpDeleteProcessorEndProcess( _
	ByVal this As HttpDeleteProcessor Ptr, _
	ByVal pContext As ProcessorContext Ptr, _
	ByVal pIAsyncResult As IAsyncResult Ptr _
)As HRESULT

#endif
