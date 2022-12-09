#ifndef HTTPTRACEPROCESSOR_BI
#define HTTPTRACEPROCESSOR_BI

#include once "IHttpTraceAsyncProcessor.bi"

Extern CLSID_HTTPTRACEASYNCPROCESSOR Alias "CLSID_HTTPTRACEASYNCPROCESSOR" As Const CLSID

Const RTTI_ID_HTTPTRACEPROCESSOR        = !"\001Trace_____Proc\001"

Type HttpTraceProcessor As _HttpTraceProcessor

Type LPHttpTraceProcessor As _HttpTraceProcessor Ptr

Declare Function CreatePermanentHttpTraceProcessor( _
	ByVal pIMemoryAllocator As IMalloc Ptr _
)As HttpTraceProcessor Ptr

Declare Sub DestroyHttpTraceProcessor( _
	ByVal this As HttpTraceProcessor Ptr _
)

Declare Function HttpTraceProcessorQueryInterface( _
	ByVal this As HttpTraceProcessor Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function HttpTraceProcessorAddRef( _
	ByVal this As HttpTraceProcessor Ptr _
)As ULONG

Declare Function HttpTraceProcessorRelease( _
	ByVal this As HttpTraceProcessor Ptr _
)As ULONG

Declare Function HttpTraceProcessorPrepare( _
	ByVal this As HttpTraceProcessor Ptr, _
	ByVal pContext As ProcessorContext Ptr, _
	ByVal ppIBuffer As IAttributedStream Ptr Ptr _
)As HRESULT

Declare Function HttpTraceProcessorBeginProcess( _
	ByVal this As HttpTraceProcessor Ptr, _
	ByVal pContext As ProcessorContext Ptr, _
	ByVal StateObject As IUnknown Ptr, _
	ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
)As HRESULT

Declare Function HttpTraceProcessorEndProcess( _
	ByVal this As HttpTraceProcessor Ptr, _
	ByVal pContext As ProcessorContext Ptr, _
	ByVal pIAsyncResult As IAsyncResult Ptr _
)As HRESULT

#endif
