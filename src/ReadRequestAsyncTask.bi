#ifndef READREQUESTASYNCTASK_BI
#define READREQUESTASYNCTASK_BI

#include once "IReadRequestAsyncIoTask.bi"

Extern CLSID_READREQUESTASYNCTASK Alias "CLSID_READREQUESTASYNCTASK" As Const CLSID

Const RTTI_ID_READREQUESTASYNCTASK    = !"\001Task______Read\001"

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
	ByVal ppIResult As IAsyncResult Ptr Ptr _
)As HRESULT

Declare Function ReadRequestAsyncTaskEndExecute( _
	ByVal this As ReadRequestAsyncTask Ptr, _
	ByVal pIResult As IAsyncResult Ptr, _
	ByVal BytesTransferred As DWORD, _
	ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
)As HRESULT

Declare Function ReadRequestAsyncTaskGetWebSiteCollectionWeakPtr( _
	ByVal this As ReadRequestAsyncTask Ptr, _
	ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
)As HRESULT

Declare Function ReadRequestAsyncTaskSetWebSiteCollectionWeakPtr( _
	ByVal this As ReadRequestAsyncTask Ptr, _
	ByVal pIWebSites As IWebSiteCollection Ptr _
)As HRESULT

Declare Function ReadRequestAsyncTaskGetHttpProcessorCollectionWeakPtr( _
	ByVal this As ReadRequestAsyncTask Ptr, _
	ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
)As HRESULT

Declare Function ReadRequestAsyncTaskSetHttpProcessorCollectionWeakPtr( _
	ByVal this As ReadRequestAsyncTask Ptr, _
	ByVal pIProcessors As IHttpProcessorCollection Ptr _
)As HRESULT

Declare Function ReadRequestAsyncTaskGetBaseStream( _
	ByVal this As ReadRequestAsyncTask Ptr, _
	ByVal ppStream As IBaseStream Ptr Ptr _
)As HRESULT

Declare Function ReadRequestAsyncTaskSetBaseStream( _
	ByVal this As ReadRequestAsyncTask Ptr, _
	byVal pStream As IBaseStream Ptr _
)As HRESULT

Declare Function ReadRequestAsyncTaskGetHttpReader( _
	ByVal this As ReadRequestAsyncTask Ptr, _
	ByVal ppReader As IHttpReader Ptr Ptr _
)As HRESULT

Declare Function ReadRequestAsyncTaskSetHttpReader( _
	ByVal this As ReadRequestAsyncTask Ptr, _
	byVal pReader As IHttpReader Ptr _
)As HRESULT

#endif
