#ifndef HTTPGETPROCESSOR_BI
#define HTTPGETPROCESSOR_BI

#include once "IRequestProcessor.bi"
#include once "ILogger.bi"

Extern CLSID_HTTPGETPROCESSOR Alias "CLSID_HTTPGETPROCESSOR" As Const CLSID

Type HttpGetProcessor As _HttpGetProcessor

Type LPHttpGetProcessor As _HttpGetProcessor Ptr

Declare Function CreateHttpGetProcessor( _
	ByVal pILogger As ILogger Ptr, _
	ByVal pIMemoryAllocator As IMalloc Ptr _
)As HttpGetProcessor Ptr

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
	ByVal pContext As ProcessorContext Ptr _
)As HRESULT

Declare Function HttpGetProcessorProcess( _
	ByVal this As HttpGetProcessor Ptr, _
	ByVal pContext As ProcessorContext Ptr _
)As HRESULT

Declare Function HttpGetProcessorBeginProcess( _
	ByVal this As HttpGetProcessor Ptr, _
	ByVal pContext As ProcessorContext Ptr, _
	ByVal StateObject As IUnknown Ptr, _
	ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
)As HRESULT

Declare Function HttpGetProcessorEndProcess( _
	ByVal this As HttpGetProcessor Ptr, _
	ByVal pIAsyncResult As IAsyncResult Ptr _
)As HRESULT

#endif
