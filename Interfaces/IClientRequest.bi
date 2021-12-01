#ifndef ICLIENTREQUEST_BI
#define ICLIENTREQUEST_BI

#include once "Http.bi"
#include once "IHttpReader.bi"
#include once "IClientUri.bi"

Const MaxRequestBufferLength As Integer = 32 * 1024 - 1

' IClientRequest.ReadRequest:
' S_OK — readed successful
' S_FALSE — client closed connection (received 0 bytes)
' E_FAIL — readed error

' IClientRequest.BeginReadRequest:
' CLIENTREQUEST_S_IO_PENDING — read request add in queue
' Any E_FAIL — error
Const CLIENTREQUEST_S_IO_PENDING As HRESULT = MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0201)

' IClientRequest.EndReadRequest:
' S_OK — readed successful
' S_FALSE — client closed connection (received 0 bytes)
' CLIENTREQUEST_S_IO_PENDING — read request add in queue
' E_FAIL — readed error
Const CLIENTREQUEST_E_HEADERFIELDSTOOLARGE As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0208)
Const CLIENTREQUEST_E_SOCKETERROR As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0201)
Const CLIENTREQUEST_E_EMPTYREQUEST As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0202)

' IClientRequest.Prepare:
' S_OK, E_FAIL, CLIENTREQUEST_E_...
Const CLIENTREQUEST_E_HTTPVERSIONNOTSUPPORTED As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0203)
Const CLIENTREQUEST_E_BADHOST As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0204)
Const CLIENTREQUEST_E_BADREQUEST As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0205)
Const CLIENTREQUEST_E_BADPATH As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0206)
Const CLIENTREQUEST_E_URITOOLARGE As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0207)
Const CLIENTREQUEST_E_HTTPMETHODNOTSUPPORTED As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0209)

Enum ByteRangeIsSet
	NotSet
	FirstBytePositionIsSet
	LastBytePositionIsSet
	FirstAndLastPositionIsSet
End Enum

Type ByteRange
	IsSet As ByteRangeIsSet
	FirstBytePosition As LongInt
	LastBytePosition As LongInt
End Type

Type IClientRequest As IClientRequest_

Type LPICLIENTREQUEST As IClientRequest Ptr

Extern IID_IClientRequest Alias "IID_IClientRequest" As Const IID

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
	
	ReadRequest As Function( _
		ByVal this As IClientRequest Ptr _
	)As HRESULT
	
	BeginReadRequest As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndReadRequest As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	
	Prepare As Function( _
		ByVal this As IClientRequest Ptr _
	)As HRESULT
	
	GetHttpMethod As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal pHttpMethod As HttpMethods Ptr _
	)As HRESULT
	
	GetUri As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal ppUri As IClientUri Ptr Ptr _
	)As HRESULT
	
	GetHttpVersion As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal pHttpVersions As HttpVersions Ptr _
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
	
	GetTextReader As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal ppIReader As ITextReader Ptr Ptr _
	)As HRESULT
	
	SetTextReader As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal pIReader As ITextReader Ptr _
	)As HRESULT
	
End Type

Type IClientRequest_
	lpVtbl As IClientRequestVirtualTable Ptr
End Type

#define IClientRequest_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IClientRequest_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IClientRequest_Release(this) (this)->lpVtbl->Release(this)
' #define IClientRequest_ReadRequest(this) (this)->lpVtbl->ReadRequest(this)
#define IClientRequest_BeginReadRequest(this, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginReadRequest(this, StateObject, ppIAsyncResult)
#define IClientRequest_EndReadRequest(this, pIAsyncResult) (this)->lpVtbl->EndReadRequest(this, pIAsyncResult)
#define IClientRequest_Prepare(this) (this)->lpVtbl->Prepare(this)
#define IClientRequest_GetHttpMethod(this, pHttpMethod) (this)->lpVtbl->GetHttpMethod(this, pHttpMethod)
#define IClientRequest_GetUri(this, pUri) (this)->lpVtbl->GetUri(this, pUri)
#define IClientRequest_GetHttpVersion(this, pHttpVersions) (this)->lpVtbl->GetHttpVersion(this, pHttpVersions)
#define IClientRequest_GetHttpHeader(this, HeaderIndex, ppHeader) (this)->lpVtbl->GetHttpHeader(this, HeaderIndex, ppHeader)
#define IClientRequest_GetKeepAlive(this, pKeepAlive) (this)->lpVtbl->GetKeepAlive(this, pKeepAlive)
#define IClientRequest_GetContentLength(this, pContentLength) (this)->lpVtbl->GetContentLength(this, pContentLength)
#define IClientRequest_GetByteRange(this, pRange) (this)->lpVtbl->GetByteRange(this, pRange)
#define IClientRequest_GetZipMode(this, ZipIndex, pSupported) (this)->lpVtbl->GetZipMode(this, ZipIndex, pSupported)
#define IClientRequest_Clear(this) (this)->lpVtbl->Clear(this)
#define IClientRequest_GetTextReader(this, ppIReader) (this)->lpVtbl->GetTextReader(this, ppIReader)
#define IClientRequest_SetTextReader(this, pIReader) (this)->lpVtbl->SetTextReader(this, pIReader)

#endif
