#ifndef HTTPTRACEPROCESSOR_BI
#define HTTPTRACEPROCESSOR_BI

#include once "IHttpTraceAsyncProcessor.bi"

Extern CLSID_HTTPTRACEASYNCPROCESSOR Alias "CLSID_HTTPTRACEASYNCPROCESSOR" As Const CLSID

Const RTTI_ID_HTTPTRACEPROCESSOR        = !"\001Trace_____Proc\001"

Type HttpTraceProcessor As _HttpTraceProcessor

Type LPHttpTraceProcessor As _HttpTraceProcessor Ptr

Declare Function CreateHttpTraceProcessor( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
