#ifndef ISERVERRESPONSE_BI
#define ISERVERRESPONSE_BI

#ifndef unicode
#define unicode
#endif
#include "windows.bi"
#include "win\ole2.bi"

#include "Http.bi"
#include "Mime.bi"

Const MaxResponseBufferLength As Integer = 32 * 1024 - 1

Type IServerResponse As IServerResponse_

Type LPISERVERRESPONSE As IServerResponse Ptr

Extern IID_IServerResponse Alias "IID_IServerResponse" As Const IID

Type IServerResponseVirtualTable
	Dim InheritedTable As IUnknownVtbl
	
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
	Dim pVirtualTable As IServerResponseVirtualTable Ptr
End Type

#define IServerResponse_QueryInterface(this, riid, ppv) (this)->pVirtualTable->InheritedTable.QueryInterface(CPtr(IUnknown Ptr, this), riid, ppv)
#define IServerResponse_AddRef(this) (this)->pVirtualTable->InheritedTable.AddRef(CPtr(IUnknown Ptr, this))
#define IServerResponse_Release(this) (this)->pVirtualTable->InheritedTable.Release(CPtr(IUnknown Ptr, this))
#define IServerResponse_GetHttpVersion(this, pHttpVersion) (this)->pVirtualTable->GetHttpVersion(this, pHttpVersion)
#define IServerResponse_SetHttpVersion(this, HttpVersion) (this)->pVirtualTable->SetHttpVersion(this, HttpVersion)
#define IServerResponse_GetStatusCode(this, pStatusCode) (this)->pVirtualTable->GetStatusCode(this, pStatusCode)
#define IServerResponse_SetStatusCode(this, StatusCode) (this)->pVirtualTable->SetStatusCode(this, StatusCode)
#define IServerResponse_GetStatusDescription(this, ppStatusDescription) (this)->pVirtualTable->GetStatusDescription(this, ppStatusDescription)
#define IServerResponse_SetStatusDescription(this, pStatusDescription) (this)->pVirtualTable->SetStatusDescription(this, pStatusDescription)
#define IServerResponse_GetKeepAlive(this, pKeepAlive) (this)->pVirtualTable->GetKeepAlive(this, pKeepAlive)
#define IServerResponse_SetKeepAlive(this, KeepAlive) (this)->pVirtualTable->SetKeepAlive(this, KeepAlive)
#define IServerResponse_GetSendOnlyHeaders(this, pSendOnlyHeaders) (this)->pVirtualTable->GetSendOnlyHeaders(this, pSendOnlyHeaders)
#define IServerResponse_SetSendOnlyHeaders(this, SendOnlyHeaders) (this)->pVirtualTable->SetSendOnlyHeaders(this, SendOnlyHeaders)
#define IServerResponse_GetMimeType(this, pMimeType) (this)->pVirtualTable->GetMimeType(this, pMimeType)
#define IServerResponse_SetMimeType(this, pMimeType) (this)->pVirtualTable->SetMimeType(this, pMimeType)
#define IServerResponse_GetHttpHeader(this, HeaderIndex, ppHeader) (this)->pVirtualTable->GetHttpHeader(this, HeaderIndex, ppHeader)
#define IServerResponse_SetHttpHeader(this, HeaderIndex, pHeader) (this)->pVirtualTable->SetHttpHeader(this, HeaderIndex, pHeader)
#define IServerResponse_GetZipEnabled(this, pZipEnabled) (this)->pVirtualTable->GetZipEnabled(this, pZipEnabled)
#define IServerResponse_SetZipEnabled(this, ZipEnabled) (this)->pVirtualTable->SetZipEnabled(this, ZipEnabled)
#define IServerResponse_GetZipMode(this, pZipMode) (this)->pVirtualTable->GetZipMode(this, pZipMode)
#define IServerResponse_SetZipMode(this, ZipMode) (this)->pVirtualTable->SetZipMode(this, ZipMode)
#define IServerResponse_AddResponseHeader(this, HeaderName, Value) (this)->pVirtualTable->AddResponseHeader(this, HeaderName, Value)
#define IServerResponse_AddKnownResponseHeader(this, HeaderIndex, Value) (this)->pVirtualTable->AddKnownResponseHeader(this, HeaderIndex, Value)
#define IServerResponse_Clear(this) (this)->pVirtualTable->Clear(this)

#endif
