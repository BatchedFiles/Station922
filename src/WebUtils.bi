#ifndef WEBUTILS_BI
#define WEBUTILS_BI

#include once "IAsyncIoTask.bi"
#include once "IClientRequest.bi"
#include once "IBaseStream.bi"
#include once "IServerResponse.bi"
#include once "IThreadPool.bi"
#include once "IWriteErrorAsyncIoTask.bi"

Declare Function ConvertSystemDateToHttpDate( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal dt As SYSTEMTIME Ptr _
)As HeapBSTR

Declare Function FindWebSiteWeakPtr( _
	ByVal pIWebSites As IWebSiteCollection Ptr, _
	ByVal pIRequest As IClientRequest Ptr, _
	ByVal ppIWebSiteWeakPtr As IWebSite Ptr Ptr _
)As HRESULT

Declare Function ProcessErrorRequestResponse( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal pIStream As IBaseStream Ptr, _
	ByVal pIHttpReader As IHttpReader Ptr, _
	ByVal pIRequest As IClientRequest Ptr, _
	ByVal pIWebSitesWeakPtr As IWebSiteCollection Ptr, _
	ByVal hrReadError As HRESULT, _
	ByVal ppTask As IWriteErrorAsyncIoTask Ptr Ptr _
)As HRESULT

Declare Function Station922Initialize( _
)As HRESULT

Declare Sub Station922CleanUp()

Declare Function GetThreadPoolWeakPtr()As IThreadPool Ptr

Declare Function WaitAlertableLoop( _
	ByVal hEvent As HANDLE _
)As HRESULT

#endif
