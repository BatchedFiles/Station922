#ifndef WORKERTHREAD_BI
#define WORKERTHREAD_BI

#include once "IWebSiteCollection.bi"
#include once "ILogger.bi"

Type WorkerThreadContext As _WorkerThreadContext

Declare Function CreateWorkerThreadContext( _
	ByVal hIOCompletionPort As HANDLE, _
	ByVal pILogger As ILogger Ptr, _
	ByVal pIWebSites As IWebSiteCollection Ptr _
)As WorkerThreadContext Ptr

Declare Sub DestroyWorkerThreadContext( _
	ByVal this As WorkerThreadContext Ptr _
)

Declare Function WorkerThread( _
	ByVal lpParam As LPVOID _
)As DWORD

#endif
