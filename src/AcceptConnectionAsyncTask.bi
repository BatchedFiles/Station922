#ifndef ACCEPTCONNECTIONASYNCTASK_BI
#define ACCEPTCONNECTIONASYNCTASK_BI

#include once "IAcceptConnectionAsyncIoTask.bi"

Extern CLSID_ACCEPTCONNECTIONASYNCTASK Alias "CLSID_ACCEPTCONNECTIONASYNCTASK" As Const CLSID

Const RTTI_ID_ACCEPTCONNECTIONASYNCTASK  = !"\001Task____Accept\001"

Type AcceptConnectionAsyncTask As _AcceptConnectionAsyncTask

Type LPAcceptConnectionAsyncTask As _AcceptConnectionAsyncTask Ptr

Declare Function CreateAcceptConnectionAsyncTask( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Sub DestroyAcceptConnectionAsyncTask( _
	ByVal this As AcceptConnectionAsyncTask Ptr _
)

Declare Function AcceptConnectionAsyncTaskQueryInterface( _
	ByVal this As AcceptConnectionAsyncTask Ptr, _
	ByVal riid As REFIID, _
	ByVal ppvObject As Any Ptr Ptr _
)As HRESULT

Declare Function AcceptConnectionAsyncTaskAddRef( _
	ByVal this As AcceptConnectionAsyncTask Ptr _
)As ULONG

Declare Function AcceptConnectionAsyncTaskRelease( _
	ByVal this As AcceptConnectionAsyncTask Ptr _
)As ULONG

Declare Function AcceptConnectionAsyncTaskBeginExecute( _
	ByVal this As AcceptConnectionAsyncTask Ptr, _
	ByVal ppIResult As IAsyncResult Ptr Ptr _
)As HRESULT

Declare Function AcceptConnectionAsyncTaskEndExecute( _
	ByVal this As AcceptConnectionAsyncTask Ptr, _
	ByVal pIResult As IAsyncResult Ptr, _
	ByVal BytesTransferred As DWORD, _
	ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
)As HRESULT

Declare Function AcceptConnectionAsyncTaskGetBaseStream( _
	ByVal this As AcceptConnectionAsyncTask Ptr, _
	ByVal ppStream As IBaseStream Ptr Ptr _
)As HRESULT

Declare Function AcceptConnectionAsyncTaskSetBaseStream( _
	ByVal this As AcceptConnectionAsyncTask Ptr, _
	byVal pStream As IBaseStream Ptr _
)As HRESULT

Declare Function AcceptConnectionAsyncTaskGetHttpReader( _
	ByVal this As AcceptConnectionAsyncTask Ptr, _
	ByVal ppReader As IHttpReader Ptr Ptr _
)As HRESULT

Declare Function AcceptConnectionAsyncTaskSetHttpReader( _
	ByVal this As AcceptConnectionAsyncTask Ptr, _
	byVal pReader As IHttpReader Ptr _
)As HRESULT

Declare Function AcceptConnectionAsyncTaskSetWebSiteCollectionWeakPtr( _
	ByVal this As AcceptConnectionAsyncTask Ptr, _
	byVal pCollection As IWebSiteCollection Ptr _
)As HRESULT

Declare Function AcceptConnectionAsyncTaskGetListenSocket( _
	ByVal this As AcceptConnectionAsyncTask Ptr, _
	ByVal pListenSocket As SOCKET Ptr _
)As HRESULT

Declare Function AcceptConnectionAsyncTaskSetListenSocket( _
	ByVal this As AcceptConnectionAsyncTask Ptr, _
	ByVal ListenSocket As SOCKET _
)As HRESULT

#endif
