#ifndef IWRITEERRORASYNCTASK_BI
#define IWRITEERRORASYNCTASK_BI

#include once "IAsyncTask.bi"
#include once "IAsyncResult.bi"
#include once "IBaseStream.bi"
#include once "IClientRequest.bi"
#include once "IHttpProcessorCollection.bi"
#include once "IHttpReader.bi"
#include once "IWebSiteCollection.bi"

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

Type IWriteErrorAsyncTask As IWriteErrorAsyncTask_

Type LPIWRITEERRORASYNCTASK As IWriteErrorAsyncTask Ptr

Extern IID_IWriteErrorAsyncTask Alias "IID_IWriteErrorAsyncTask" As Const IID

Type IWriteErrorAsyncTaskVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IWriteErrorAsyncTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IWriteErrorAsyncTask Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IWriteErrorAsyncTask Ptr _
	)As ULONG
	
	BeginExecute As Function( _
		ByVal this As IWriteErrorAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndExecute As Function( _
		ByVal this As IWriteErrorAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal CompletionKey As ULONG_PTR _
	)As HRESULT
	
	GetWebSiteCollection As Function( _
		ByVal this As IWriteErrorAsyncTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	
	SetWebSiteCollection As Function( _
		ByVal this As IWriteErrorAsyncTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	
	GetBaseStream As Function( _
		ByVal this As IWriteErrorAsyncTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	
	SetBaseStream As Function( _
		ByVal this As IWriteErrorAsyncTask Ptr, _
		ByVal pStream As IBaseStream Ptr _
	)As HRESULT
	
	GetHttpReader As Function( _
		ByVal this As IWriteErrorAsyncTask Ptr, _
		ByVal ppIHttpReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	SetHttpReader As Function( _
		ByVal this As IWriteErrorAsyncTask Ptr, _
		ByVal pIHttpReader As IHttpReader Ptr _
	)As HRESULT
	
	GetClientRequest As Function( _
		ByVal this As IWriteErrorAsyncTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	
	SetClientRequest As Function( _
		ByVal this As IWriteErrorAsyncTask Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT
	
	SetErrorCode As Function( _
		ByVal this As IWriteErrorAsyncTask Ptr, _
		ByVal HttpError As ResponseErrorCode, _
		ByVal hrCode As HRESULT _
	)As HRESULT
	
	GetHttpProcessorCollection As Function( _
		ByVal this As IWriteErrorAsyncTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	
	SetHttpProcessorCollection As Function( _
		ByVal this As IWriteErrorAsyncTask Ptr, _
		ByVal pIProcessors As IHttpProcessorCollection Ptr _
	)As HRESULT
	
End Type

Type IWriteErrorAsyncTask_
	lpVtbl As IWriteErrorAsyncTaskVirtualTable Ptr
End Type

#define IWriteErrorAsyncTask_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IWriteErrorAsyncTask_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IWriteErrorAsyncTask_Release(this) (this)->lpVtbl->Release(this)
#define IWriteErrorAsyncTask_BeginExecute(this, pPool, ppIResult) (this)->lpVtbl->BeginExecute(this, pPool, ppIResult)
#define IWriteErrorAsyncTask_EndExecute(this, pPool, pIResult, BytesTransferred, CompletionKey) (this)->lpVtbl->EndExecute(this, pPool, pIResult, BytesTransferred, CompletionKey)
#define IWriteErrorAsyncTask_GetAssociatedWithIOCP(this, pAssociated) (this)->lpVtbl->GetAssociatedWithIOCP(this, pAssociated)
#define IWriteErrorAsyncTask_SetAssociatedWithIOCP(this, Associated) (this)->lpVtbl->SetAssociatedWithIOCP(this, Associated)
#define IWriteErrorAsyncTask_GetWebSiteCollection(this, ppIWebSites) (this)->lpVtbl->GetWebSiteCollection(this, ppIWebSites)
#define IWriteErrorAsyncTask_SetWebSiteCollection(this, pIWebSites) (this)->lpVtbl->SetWebSiteCollection(this, pIWebSites)
#define IWriteErrorAsyncTask_GetBaseStream(this, ppStream) (this)->lpVtbl->GetBaseStream(this, ppStream)
#define IWriteErrorAsyncTask_SetBaseStream(this, pStream) (this)->lpVtbl->SetBaseStream(this, pStream)
#define IWriteErrorAsyncTask_GetHttpReader(this, ppIHttpReader) (this)->lpVtbl->GetHttpReader(this, ppIHttpReader)
#define IWriteErrorAsyncTask_SetHttpReader(this, pIHttpReader) (this)->lpVtbl->SetHttpReader(this, pIHttpReader)
#define IWriteErrorAsyncTask_GetClientRequest(this, ppIRequest) (this)->lpVtbl->GetClientRequest(this, ppIRequest)
#define IWriteErrorAsyncTask_SetClientRequest(this, pIRequest) (this)->lpVtbl->SetClientRequest(this, pIRequest)
#define IWriteErrorAsyncTask_SetErrorCode(this, HttpError, hrCode) (this)->lpVtbl->SetErrorCode(this, HttpError, hrCode)
#define IWriteErrorAsyncTask_GetHttpProcessorCollection(this, ppIProcessors) (this)->lpVtbl->GetHttpProcessorCollection(this, ppIProcessors)
#define IWriteErrorAsyncTask_SetHttpProcessorCollection(this, pIProcessors) (this)->lpVtbl->SetHttpProcessorCollection(this, pIProcessors)

#endif
