#include "ProcessWebSocketRequest.bi"
#include "HttpConst.bi"
#include "WebUtils.bi"

Function ProcessWebSocketRequest( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pResponse As WebResponse Ptr, _
		ByVal pINetworkStream As INetworkStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr, _
		ByVal pIClientReader As IHttpReader Ptr, _
		ByVal pIRequestedFile As IRequestedFile Ptr _
	)As Boolean
	
	pResponse->ResponseHeaders(HttpResponseHeaders.HeaderConnection) = @UpgradeString
	pResponse->ResponseHeaders(HttpResponseHeaders.HeaderSecWebSocketProtocol) = @"chat"
	pResponse->ResponseHeaders(HttpResponseHeaders.HeaderUpgrade) = @WebSocketString
	
	Dim pHeaderSecWebSocketKey As WString Ptr = Any
	IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderSecWebSocketKey, @pHeaderSecWebSocketKey)
	
	Dim wHeaderSecWebSocketAccept As WString * (127 + 1) = Any
	lstrcpyn(@wHeaderSecWebSocketAccept, pHeaderSecWebSocketKey, 25)
	lstrcpy(@wHeaderSecWebSocketAccept[24], @WebSocketGuidString)
	
	Dim Sha1Base64 As WString * (127 + 1) = Any
	GetBase64Sha1(@Sha1Base64, @wHeaderSecWebSocketAccept)
	
	pResponse->ResponseHeaders(HttpResponseHeaders.HeaderSecWebSocketAccept) = @Sha1Base64
	
	pResponse->StatusCode = HttpStatusCodes.SwitchingProtocols
	
	Dim SendBuffer As ZString * (WebResponse.MaxResponseHeaderBuffer + 1) = Any
	Dim WritedBytes As Integer = Any
	
	Dim hr As HRESULT = INetworkStream_Write(pINetworkStream, _
		@SendBuffer, 0, AllResponseHeadersToBytes(pIRequest, pResponse, @SendBuffer, 0), @WritedBytes _
	)
	
	Dim ReceiveBuffer As ZString * (4095 + 1) = Any
	Dim ReadedBytes As Integer = Any
	
	hr = INetworkStream_Read(pINetworkStream, _
		@ReceiveBuffer, 0, 4095, @ReadedBytes _
	)
	Print "Прочитал", ReadedBytes
	
	For i As Integer = 0 To ReadedBytes - 1
		Print Bin(ReceiveBuffer[i]),
	Next
	
	Sleep_(INFINITE)
	
	If FAILED(hr) Then
		Return False
	End If
	
	Return True
	
End Function
