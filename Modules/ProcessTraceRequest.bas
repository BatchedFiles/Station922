#include "ProcessTraceRequest.bi"
#include "Mime.bi"
#include "WebUtils.bi"
#include "HttpReader.bi"

Function ProcessTraceRequest( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pINetworkStream As INetworkStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr, _
		ByVal pIClientReader As IHttpReader Ptr, _
		ByVal pIRequestedFile As IRequestedFile Ptr _
	)As Boolean
	
	Dim Mime As MimeType = Any
	
	With Mime
		.ContentType = ContentTypes.MessageHttp
		.IsTextFormat = True
		.Charset = DocumentCharsets.ASCII
	End With
	
	IServerResponse_SetMimeType(pIResponse, @Mime)
	
	Dim pRequestedBytes As UByte  Ptr = Any
	Dim RequestedBytesLength As Integer = Any
	
	IHttpReader_GetRequestedBytes(pIClientReader, @RequestedBytesLength, @pRequestedBytes)
	
	Dim SendBuffer As ZString * (MaxResponseBufferLength + HTTPREADER_MAXBUFFER_LENGTH) = Any
	Dim HeadersLength As Integer = AllResponseHeadersToBytes(pIRequest, pIResponse, @SendBuffer, RequestedBytesLength)
	
	RtlCopyMemory(@SendBuffer[HeadersLength], pRequestedBytes, RequestedBytesLength)
	
	Dim WritedBytes As Integer = Any
	Dim hr As HRESULT = INetworkStream_Write(pINetworkStream, _
		@SendBuffer, 0, HeadersLength + RequestedBytesLength, @WritedBytes _
	)
	
	If FAILED(hr) Then
		Return False
	End If
	
	Return True
	
End Function
