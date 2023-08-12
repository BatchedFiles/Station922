#ifndef ACCEPTCONNECTIONASYNCTASK_BI
#define ACCEPTCONNECTIONASYNCTASK_BI

#include once "IAcceptConnectionAsyncIoTask.bi"

Extern CLSID_ACCEPTCONNECTIONASYNCTASK Alias "CLSID_ACCEPTCONNECTIONASYNCTASK" As Const CLSID

Const RTTI_ID_ACCEPTCONNECTIONASYNCTASK  = !"\001Task____Accept\001"

Type AcceptConnectionAsyncTask As _AcceptConnectionAsyncTask

Type LPAcceptConnectionAsyncTask As _AcceptConnectionAsyncTask Ptr

Declare Function CreateAcceptConnectionAsyncTask( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
