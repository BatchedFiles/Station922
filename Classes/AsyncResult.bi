#ifndef ASYNCRESULT_BI
#define ASYNCRESULT_BI

#include once "IMutableAsyncResult.bi"
#include once "ILogger.bi"

Extern CLSID_ASYNCRESULT Alias "CLSID_ASYNCRESULT" As Const CLSID

Type AsyncResult As _AsyncResult

Type LPAsyncResult As _AsyncResult Ptr

Declare Function CreateAsyncResult( _
	ByVal pILogger As ILogger Ptr, _
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

Declare Function AsyncResultGetAsyncState( _
	ByVal this As AsyncResult Ptr, _
	ByVal ppState As IUnknown Ptr Ptr _
)As HRESULT

Declare Function AsyncResultGetWaitHandle( _
	ByVal this As AsyncResult Ptr, _
	ByVal pWaitHandle As HANDLE Ptr _
)As HRESULT

Declare Function AsyncResultGetCompletedSynchronously( _
	ByVal this As AsyncResult Ptr, _
	ByVal pCompletedSynchronously As Boolean Ptr _
)As HRESULT

Declare Function AsyncResultSetAsyncState( _
	ByVal this As AsyncResult Ptr, _
	ByVal pState As IUnknown Ptr _
)As HRESULT

Declare Function AsyncResultSetWaitHandle( _
	ByVal this As AsyncResult Ptr, _
	ByVal WaitHandle As HANDLE _
)As HRESULT

Declare Function AsyncResultSetCompletedSynchronously( _
	ByVal this As AsyncResult Ptr, _
	ByVal CompletedSynchronously As Boolean _
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
	ByVal ppRecvOverlapped As LPASYNCRESULTOVERLAPPED Ptr _
)As HRESULT

#endif
