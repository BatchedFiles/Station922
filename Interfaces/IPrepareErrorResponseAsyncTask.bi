#ifndef IPREPAREERRORRESPONSEASYNCTASK_BI
#define IPREPAREERRORRESPONSEASYNCTASK_BI

#include once "IAsyncTask.bi"
#include once "IAsyncResult.bi"
#include once "IBaseStream.bi"
#include once "IClientRequest.bi"
#include once "IHttpReader.bi"
#include once "IWebSiteCollection.bi"
#include once "win\winsock2.bi"

Enum ResponseErrorCode
	MovedPermanently
	BadRequest
	PathNotValid
	HostNotFound
	SiteNotFound
	NeedAuthenticate
	BadAuthenticateParam
	NeedBasicAuthenticate
	EmptyPassword
	BadUserNamePassword
	Forbidden
	FileNotFound
	MethodNotAllowed
	FileGone
	LengthRequired
	RequestEntityTooLarge
	RequestUrlTooLarge
	RequestRangeNotSatisfiable
	RequestHeaderFieldsTooLarge
	InternalServerError
	FileNotAvailable
	CannotCreateChildProcess
	CannotCreatePipe
	NotImplemented
	ContentTypeEmpty
	ContentEncodingNotEmpty
	BadGateway
	NotEnoughMemory
	CannotCreateThread
	GatewayTimeout
	VersionNotSupported
End Enum

Type IPrepareErrorResponseAsyncTask As IPrepareErrorResponseAsyncTask_

Type LPIPREPAREERRORRESPONSEASYNCTASK As IPrepareErrorResponseAsyncTask Ptr

Extern IID_IPrepareErrorResponseAsyncTask Alias "IID_IPrepareErrorResponseAsyncTask" As Const IID

Type IPrepareErrorResponseAsyncTaskVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr _
	)As ULONG
	
	BeginExecute As Function( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndExecute As Function( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal CompletionKey As ULONG_PTR _
	)As HRESULT
	
	GetWebSiteCollection As Function( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	
	SetWebSiteCollection As Function( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	
	GetRemoteAddress As Function( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal pRemoteAddress As SOCKADDR Ptr, _
		ByVal pRemoteAddressLength As Integer Ptr _
	)As HRESULT
	
	SetRemoteAddress As Function( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal RemoteAddress As SOCKADDR Ptr, _
		ByVal RemoteAddressLength As Integer _
	)As HRESULT
	
	GetBaseStream As Function( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	
	SetBaseStream As Function( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal pStream As IBaseStream Ptr _
	)As HRESULT
	
	GetHttpReader As Function( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal ppIHttpReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	SetHttpReader As Function( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal pIHttpReader As IHttpReader Ptr _
	)As HRESULT
	
	GetClientRequest As Function( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	
	SetClientRequest As Function( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT
	
	SetErrorCode As Function( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal HttpError As ResponseErrorCode, _
		ByVal hrCode As HRESULT _
	)As HRESULT
	
End Type

Type IPrepareErrorResponseAsyncTask_
	lpVtbl As IPrepareErrorResponseAsyncTaskVirtualTable Ptr
End Type

#define IPrepareErrorResponseAsyncTask_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IPrepareErrorResponseAsyncTask_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IPrepareErrorResponseAsyncTask_Release(this) (this)->lpVtbl->Release(this)
#define IPrepareErrorResponseAsyncTask_BeginExecute(this, pPool, ppIResult) (this)->lpVtbl->BeginExecute(this, pPool, ppIResult)
#define IPrepareErrorResponseAsyncTask_EndExecute(this, pPool, pIResult, BytesTransferred, CompletionKey) (this)->lpVtbl->EndExecute(this, pPool, pIResult, BytesTransferred, CompletionKey)
#define IPrepareErrorResponseAsyncTask_GetAssociatedWithIOCP(this, pAssociated) (this)->lpVtbl->GetAssociatedWithIOCP(this, pAssociated)
#define IPrepareErrorResponseAsyncTask_SetAssociatedWithIOCP(this, Associated) (this)->lpVtbl->SetAssociatedWithIOCP(this, Associated)
#define IPrepareErrorResponseAsyncTask_GetWebSiteCollection(this, ppIWebSites) (this)->lpVtbl->GetWebSiteCollection(this, ppIWebSite)
#define IPrepareErrorResponseAsyncTask_SetWebSiteCollection(this, pIWebSites) (this)->lpVtbl->SetWebSiteCollection(this, pIWebSite)
#define IPrepareErrorResponseAsyncTask_GetRemoteAddress(this, pRemoteAddress, pRemoteAddressLength) (this)->lpVtbl->GetRemoteAddress(this, pRemoteAddress, pRemoteAddressLength)
#define IPrepareErrorResponseAsyncTask_SetRemoteAddress(this, RemoteAddress, RemoteAddressLength) (this)->lpVtbl->SetRemoteAddress(this, RemoteAddress, RemoteAddressLength)
#define IPrepareErrorResponseAsyncTask_GetBaseStream(this, ppStream) (this)->lpVtbl->GetBaseStream(this, ppStream)
#define IPrepareErrorResponseAsyncTask_SetBaseStream(this, pStream) (this)->lpVtbl->SetBaseStream(this, pStream)
#define IPrepareErrorResponseAsyncTask_GetHttpReader(this, ppIHttpReader) (this)->lpVtbl->GetHttpReader(this, ppIHttpReader)
#define IPrepareErrorResponseAsyncTask_SetHttpReader(this, pIHttpReader) (this)->lpVtbl->SetHttpReader(this, pIHttpReader)
#define IPrepareErrorResponseAsyncTask_GetClientRequest(this, ppIRequest) (this)->lpVtbl->GetClientRequest(this, ppIRequest)
#define IPrepareErrorResponseAsyncTask_SetClientRequest(this, pIRequest) (this)->lpVtbl->SetClientRequest(this, pIRequest)
#define IPrepareErrorResponseAsyncTask_SetErrorCode(this, HttpError, hrCode) (this)->lpVtbl->SetErrorCode(this, HttpError, hrCode)

#endif
