#ifndef ASYNCRESULT_BI
#define ASYNCRESULT_BI

#include once "IAsyncResult.bi"

Extern CLSID_ASYNCRESULT Alias "CLSID_ASYNCRESULT" As Const CLSID

Const RTTI_ID_ASYNCRESULT             = !"\001Async___Result\001"

Type AsyncResult As _AsyncResult

Type LPAsyncResult As _AsyncResult Ptr

Declare Function CreateAsyncResult( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Sub DestroyAsyncResult( _
	ByVal this As AsyncResult Ptr _
)

Declare Function AsyncResultQueryInterface( _
	ByVal this As AsyncResult Ptr, _
	ByVal riid As REFIID, _
	ByVal ppvObject As Any Ptr Ptr _
)As HRESULT

Declare Function AsyncResultAddRef( _
	ByVal this As AsyncResult Ptr _
)As ULONG

Declare Function AsyncResultRelease( _
	ByVal this As AsyncResult Ptr _
)As ULONG

Declare Function AsyncResultGetAsyncStateWeakPtr( _
	ByVal this As AsyncResult Ptr, _
	ByVal ppState As Any Ptr Ptr _
)As HRESULT

Declare Function AsyncResultGetCompleted( _
	ByVal this As AsyncResult Ptr, _
	ByVal pBytesTransferred As DWORD Ptr, _
	ByVal pCompleted As Boolean Ptr, _
	ByVal pdwError As DWORD Ptr _
)As HRESULT

Declare Function AsyncResultSetCompleted( _
	ByVal this As AsyncResult Ptr, _
	ByVal BytesTransferred As DWORD, _
	ByVal Completed As Boolean, _
	ByVal dwError As DWORD _
)As HRESULT

Declare Function AsyncResultSetAsyncStateWeakPtr( _
	ByVal this As AsyncResult Ptr, _
	ByVal pState As Any Ptr _
)As HRESULT

Declare Function AsyncResultGetWsaOverlapped( _
	ByVal this As AsyncResult Ptr, _
	ByVal ppOverlapped As OVERLAPPED Ptr Ptr _
)As HRESULT

Declare Function AsyncResultAllocBuffers( _
	ByVal this As AsyncResult Ptr, _
	ByVal Length As Integer, _
	ByVal ppBuffers As Any Ptr Ptr _
)As HRESULT

#endif
