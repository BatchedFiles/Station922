#ifndef TASKEXECUTOR_BI
#define TASKEXECUTOR_BI

#include once "IAsyncIoTask.bi"

Declare Function StartExecuteTask( _
	ByVal pTask As IAsyncIoTask Ptr _
)As HRESULT

Declare Sub ThreadPoolCallBack( _
	ByVal dwError As DWORD, _
	ByVal BytesTransferred As DWORD, _
	ByVal pOverlap As OVERLAPPED Ptr _
)

#endif
