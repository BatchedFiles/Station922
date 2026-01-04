#ifndef IWEBSITE_BI
#define IWEBSITE_BI

Type IWebSite As IWebSite_

#include once "IAttributedAsyncStream.bi"
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
		ByVal self As IWebSite Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IWebSite Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IWebSite Ptr _
	)As ULONG

	GetHostName As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal ppHost As HeapBSTR Ptr _
	)As HRESULT

	GetSitePhysicalDirectory As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal ppPhysicalDirectory As HeapBSTR Ptr _
	)As HRESULT

	GetVirtualPath As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal ppVirtualPath As HeapBSTR Ptr _
	)As HRESULT

	GetIsMoved As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal pIsMoved As Boolean Ptr _
	)As HRESULT

	GetMovedUrl As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal ppMovedUrl As HeapBSTR Ptr _
	)As HRESULT

	GetBuffer As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal pIMalloc As IMalloc Ptr, _
		ByVal pRequest As IClientRequest Ptr, _
		ByVal pIReader As IHttpAsyncReader Ptr, _
		ByVal BufferLength As LongInt, _
		ByVal pFlags As ContentNegotiationFlags Ptr, _
		ByVal fAccess As FileAccess, _
		ByVal ppResult As IAttributedAsyncStream Ptr Ptr _
	)As HRESULT

	GetErrorBuffer As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal pIMalloc As IMalloc Ptr, _
		ByVal HttpError As ResponseErrorCode, _
		ByVal hrErrorCode As HRESULT, _
		ByVal StatusCode As HttpStatusCodes, _
		ByVal ppResult As IAttributedAsyncStream Ptr Ptr _
	)As HRESULT

	GetProcessorCollectionWeakPtr As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal ppResult As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT

	SetHostName As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal pHost As HeapBSTR _
	)As HRESULT

	SetSitePhysicalDirectory As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal pPhysicalDirectory As HeapBSTR _
	)As HRESULT

	SetVirtualPath As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal pVirtualPath As HeapBSTR _
	)As HRESULT

	SetIsMoved As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal IsMoved As Boolean _
	)As HRESULT

	SetMovedUrl As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal pMovedUrl As HeapBSTR _
	)As HRESULT

	SetTextFileEncoding As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal CodePage As HeapBSTR _
	)As HRESULT

	SetUtfBomFileOffset As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal Offset As UInteger _
	)As HRESULT

	SetListenAddress As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal ListenAddress As HeapBSTR _
	)As HRESULT

	SetListenPort As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal ListenPort As HeapBSTR _
	)As HRESULT

	SetConnectBindAddress As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal ConnectBindAddress As HeapBSTR _
	)As HRESULT

	SetConnectBindPort As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal ConnectBindPort As HeapBSTR _
	)As HRESULT

	SetUseSsl As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal UseSsl As Boolean _
	)As HRESULT

	SetDefaultFileName As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal DefaultFileName As HeapBSTR _
	)As HRESULT

	SetReservedFileBytes As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal ReservedFileBytes As UInteger _
	)As HRESULT

	AddHttpProcessor As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal Key As HeapBSTR, _
		ByVal Value As IHttpAsyncProcessor Ptr _
	)As HRESULT

	NeedCgiProcessing As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal Path As HeapBSTR, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT

	SetDirectoryListing As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal DirectoryListing As Boolean _
	)As HRESULT

	SetGetAllFiles As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal bGetAllFiles As Boolean _
	)As HRESULT

	SetAllMethods As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal pMethods As HeapBSTR _
	)As HRESULT

	SetUserName As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal pUserName As HeapBSTR _
	)As HRESULT

	SetPassword As Function( _
		ByVal self As IWebSite Ptr, _
		ByVal pPassword As HeapBSTR _
	)As HRESULT

End Type

Type IWebSite_
	lpVtbl As IWebSiteVirtualTable Ptr
End Type

#define IWebSite_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define IWebSite_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IWebSite_Release(self) (self)->lpVtbl->Release(self)
#define IWebSite_GetHostName(self, ppHost) (self)->lpVtbl->GetHostName(self, ppHost)
#define IWebSite_GetSitePhysicalDirectory(self, ppPhysicalDirectory) (self)->lpVtbl->GetSitePhysicalDirectory(self, ppPhysicalDirectory)
#define IWebSite_GetVirtualPath(self, ppVirtualPath) (self)->lpVtbl->GetVirtualPath(self, ppVirtualPath)
#define IWebSite_GetIsMoved(self, pIsMoved) (self)->lpVtbl->GetIsMoved(self, pIsMoved)
#define IWebSite_GetMovedUrl(self, ppMovedUrl) (self)->lpVtbl->GetMovedUrl(self, ppMovedUrl)
#define IWebSite_GetBuffer(self, pIMalloc, pRequest, pIReader, BufferLength, pFlags, fAccess, ppResult) (self)->lpVtbl->GetBuffer(self, pIMalloc, pRequest, pIReader, BufferLength, pFlags, fAccess, ppResult)
#define IWebSite_GetErrorBuffer(self, pIMalloc, HttpError, hrErrorCode, StatusCode, ppResult) (self)->lpVtbl->GetErrorBuffer(self, pIMalloc, HttpError, hrErrorCode, StatusCode, ppResult)
#define IWebSite_GetProcessorCollectionWeakPtr(self, ppResult) (self)->lpVtbl->GetProcessorCollectionWeakPtr(self, ppResult)
#define IWebSite_SetHostName(self, pHost) (self)->lpVtbl->SetHostName(self, pHost)
#define IWebSite_SetSitePhysicalDirectory(self, pPhysicalDirectory) (self)->lpVtbl->SetSitePhysicalDirectory(self, pPhysicalDirectory)
#define IWebSite_SetVirtualPath(self, pVirtualPath) (self)->lpVtbl->SetVirtualPath(self, pVirtualPath)
#define IWebSite_SetIsMoved(self, IsMoved) (self)->lpVtbl->SetIsMoved(self, IsMoved)
#define IWebSite_SetMovedUrl(self, pMovedUrl) (self)->lpVtbl->SetMovedUrl(self, pMovedUrl)
#define IWebSite_SetTextFileEncoding(self, CodePage) (self)->lpVtbl->SetTextFileEncoding(self, CodePage)
#define IWebSite_SetUtfBomFileOffset(self, Offset) (self)->lpVtbl->SetUtfBomFileOffset(self, Offset)
#define IWebSite_SetListenAddress(self, ListenAddress) (self)->lpVtbl->SetListenAddress(self, ListenAddress)
#define IWebSite_SetListenPort(self, ListenPort) (self)->lpVtbl->SetListenPort(self, ListenPort)
#define IWebSite_SetConnectBindAddress(self, ConnectBindAddress) (self)->lpVtbl->SetConnectBindAddress(self, ConnectBindAddress)
#define IWebSite_SetConnectBindPort(self, ConnectBindPort) (self)->lpVtbl->SetConnectBindPort(self, ConnectBindPort)
#define IWebSite_SetUseSsl(self, UseSsl) (self)->lpVtbl->SetUseSsl(self, UseSsl)
#define IWebSite_SetDefaultFileName(self, DefaultFileName) (self)->lpVtbl->SetDefaultFileName(self, DefaultFileName)
#define IWebSite_SetReservedFileBytes(self, ReservedFileBytes) (self)->lpVtbl->SetReservedFileBytes(self, ReservedFileBytes)
#define IWebSite_AddHttpProcessor(self, Key, Value) (self)->lpVtbl->AddHttpProcessor(self, Key, Value)
#define IWebSite_NeedCgiProcessing(self, Path, pResult) (self)->lpVtbl->NeedCgiProcessing(self, Path, pResult)
#define IWebSite_SetDirectoryListing(self, DirectoryListing) (self)->lpVtbl->SetDirectoryListing(self, DirectoryListing)
#define IWebSite_SetGetAllFiles(self, bGetAllFiles) (self)->lpVtbl->SetGetAllFiles(self, bGetAllFiles)
#define IWebSite_SetAllMethods(self, pMethods) (self)->lpVtbl->SetAllMethods(self, pMethods)
#define IWebSite_SetUserName(self, pUserName) (self)->lpVtbl->SetUserName(self, pUserName)
#define IWebSite_SetPassword(self, pPassword) (self)->lpVtbl->SetPassword(self, pPassword)

#endif
