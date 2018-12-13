#ifndef ICLIENTREQUEST_BI
#define ICLIENTREQUEST_BI

#include "Http.bi"
#include "IHttpReader.bi"
#include "IUri.bi"

' {E998CAB4-5559-409C-93BC-97AFDF6A3921}
Dim Shared IID_ICLIENTREQUEST As IID = Type(&he998cab4, &h5559, &h409c, _
	{&h93, &hbc, &h97, &haf, &hdf, &h6a, &h39, &h21})

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

Type LPICLIENTREQUEST As IClientRequest Ptr

Type IClientRequest As IClientRequest_

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
	
	Dim GetUri As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal pIUri As IUri Ptr Ptr _
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
	
	Dim GetPreloadedContent As Function( _
		ByVal this As IClientRequest Ptr, _
		ByVal pPreloadedContentLength As Integer Ptr, _
		ByVal ppPreloadedContent As UByte Ptr Ptr _
	)As HRESULT
End Type

Type IClientRequest_
	Dim pVirtualTable As IClientRequestVirtualTable Ptr
End Type

#endif
