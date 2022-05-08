#ifndef IWRITEERRORASYNCIOTASK_BI
#define IWRITEERRORASYNCIOTASK_BI

#include once "IClientRequest.bi"
#include once "IHttpAsyncIoTask.bi"

' BeginExecute:
' ASYNCTASK_S_IO_PENDING
' Any E_FAIL

' EndExecute:
' S_OK
' S_FALSE
' Any E_FAIL

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

Type IWriteErrorAsyncIoTask As IWriteErrorAsyncIoTask_

Type LPIWRITEERRORASYNCIOTASK As IWriteErrorAsyncIoTask Ptr

Extern IID_IWriteErrorAsyncIoTask Alias "IID_IWriteErrorAsyncIoTask" As Const IID

Type IWriteErrorAsyncIoTaskVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr _
	)As ULONG
	
	BeginExecute As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndExecute As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
	)As HRESULT
	
	GetFileHandle As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal pFileHandle As HANDLE Ptr _
	)As HRESULT
	
	GetWebSiteCollection As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	
	SetWebSiteCollection As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	
	GetBaseStream As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	
	SetBaseStream As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		byVal pStream As IBaseStream Ptr _
	)As HRESULT
	
	GetHttpReader As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	SetHttpReader As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	
	GetHttpProcessorCollection As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	
	SetHttpProcessorCollection As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal pIProcessors As IHttpProcessorCollection Ptr _
	)As HRESULT
	
	GetClientRequest As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	
	SetClientRequest As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT
	
	SetErrorCode As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal HttpError As ResponseErrorCode, _
		ByVal hrCode As HRESULT _
	)As HRESULT
	
	Prepare As Function( _
		ByVal this As IWriteErrorAsyncIoTask Ptr _
	)As HRESULT
	
End Type

Type IWriteErrorAsyncIoTask_
	lpVtbl As IWriteErrorAsyncIoTaskVirtualTable Ptr
End Type

#define IWriteErrorAsyncIoTask_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IWriteErrorAsyncIoTask_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IWriteErrorAsyncIoTask_Release(this) (this)->lpVtbl->Release(this)
#define IWriteErrorAsyncIoTask_BeginExecute(this, ppIResult) (this)->lpVtbl->BeginExecute(this, ppIResult)
#define IWriteErrorAsyncIoTask_EndExecute(this, pIResult, BytesTransferred, ppNextTask) (this)->lpVtbl->EndExecute(this, pIResult, BytesTransferred, ppNextTask)
#define IWriteErrorAsyncIoTask_GetFileHandle(this, pFileHandle) (this)->lpVtbl->GetFileHandle(this, pFileHandle)
#define IWriteErrorAsyncIoTask_GetAssociatedWithIOCP(this, pAssociated) (this)->lpVtbl->GetAssociatedWithIOCP(this, pAssociated)
#define IWriteErrorAsyncIoTask_SetAssociatedWithIOCP(this, Associated) (this)->lpVtbl->SetAssociatedWithIOCP(this, Associated)
#define IWriteErrorAsyncIoTask_GetWebSiteCollection(this, ppIWebSites) (this)->lpVtbl->GetWebSiteCollection(this, ppIWebSites)
#define IWriteErrorAsyncIoTask_SetWebSiteCollection(this, pIWebSites) (this)->lpVtbl->SetWebSiteCollection(this, pIWebSites)
#define IWriteErrorAsyncIoTask_GetBaseStream(this, ppStream) (this)->lpVtbl->GetBaseStream(this, ppStream)
#define IWriteErrorAsyncIoTask_SetBaseStream(this, pStream) (this)->lpVtbl->SetBaseStream(this, pStream)
#define IWriteErrorAsyncIoTask_GetHttpReader(this, ppIHttpReader) (this)->lpVtbl->GetHttpReader(this, ppIHttpReader)
#define IWriteErrorAsyncIoTask_SetHttpReader(this, pIHttpReader) (this)->lpVtbl->SetHttpReader(this, pIHttpReader)
#define IWriteErrorAsyncIoTask_GetHttpProcessorCollection(this, ppIProcessors) (this)->lpVtbl->GetHttpProcessorCollection(this, ppIProcessors)
#define IWriteErrorAsyncIoTask_SetHttpProcessorCollection(this, pIProcessors) (this)->lpVtbl->SetHttpProcessorCollection(this, pIProcessors)
#define IWriteErrorAsyncIoTask_GetClientRequest(this, ppIRequest) (this)->lpVtbl->GetClientRequest(this, ppIRequest)
#define IWriteErrorAsyncIoTask_SetClientRequest(this, pIRequest) (this)->lpVtbl->SetClientRequest(this, pIRequest)
#define IWriteErrorAsyncIoTask_SetErrorCode(this, HttpError, hrCode) (this)->lpVtbl->SetErrorCode(this, HttpError, hrCode)
#define IWriteErrorAsyncIoTask_Prepare(this) (this)->lpVtbl->Prepare(this)

#endif
