#ifndef READREQUESTASYNCTASK_BI
#define READREQUESTASYNCTASK_BI

#include once "IReadRequestAsyncIoTask.bi"

Extern CLSID_READREQUESTASYNCTASK Alias "CLSID_READREQUESTASYNCTASK" As Const CLSID

Const RTTI_ID_READREQUESTASYNCTASK    = !"\001Task______Read\001"

Type ReadRequestAsyncTask As _ReadRequestAsyncTask

Type LPReadRequestAsyncTask As _ReadRequestAsyncTask Ptr

Declare Function CreateReadRequestAsyncTask( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
