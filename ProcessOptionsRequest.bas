#include "ProcessOptionsRequest.bi"
#include "WebUtils.bi"

Function ProcessOptionsRequest( _
		ByVal pRequest As WebRequest Ptr, _
		ByVal pResponse As WebResponse Ptr, _
		ByVal pINetworkStream As INetworkStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr, _
		ByVal pClientReader As StreamSocketReader Ptr, _
		ByVal pIRequestedFile As IRequestedFile Ptr _
	)As Boolean
	
	' Если звёздочка, то ко всему серверу
	If lstrcmp(pRequest->ClientURI.Url, "*") = 0 Then
		pResponse->ResponseHeaders(HttpResponseHeaders.HeaderAllow) = @AllSupportHttpMethods
	Else
		' К конкретному ресурсу
		
		Dim NeedProcessing As Boolean = Any
		
		IWebSite_NeedCgiProcessing(pIWebSite, pRequest->ClientUri.Path, @NeedProcessing)
		
		If NeedProcessing Then
			pResponse->ResponseHeaders(HttpResponseHeaders.HeaderAllow) = @AllSupportHttpMethodsForScript
		Else
			IWebSite_NeedDllProcessing(pIWebSite, pRequest->ClientUri.Path, @NeedProcessing)
			
			If NeedProcessing Then
				pResponse->ResponseHeaders(HttpResponseHeaders.HeaderAllow) = @AllSupportHttpMethodsForScript
			Else
				pResponse->ResponseHeaders(HttpResponseHeaders.HeaderAllow) = @AllSupportHttpMethodsForFile
			End If
		End If
	End If
	
	pResponse->StatusCode = HttpStatusCodes.NoContent
	
	Dim SendBuffer As ZString * (WebResponse.MaxResponseHeaderBuffer + 1) = Any
	Dim WritedBytes As Integer = Any
	
	Dim hr As HRESULT = INetworkStream_Write(pINetworkStream, _
		@SendBuffer, 0, AllResponseHeadersToBytes(pRequest, pResponse, @SendBuffer, 0), @WritedBytes _
	)
	
	If FAILED(hr) Then
		Return False
	End If
	
	Return True
End Function
