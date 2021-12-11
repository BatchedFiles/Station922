#ifndef PREPAREERRORRESPONSEASYNCTASK_BI
#define PREPAREERRORRESPONSEASYNCTASK_BI

#include once "IPrepareErrorResponseAsyncTask.bi"

Extern CLSID_PREPAREERRORRESPONSEASYNCTASK Alias "CLSID_PREPAREERRORRESPONSEASYNCTASK" As Const CLSID

Type PrepareErrorResponseAsyncTask As _PrepareErrorResponseAsyncTask

Type LPPrepareErrorResponseAsyncTask As _PrepareErrorResponseAsyncTask Ptr

Declare Function CreatePrepareErrorResponseAsyncTask( _
	ByVal pIMemoryAllocator As IMalloc Ptr _
)As PrepareErrorResponseAsyncTask Ptr

Declare Sub DestroyPrepareErrorResponseAsyncTask( _
	ByVal this As PrepareErrorResponseAsyncTask Ptr _
)

Declare Function PrepareErrorResponseAsyncTaskQueryInterface( _
	ByVal this As PrepareErrorResponseAsyncTask Ptr, _
	ByVal riid As REFIID, _
	ByVal ppvObject As Any Ptr Ptr _
)As HRESULT

Declare Function PrepareErrorResponseAsyncTaskAddRef( _
	ByVal this As PrepareErrorResponseAsyncTask Ptr _
)As ULONG

Declare Function PrepareErrorResponseAsyncTaskRelease( _
	ByVal this As PrepareErrorResponseAsyncTask Ptr _
)As ULONG

Declare Function PrepareErrorResponseAsyncTaskBeginExecute( _
	ByVal this As PrepareErrorResponseAsyncTask Ptr, _
	ByVal pPool As IThreadPool Ptr, _
	ByVal ppIResult As IAsyncResult Ptr Ptr _
)As HRESULT

Declare Function PrepareErrorResponseAsyncTaskEndExecute( _
	ByVal this As PrepareErrorResponseAsyncTask Ptr, _
	ByVal pPool As IThreadPool Ptr, _
	ByVal pIResult As IAsyncResult Ptr, _
	ByVal BytesTransferred As DWORD, _
	ByVal CompletionKey As ULONG_PTR _
)As HRESULT

Declare Function PrepareErrorResponseAsyncTaskGetWebSiteCollection( _
	ByVal this As PrepareErrorResponseAsyncTask Ptr, _
	ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
)As HRESULT

Declare Function PrepareErrorResponseAsyncTaskSetWebSiteCollection( _
	ByVal this As PrepareErrorResponseAsyncTask Ptr, _
	ByVal pIWebSites As IWebSiteCollection Ptr _
)As HRESULT

Declare Function PrepareErrorResponseAsyncTaskGetRemoteAddress( _
	ByVal this As PrepareErrorResponseAsyncTask Ptr, _
	ByVal pRemoteAddress As SOCKADDR Ptr, _
	ByVal pRemoteAddressLength As Integer Ptr _
)As HRESULT

Declare Function PrepareErrorResponseAsyncTaskSetRemoteAddress( _
	ByVal this As PrepareErrorResponseAsyncTask Ptr, _
	ByVal RemoteAddress As SOCKADDR Ptr, _
	ByVal RemoteAddressLength As Integer _
)As HRESULT

Declare Function PrepareErrorResponseAsyncTaskGetBaseStream( _
	ByVal this As PrepareErrorResponseAsyncTask Ptr, _
	ByVal ppStream As IBaseStream Ptr Ptr _
)As HRESULT

Declare Function PrepareErrorResponseAsyncTaskSetBaseStream( _
	ByVal this As PrepareErrorResponseAsyncTask Ptr, _
	ByVal pStream As IBaseStream Ptr _
)As HRESULT

Declare Function PrepareErrorResponseAsyncTaskGetHttpReader( _
	ByVal this As PrepareErrorResponseAsyncTask Ptr, _
	ByVal ppIHttpReader As IHttpReader Ptr Ptr _
)As HRESULT

Declare Function PrepareErrorResponseAsyncTaskSetHttpReader( _
	ByVal this As PrepareErrorResponseAsyncTask Ptr, _
	ByVal pIHttpReader As IHttpReader Ptr _
)As HRESULT

Declare Function PrepareErrorResponseAsyncTaskGetClientRequest( _
	ByVal this As PrepareErrorResponseAsyncTask Ptr, _
	ByVal ppIRequest As IClientRequest Ptr Ptr _
)As HRESULT

Declare Function PrepareErrorResponseAsyncTaskSetClientRequest( _
	ByVal this As PrepareErrorResponseAsyncTask Ptr, _
	ByVal pIRequest As IClientRequest Ptr _
)As HRESULT

Declare Function PrepareErrorResponseAsyncTaskSetErrorCode( _
	ByVal this As PrepareErrorResponseAsyncTask Ptr, _
	ByVal HttpError As ResponseErrorCode, _
	ByVal hrCode As HRESULT _
)As HRESULT

Declare Function PrepareErrorResponseAsyncTaskGetHttpProcessorCollection( _
	ByVal this As PrepareErrorResponseAsyncTask Ptr, _
	ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
)As HRESULT

Declare Function PrepareErrorResponseAsyncTaskSetHttpProcessorCollection( _
	ByVal this As PrepareErrorResponseAsyncTask Ptr, _
	ByVal pIProcessors As IHttpProcessorCollection Ptr _
)As HRESULT

#endif
