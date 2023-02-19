#ifndef THREADPOOL_BI
#define THREADPOOL_BI

#include once "IThreadPool.bi"

Extern CLSID_THREADPOOL Alias "CLSID_THREADPOOL" As Const CLSID

Extern ThreadPoolCompletionPort As HANDLE

Const RTTI_ID_THREADPOOL              = !"\001Thread____Pool\001"

Type ThreadPool As _ThreadPool

Type LPThreadPool As _ThreadPool Ptr

Declare Function CreateThreadPool( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

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
	ByVal pMaxThreads As UInteger Ptr _
)As HRESULT

Declare Function ThreadPoolSetMaxThreads( _
	ByVal this As ThreadPool Ptr, _
	ByVal MaxThreads As UInteger _
)As HRESULT

Declare Function ThreadPoolRun( _
	ByVal this As ThreadPool Ptr _
)As HRESULT

Declare Function ThreadPoolStop( _
	ByVal this As ThreadPool Ptr _
)As HRESULT

#endif
