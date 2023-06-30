#ifndef TASKEXECUTOR_BI
#define TASKEXECUTOR_BI

#include once "IAsyncIoTask.bi"

Declare Function StartExecuteTask( _
	ByVal pTask As IAsyncIoTask Ptr _
)As HRESULT

#endif
