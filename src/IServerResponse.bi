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
		ByVal self As IServerResponse Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IServerResponse Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IServerResponse Ptr _
	)As ULONG

	GetHttpVersion As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal pHttpVersion As HttpVersions Ptr _
	)As HRESULT

	SetHttpVersion As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal HttpVersion As HttpVersions _
	)As HRESULT

	GetStatusCode As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal pStatusCode As HttpStatusCodes Ptr _
	)As HRESULT

	SetStatusCode As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal StatusCode As HttpStatusCodes _
	)As HRESULT

	GetStatusDescription As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal ppStatusDescription As HeapBSTR Ptr _
	)As HRESULT

	SetStatusDescription As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal pStatusDescription As HeapBSTR _
	)As HRESULT

	GetKeepAlive As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal pKeepAlive As Boolean Ptr _
	)As HRESULT

	SetKeepAlive As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal KeepAlive As Boolean _
	)As HRESULT

	GetSendOnlyHeaders As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal pSendOnlyHeaders As Boolean Ptr _
	)As HRESULT

	SetSendOnlyHeaders As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal SendOnlyHeaders As Boolean _
	)As HRESULT

	GetMimeType As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal pMimeType As MimeType Ptr _
	)As HRESULT

	SetMimeType As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal pMimeType As MimeType Ptr _
	)As HRESULT

	GetHttpHeader As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal ppHeader As HeapBSTR Ptr _
	)As HRESULT

	SetHttpHeader As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal pHeader As HeapBSTR _
	)As HRESULT

	GetZipEnabled As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal pZipEnabled As Boolean Ptr _
	)As HRESULT

	SetZipEnabled As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal ZipEnabled As Boolean _
	)As HRESULT

	GetZipMode As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT

	SetZipMode As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal ZipMode As ZipModes _
	)As HRESULT

	AddResponseHeader As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal HeaderName As HeapBSTR, _
		ByVal Value As HeapBSTR _
	)As HRESULT

	AddKnownResponseHeader As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As HeapBSTR _
	)As HRESULT

	AddKnownResponseHeaderWstr As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As WString Ptr _
	)As HRESULT

	AddKnownResponseHeaderWstrLen As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As WString Ptr, _
		ByVal Length As Integer _
	)As HRESULT

	GetByteRange As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal pOffset As LongInt Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT

	SetByteRange As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal Offset As LongInt, _
		ByVal Length As LongInt _
	)As HRESULT

	AllHeadersToZString As Function( _
		ByVal self As IServerResponse Ptr, _
		ByVal ContentLength As LongInt, _
		ByVal ppHeaders As ZString Ptr Ptr, _
		ByVal pHeadersLength As LongInt Ptr _
	)As HRESULT

End Type

Type IServerResponse_
	lpVtbl As IServerResponseVirtualTable Ptr
End Type

#define IServerResponse_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define IServerResponse_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IServerResponse_Release(self) (self)->lpVtbl->Release(self)
#define IServerResponse_GetHttpVersion(self, pHttpVersion) (self)->lpVtbl->GetHttpVersion(self, pHttpVersion)
#define IServerResponse_SetHttpVersion(self, HttpVersion) (self)->lpVtbl->SetHttpVersion(self, HttpVersion)
#define IServerResponse_GetStatusCode(self, pStatusCode) (self)->lpVtbl->GetStatusCode(self, pStatusCode)
#define IServerResponse_SetStatusCode(self, StatusCode) (self)->lpVtbl->SetStatusCode(self, StatusCode)
' #define IServerResponse_GetStatusDescription(self, ppStatusDescription) (self)->lpVtbl->GetStatusDescription(self, ppStatusDescription)
' #define IServerResponse_SetStatusDescription(self, pStatusDescription) (self)->lpVtbl->SetStatusDescription(self, pStatusDescription)
#define IServerResponse_GetKeepAlive(self, pKeepAlive) (self)->lpVtbl->GetKeepAlive(self, pKeepAlive)
#define IServerResponse_SetKeepAlive(self, KeepAlive) (self)->lpVtbl->SetKeepAlive(self, KeepAlive)
#define IServerResponse_GetSendOnlyHeaders(self, pSendOnlyHeaders) (self)->lpVtbl->GetSendOnlyHeaders(self, pSendOnlyHeaders)
#define IServerResponse_SetSendOnlyHeaders(self, SendOnlyHeaders) (self)->lpVtbl->SetSendOnlyHeaders(self, SendOnlyHeaders)
#define IServerResponse_GetMimeType(self, pMimeType) (self)->lpVtbl->GetMimeType(self, pMimeType)
#define IServerResponse_SetMimeType(self, pMimeType) (self)->lpVtbl->SetMimeType(self, pMimeType)
#define IServerResponse_GetHttpHeader(self, HeaderIndex, ppHeader) (self)->lpVtbl->GetHttpHeader(self, HeaderIndex, ppHeader)
' #define IServerResponse_SetHttpHeader(self, HeaderIndex, pHeader) (self)->lpVtbl->SetHttpHeader(self, HeaderIndex, pHeader)
#define IServerResponse_GetZipEnabled(self, pZipEnabled) (self)->lpVtbl->GetZipEnabled(self, pZipEnabled)
#define IServerResponse_SetZipEnabled(self, ZipEnabled) (self)->lpVtbl->SetZipEnabled(self, ZipEnabled)
#define IServerResponse_GetZipMode(self, pZipMode) (self)->lpVtbl->GetZipMode(self, pZipMode)
#define IServerResponse_SetZipMode(self, ZipMode) (self)->lpVtbl->SetZipMode(self, ZipMode)
#define IServerResponse_AddResponseHeader(self, HeaderName, Value) (self)->lpVtbl->AddResponseHeader(self, HeaderName, Value)
#define IServerResponse_AddKnownResponseHeader(self, HeaderIndex, Value) (self)->lpVtbl->AddKnownResponseHeader(self, HeaderIndex, Value)
#define IServerResponse_AddKnownResponseHeaderWstr(self, HeaderIndex, Value) (self)->lpVtbl->AddKnownResponseHeaderWstr(self, HeaderIndex, Value)
#define IServerResponse_AddKnownResponseHeaderWstrLen(self, HeaderIndex, Value, Length) (self)->lpVtbl->AddKnownResponseHeaderWstrLen(self, HeaderIndex, Value, Length)
#define IServerResponse_GetByteRange(self, pOffset, pLength) (self)->lpVtbl->GetByteRange(self, pOffset, pLength)
#define IServerResponse_SetByteRange(self, Offset, Length) (self)->lpVtbl->SetByteRange(self, Offset, Length)
#define IServerResponse_AllHeadersToZString(self, ContentLength, ppHeaders, pHeadersLength) (self)->lpVtbl->AllHeadersToZString(self, ContentLength, ppHeaders, pHeadersLength)

#endif
