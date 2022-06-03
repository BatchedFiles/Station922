#ifndef ASYNCRESULT_BI
#define ASYNCRESULT_BI

#include once "IAsyncResult.bi"

Extern CLSID_ASYNCRESULT Alias "CLSID_ASYNCRESULT" As Const CLSID

Type AsyncResult As _AsyncResult

Type LPAsyncResult As _AsyncResult Ptr

Declare Function CreateAsyncResult( _
	ByVal pIMemoryAllocator As IMalloc Ptr _
)As AsyncResult Ptr

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
	ByVal pCompleted As Boolean Ptr _
)As HRESULT

Declare Function AsyncResultSetCompleted( _
	ByVal this As AsyncResult Ptr, _
	ByVal BytesTransferred As DWORD, _
	ByVal Completed As Boolean _
)As HRESULT

Declare Function AsyncResultSetAsyncStateWeakPtr( _
	ByVal this As AsyncResult Ptr, _
	ByVal pState As Any Ptr _
)As HRESULT

Declare Function AsyncResultGetAsyncCallback( _
	ByVal this As AsyncResult Ptr, _
	ByVal pcallback As AsyncCallback Ptr _
)As HRESULT

Declare Function AsyncResultSetAsyncCallback( _
	ByVal this As AsyncResult Ptr, _
	ByVal callback As AsyncCallback _
)As HRESULT

Declare Function AsyncResultGetWsaOverlapped( _
	ByVal this As AsyncResult Ptr, _
	ByVal ppRecvOverlapped As ASYNCRESULTOVERLAPPED Ptr Ptr _
)As HRESULT

Declare Function AsyncResultAllocBuffers( _
	ByVal this As AsyncResult Ptr, _
	ByVal Count As Integer, _
	ByVal ppBuffers As WSABUF Ptr Ptr _
)As HRESULT

#endif
