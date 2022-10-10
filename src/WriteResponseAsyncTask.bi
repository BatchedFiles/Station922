#ifndef WRITERESPONSEASYNCTASK_BI
#define WRITERESPONSEASYNCTASK_BI

#include once "IWriteResponseAsyncIoTask.bi"

Extern CLSID_WRITERESPONSEASYNCTASK Alias "CLSID_WRITERESPONSEASYNCTASK" As Const CLSID

Const RTTI_ID_WRITERESPONSEASYNCTASK  = !"\001Task__Response\001"

Type WriteResponseAsyncTask As _WriteResponseAsyncTask

Type LPWriteResponseAsyncTask As _WriteResponseAsyncTask Ptr

Declare Function CreateWriteResponseAsyncTask( _
	ByVal pIMemoryAllocator As IMalloc Ptr _
)As WriteResponseAsyncTask Ptr

Declare Sub DestroyWriteResponseAsyncTask( _
	ByVal this As WriteResponseAsyncTask Ptr _
)

Declare Function WriteResponseAsyncTaskQueryInterface( _
	ByVal this As WriteResponseAsyncTask Ptr, _
	ByVal riid As REFIID, _
	ByVal ppvObject As Any Ptr Ptr _
)As HRESULT

Declare Function WriteResponseAsyncTaskAddRef( _
	ByVal this As WriteResponseAsyncTask Ptr _
)As ULONG

Declare Function WriteResponseAsyncTaskRelease( _
	ByVal this As WriteResponseAsyncTask Ptr _
)As ULONG

Declare Function WriteResponseAsyncTaskBindToThreadPool( _
	ByVal this As WriteResponseAsyncTask Ptr, _
	ByVal pPool As IThreadPool Ptr _
)As HRESULT

Declare Function WriteResponseAsyncTaskBeginExecute( _
	ByVal this As WriteResponseAsyncTask Ptr, _
	ByVal ppIResult As IAsyncResult Ptr Ptr _
)As HRESULT

Declare Function WriteResponseAsyncTaskEndExecute( _
	ByVal this As WriteResponseAsyncTask Ptr, _
	ByVal pIResult As IAsyncResult Ptr, _
	ByVal BytesTransferred As DWORD, _
	ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
)As HRESULT

Declare Function WriteResponseAsyncTaskGetWebSiteCollectionWeakPtr( _
	ByVal this As WriteResponseAsyncTask Ptr, _
	ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
)As HRESULT

Declare Function WriteResponseAsyncTaskSetWebSiteCollectionWeakPtr( _
	ByVal this As WriteResponseAsyncTask Ptr, _
	ByVal pIWebSites As IWebSiteCollection Ptr _
)As HRESULT

Declare Function WriteResponseAsyncTaskGetHttpProcessorCollectionWeakPtr( _
	ByVal this As WriteResponseAsyncTask Ptr, _
	ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
)As HRESULT

Declare Function WriteResponseAsyncTaskSetHttpProcessorCollectionWeakPtr( _
	ByVal this As WriteResponseAsyncTask Ptr, _
	ByVal pIProcessors As IHttpProcessorCollection Ptr _
)As HRESULT

Declare Function WriteResponseAsyncTaskGetBaseStream( _
	ByVal this As WriteResponseAsyncTask Ptr, _
	ByVal ppStream As IBaseStream Ptr Ptr _
)As HRESULT

Declare Function WriteResponseAsyncTaskSetBaseStream( _
	ByVal this As WriteResponseAsyncTask Ptr, _
	byVal pStream As IBaseStream Ptr _
)As HRESULT

Declare Function WriteResponseAsyncTaskGetHttpReader( _
	ByVal this As WriteResponseAsyncTask Ptr, _
	ByVal ppReader As IHttpReader Ptr Ptr _
)As HRESULT

Declare Function WriteResponseAsyncTaskSetHttpReader( _
	ByVal this As WriteResponseAsyncTask Ptr, _
	byVal pReader As IHttpReader Ptr _
)As HRESULT

Declare Function WriteResponseAsyncTaskPrepare( _
	ByVal this As WriteResponseAsyncTask Ptr _
)As HRESULT

#endif
