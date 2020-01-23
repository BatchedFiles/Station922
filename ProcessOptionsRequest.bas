#include "ProcessOptionsRequest.bi"
#include "WebUtils.bi"

Function ProcessOptionsRequest( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pINetworkStream As INetworkStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr, _
		ByVal pIClientReader As IHttpReader Ptr, _
		ByVal pIRequestedFile As IRequestedFile Ptr _
	)As Boolean
	
	Dim ClientURI As Station922Uri = Any
	IClientRequest_GetUri(pIRequest, @ClientURI)
	
	' TODO Если звёздочка, то ко всему серверу
	If lstrcmp(ClientURI.pUrl, "*") = 0 Then
		IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderAllow, @AllSupportHttpMethods)
	Else
		' К конкретному ресурсу
		
		Dim NeedProcessing As Boolean = Any
		
		IWebSite_NeedCgiProcessing(pIWebSite, ClientUri.Path, @NeedProcessing)
		
		If NeedProcessing Then
			IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderAllow, @AllSupportHttpMethodsForScript)
		Else
			IWebSite_NeedDllProcessing(pIWebSite, ClientUri.Path, @NeedProcessing)
			
			If NeedProcessing Then
				IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderAllow, @AllSupportHttpMethodsForScript)
			Else
				IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderAllow, @AllSupportHttpMethodsForFile)
			End If
		End If
	End If
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.NoContent)
	
	Dim SendBuffer As ZString * (MaxResponseBufferLength + 1) = Any
	Dim WritedBytes As Integer = Any
	
	Dim hr As HRESULT = INetworkStream_Write(pINetworkStream, _
		@SendBuffer, 0, AllResponseHeadersToBytes(pIRequest, pIResponse, @SendBuffer, 0), @WritedBytes _
	)
	
	If FAILED(hr) Then
		Return False
	End If
	
	Return True
	
End Function
