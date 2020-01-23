#ifndef ICLIENTREQUEST_BI
#define ICLIENTREQUEST_BI

#include "Http.bi"
#include "IHttpReader.bi"
#include "Station922Uri.bi"

Const MaxRequestBufferLength As Integer = 32 * 1024 - 1

Const CLIENTREQUEST_E_SOCKETERROR As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, 1)
Const CLIENTREQUEST_E_EMPTYREQUEST As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, 2)
Const CLIENTREQUEST_E_HTTPVERSIONNOTSUPPORTED As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, 3)
Const CLIENTREQUEST_E_BADHOST As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, 4)
Const CLIENTREQUEST_E_BADREQUEST As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, 5)
Const CLIENTREQUEST_E_BADPATH As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, 6)
Const CLIENTREQUEST_E_URITOOLARGE As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, 7)
Const CLIENTREQUEST_E_HEADERFIELDSTOOLARGE As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, 8)
Const CLIENTREQUEST_E_HTTPMETHODNOTSUPPORTED As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, 9)

Enum ByteRangeIsSet
	NotSet
	FirstBytePositionIsSet
	LastBytePositionIsSet
	FirstAndLastPositionIsSet
End Enum

Type ByteRange
	Dim IsSet As ByteRangeIsSet
	Dim FirstBytePosition As LongInt
	Dim LastBytePosition As LongInt
End Type

Type IClientRequest As IClientRequest_

Type LPICLIENTREQUEST As IClientRequest Ptr

Extern IID_IClientRequest Alias "IID_IClientRequest" As Const IID

Type IClientRequestVirtualTable
	Dim InheritedTable As IUnknownVtbl
	
	Dim ReadRequest As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal pIReader As IHttpReader Ptr _
	)As HRESULT
	
	Dim GetHttpMethod As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal pHttpMethod As HttpMethods Ptr _
	)As HRESULT
	
	' TODO Возвращать интерфейс IClientUri
	Dim GetUri As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal pUri As Station922Uri Ptr _
	)As HRESULT
	
	Dim GetHttpVersion As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal pHttpVersions As HttpVersions Ptr _
	)As HRESULT
	
	Dim GetHttpHeader As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal HeaderIndex As HttpRequestHeaders, _
		ByVal ppHeader As WString Ptr Ptr _
	)As HRESULT
	
	Dim GetKeepAlive As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal pKeepAlive As Boolean Ptr _
	)As HRESULT
	
	Dim GetContentLength As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal pContentLength As LongInt Ptr _
	)As HRESULT
	
	Dim GetByteRange As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal pRange As ByteRange Ptr _
	)As HRESULT
	
	Dim GetZipMode As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal ZipIndex As ZipModes, _
		ByVal pSupported As Boolean Ptr _
	)As HRESULT
	
	Dim Clear As Function( _
		ByVal this As IClientRequest Ptr _
	)As HRESULT
	
End Type

Type IClientRequest_
	Dim pVirtualTable As IClientRequestVirtualTable Ptr
End Type

#define IClientRequest_QueryInterface(this, riid, ppv) (this)->pVirtualTable->InheritedTable.QueryInterface(CPtr(IUnknown Ptr, this), riid, ppv)
#define IClientRequest_AddRef(this) (this)->pVirtualTable->InheritedTable.AddRef(CPtr(IUnknown Ptr, this))
#define IClientRequest_Release(this) (this)->pVirtualTable->InheritedTable.Release(CPtr(IUnknown Ptr, this))
#define IClientRequest_ReadRequest(this, pIReader) (this)->pVirtualTable->ReadRequest(this, pIReader)
#define IClientRequest_GetHttpMethod(this, pHttpMethod) (this)->pVirtualTable->GetHttpMethod(this, pHttpMethod)
#define IClientRequest_GetUri(this, pUri) (this)->pVirtualTable->GetUri(this, pUri)
#define IClientRequest_GetHttpVersion(this, pHttpVersions) (this)->pVirtualTable->GetHttpVersion(this, pHttpVersions)
#define IClientRequest_GetHttpHeader(this, HeaderIndex, ppHeader) (this)->pVirtualTable->GetHttpHeader(this, HeaderIndex, ppHeader)
#define IClientRequest_GetKeepAlive(this, pKeepAlive) (this)->pVirtualTable->GetKeepAlive(this, pKeepAlive)
#define IClientRequest_GetContentLength(this, pContentLength) (this)->pVirtualTable->GetContentLength(this, pContentLength)
#define IClientRequest_GetByteRange(this, pRange) (this)->pVirtualTable->GetByteRange(this, pRange)
#define IClientRequest_GetZipMode(this, ZipIndex, pSupported) (this)->pVirtualTable->GetZipMode(this, ZipIndex, pSupported)
#define IClientRequest_Clear(this) (this)->pVirtualTable->Clear(this)

#endif
