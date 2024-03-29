#ifndef ISERVERRESPONSE_BI
#define ISERVERRESPONSE_BI

#include once "Http.bi"
#include once "IString.bi"
#include once "Mime.bi"

Extern IID_IServerResponse Alias "IID_IServerResponse" As Const IID

' IServerResponse.Prepare:
' S_OK, E_FAIL

Type IServerResponse As IServerResponse_

Type IServerResponseVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IServerResponse Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IServerResponse Ptr _
	)As ULONG
	
	GetHttpVersion As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal pHttpVersion As HttpVersions Ptr _
	)As HRESULT
	
	SetHttpVersion As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal HttpVersion As HttpVersions _
	)As HRESULT
	
	GetStatusCode As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal pStatusCode As HttpStatusCodes Ptr _
	)As HRESULT
	
	SetStatusCode As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal StatusCode As HttpStatusCodes _
	)As HRESULT
	
	GetStatusDescription As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal ppStatusDescription As HeapBSTR Ptr _
	)As HRESULT
	
	SetStatusDescription As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal pStatusDescription As HeapBSTR _
	)As HRESULT
	
	GetKeepAlive As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal pKeepAlive As Boolean Ptr _
	)As HRESULT
	
	SetKeepAlive As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal KeepAlive As Boolean _
	)As HRESULT
	
	GetSendOnlyHeaders As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal pSendOnlyHeaders As Boolean Ptr _
	)As HRESULT
	
	SetSendOnlyHeaders As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal SendOnlyHeaders As Boolean _
	)As HRESULT
	
	GetMimeType As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal pMimeType As MimeType Ptr _
	)As HRESULT
	
	SetMimeType As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal pMimeType As MimeType Ptr _
	)As HRESULT
	
	GetHttpHeader As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal ppHeader As HeapBSTR Ptr _
	)As HRESULT
	
	SetHttpHeader As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal pHeader As HeapBSTR _
	)As HRESULT
	
	GetZipEnabled As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal pZipEnabled As Boolean Ptr _
	)As HRESULT
	
	SetZipEnabled As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal ZipEnabled As Boolean _
	)As HRESULT
	
	GetZipMode As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	
	SetZipMode As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal ZipMode As ZipModes _
	)As HRESULT
	
	AddResponseHeader As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal HeaderName As HeapBSTR, _
		ByVal Value As HeapBSTR _
	)As HRESULT
	
	AddKnownResponseHeader As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As HeapBSTR _
	)As HRESULT
	
	AddKnownResponseHeaderWstr As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As WString Ptr _
	)As HRESULT
	
	AddKnownResponseHeaderWstrLen As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As WString Ptr, _
		ByVal Length As Integer _
	)As HRESULT
	
	GetByteRange As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal pOffset As LongInt Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT
	
	SetByteRange As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal Offset As LongInt, _
		ByVal Length As LongInt _
	)As HRESULT
	
	AllHeadersToZString As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal ContentLength As LongInt, _
		ByVal ppHeaders As ZString Ptr Ptr, _
		ByVal pHeadersLength As LongInt Ptr _
	)As HRESULT
	
End Type

Type IServerResponse_
	lpVtbl As IServerResponseVirtualTable Ptr
End Type

#define IServerResponse_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IServerResponse_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IServerResponse_Release(this) (this)->lpVtbl->Release(this)
#define IServerResponse_GetHttpVersion(this, pHttpVersion) (this)->lpVtbl->GetHttpVersion(this, pHttpVersion)
#define IServerResponse_SetHttpVersion(this, HttpVersion) (this)->lpVtbl->SetHttpVersion(this, HttpVersion)
#define IServerResponse_GetStatusCode(this, pStatusCode) (this)->lpVtbl->GetStatusCode(this, pStatusCode)
#define IServerResponse_SetStatusCode(this, StatusCode) (this)->lpVtbl->SetStatusCode(this, StatusCode)
' #define IServerResponse_GetStatusDescription(this, ppStatusDescription) (this)->lpVtbl->GetStatusDescription(this, ppStatusDescription)
' #define IServerResponse_SetStatusDescription(this, pStatusDescription) (this)->lpVtbl->SetStatusDescription(this, pStatusDescription)
#define IServerResponse_GetKeepAlive(this, pKeepAlive) (this)->lpVtbl->GetKeepAlive(this, pKeepAlive)
#define IServerResponse_SetKeepAlive(this, KeepAlive) (this)->lpVtbl->SetKeepAlive(this, KeepAlive)
#define IServerResponse_GetSendOnlyHeaders(this, pSendOnlyHeaders) (this)->lpVtbl->GetSendOnlyHeaders(this, pSendOnlyHeaders)
#define IServerResponse_SetSendOnlyHeaders(this, SendOnlyHeaders) (this)->lpVtbl->SetSendOnlyHeaders(this, SendOnlyHeaders)
#define IServerResponse_GetMimeType(this, pMimeType) (this)->lpVtbl->GetMimeType(this, pMimeType)
#define IServerResponse_SetMimeType(this, pMimeType) (this)->lpVtbl->SetMimeType(this, pMimeType)
#define IServerResponse_GetHttpHeader(this, HeaderIndex, ppHeader) (this)->lpVtbl->GetHttpHeader(this, HeaderIndex, ppHeader)
' #define IServerResponse_SetHttpHeader(this, HeaderIndex, pHeader) (this)->lpVtbl->SetHttpHeader(this, HeaderIndex, pHeader)
#define IServerResponse_GetZipEnabled(this, pZipEnabled) (this)->lpVtbl->GetZipEnabled(this, pZipEnabled)
#define IServerResponse_SetZipEnabled(this, ZipEnabled) (this)->lpVtbl->SetZipEnabled(this, ZipEnabled)
#define IServerResponse_GetZipMode(this, pZipMode) (this)->lpVtbl->GetZipMode(this, pZipMode)
#define IServerResponse_SetZipMode(this, ZipMode) (this)->lpVtbl->SetZipMode(this, ZipMode)
#define IServerResponse_AddResponseHeader(this, HeaderName, Value) (this)->lpVtbl->AddResponseHeader(this, HeaderName, Value)
#define IServerResponse_AddKnownResponseHeader(this, HeaderIndex, Value) (this)->lpVtbl->AddKnownResponseHeader(this, HeaderIndex, Value)
#define IServerResponse_AddKnownResponseHeaderWstr(this, HeaderIndex, Value) (this)->lpVtbl->AddKnownResponseHeaderWstr(this, HeaderIndex, Value)
#define IServerResponse_AddKnownResponseHeaderWstrLen(this, HeaderIndex, Value, Length) (this)->lpVtbl->AddKnownResponseHeaderWstrLen(this, HeaderIndex, Value, Length)
#define IServerResponse_GetByteRange(this, pOffset, pLength) (this)->lpVtbl->GetByteRange(this, pOffset, pLength)
#define IServerResponse_SetByteRange(this, Offset, Length) (this)->lpVtbl->SetByteRange(this, Offset, Length)
#define IServerResponse_AllHeadersToZString(this, ContentLength, ppHeaders, pHeadersLength) (this)->lpVtbl->AllHeadersToZString(this, ContentLength, ppHeaders, pHeadersLength)

#endif
