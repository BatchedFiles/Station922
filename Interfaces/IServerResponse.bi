#ifndef ISERVERRESPONSE_BI
#define ISERVERRESPONSE_BI

#include once "windows.bi"
#include once "win\ole2.bi"
#include once "Http.bi"
#include once "Mime.bi"

Const MaxResponseBufferLength As Integer = 32 * 1024 - 1

Type IServerResponse As IServerResponse_

Type LPISERVERRESPONSE As IServerResponse Ptr

Extern IID_IServerResponse Alias "IID_IServerResponse" As Const IID

Type IServerResponseVirtualTable
	
	Dim QueryInterface As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	Dim AddRef As Function( _
		ByVal this As IServerResponse Ptr _
	)As ULONG
	
	Dim Release As Function( _
		ByVal this As IServerResponse Ptr _
	)As ULONG
	
	Dim GetHttpVersion As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal pHttpVersion As HttpVersions Ptr _
	)As HRESULT
	
	Dim SetHttpVersion As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal HttpVersion As HttpVersions _
	)As HRESULT
	
	Dim GetStatusCode As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal pStatusCode As HttpStatusCodes Ptr _
	)As HRESULT
	
	Dim SetStatusCode As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal StatusCode As HttpStatusCodes _
	)As HRESULT
	
	Dim GetStatusDescription As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal ppStatusDescription As WString Ptr Ptr _
	)As HRESULT
	
	Dim SetStatusDescription As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal pStatusDescription As WString Ptr _
	)As HRESULT
	
	Dim GetKeepAlive As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal pKeepAlive As Boolean Ptr _
	)As HRESULT
	
	Dim SetKeepAlive As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal KeepAlive As Boolean _
	)As HRESULT
	
	Dim GetSendOnlyHeaders As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal pSendOnlyHeaders As Boolean Ptr _
	)As HRESULT
	
	Dim SetSendOnlyHeaders As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal SendOnlyHeaders As Boolean _
	)As HRESULT
	
	Dim GetMimeType As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal pMimeType As MimeType Ptr _
	)As HRESULT
	
	Dim SetMimeType As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal pMimeType As MimeType Ptr _
	)As HRESULT
	
	Dim GetHttpHeader As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal ppHeader As WString Ptr Ptr _
	)As HRESULT
	
	Dim SetHttpHeader As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal pHeader As WString Ptr _
	)As HRESULT
	
	Dim GetZipEnabled As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal pZipEnabled As Boolean Ptr _
	)As HRESULT
	
	Dim SetZipEnabled As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal ZipEnabled As Boolean _
	)As HRESULT
	
	Dim GetZipMode As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	
	Dim SetZipMode As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal ZipMode As ZipModes _
	)As HRESULT
	
	Dim AddResponseHeader As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal HeaderName As WString Ptr, _
		ByVal Value As WString Ptr _
	)As HRESULT
	
	Dim AddKnownResponseHeader As Function( _
		ByVal this As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As WString Ptr _
	)As HRESULT
	
	Dim Clear As Function( _
		ByVal this As IServerResponse Ptr _
	)As HRESULT
	
End Type

Type IServerResponse_
	Dim lpVtbl As IServerResponseVirtualTable Ptr
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
#define IServerResponse_Clear(this) (this)->lpVtbl->Clear(this)

#endif
