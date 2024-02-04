#ifndef THREADPOOL_BI
#define THREADPOOL_BI

#include once "IThreadPool.bi"

Extern CLSID_THREADPOOL Alias "CLSID_THREADPOOL" As Const CLSID

Const RTTI_ID_THREADPOOL              = !"\001Thread____Pool\001"

Declare Function CreateThreadPool( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
