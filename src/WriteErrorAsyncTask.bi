#ifndef WRITEERRORASYNCTASK_BI
#define WRITEERRORASYNCTASK_BI

#include once "IWriteErrorAsyncIoTask.bi"

Extern CLSID_WRITEERRORASYNCTASK Alias "CLSID_WRITEERRORASYNCTASK" As Const CLSID

Const RTTI_ID_WRITEERRORASYNCTASK     = !"\001Task_____Error\001"

Type WriteErrorAsyncTask As _WriteErrorAsyncTask

Type LPWriteErrorAsyncTask As _WriteErrorAsyncTask Ptr

Declare Function CreateWriteErrorAsyncTask( _
	ByVal pIMemoryAllocator As IMalloc Ptr _
)As WriteErrorAsyncTask Ptr

Declare Sub DestroyWriteErrorAsyncTask( _
	ByVal this As WriteErrorAsyncTask Ptr _
)

Declare Function WriteErrorAsyncTaskQueryInterface( _
	ByVal this As WriteErrorAsyncTask Ptr, _
	ByVal riid As REFIID, _
	ByVal ppvObject As Any Ptr Ptr _
)As HRESULT

Declare Function WriteErrorAsyncTaskAddRef( _
	ByVal this As WriteErrorAsyncTask Ptr _
)As ULONG

Declare Function WriteErrorAsyncTaskRelease( _
	ByVal this As WriteErrorAsyncTask Ptr _
)As ULONG

Declare Function WriteErrorAsyncTaskBeginExecute( _
	ByVal this As WriteErrorAsyncTask Ptr, _
	ByVal ppIResult As IAsyncResult Ptr Ptr _
)As HRESULT

Declare Function WriteErrorAsyncTaskEndExecute( _
	ByVal this As WriteErrorAsyncTask Ptr, _
	ByVal pIResult As IAsyncResult Ptr, _
	ByVal BytesTransferred As DWORD, _
	ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
)As HRESULT

Declare Function WriteErrorAsyncTaskGetWebSiteCollectionWeakPtr( _
	ByVal this As WriteErrorAsyncTask Ptr, _
	ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
)As HRESULT

Declare Function WriteErrorAsyncTaskSetWebSiteCollectionWeakPtr( _
	ByVal this As WriteErrorAsyncTask Ptr, _
	ByVal pIWebSites As IWebSiteCollection Ptr _
)As HRESULT

Declare Function WriteErrorAsyncTaskGetHttpProcessorCollectionWeakPtr( _
	ByVal this As WriteErrorAsyncTask Ptr, _
	ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
)As HRESULT

Declare Function WriteErrorAsyncTaskSetHttpProcessorCollectionWeakPtr( _
	ByVal this As WriteErrorAsyncTask Ptr, _
	ByVal pIProcessors As IHttpProcessorCollection Ptr _
)As HRESULT

Declare Function WriteErrorAsyncTaskGetBaseStream( _
	ByVal this As WriteErrorAsyncTask Ptr, _
	ByVal ppStream As IBaseStream Ptr Ptr _
)As HRESULT

Declare Function WriteErrorAsyncTaskSetBaseStream( _
	ByVal this As WriteErrorAsyncTask Ptr, _
	ByVal pStream As IBaseStream Ptr _
)As HRESULT

Declare Function WriteErrorAsyncTaskGetHttpReader( _
	ByVal this As WriteErrorAsyncTask Ptr, _
	ByVal ppIHttpReader As IHttpReader Ptr Ptr _
)As HRESULT

Declare Function WriteErrorAsyncTaskSetHttpReader( _
	ByVal this As WriteErrorAsyncTask Ptr, _
	ByVal pIHttpReader As IHttpReader Ptr _
)As HRESULT

Declare Function WriteErrorAsyncTaskGetClientRequest( _
	ByVal this As WriteErrorAsyncTask Ptr, _
	ByVal ppIRequest As IClientRequest Ptr Ptr _
)As HRESULT

Declare Function WriteErrorAsyncTaskSetClientRequest( _
	ByVal this As WriteErrorAsyncTask Ptr, _
	ByVal pIRequest As IClientRequest Ptr _
)As HRESULT

Declare Function WriteErrorAsyncTaskSetErrorCode( _
	ByVal this As WriteErrorAsyncTask Ptr, _
	ByVal HttpError As ResponseErrorCode, _
	ByVal hrCode As HRESULT _
)As HRESULT

Declare Function WriteErrorAsyncTaskPrepare( _
	ByVal this As WriteErrorAsyncTask Ptr _
)As HRESULT

#endif
