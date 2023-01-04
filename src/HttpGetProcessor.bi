#ifndef HTTPGETPROCESSOR_BI
#define HTTPGETPROCESSOR_BI

#include once "IHttpGetAsyncProcessor.bi"

Extern CLSID_HTTPGETASYNCPROCESSOR Alias "CLSID_HTTPGETASYNCPROCESSOR" As Const CLSID

Const RTTI_ID_HTTPGETPROCESSOR        = !"\001Get_______Proc\001"

Type HttpGetProcessor As _HttpGetProcessor

Type LPHttpGetProcessor As _HttpGetProcessor Ptr

Declare Function CreateHttpGetProcessor( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Sub DestroyHttpGetProcessor( _
	ByVal this As HttpGetProcessor Ptr _
)

Declare Function HttpGetProcessorQueryInterface( _
	ByVal this As HttpGetProcessor Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function HttpGetProcessorAddRef( _
	ByVal this As HttpGetProcessor Ptr _
)As ULONG

Declare Function HttpGetProcessorRelease( _
	ByVal this As HttpGetProcessor Ptr _
)As ULONG

Declare Function HttpGetProcessorPrepare( _
	ByVal this As HttpGetProcessor Ptr, _
	ByVal pContext As ProcessorContext Ptr, _
	ByVal ppIBuffer As IAttributedStream Ptr Ptr _
)As HRESULT

Declare Function HttpGetProcessorBeginProcess( _
	ByVal this As HttpGetProcessor Ptr, _
	ByVal pContext As ProcessorContext Ptr, _
	ByVal StateObject As IUnknown Ptr, _
	ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
)As HRESULT

Declare Function HttpGetProcessorEndProcess( _
	ByVal this As HttpGetProcessor Ptr, _
	ByVal pContext As ProcessorContext Ptr, _
	ByVal pIAsyncResult As IAsyncResult Ptr _
)As HRESULT

#endif
