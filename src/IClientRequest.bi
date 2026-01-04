#ifndef ICLIENTREQUEST_BI
#define ICLIENTREQUEST_BI

#include once "IClientUri.bi"
#include once "Http.bi"
#include once "IHttpAsyncReader.bi"

Extern IID_IClientRequest Alias "IID_IClientRequest" As Const IID

' IClientRequest.Parse:
' S_OK, E_FAIL, CLIENTREQUEST_E_...

Enum ByteRangeIsSet
	NotSet
	FirstBytePositionIsSet
	LastBytePositionIsSet
	FirstAndLastPositionIsSet
End Enum

Type ByteRange
	FirstBytePosition As LongInt
	LastBytePosition As LongInt
	IsSet As ByteRangeIsSet
End Type

Type IClientRequest As IClientRequest_

Type IClientRequestVirtualTable

	QueryInterface As Function( _
		ByVal self As IClientRequest Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IClientRequest Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IClientRequest Ptr _
	)As ULONG

	Parse As Function( _
		ByVal self As IClientRequest Ptr, _
		ByVal pIReader As IHttpAsyncReader Ptr, _
		ByVal RequestedLine As HeapBSTR _
	)As HRESULT

	GetHttpMethod As Function( _
		ByVal self As IClientRequest Ptr, _
		ByVal bstrHttpMethod As HeapBSTR Ptr _
	)As HRESULT

	GetUri As Function( _
		ByVal self As IClientRequest Ptr, _
		ByVal ppUri As IClientUri Ptr Ptr _
	)As HRESULT

	GetHttpVersion As Function( _
		ByVal self As IClientRequest Ptr, _
		ByVal pHttpVersion As HttpVersions Ptr _
	)As HRESULT

	GetHttpHeader As Function( _
		ByVal self As IClientRequest Ptr, _
		ByVal HeaderIndex As HttpRequestHeaders, _
		ByVal ppHeader As HeapBSTR Ptr _
	)As HRESULT

	GetKeepAlive As Function( _
		ByVal self As IClientRequest Ptr, _
		ByVal pKeepAlive As Boolean Ptr _
	)As HRESULT

	GetContentLength As Function( _
		ByVal self As IClientRequest Ptr, _
		ByVal pContentLength As LongInt Ptr _
	)As HRESULT

	GetByteRange As Function( _
		ByVal self As IClientRequest Ptr, _
		ByVal pRange As ByteRange Ptr _
	)As HRESULT

	GetZipMode As Function( _
		ByVal self As IClientRequest Ptr, _
		ByVal ZipIndex As ZipModes, _
		ByVal pSupported As Boolean Ptr _
	)As HRESULT

	GetExpect100Continue As Function( _
		ByVal self As IClientRequest Ptr, _
		ByVal pExpect As Boolean Ptr _
	)As HRESULT

End Type

Type IClientRequest_
	lpVtbl As IClientRequestVirtualTable Ptr
End Type

#define IClientRequest_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define IClientRequest_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IClientRequest_Release(self) (self)->lpVtbl->Release(self)
#define IClientRequest_Parse(self, pIReader, RequestedLine) (self)->lpVtbl->Parse(self, pIReader, RequestedLine)
#define IClientRequest_GetHttpMethod(self, pHttpMethod) (self)->lpVtbl->GetHttpMethod(self, pHttpMethod)
#define IClientRequest_GetUri(self, pUri) (self)->lpVtbl->GetUri(self, pUri)
#define IClientRequest_GetHttpVersion(self, pHttpVersions) (self)->lpVtbl->GetHttpVersion(self, pHttpVersions)
#define IClientRequest_GetHttpHeader(self, HeaderIndex, ppHeader) (self)->lpVtbl->GetHttpHeader(self, HeaderIndex, ppHeader)
#define IClientRequest_GetKeepAlive(self, pKeepAlive) (self)->lpVtbl->GetKeepAlive(self, pKeepAlive)
#define IClientRequest_GetContentLength(self, pContentLength) (self)->lpVtbl->GetContentLength(self, pContentLength)
#define IClientRequest_GetByteRange(self, pRange) (self)->lpVtbl->GetByteRange(self, pRange)
#define IClientRequest_GetZipMode(self, ZipIndex, pSupported) (self)->lpVtbl->GetZipMode(self, ZipIndex, pSupported)
#define IClientRequest_GetExpect100Continue(self, pExpect) (self)->lpVtbl->GetExpect100Continue(self, pExpect)

#endif
