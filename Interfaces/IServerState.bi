#ifndef ISERVERSTATE_BI
#define ISERVERSTATE_BI

#include once "windows.bi"
#include once "win\ole2.bi"
#include once "Http.bi"

Type IServerState As IServerState_

Type LPISERVERSTATE As IServerState Ptr

Extern IID_IServerState Alias "IID_IServerState" As Const IID

Type IServerStateVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IServerState Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IServerState Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IServerState Ptr _
	)As ULONG
	
	GetRequestHeader As Function( _
		ByVal this As IServerState Ptr, _
		ByVal Value As WString Ptr, _
		ByVal BufferLength As Integer, _
		ByVal HeaderIndex As HttpRequestHeaders, _
		ByVal pHeaderLength As Integer Ptr _
	)As HRESULT
	
	GetHttpMethod As Function( _
		ByVal this As IServerState Ptr, _
		ByVal pMethod As HttpMethods Ptr _
	)As HRESULT
	
	GetHttpVersion As Function( _
		ByVal this As IServerState Ptr, _
		ByVal pVersion As HttpVersions Ptr _
	)As HRESULT
	
	SetStatusCode As Function( _
		ByVal this As IServerState Ptr, _
		ByVal Code As Integer _
	)As HRESULT
	
	GetStatusCode As Function( _
		ByVal this As IServerState Ptr, _
		ByVal pStatusCode As Integer Ptr _
	)As HRESULT
	
	SetStatusDescription As Function( _
		ByVal this As IServerState Ptr, _
		ByVal Description As WString Ptr _
	)As HRESULT
	
	GetStatusDescription As Function( _
		ByVal this As IServerState Ptr, _
		ByVal Description As WString Ptr _
	)As HRESULT
	
	SetResponseHeader As Function( _
		ByVal this As IServerState Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As WString Ptr _
	)As HRESULT
	
	WriteData As Function( _
		ByVal this As IServerState Ptr, _
		ByVal Buffer As Any Ptr, _
		ByVal BytesCount As Integer, _
		ByVal pResult As Integer Ptr _
	)As HRESULT
	
	ReadData As Function( _
		ByVal this As IServerState Ptr, _
		ByVal Buffer As Any Ptr, _
		ByVal BufferLength As Integer, _
		ByVal ReadedBytesCount As Integer Ptr, _
		ByVal pResult As Integer Ptr _
	)As HRESULT
	
	GetHtmlSafeString As Function( _
		ByVal this As IServerState Ptr, _
		ByVal Buffer As WString Ptr, _
		ByVal BufferLength As Integer, _
		ByVal HtmlSafe As WString Ptr, _
		ByVal HtmlSafeLength As Integer Ptr, _
		ByVal pResult As Integer Ptr _
	)As HRESULT
	
End Type

Type IServerState_
	lpVtbl As IServerStateVirtualTable Ptr
End Type

#endif
