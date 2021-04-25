#include once "WriteHttpError.bi"
#include once "IArrayStringWriter.bi"
#include once "CreateInstance.bi"
#include once "HttpConst.bi"
#include once "WebUtils.bi"

Extern CLSID_ARRAYSTRINGWRITER Alias "CLSID_ARRAYSTRINGWRITER" As Const CLSID

' TODO Описания ошибок перевести на эсперанто

' Размер буфера в символах для записи в него кода html страницы с ошибкой
Const MaxHttpErrorBuffer As Integer = 16 * 1024 - 1

Const DefaultContentLanguage = WStr("ru")
Const HttpErrorHead1 = WStr("<!DOCTYPE html><html xmlns=""http://www.w3.org/1999/xhtml""><head><meta name=""viewport"" content=""width=device-width, initial-scale=1"" /><title>")
Const HttpErrorHead2 = WStr("</title></head>")
Const HttpErrorBody1 = WStr("<body><h1>")
Const HttpErrorBody3 = WStr("</h1><h2>HTTP Status Code ")
Const HttpErrorBody4 = WStr(" — ")
Const HttpErrorBody5 = WStr("</h2><p>")
Const HttpErrorBody6 = WStr("</p><p>Visit <a href=""/"">website main page</a>.</p></body></html>")

Const ClientCreatedString = WStr("Resource created")
Const ClientMovedString = WStr("Redirection")
Const ClientErrorString = WStr("Client Error")
Const ServerErrorString = WStr("Server Error")
Const HttpErrorBody2 = WStr(" in application ")

' TODO Исправить для ошибок HttpCreated и HttpCreatedUpdated, которые на самом деле не ошибки
Const HttpCreated201_1 = WStr("Resource created successful.")
Const HttpCreated201_2 = WStr("Resource updated successful.")

Const HttpError400BadRequest = WStr("Bad Request.")
Const HttpError400BadPath = WStr("Bad Path.")
Const HttpError400Host = WStr("Bad Host Header.")
Const HttpError403Forbidden = WStr("Forbidden.")
Const HttpError404FileNotFound = WStr("File Not Found.")
Const HttpError404SiteNotFound = WStr("Website Not Found.")
Const HttpError405NotAllowed = WStr("Method Not Allowed.")
Const HttpError410Gone = WStr("File Gone.")
Const HttpError411LengthRequired = WStr("Length Header Required.")
Const HttpError413RequestEntityTooLarge = WStr("Request Entity Too Large.")
Const HttpError414RequestUrlTooLarge = WStr("Request URL Too Large.")
Const HttpError431RequestRequestHeaderFieldsTooLarge = WStr("Request Header Fields Too Large")

Const HttpError500InternalServerError = WStr("Internal Server Error.")
Const HttpError500FileNotAvailable = WStr("File Not Available.")
Const HttpError500CannotCreateChildProcess = WStr("Can not Create Child Process")
Const HttpError500CannotCreatePipe = WStr("Can not Create Pipe.")
Const HttpError501NotImplemented = WStr("Method Not Implemented.")
Const HttpError501ContentTypeEmpty = WStr("Content-Type Header Empty.")
Const HttpError501ContentEncoding = WStr("Content Encoding is wrong.")
Const HttpError502BadGateway = WStr("Bad GateAway.")
Const HttpError503ThreadError = WStr("Can not create Thread.")
Const HttpError503Memory = WStr("Can not Allocate Memory.")
Const HttpError504GatewayTimeout = WStr("GateAway Timeout")
Const HttpError505VersionNotSupported = WStr("HTTP Version Not Supported.")

Const NeedUsernamePasswordString = WStr("Need Username And Password")
Const NeedUsernamePasswordString1 = WStr("Authorization wrong")
Const NeedUsernamePasswordString2 = WStr("Need Basic Authorization")
Const NeedUsernamePasswordString3 = WStr("Password must not be empty")

Const MovedPermanently = WStr("Moved Permanently.")

Const DefaultHeaderWwwAuthenticate = WStr("Basic realm=""Need username and password""")
Const DefaultHeaderWwwAuthenticate1 = WStr("Basic realm=""Authorization""")
Const DefaultHeaderWwwAuthenticate2 = WStr("Basic realm=""Use Basic auth""")

Declare Sub WriteHttpResponse( _
	ByVal pIRequest As IClientRequest Ptr, _
	ByVal pIResponse As IServerResponse Ptr, _
	ByVal pStream As IBaseStream Ptr, _
	ByVal pIWebSite As IWebSite Ptr, _
	ByVal BodyText As WString Ptr _
)

Declare Sub FormatErrorMessageBody( _
	ByVal pIWriter As IArrayStringWriter Ptr, _
	ByVal StatusCode As HttpStatusCodes, _
	ByVal VirtualPath As WString Ptr, _
	ByVal strMessage As WString Ptr _
)

Sub WriteMovedPermanently( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.MovedPermanently)
	
	Dim buf As WString * (Station922Uri.MaxUrlLength * 2 + 1) = Any
	
	Dim MovedUrl As WString Ptr = Any
	
	IWebSite_GetMovedUrl(pIWebSite, @MovedUrl)
	
	lstrcpyW(@buf, MovedUrl)
	
	Dim ClientURI As Station922Uri = Any
	IClientRequest_GetUri(pIRequest, @ClientURI)
	
	lstrcatW(@buf, ClientURI.pUrl)
	
	IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderLocation, @buf)
	
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @MovedPermanently)
	
End Sub

Sub WriteHttpBadRequest( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.BadRequest)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError400BadRequest)
End Sub

Sub WriteHttpPathNotValid( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.BadRequest)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError400BadPath)
End Sub

Sub WriteHttpHostNotFound( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.BadRequest)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError400Host)
End Sub

Sub WriteHttpSiteNotFound( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.NotFound)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError404SiteNotFound)
End Sub

Sub WriteHttpNeedAuthenticate( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderWwwAuthenticate, @DefaultHeaderWwwAuthenticate)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.Unauthorized)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @NeedUsernamePasswordString)
End Sub

Sub WriteHttpBadAuthenticateParam( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderWwwAuthenticate, @DefaultHeaderWwwAuthenticate1)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.Unauthorized)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @NeedUsernamePasswordString1)
End Sub

Sub WriteHttpNeedBasicAuthenticate( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderWwwAuthenticate, @DefaultHeaderWwwAuthenticate2)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.Unauthorized)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @NeedUsernamePasswordString2)
End Sub

Sub WriteHttpEmptyPassword( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderWwwAuthenticate, @DefaultHeaderWwwAuthenticate)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.Unauthorized)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @NeedUsernamePasswordString3)
End Sub

Sub WriteHttpBadUserNamePassword( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderWwwAuthenticate, @DefaultHeaderWwwAuthenticate)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.Unauthorized)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @NeedUsernamePasswordString)
End Sub

Sub WriteHttpForbidden( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.Forbidden)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError403Forbidden)
End Sub

Sub WriteHttpFileNotFound( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.NotFound)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError404FileNotFound)
End Sub

Sub WriteHttpMethodNotAllowed( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.MethodNotAllowed)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError405NotAllowed)
End Sub

Sub WriteHttpFileGone( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.Gone)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError410Gone)
End Sub

Sub WriteHttpLengthRequired( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.LengthRequired)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError411LengthRequired)
End Sub

Sub WriteHttpRequestEntityTooLarge( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.RequestEntityTooLarge)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError413RequestEntityTooLarge)
End Sub

Sub WriteHttpRequestUrlTooLarge( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.RequestURITooLarge)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError414RequestUrlTooLarge)
End Sub

Sub WriteHttpRequestHeaderFieldsTooLarge( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.RequestHeaderFieldsTooLarge)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError431RequestRequestHeaderFieldsTooLarge)
End Sub

Sub WriteHttpInternalServerError( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.InternalServerError)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError500InternalServerError)
End Sub

Sub WriteHttpFileNotAvailable( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.InternalServerError)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError500FileNotAvailable)
End Sub

Sub WriteHttpCannotCreateChildProcess( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.InternalServerError)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError500CannotCreateChildProcess)
End Sub

Sub WriteHttpCannotCreatePipe( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.InternalServerError)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError500CannotCreatePipe)
End Sub

Sub WriteHttpNotImplemented( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.NotImplemented)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError501NotImplemented)
End Sub

Sub WriteHttpContentTypeEmpty( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.NotImplemented)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError501ContentTypeEmpty)
End Sub

Sub WriteHttpContentEncodingNotEmpty( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.NotImplemented)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError501ContentEncoding)
End Sub

Sub WriteHttpBadGateway( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.BadGateway)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError502BadGateway)
End Sub

Sub WriteHttpNotEnoughMemory( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderRetryAfter, @WStr("Retry-After: 300"))
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.ServiceUnavailable)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError503Memory)
End Sub

Sub WriteHttpCannotCreateThread( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderRetryAfter, @WStr("Retry-After: 300"))
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.ServiceUnavailable)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError503ThreadError)
End Sub

Sub WriteHttpGatewayTimeout( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.GatewayTimeout)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError504GatewayTimeout)
End Sub

Sub WriteHttpVersionNotSupported( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.HTTPVersionNotSupported)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError505VersionNotSupported)
End Sub

Sub WriteHttpCreated( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim StatusCode As HttpStatusCodes = Any
	IServerResponse_GetStatusCode(pIResponse, @StatusCode)
	
	Dim strMessage As WString Ptr = Any
	
	If StatusCode = HttpStatusCodes.Created Then
		strMessage = @HttpCreated201_1
	Else
		strMessage = @HttpCreated201_2
	End If
	
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, strMessage)
	
End Sub

Sub WriteHttpResponse( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr, _
		ByVal BodyText As WString Ptr _
	)
	
	Scope
		Dim Mime As MimeType = Any
		With Mime
			.ContentType = ContentTypes.TextHtml
			.IsTextFormat = True
			.Charset = DocumentCharsets.Utf8BOM
		End With
		IServerResponse_SetMimeType(pIResponse, @Mime)
	End Scope
	
	IServerResponse_SetKeepAlive(pIResponse, False)
	IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderContentLanguage, @DefaultContentLanguage)
	
	Dim pIWriter As IArrayStringWriter Ptr = Any
	Scope
		Dim pIMemoryAllocator As IMalloc Ptr = Any
		Dim hr As HRESULT = CoGetMalloc(1, @pIMemoryAllocator)
		If FAILED(hr) Then
			Exit Sub
		End If
		
		hr = CreateInstance( _
			pIMemoryAllocator, _
			@CLSID_ARRAYSTRINGWRITER, _
			@IID_IArrayStringWriter, _
			@pIWriter _
		)
		If FAILED(hr) Then
			IMalloc_Release(pIMemoryAllocator)
			Exit Sub
		End If
		
		IMalloc_Release(pIMemoryAllocator)
	End Scope
	
	Dim Utf8Body As ZString * (MaxResponseBufferLength + 1) = Any
	Dim ContentBodyLength As Integer = Any
	
	Scope
		Dim BodyBuffer As WString * (MaxHttpErrorBuffer + 1) = Any
		IArrayStringWriter_SetBuffer(pIWriter, @BodyBuffer, MaxHttpErrorBuffer)
		
		Scope
			
			Dim VirtualPath As WString Ptr = Any
			
			If pIWebSite = NULL Then
				VirtualPath = @DefaultVirtualPath
			Else
				IWebSite_GetVirtualPath(pIWebSite, @VirtualPath)
			End If
			
			Dim StatusCode As HttpStatusCodes = Any
			IServerResponse_GetStatusCode(pIResponse, @StatusCode)
			
			FormatErrorMessageBody(pIWriter, StatusCode, VirtualPath, BodyText)
			
		End Scope
		
		ContentBodyLength = WideCharToMultiByte( _
			CP_UTF8, _
			0, _
			@BodyBuffer, _
			-1, _
			@Utf8Body, _
			MaxResponseBufferLength + 1, _
			0, _
			0 _
		) - 1
	End Scope
	IArrayStringWriter_Release(pIWriter)
	
	Dim SendBuffer As ZString * (MaxResponseBufferLength * 2 + 1) = Any
	Dim SendBufferLength As Integer = AllResponseHeadersToBytes(pIRequest, pIResponse, @SendBuffer, ContentBodyLength)
	
	RtlCopyMemory(@SendBuffer + SendBufferLength, @Utf8Body, ContentBodyLength)
	SendBufferLength += ContentBodyLength
	
	Dim BytesWrited As Integer = Any
	IBaseStream_Write(pStream, @SendBuffer, SendBufferLength, @BytesWrited)
	
End Sub

Sub FormatErrorMessageBody( _
		ByVal pIWriter As IArrayStringWriter Ptr, _
		ByVal StatusCode As HttpStatusCodes, _
		ByVal VirtualPath As WString Ptr, _
		ByVal BodyText As WString Ptr _
	)
	
	Dim DescriptionBuffer As WString Ptr = GetStatusDescription(StatusCode, 0)
	
	IArrayStringWriter_WriteString(pIWriter, HttpErrorHead1)
	IArrayStringWriter_WriteString(pIWriter, DescriptionBuffer)
	IArrayStringWriter_WriteString(pIWriter, HttpErrorHead2)
	
	IArrayStringWriter_WriteString(pIWriter, HttpErrorBody1)
	
	' Заголовок <h1>
	Select Case StatusCode
		Case 200 To 299
			IArrayStringWriter_WriteString(pIWriter, ClientCreatedString)
			
		Case 300 To 399
			IArrayStringWriter_WriteString(pIWriter, ClientMovedString)
			
		Case 400 To 499
			IArrayStringWriter_WriteString(pIWriter, ClientErrorString)
			
		Case 500 To 599
			IArrayStringWriter_WriteString(pIWriter, ServerErrorString)
			
	End Select
	
	IArrayStringWriter_WriteString(pIWriter, HttpErrorBody2)
	
	' Имя приложения в заголовке <h1>
	IArrayStringWriter_WriteString(pIWriter, VirtualPath)
	IArrayStringWriter_WriteString(pIWriter, HttpErrorBody3)
	
	' Код статуса в заголовке <h2>
	IArrayStringWriter_WriteInt32(pIWriter, StatusCode)
	IArrayStringWriter_WriteString(pIWriter, HttpErrorBody4)
	
	' Описание ошибки в заголовке <h2>
	IArrayStringWriter_WriteString(pIWriter, DescriptionBuffer)
	IArrayStringWriter_WriteString(pIWriter, HttpErrorBody5)
	
	' Текст сообщения между <p></p>
	IArrayStringWriter_WriteString(pIWriter, BodyText)
	IArrayStringWriter_WriteString(pIWriter, HttpErrorBody6)
	
End Sub
