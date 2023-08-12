#ifndef WRITERESPONSEASYNCTASK_BI
#define WRITERESPONSEASYNCTASK_BI

#include once "IWriteResponseAsyncIoTask.bi"

Extern CLSID_WRITERESPONSEASYNCTASK Alias "CLSID_WRITERESPONSEASYNCTASK" As Const CLSID

Const RTTI_ID_WRITERESPONSEASYNCTASK  = !"\001Task__Response\001"

Type WriteResponseAsyncTask As _WriteResponseAsyncTask

Type LPWriteResponseAsyncTask As _WriteResponseAsyncTask Ptr

Declare Function CreateWriteResponseAsyncTask( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
