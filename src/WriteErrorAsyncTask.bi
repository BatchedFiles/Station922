#ifndef WRITEERRORASYNCTASK_BI
#define WRITEERRORASYNCTASK_BI

#include once "IWriteErrorAsyncIoTask.bi"

Extern CLSID_WRITEERRORASYNCTASK Alias "CLSID_WRITEERRORASYNCTASK" As Const CLSID

Const RTTI_ID_WRITEERRORASYNCTASK     = !"\001Task_____Error\001"

Type WriteErrorAsyncTask As _WriteErrorAsyncTask

Type LPWriteErrorAsyncTask As _WriteErrorAsyncTask Ptr

Declare Function CreateWriteErrorAsyncTask( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
