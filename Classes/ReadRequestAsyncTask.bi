#ifndef READREQUESTASYNCTASK_BI
#define READREQUESTASYNCTASK_BI

#include once "IReadRequestAsyncTask.bi"

Extern CLSID_READREQUESTASYNCTASK Alias "CLSID_READREQUESTASYNCTASK" As Const CLSID

Type ReadRequestAsyncTask As _ReadRequestAsyncTask

Type LPReadRequestAsyncTask As _ReadRequestAsyncTask Ptr

Declare Function CreateReadRequestAsyncTask( _
	ByVal pIMemoryAllocator As IMalloc Ptr _
)As ReadRequestAsyncTask Ptr

Declare Sub DestroyReadRequestAsyncTask( _
	ByVal this As ReadRequestAsyncTask Ptr _
)

Declare Function ReadRequestAsyncTaskQueryInterface( _
	ByVal this As ReadRequestAsyncTask Ptr, _
	ByVal riid As REFIID, _
	ByVal ppvObject As Any Ptr Ptr _
)As HRESULT

Declare Function ReadRequestAsyncTaskAddRef( _
	ByVal this As ReadRequestAsyncTask Ptr _
)As ULONG

Declare Function ReadRequestAsyncTaskRelease( _
	ByVal this As ReadRequestAsyncTask Ptr _
)As ULONG

Declare Function ReadRequestAsyncTaskBeginExecute( _
	ByVal this As ReadRequestAsyncTask Ptr, _
	ByVal pPool As IThreadPool Ptr _
)As HRESULT

Declare Function ReadRequestAsyncTaskEndExecute( _
	ByVal this As ReadRequestAsyncTask Ptr, _
	ByVal pPool As IThreadPool Ptr, _
	ByVal pIResult As IAsyncResult Ptr, _
	ByVal BytesTransferred As DWORD, _
	ByVal CompletionKey As ULONG_PTR _
)As HRESULT

Declare Function ReadRequestAsyncTaskGetAssociatedWithIOCP( _
	ByVal this As ReadRequestAsyncTask Ptr, _
	ByVal pAssociated As Boolean Ptr _
)As HRESULT

Declare Function ReadRequestAsyncTaskSetAssociatedWithIOCP( _
	ByVal this As ReadRequestAsyncTask Ptr, _
	ByVal Associated As Boolean _
)As HRESULT

Declare Function ReadRequestAsyncTaskGetSocket( _
	ByVal this As ReadRequestAsyncTask Ptr, _
	ByVal pResult As SOCKET Ptr _
)As HRESULT
	
Declare Function ReadRequestAsyncTaskSetSocket( _
	ByVal this As ReadRequestAsyncTask Ptr, _
	ByVal sock As SOCKET _
)As HRESULT

Declare Function ReadRequestAsyncTaskGetWebSiteCollection( _
	ByVal this As ReadRequestAsyncTask Ptr, _
	ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
)As HRESULT

Declare Function ReadRequestAsyncTaskSetWebSiteCollection( _
	ByVal this As ReadRequestAsyncTask Ptr, _
	ByVal pIWebSites As IWebSiteCollection Ptr _
)As HRESULT

Declare Function ReadRequestAsyncTaskGetRemoteAddress( _
	ByVal this As ReadRequestAsyncTask Ptr, _
	ByVal pRemoteAddress As SOCKADDR Ptr, _
	ByVal pRemoteAddressLength As Integer Ptr _
)As HRESULT

Declare Function ReadRequestAsyncTaskSetRemoteAddress( _
	ByVal this As ReadRequestAsyncTask Ptr, _
	ByVal RemoteAddress As SOCKADDR Ptr, _
	ByVal RemoteAddressLength As Integer _
)As HRESULT

Declare Function ReadRequestAsyncTaskCloneableQueryInterface( _
	ByVal this As ReadRequestAsyncTask Ptr, _
	ByVal riid As REFIID, _
	ByVal ppvObject As Any Ptr Ptr _
)As HRESULT

Declare Function ReadRequestAsyncTaskCloneableAddRef( _
	ByVal this As ReadRequestAsyncTask Ptr _
)As ULONG

Declare Function ReadRequestAsyncTaskCloneableRelease( _
	ByVal this As ReadRequestAsyncTask Ptr _
)As ULONG

Declare Function ReadRequestAsyncTaskCloneableClone( _
	ByVal this As ReadRequestAsyncTask Ptr, _
	ByVal pMalloc As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppvObject As Any Ptr Ptr _
)As HRESULT

#endif
