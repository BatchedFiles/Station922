#ifndef IWEBSITE_BI
#define IWEBSITE_BI

#include once "IAttributedStream.bi"
#include once "IClientRequest.bi"
#include once "IString.bi"

Extern IID_IWebSite Alias "IID_IWebSite" As Const IID

' GetBuffer:
' S_OK, WEBSITE_S_CREATE_NEW, WEBSITE_S_ALREADY_EXISTS
' Any Error

Enum ContentNegotiationFlags
	None = 0
	AcceptEncoding = 1
	AcceptMime = 2
	AcceptCharset = 4
	AcceptLanguage = 8
	UserAgent = 16
End Enum

Type IWebSite As IWebSite_

Type IWebSiteVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IWebSite Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IWebSite Ptr _
	)As ULONG
	
	GetHostName As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal ppHost As HeapBSTR Ptr _
	)As HRESULT
	
	GetSitePhysicalDirectory As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal ppPhysicalDirectory As HeapBSTR Ptr _
	)As HRESULT
	
	GetVirtualPath As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal ppVirtualPath As HeapBSTR Ptr _
	)As HRESULT
	
	GetIsMoved As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal pIsMoved As Boolean Ptr _
	)As HRESULT
	
	GetMovedUrl As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal ppMovedUrl As HeapBSTR Ptr _
	)As HRESULT
	
	GetBuffer As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal pIMalloc As IMalloc Ptr, _
		ByVal fAccess As FileAccess, _
		ByVal pRequest As IClientRequest Ptr, _
		ByVal BufferLength As LongInt, _
		ByVal pFlags As ContentNegotiationFlags Ptr, _
		ByVal ppResult As IAttributedStream Ptr Ptr _
	)As HRESULT
	
	GetErrorBuffer As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal pIMalloc As IMalloc Ptr, _
		ByVal HttpError As ResponseErrorCode, _
		ByVal hrErrorCode As HRESULT, _
		ByVal StatusCode As HttpStatusCodes, _
		ByVal ppResult As IAttributedStream Ptr Ptr _
	)As HRESULT
	
	SetHostName As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal pHost As HeapBSTR _
	)As HRESULT
	
	SetSitePhysicalDirectory As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal pPhysicalDirectory As HeapBSTR _
	)As HRESULT
	
	SetVirtualPath As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal pVirtualPath As HeapBSTR _
	)As HRESULT
	
	SetIsMoved As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal IsMoved As Boolean _
	)As HRESULT
	
	SetMovedUrl As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal pMovedUrl As HeapBSTR _
	)As HRESULT
	
	SetTextFileEncoding As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal CodePage As HeapBSTR _
	)As HRESULT
	
	NeedCgiProcessing As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal Path As HeapBSTR, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
End Type

Type IWebSite_
	lpVtbl As IWebSiteVirtualTable Ptr
End Type

#define IWebSite_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IWebSite_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IWebSite_Release(this) (this)->lpVtbl->Release(this)
#define IWebSite_GetHostName(this, ppHost) (this)->lpVtbl->GetHostName(this, ppHost)
#define IWebSite_GetSitePhysicalDirectory(this, ppPhysicalDirectory) (this)->lpVtbl->GetSitePhysicalDirectory(this, ppPhysicalDirectory)
#define IWebSite_GetVirtualPath(this, ppVirtualPath) (this)->lpVtbl->GetVirtualPath(this, ppVirtualPath)
#define IWebSite_GetIsMoved(this, pIsMoved) (this)->lpVtbl->GetIsMoved(this, pIsMoved)
#define IWebSite_GetMovedUrl(this, ppMovedUrl) (this)->lpVtbl->GetMovedUrl(this, ppMovedUrl)
#define IWebSite_GetBuffer(this, pIMalloc, fAccess, pRequest, BufferLength, pFlags, ppResult) (this)->lpVtbl->GetBuffer(this, pIMalloc, fAccess, pRequest, BufferLength, pFlags, ppResult)
#define IWebSite_GetErrorBuffer(this, pIMalloc, HttpError, hrErrorCode, StatusCode, ppResult) (this)->lpVtbl->GetErrorBuffer(this, pIMalloc, HttpError, hrErrorCode, StatusCode, ppResult)
#define IWebSite_SetHostName(this, pHost) (this)->lpVtbl->SetHostName(this, pHost)
#define IWebSite_SetSitePhysicalDirectory(this, pPhysicalDirectory) (this)->lpVtbl->SetSitePhysicalDirectory(this, pPhysicalDirectory)
#define IWebSite_SetVirtualPath(this, pVirtualPath) (this)->lpVtbl->SetVirtualPath(this, pVirtualPath)
#define IWebSite_SetIsMoved(this, IsMoved) (this)->lpVtbl->SetIsMoved(this, IsMoved)
#define IWebSite_SetMovedUrl(this, pMovedUrl) (this)->lpVtbl->SetMovedUrl(this, pMovedUrl)
#define IWebSite_SetTextFileEncoding(this, CodePage) (this)->lpVtbl->SetTextFileEncoding(this, CodePage)
#define IWebSite_NeedCgiProcessing(this, Path, pResult) (this)->lpVtbl->NeedCgiProcessing(this, Path, pResult)

#endif
