#ifndef THREADPOOL_BI
#define THREADPOOL_BI

#include once "IThreadPool.bi"

Extern CLSID_THREADPOOL Alias "CLSID_THREADPOOL" As Const CLSID

Const RTTI_ID_THREADPOOL              = !"\001Thread____Pool\001"

Type ThreadPool As _ThreadPool

Type LPThreadPool As _ThreadPool Ptr

Declare Function CreatePermanentThreadPool( _
	ByVal pIMemoryAllocator As IMalloc Ptr _
)As ThreadPool Ptr

Declare Sub DestroyThreadPool( _
	ByVal this As ThreadPool Ptr _
)

Declare Function ThreadPoolQueryInterface( _
	ByVal this As ThreadPool Ptr, _
	ByVal riid As REFIID, _
	ByVal ppvObject As Any Ptr Ptr _
)As HRESULT

Declare Function ThreadPoolAddRef( _
	ByVal this As ThreadPool Ptr _
)As ULONG

Declare Function ThreadPoolRelease( _
	ByVal this As ThreadPool Ptr _
)As ULONG

Declare Function ThreadPoolGetMaxThreads( _
	ByVal this As ThreadPool Ptr, _
	ByVal pMaxThreads As Integer Ptr _
)As HRESULT

Declare Function ThreadPoolSetMaxThreads( _
	ByVal this As ThreadPool Ptr, _
	ByVal MaxThreads As Integer _
)As HRESULT

Declare Function ThreadPoolRun( _
	ByVal this As ThreadPool Ptr, _
	ByVal CallBack As ThreadPoolCallBack, _
	ByVal param As Any Ptr _
)As HRESULT

Declare Function ThreadPoolStop( _
	ByVal this As ThreadPool Ptr _
)As HRESULT

Declare Function ThreadPoolGetIOCompletionPort( _
	ByVal this As ThreadPool Ptr, _
	ByVal pPort As HANDLE Ptr _
)As HRESULT

#endif