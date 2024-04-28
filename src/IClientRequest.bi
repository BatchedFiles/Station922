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
		ByVal this As IClientRequest Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IClientRequest Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IClientRequest Ptr _
	)As ULONG
	
	Parse As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal pIReader As IHttpAsyncReader Ptr, _
		ByVal RequestedLine As HeapBSTR _
	)As HRESULT
	
	GetHttpMethod As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal bstrHttpMethod As HeapBSTR Ptr _
	)As HRESULT
	
	GetUri As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal ppUri As IClientUri Ptr Ptr _
	)As HRESULT
	
	GetHttpVersion As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal pHttpVersion As HttpVersions Ptr _
	)As HRESULT
	
	GetHttpHeader As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal HeaderIndex As HttpRequestHeaders, _
		ByVal ppHeader As HeapBSTR Ptr _
	)As HRESULT
	
	GetKeepAlive As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal pKeepAlive As Boolean Ptr _
	)As HRESULT
	
	GetContentLength As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal pContentLength As LongInt Ptr _
	)As HRESULT
	
	GetByteRange As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal pRange As ByteRange Ptr _
	)As HRESULT
	
	GetZipMode As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal ZipIndex As ZipModes, _
		ByVal pSupported As Boolean Ptr _
	)As HRESULT
	
	GetExpect100Continue As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal pExpect As Boolean Ptr _
	)As HRESULT
	
End Type

Type IClientRequest_
	lpVtbl As IClientRequestVirtualTable Ptr
End Type

#define IClientRequest_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IClientRequest_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IClientRequest_Release(this) (this)->lpVtbl->Release(this)
#define IClientRequest_Parse(this, pIReader, RequestedLine) (this)->lpVtbl->Parse(this, pIReader, RequestedLine)
#define IClientRequest_GetHttpMethod(this, pHttpMethod) (this)->lpVtbl->GetHttpMethod(this, pHttpMethod)
#define IClientRequest_GetUri(this, pUri) (this)->lpVtbl->GetUri(this, pUri)
#define IClientRequest_GetHttpVersion(this, pHttpVersions) (this)->lpVtbl->GetHttpVersion(this, pHttpVersions)
#define IClientRequest_GetHttpHeader(this, HeaderIndex, ppHeader) (this)->lpVtbl->GetHttpHeader(this, HeaderIndex, ppHeader)
#define IClientRequest_GetKeepAlive(this, pKeepAlive) (this)->lpVtbl->GetKeepAlive(this, pKeepAlive)
#define IClientRequest_GetContentLength(this, pContentLength) (this)->lpVtbl->GetContentLength(this, pContentLength)
#define IClientRequest_GetByteRange(this, pRange) (this)->lpVtbl->GetByteRange(this, pRange)
#define IClientRequest_GetZipMode(this, ZipIndex, pSupported) (this)->lpVtbl->GetZipMode(this, ZipIndex, pSupported)
#define IClientRequest_GetExpect100Continue(this, pExpect) (this)->lpVtbl->GetExpect100Continue(this, pExpect)

#endif
