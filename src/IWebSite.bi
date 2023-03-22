#ifndef IWEBSITE_BI
#define IWEBSITE_BI

Type IWebSite As IWebSite_

#include once "IAttributedStream.bi"
#include once "IClientRequest.bi"
#include once "IHttpProcessorCollection.bi"
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
		ByVal pIReader As IHttpReader Ptr, _
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
	
	GetProcessorCollectionWeakPtr As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal ppResult As IHttpProcessorCollection Ptr Ptr _
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
	
	SetUtfBomFileOffset As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal Offset As UInteger _
	)As HRESULT
	
	SetListenAddress As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal ListenAddress As HeapBSTR _
	)As HRESULT
	
	SetListenPort As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal ListenPort As HeapBSTR _
	)As HRESULT
	
	SetConnectBindAddress As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal ConnectBindAddress As HeapBSTR _
	)As HRESULT
	
	SetConnectBindPort As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal ConnectBindPort As HeapBSTR _
	)As HRESULT
	
	SetUseSsl As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal UseSsl As Boolean _
	)As HRESULT
	
	SetDefaultFileName As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal DefaultFileName As HeapBSTR _
	)As HRESULT
	
	SetReservedFileBytes As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal ReservedFileBytes As UInteger _
	)As HRESULT
	
	AddHttpProcessor As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal Key As HeapBSTR, _
		ByVal Value As IHttpAsyncProcessor Ptr _
	)As HRESULT
	
	NeedCgiProcessing As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal Path As HeapBSTR, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
	SetDirectoryListing As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal DirectoryListing As Boolean _
	)As HRESULT
	
	SetGetAllFiles As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal bGetAllFiles As Boolean _
	)As HRESULT
	
	SetAllMethods As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal pMethods As HeapBSTR _
	)As HRESULT
	
	SetUserName As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal pUserName As HeapBSTR _
	)As HRESULT
	
	SetPassword As Function( _
		ByVal this As IWebSite Ptr, _
		ByVal pPassword As HeapBSTR _
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
#define IWebSite_GetBuffer(this, pIMalloc, fAccess, pRequest, pIReader, BufferLength, pFlags, ppResult) (this)->lpVtbl->GetBuffer(this, pIMalloc, fAccess, pRequest, pIReader, BufferLength, pFlags, ppResult)
#define IWebSite_GetErrorBuffer(this, pIMalloc, HttpError, hrErrorCode, StatusCode, ppResult) (this)->lpVtbl->GetErrorBuffer(this, pIMalloc, HttpError, hrErrorCode, StatusCode, ppResult)
#define IWebSite_GetProcessorCollectionWeakPtr(this, ppResult) (this)->lpVtbl->GetProcessorCollectionWeakPtr(this, ppResult)
#define IWebSite_SetHostName(this, pHost) (this)->lpVtbl->SetHostName(this, pHost)
#define IWebSite_SetSitePhysicalDirectory(this, pPhysicalDirectory) (this)->lpVtbl->SetSitePhysicalDirectory(this, pPhysicalDirectory)
#define IWebSite_SetVirtualPath(this, pVirtualPath) (this)->lpVtbl->SetVirtualPath(this, pVirtualPath)
#define IWebSite_SetIsMoved(this, IsMoved) (this)->lpVtbl->SetIsMoved(this, IsMoved)
#define IWebSite_SetMovedUrl(this, pMovedUrl) (this)->lpVtbl->SetMovedUrl(this, pMovedUrl)
#define IWebSite_SetTextFileEncoding(this, CodePage) (this)->lpVtbl->SetTextFileEncoding(this, CodePage)
#define IWebSite_SetUtfBomFileOffset(this, Offset) (this)->lpVtbl->SetUtfBomFileOffset(this, Offset)
#define IWebSite_SetListenAddress(this, ListenAddress) (this)->lpVtbl->SetListenAddress(this, ListenAddress)
#define IWebSite_SetListenPort(this, ListenPort) (this)->lpVtbl->SetListenPort(this, ListenPort)
#define IWebSite_SetConnectBindAddress(this, ConnectBindAddress) (this)->lpVtbl->SetConnectBindAddress(this, ConnectBindAddress)
#define IWebSite_SetConnectBindPort(this, ConnectBindPort) (this)->lpVtbl->SetConnectBindPort(this, ConnectBindPort)
#define IWebSite_SetUseSsl(this, UseSsl) (this)->lpVtbl->SetUseSsl(this, UseSsl)
#define IWebSite_SetDefaultFileName(this, DefaultFileName) (this)->lpVtbl->SetDefaultFileName(this, DefaultFileName)
#define IWebSite_SetReservedFileBytes(this, ReservedFileBytes) (this)->lpVtbl->SetReservedFileBytes(this, ReservedFileBytes)
#define IWebSite_AddHttpProcessor(this, Key, Value) (this)->lpVtbl->AddHttpProcessor(this, Key, Value)
#define IWebSite_NeedCgiProcessing(this, Path, pResult) (this)->lpVtbl->NeedCgiProcessing(this, Path, pResult)
#define IWebSite_SetDirectoryListing(this, DirectoryListing) (this)->lpVtbl->SetDirectoryListing(this, DirectoryListing)
#define IWebSite_SetGetAllFiles(this, bGetAllFiles) (this)->lpVtbl->SetGetAllFiles(this, bGetAllFiles)
#define IWebSite_SetAllMethods(this, pMethods) (this)->lpVtbl->SetAllMethods(this, pMethods)
#define IWebSite_SetUserName(this, pUserName) (this)->lpVtbl->SetUserName(this, pUserName)
#define IWebSite_SetPassword(this, pPassword) (this)->lpVtbl->SetPassword(this, pPassword)

#endif
