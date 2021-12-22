#include once "PrepareErrorResponseAsyncTask.bi"
#include once "ArrayStringWriter.bi"
#include once "ReadRequestAsyncTask.bi"
#include once "ClientRequest.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "HeapBSTR.bi"
#include once "Logger.bi"
#include once "ServerResponse.bi"
#include once "WebUtils.bi"

Extern GlobalPrepareErrorResponseAsyncTaskVirtualTable As Const IPrepareErrorResponseAsyncTaskVirtualTable

' Размер буфера в символах для записи в него кода html страницы с ошибкой
Const MaxHttpErrorBuffer As Integer = 16 * 1024 - 1

Const DefaultContentLanguage = WStr("en")
Const DefaultCacheControlNoCache = WStr("no-cache")

Const MovedPermanently = WStr("Moved Permanently.")
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
Const HttpError416RangeNotSatisfiable = WStr("Range Not Satisfiable.")
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

Const DefaultHeaderWwwAuthenticate = WStr("Basic realm=""Need username and password""")
Const DefaultHeaderWwwAuthenticate1 = WStr("Basic realm=""Authorization""")
Const DefaultHeaderWwwAuthenticate2 = WStr("Basic realm=""Use Basic auth""")

Type _PrepareErrorResponseAsyncTask
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IPrepareErrorResponseAsyncTaskVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	pIWebSites As IWebSiteCollection Ptr
	pIProcessors As IHttpProcessorCollection Ptr
	RemoteAddress As SOCKADDR_STORAGE
	RemoteAddressLength As Integer
	pIStream As IBaseStream Ptr
	pIHttpReader As IHttpReader Ptr
	pIRequest As IClientRequest Ptr
	pIResponse As IServerResponse Ptr
	pSendBuffer As ZString Ptr
	HttpError As ResponseErrorCode
	hrCode As HRESULT
End Type

Sub FormatErrorMessageBody( _
		ByVal pIWriter As IArrayStringWriter Ptr, _
		ByVal StatusCode As HttpStatusCodes, _
		ByVal VirtualPath As WString Ptr, _
		ByVal BodyText As WString Ptr, _
		ByVal hrErrorCode As HRESULT _
	)
	
	Const HttpStartHeadTag = WStr("<!DOCTYPE html><html xmlns=""http://www.w3.org/1999/xhtml"" lang=""en"" xml:lang=""en""><head><meta name=""viewport"" content=""width=device-width, initial-scale=1"" />")
	Const HttpStartTitleTag = WStr("<title>")
	Const HttpEndTitleTag = WStr("</title>")
	Const HttpEndHeadTag = WStr("</head>")
	Const HttpStartBodyTag = WStr("<body>")
	Const HttpStartH1Tag = WStr("<h1>")
	Const HttpEndH1Tag = WStr("</h1>")
	
	' 300
	Const ClientMovedString = WStr("Redirection")
	' 400
	Const ClientErrorString = WStr("Client Error")
	' 500
	Const ServerErrorString = WStr("Server Error")
	Const HttpErrorInApplicationString = WStr(" in application ")
	
	Const HttpStartH2Tag = WStr("<h2>")
	Const HttpStatusCodeString = WStr("HTTP Status Code ")
	Const HttpEndH2Tag = WStr("</h2>")
	Const HttpHresultErrorCodeString = WStr("HRESULT Error Code")
	Const HttpStartPTag = WStr("<p>")
	Const HttpEndPTag = WStr("</p>")
	
	'<p>Visit <a href=""/"">website main page</a>.</p>
	
	Const HttpEndBodyTag = WStr("</body></html>")
	
	Dim DescriptionBuffer As WString Ptr = GetStatusDescription(StatusCode, 0)
	
	IArrayStringWriter_WriteString(pIWriter, HttpStartHeadTag)
	IArrayStringWriter_WriteString(pIWriter, HttpStartTitleTag)
	IArrayStringWriter_WriteString(pIWriter, DescriptionBuffer)
	IArrayStringWriter_WriteString(pIWriter, HttpEndTitleTag)
	IArrayStringWriter_WriteString(pIWriter, HttpEndHeadTag)
	
	IArrayStringWriter_WriteString(pIWriter, HttpStartBodyTag)
	IArrayStringWriter_WriteString(pIWriter, HttpStartH1Tag)
	IArrayStringWriter_WriteString(pIWriter, DescriptionBuffer)
	IArrayStringWriter_WriteString(pIWriter, HttpEndH1Tag)
	
	IArrayStringWriter_WriteString(pIWriter, HttpStartPTag)
	Select Case StatusCode
		
		Case 300 To 399
			IArrayStringWriter_WriteString(pIWriter, ClientMovedString)
			
		Case 400 To 499
			IArrayStringWriter_WriteString(pIWriter, ClientErrorString)
			
		Case 500 To 599
			IArrayStringWriter_WriteString(pIWriter, ServerErrorString)
			
	End Select
	
	IArrayStringWriter_WriteString(pIWriter, HttpErrorInApplicationString)
	IArrayStringWriter_WriteString(pIWriter, VirtualPath)
	IArrayStringWriter_WriteString(pIWriter, HttpEndPTag)
	
	
	IArrayStringWriter_WriteString(pIWriter, HttpStartH2Tag)
	IArrayStringWriter_WriteString(pIWriter, HttpStatusCodeString)
	IArrayStringWriter_WriteInt32(pIWriter, StatusCode)
	IArrayStringWriter_WriteString(pIWriter, HttpEndH2Tag)


	IArrayStringWriter_WriteString(pIWriter, HttpStartPTag)
	IArrayStringWriter_WriteString(pIWriter, BodyText)
	IArrayStringWriter_WriteString(pIWriter, HttpEndPTag)
	
	
	IArrayStringWriter_WriteString(pIWriter, HttpStartH2Tag)
	IArrayStringWriter_WriteString(pIWriter, HttpHresultErrorCodeString)
	IArrayStringWriter_WriteString(pIWriter, HttpEndH2Tag)
	
	IArrayStringWriter_WriteString(pIWriter, HttpStartPTag)
	IArrayStringWriter_WriteUInt32(pIWriter, hrErrorCode)
	IArrayStringWriter_WriteString(pIWriter, HttpEndPTag)
	
	Dim wBuffer As WString * 256 = Any
	Dim CharsCount As DWORD = FormatMessageW( _
		FORMAT_MESSAGE_FROM_SYSTEM Or FORMAT_MESSAGE_MAX_WIDTH_MASK, _
		NULL, _
		hrErrorCode, _
		MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_US), _
		@wBuffer, _
		256 - 1, _
		NULL _
	)
	If CharsCount <> 0 Then
		IArrayStringWriter_WriteString(pIWriter, HttpStartPTag)
		IArrayStringWriter_WriteString(pIWriter, wBuffer)
		IArrayStringWriter_WriteString(pIWriter, HttpEndPTag)
	End If
	
	IArrayStringWriter_WriteString(pIWriter, HttpEndBodyTag)
	
End Sub

Sub WriteHttpResponse( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal BodyText As WString Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)
	
	Scope
		Dim Mime As MimeType = Any
		With Mime
			.ContentType = ContentTypes.TextHtml
			.IsTextFormat = True
			.Charset = DocumentCharsets.Utf8BOM
		End With
		IServerResponse_SetMimeType(this->pIResponse, @Mime)
	End Scope
	
	Scope
		IServerResponse_AddKnownResponseHeaderWstrLen( _
			this->pIResponse, _
			HttpResponseHeaders.HeaderContentLanguage, _
			@DefaultContentLanguage, _
			Len(DefaultContentLanguage) _
		)
		IServerResponse_AddKnownResponseHeaderWstrLen( _
			this->pIResponse, _
			HttpResponseHeaders.HeaderCacheControl, _
			@DefaultCacheControlNoCache, _
			Len(DefaultCacheControlNoCache) _
		)
	End Scope
	
	Dim Utf8Body As ZString * (MaxResponseBufferLength + 1) = Any
	Dim ContentBodyLength As Integer = Any
	
	Scope
		Dim pIWriter As IArrayStringWriter Ptr = Any
		Dim hr As HRESULT = CreateInstance( _
			this->pIMemoryAllocator, _
			@CLSID_ARRAYSTRINGWRITER, _
			@IID_IArrayStringWriter, _
			@pIWriter _
		)
		If FAILED(hr) Then
			Exit Sub
		End If
		
		Dim BodyBuffer As WString * (MaxHttpErrorBuffer + 1) = Any
		IArrayStringWriter_SetBuffer(pIWriter, @BodyBuffer, MaxHttpErrorBuffer)
		
		Scope
			
			Dim VirtualPath As WString Ptr = Any
			' If this->pIWebSites = NULL Then
				VirtualPath = @WStr("/")
			' Else
				' IWebSite_GetVirtualPath(this->pIWebSite, @VirtualPath)
			' End If
			
			Dim StatusCode As HttpStatusCodes = Any
			IServerResponse_GetStatusCode(this->pIResponse, @StatusCode)
			
			FormatErrorMessageBody( _
				pIWriter, _
				StatusCode, _
				VirtualPath, _
				BodyText, _
				this->hrCode _
			)
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
		
		IArrayStringWriter_Release(pIWriter)
	End Scope
	
	Scope
		Dim SendBuffer As ZString * (MaxResponseBufferLength * 2 + 1) = Any
		Dim HeadersBufferLength As Integer = AllResponseHeadersToBytes( _
			this->pIRequest, _
			this->pIResponse, _
			@SendBuffer, _
			ContentBodyLength _
		)
		
		Dim SendBufferLength As Integer = HeadersBufferLength + ContentBodyLength
		
		this->pSendBuffer = IMalloc_Alloc( _
			this->pIMemoryAllocator, _
			SendBufferLength _
		)
		
		If this->pSendBuffer <> NULL Then
			
			CopyMemory( _
				@SendBuffer[HeadersBufferLength], _
				@Utf8Body, _
				ContentBodyLength _
			)
			
			CopyMemory( _
				this->pSendBuffer, _
				@SendBuffer[0], _
				SendBufferLength _
			)
			
			IBaseStream_BeginWrite( _
				this->pIStream, _
				this->pSendBuffer, _
				Cast(DWORD, SendBufferLength), _
				NULL, _
				CPtr(IUnknown Ptr, @this->lpVtbl), _
				ppIResult _
			)
			
		End If
	End Scope
	
End Sub

/'

Sub WriteMovedPermanently( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIRequest As IClientRequest Ptr = Any
	IClientContext_GetClientRequest(pIContext, @pIRequest)
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.MovedPermanently)
	
	' TODO Добавить заголовок
	
	' Dim MovedUrl As WString Ptr = Any
	' IWebSite_GetMovedUrl(pIWebSite, @MovedUrl)
	
	' Dim buf As WString * (URI_BUFFER_CAPACITY * 2 + 1) = Any
	' lstrcpyW(@buf, MovedUrl)
	
	' Dim ClientURI As Station922Uri = Any
	' IClientRequest_GetUri(pIRequest, @ClientURI)
	
	' lstrcatW(@buf, ClientURI.Uri)
	
	' IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderLocation, @buf)
	
	
	WriteHttpResponse(pIContext, pIWebSite, @MovedPermanently)
	
	IServerResponse_Release(pIResponse)
	IClientRequest_Release(pIRequest)
	
End Sub

Sub WriteHttpBadRequest( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.BadRequest)
	
	WriteHttpResponse(pIContext, pIWebSite, @HttpError400BadRequest)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpPathNotValid( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.BadRequest)
	
	WriteHttpResponse(pIContext, pIWebSite, @HttpError400BadPath)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpHostNotFound( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.BadRequest)
	
	WriteHttpResponse(pIContext, pIWebSite, @HttpError400Host)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpSiteNotFound( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.NotFound)
	
	WriteHttpResponse(pIContext, pIWebSite, @HttpError404SiteNotFound)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpNeedAuthenticate( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderWwwAuthenticate, @DefaultHeaderWwwAuthenticate)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.Unauthorized)
	
	WriteHttpResponse(pIContext, pIWebSite, @NeedUsernamePasswordString)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpBadAuthenticateParam( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderWwwAuthenticate, @DefaultHeaderWwwAuthenticate1)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.Unauthorized)
	
	WriteHttpResponse(pIContext, pIWebSite, @NeedUsernamePasswordString1)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpNeedBasicAuthenticate( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderWwwAuthenticate, @DefaultHeaderWwwAuthenticate2)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.Unauthorized)
	
	WriteHttpResponse(pIContext, pIWebSite, @NeedUsernamePasswordString2)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpEmptyPassword( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderWwwAuthenticate, @DefaultHeaderWwwAuthenticate)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.Unauthorized)
	
	WriteHttpResponse(pIContext, pIWebSite, @NeedUsernamePasswordString3)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpBadUserNamePassword( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderWwwAuthenticate, @DefaultHeaderWwwAuthenticate)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.Unauthorized)
	
	WriteHttpResponse(pIContext, pIWebSite, @NeedUsernamePasswordString)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpForbidden( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.Forbidden)
	
	WriteHttpResponse(pIContext, pIWebSite, @HttpError403Forbidden)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpFileNotFound( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.NotFound)
	
	WriteHttpResponse(pIContext, pIWebSite, @HttpError404FileNotFound)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpMethodNotAllowed( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.MethodNotAllowed)
	
	WriteHttpResponse(pIContext, pIWebSite, @HttpError405NotAllowed)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpFileGone( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.Gone)
	
	WriteHttpResponse(pIContext, pIWebSite, @HttpError410Gone)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpLengthRequired( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.LengthRequired)
	
	WriteHttpResponse(pIContext, pIWebSite, @HttpError411LengthRequired)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpRequestEntityTooLarge( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.RequestEntityTooLarge)
	
	WriteHttpResponse(pIContext, pIWebSite, @HttpError413RequestEntityTooLarge)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpRequestUrlTooLarge( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.RequestURITooLarge)
	
	WriteHttpResponse(pIContext, pIWebSite, @HttpError414RequestUrlTooLarge)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpRequestRangeNotSatisfiable( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.RangeNotSatisfiable)
	
	WriteHttpResponse(pIContext, pIWebSite, @HttpError416RangeNotSatisfiable)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpRequestHeaderFieldsTooLarge( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.RequestHeaderFieldsTooLarge)
	
	WriteHttpResponse(pIContext, pIWebSite, @HttpError431RequestRequestHeaderFieldsTooLarge)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpInternalServerError( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.InternalServerError)
	
	WriteHttpResponse(pIContext, pIWebSite, @HttpError500InternalServerError)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpFileNotAvailable( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.InternalServerError)
	
	WriteHttpResponse(pIContext, pIWebSite, @HttpError500FileNotAvailable)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpCannotCreateChildProcess( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.InternalServerError)
	
	WriteHttpResponse(pIContext, pIWebSite, @HttpError500CannotCreateChildProcess)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpCannotCreatePipe( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.InternalServerError)
	
	WriteHttpResponse(pIContext, pIWebSite, @HttpError500CannotCreatePipe)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpNotImplemented( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.NotImplemented)
	
	WriteHttpResponse(pIContext, pIWebSite, @HttpError501NotImplemented)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpContentTypeEmpty( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.NotImplemented)
	
	WriteHttpResponse(pIContext, pIWebSite, @HttpError501ContentTypeEmpty)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpContentEncodingNotEmpty( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.NotImplemented)
	
	WriteHttpResponse(pIContext, pIWebSite, @HttpError501ContentEncoding)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpBadGateway( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.BadGateway)
	
	WriteHttpResponse(pIContext, pIWebSite, @HttpError502BadGateway)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpNotEnoughMemory( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderRetryAfter, @WStr("Retry-After: 300"))
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.ServiceUnavailable)
	
	WriteHttpResponse(pIContext, pIWebSite, @HttpError503Memory)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpCannotCreateThread( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderRetryAfter, @WStr("Retry-After: 300"))
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.ServiceUnavailable)
	
	WriteHttpResponse(pIContext, pIWebSite, @HttpError503ThreadError)
	
	IServerResponse_Release(pIResponse)
	
End Sub

Sub WriteHttpGatewayTimeout( _
		ByVal pIContext As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.GatewayTimeout)
	
	WriteHttpResponse(pIContext, pIWebSite, @HttpError504GatewayTimeout)
	
	IServerResponse_Release(pIResponse)
	
End Sub

'/

Sub InitializePrepareErrorResponseAsyncTask( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pIResponse As IServerResponse Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory(@this->IdString, @Str("WriteHttpErrorRs"), 16)
	#endif
	this->lpVtbl = @GlobalPrepareErrorResponseAsyncTaskVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIWebSites = NULL
	this->pIProcessors = NULL
	this->RemoteAddressLength = 0
	this->pIStream = NULL
	this->pIHttpReader = NULL
	this->pIRequest = NULL
	this->pIResponse = pIResponse
	this->pSendBuffer = NULL
	this->HttpError = ResponseErrorCode.InternalServerError
	this->hrCode = E_UNEXPECTED
	
End Sub

Sub UnInitializePrepareErrorResponseAsyncTask( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr _
	)
	
	If this->pSendBuffer <> NULL Then
		IMalloc_Free(this->pIMemoryAllocator, this->pSendBuffer)
	End If
	
	If this->pIResponse <> NULL Then
		IServerResponse_Release(this->pIResponse)
	End If
	
	If this->pIRequest <> NULL Then
		IClientRequest_Release(this->pIRequest)
	End If
	
	If this->pIHttpReader <> NULL Then
		IHttpReader_Release(this->pIHttpReader)
	End If
	
	If this->pIStream <> NULL Then
		IBaseStream_Release(this->pIStream)
	End If
	
	If this->pIProcessors <> NULL Then
		IHttpProcessorCollection_Release(this->pIProcessors)
	End If
	
	If this->pIWebSites <> NULL Then
		IWebSiteCollection_Release(this->pIWebSites)
	End If
	
	IMalloc_Release(this->pIMemoryAllocator)
	
End Sub

Function CreatePrepareErrorResponseAsyncTask( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As PrepareErrorResponseAsyncTask Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(PrepareErrorResponseAsyncTask)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"PrepareErrorResponseAsyncTask creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim pIResponse As IServerResponse Ptr = Any
	Dim hrCreateRequest As HRESULT = CreateInstance( _
		pIMemoryAllocator, _
		@CLSID_SERVERRESPONSE, _
		@IID_IServerResponse, _
		@pIResponse _
	)
	
	If SUCCEEDED(hrCreateRequest) Then
		
		Dim this As PrepareErrorResponseAsyncTask Ptr = IMalloc_Alloc( _
			pIMemoryAllocator, _
			SizeOf(PrepareErrorResponseAsyncTask) _
		)
		
		If this <> NULL Then
			InitializePrepareErrorResponseAsyncTask( _
				this, _
				pIMemoryAllocator, _
				pIResponse _
			)
			
			#if __FB_DEBUG__
			Scope
				Dim vtEmpty As VARIANT = Any
				VariantInit(@vtEmpty)
				LogWriteEntry( _
					LogEntryType.Debug, _
					WStr("PrepareErrorResponseAsyncTask created"), _
					@vtEmpty _
				)
			End Scope
			#endif
			
			Return this
		End If
		
		IServerResponse_Release(pIResponse)
	End If
	
	Return NULL
	
End Function

Sub DestroyPrepareErrorResponseAsyncTask( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("PrepareErrorResponseAsyncTask destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializePrepareErrorResponseAsyncTask(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("PrepareErrorResponseAsyncTask destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function PrepareErrorResponseAsyncTaskQueryInterface( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IPrepareErrorResponseAsyncTask, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IAsyncTask, riid) Then
			*ppv = @this->lpVtbl
		Else
			If IsEqualIID(@IID_IUnknown, riid) Then
				*ppv = @this->lpVtbl
			Else
				*ppv = NULL
				Return E_NOINTERFACE
			End If
		End If
	End If
	
	PrepareErrorResponseAsyncTaskAddRef(this)
	
	Return S_OK
	
End Function

Function PrepareErrorResponseAsyncTaskAddRef( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		InterlockedIncrement64(@this->ReferenceCounter)
	#else
		InterlockedIncrement(@this->ReferenceCounter)
	#endif
	
	Return 1
	
End Function

Function PrepareErrorResponseAsyncTaskRelease( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		If InterlockedDecrement64(@this->ReferenceCounter) Then
			Return 1
		End If
	#else
		If InterlockedDecrement(@this->ReferenceCounter) Then
			Return 1
		End If
	#endif
	
	DestroyPrepareErrorResponseAsyncTask(this)
	
	Return 0
	
End Function

Function PrepareErrorResponseAsyncTaskBeginExecute( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Dim pBodyText As WString Ptr = Any
	
	Select Case this->HttpError
		
		' Case ResponseErrorCode.MovedPermanently
			
		' Case ResponseErrorCode.BadRequest
			
		' Case ResponseErrorCode.PathNotValid
			
		' Case ResponseErrorCode.HostNotFound
			
		' Case ResponseErrorCode.SiteNotFound
			
		' Case ResponseErrorCode.NeedAuthenticate
			
		' Case ResponseErrorCode.BadAuthenticateParam
			
		' Case ResponseErrorCode.NeedBasicAuthenticate
			
		' Case ResponseErrorCode.EmptyPassword
			
		' Case ResponseErrorCode.BadUserNamePassword
			
		' Case ResponseErrorCode.Forbidden
			
		' Case ResponseErrorCode.FileNotFound
			
		' Case ResponseErrorCode.MethodNotAllowed
			
		' Case ResponseErrorCode.FileGone
			
		' Case ResponseErrorCode.LengthRequired
			
		' Case ResponseErrorCode.RequestEntityTooLarge
			
		' Case ResponseErrorCode.RequestUrlTooLarge
			
		' Case ResponseErrorCode.RequestRangeNotSatisfiable
			
		' Case ResponseErrorCode.RequestHeaderFieldsTooLarge
			
		' Case ResponseErrorCode.InternalServerError
			
		' Case ResponseErrorCode.FileNotAvailable
			
		' Case ResponseErrorCode.CannotCreateChildProcess
			
		' Case ResponseErrorCode.CannotCreatePipe
			
		' Case ResponseErrorCode.NotImplemented
			
		' Case ResponseErrorCode.ContentTypeEmpty
			
		' Case ResponseErrorCode.ContentEncodingNotEmpty
			
		' Case ResponseErrorCode.BadGateway
			
		' Case ResponseErrorCode.NotEnoughMemory
			
		' Case ResponseErrorCode.CannotCreateThread
			
		' Case ResponseErrorCode.GatewayTimeout
			
		Case ResponseErrorCode.VersionNotSupported
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.HTTPVersionNotSupported _
			)
			pBodyText = @HttpError505VersionNotSupported
			
		Case Else
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.InternalServerError _
			)
			pBodyText = @HttpError500InternalServerError
			
	End Select
	
	WriteHttpResponse( _
		this, _
		pBodyText, _
		ppIResult _
	)
	
	Return S_OK
	
End Function

Function PrepareErrorResponseAsyncTaskEndExecute( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal CompletionKey As ULONG_PTR _
	)As HRESULT
	
	Dim dwBytes As DWORD = Any
	Dim hrEndWrite As HRESULT = IBaseStream_EndWrite( _
		this->pIStream, _
		pIResult, _
		@dwBytes _
	)
	If FAILED(hrEndWrite) Then
		Return E_FAIL
	End If
	
	Select Case hrEndWrite
		
		Case S_OK
			
			Dim KeepAlive As Boolean = Any
			IServerResponse_GetKeepAlive(this->pIResponse, @KeepAlive)
			
			If KeepAlive = False Then
				Return S_FALSE
			End If
			
			Dim pTask As IReadRequestAsyncTask Ptr = Any
			Dim hrCreateTask As HRESULT = CreateInstance( _
				this->pIMemoryAllocator, _
				@CLSID_READREQUESTASYNCTASK, _
				@IID_IReadRequestAsyncTask, _
				@pTask _
			)
			If FAILED(hrCreateTask) Then
				Return hrCreateTask
			End If
			
			IHttpReader_Clear(this->pIHttpReader)
			IReadRequestAsyncTask_SetBaseStream(pTask, this->pIStream)
			IReadRequestAsyncTask_SetHttpReader(pTask, this->pIHttpReader)
			IReadRequestAsyncTask_SetWebSiteCollection(pTask, this->pIWebSites)
			IReadRequestAsyncTask_SetHttpProcessorCollection(pTask, this->pIProcessors)
			IReadRequestAsyncTask_SetRemoteAddress( _
				pTask, _
				CPtr(SOCKADDR Ptr, @this->RemoteAddress), _
				this->RemoteAddressLength _
			)
			
			Dim ppIResult As IAsyncResult Ptr = Any
			Dim hrBeginExecute As HRESULT = IReadRequestAsyncTask_BeginExecute( _
				pTask, _
				pPool, _
				@ppIResult _
			)
			If FAILED(hrBeginExecute) Then
				IReadRequestAsyncTask_Release(pTask)
				Return hrBeginExecute
			End If
			
			' Сейчас мы не уменьшаем счётчик ссылок на pTask
			' Счётчик ссылок уменьшим в функции EndExecute
			' Когда задача будет завершена
			
			Return S_OK
			
		Case S_FALSE
			' Received 0 bytes
			' TODO Вывести байты запроса в лог
			' DebugPrintHttpReader(pIHttpReader)
			
			Return S_FALSE
			
		Case BASESTREAM_S_IO_PENDING
			' PrepareErrorResponseAsyncTaskAddRef(this)
			/'
			Dim pIAsyncResult As IAsyncResult Ptr = Any
			Dim hrBeginWrite As HRESULT = IBaseStream_BeginWrite( _
				this->pIRequest, _
				CPtr(IUnknown Ptr, @this->lpVtbl), _
				@pIAsyncResult _
			)
			If FAILED(hrBeginWrite) Then
				PrepareErrorResponseAsyncTaskRelease(this)
				Return hrBeginWrite
			End If
			
			' Ссылка на this сохранена в pIAsyncResult
			' Ссылка на pIAsyncResult сохранена в унаследованной от OVERLAPPED структуре
			' Ссылку на OVERLAPPED возвратит функция GetQueuedCompletionStatus бассейну потоков
			'/
			Return ASYNCTASK_S_IO_PENDING
			
	End Select
	
End Function

Function PrepareErrorResponseAsyncTaskGetClientRequest( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	
	If this->pIRequest <> NULL Then
		IClientRequest_AddRef(this->pIRequest)
	End If
	
	*ppIRequest = this->pIRequest
	
	Return S_OK
	
End Function

Function PrepareErrorResponseAsyncTaskSetClientRequest( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT
	
	If pIRequest <> NULL Then
		IClientRequest_AddRef(pIRequest)
	End If
	
	If this->pIRequest <> NULL Then
		IClientRequest_Release(this->pIRequest)
	End If
	
	this->pIRequest = pIRequest
	
	Return S_OK
	
End Function

Function PrepareErrorResponseAsyncTaskGetWebSiteCollection( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	
	If this->pIWebSites <> NULL Then
		IWebSiteCollection_AddRef(this->pIWebSites)
	End If
	
	*ppIWebSites = this->pIWebSites
	
	Return S_OK
	
End Function

Function PrepareErrorResponseAsyncTaskSetWebSiteCollection( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	
	If pIWebSites <> NULL Then
		IWebSiteCollection_AddRef(pIWebSites)
	End If
	
	If this->pIWebSites <> NULL Then
		IWebSiteCollection_Release(this->pIWebSites)
	End If
	
	this->pIWebSites = pIWebSites
	
	Return S_OK
	
End Function

Function PrepareErrorResponseAsyncTaskGetRemoteAddress( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal pRemoteAddress As SOCKADDR Ptr, _
		ByVal pRemoteAddressLength As Integer Ptr _
	)As HRESULT
	
	*pRemoteAddressLength = this->RemoteAddressLength
	CopyMemory(pRemoteAddress, @this->RemoteAddress, this->RemoteAddressLength)
	
	Return S_OK
	
End Function

Function PrepareErrorResponseAsyncTaskSetRemoteAddress( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal RemoteAddress As SOCKADDR Ptr, _
		ByVal RemoteAddressLength As Integer _
	)As HRESULT
	
	this->RemoteAddressLength = RemoteAddressLength
	CopyMemory(@this->RemoteAddress, RemoteAddress, RemoteAddressLength)
	
	Return S_OK
	
End Function

Function PrepareErrorResponseAsyncTaskGetBaseStream( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	
	If this->pIStream <> NULL Then
		IBaseStream_AddRef(this->pIStream)
	End If
	
	*ppStream = this->pIStream
	
	Return S_OK
	
End Function

Function PrepareErrorResponseAsyncTaskSetBaseStream( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal pStream As IBaseStream Ptr _
	)As HRESULT
	
	If this->pIStream <> NULL Then
		IBaseStream_Release(this->pIStream)
	End If
	
	If pStream <> NULL Then
		IBaseStream_AddRef(pStream)
	End If
	
	this->pIStream = pStream
	
	Return S_OK
	
End Function

Function PrepareErrorResponseAsyncTaskGetHttpReader( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	If this->pIHttpReader <> NULL Then
		IHttpReader_AddRef(this->pIHttpReader)
	End If
	
	*ppReader = this->pIHttpReader
	
	Return S_OK
	
End Function

Function PrepareErrorResponseAsyncTaskSetHttpReader( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	
	If this->pIHttpReader <> NULL Then
		IHttpReader_Release(this->pIHttpReader)
	End If
	
	If pReader <> NULL Then
		IHttpReader_AddRef(pReader)
	End If
	
	this->pIHttpReader = pReader
	
	Return S_OK
	
End Function

Function PrepareErrorResponseAsyncTaskSetErrorCode( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal HttpError As ResponseErrorCode, _
		ByVal hrCode As HRESULT _
	)As HRESULT
	
	this->HttpError = HttpError
	this->hrCode = hrCode
	
	Return S_OK
	
End Function

Function PrepareErrorResponseAsyncTaskGetHttpProcessorCollection( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	
	If this->pIProcessors <> NULL Then
		IHttpReader_AddRef(this->pIProcessors)
	End If
	
	*ppIProcessors = this->pIProcessors
	
	Return S_OK
	
End Function

Function PrepareErrorResponseAsyncTaskSetHttpProcessorCollection( _
		ByVal this As PrepareErrorResponseAsyncTask Ptr, _
		ByVal pIProcessors As IHttpProcessorCollection Ptr _
	)As HRESULT
	
	If this->pIProcessors <> NULL Then
		IBaseStream_Release(this->pIProcessors)
	End If
	
	If pIProcessors <> NULL Then
		IBaseStream_AddRef(pIProcessors)
	End If
	
	this->pIProcessors = pIProcessors
	
	Return S_OK
	
End Function


Function IPrepareErrorResponseAsyncTaskQueryInterface( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskQueryInterface(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), riid, ppv)
End Function

Function IPrepareErrorResponseAsyncTaskAddRef( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr _
	)As ULONG
	Return PrepareErrorResponseAsyncTaskAddRef(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl))
End Function

Function IPrepareErrorResponseAsyncTaskRelease( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr _
	)As ULONG
	Return PrepareErrorResponseAsyncTaskRelease(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl))
End Function

Function IPrepareErrorResponseAsyncTaskBeginExecute( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As ULONG
	Return PrepareErrorResponseAsyncTaskBeginExecute(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), pPool, ppIResult)
End Function

Function IPrepareErrorResponseAsyncTaskEndExecute( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal CompletionKey As ULONG_PTR _
	)As ULONG
	Return PrepareErrorResponseAsyncTaskEndExecute(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), pPool, pIResult, BytesTransferred, CompletionKey)
End Function

Function IPrepareErrorResponseAsyncTaskGetWebSiteCollection( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskGetWebSiteCollection(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), ppIWebSites)
End Function

Function IPrepareErrorResponseAsyncTaskSetWebSiteCollection( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskSetWebSiteCollection(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), pIWebSites)
End Function

Function IPrepareErrorResponseAsyncTaskGetRemoteAddress( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal pRemoteAddress As SOCKADDR Ptr, _
		ByVal pRemoteAddressLength As Integer Ptr _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskGetRemoteAddress(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), pRemoteAddress, pRemoteAddressLength)
End Function

Function IPrepareErrorResponseAsyncTaskSetRemoteAddress( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal RemoteAddress As SOCKADDR Ptr, _
		ByVal RemoteAddressLength As Integer _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskSetRemoteAddress(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), RemoteAddress, RemoteAddressLength)
End Function

Function IPrepareErrorResponseAsyncTaskGetBaseStream( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskGetBaseStream(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), ppStream)
End Function

Function IPrepareErrorResponseAsyncTaskSetBaseStream( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		byVal pStream As IBaseStream Ptr _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskSetBaseStream(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), pStream)
End Function

Function IPrepareErrorResponseAsyncTaskGetHttpReader( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskGetHttpReader(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), ppReader)
End Function

Function IPrepareErrorResponseAsyncTaskSetHttpReader( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskSetHttpReader(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), pReader)
End Function

Function IPrepareErrorResponseAsyncTaskGetClientRequest( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskGetClientRequest(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), ppIRequest)
End Function

Function IPrepareErrorResponseAsyncTaskSetClientRequest( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskSetClientRequest(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), pIRequest)
End Function

Function IPrepareErrorResponseAsyncTaskSetErrorCode( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal HttpError As ResponseErrorCode, _
		ByVal hrCode As HRESULT _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskSetErrorCode(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), HttpError, hrCode)
End Function

Function IPrepareErrorResponseAsyncTaskGetHttpProcessorCollection( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskGetHttpProcessorCollection(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), ppIProcessors)
End Function

Function IPrepareErrorResponseAsyncTaskSetHttpProcessorCollection( _
		ByVal this As IPrepareErrorResponseAsyncTask Ptr, _
		ByVal pIProcessors As IHttpProcessorCollection Ptr _
	)As HRESULT
	Return PrepareErrorResponseAsyncTaskSetHttpProcessorCollection(ContainerOf(this, PrepareErrorResponseAsyncTask, lpVtbl), pIProcessors)
End Function

Dim GlobalPrepareErrorResponseAsyncTaskVirtualTable As Const IPrepareErrorResponseAsyncTaskVirtualTable = Type( _
	@IPrepareErrorResponseAsyncTaskQueryInterface, _
	@IPrepareErrorResponseAsyncTaskAddRef, _
	@IPrepareErrorResponseAsyncTaskRelease, _
	@IPrepareErrorResponseAsyncTaskBeginExecute, _
	@IPrepareErrorResponseAsyncTaskEndExecute, _
	@IPrepareErrorResponseAsyncTaskGetWebSiteCollection, _
	@IPrepareErrorResponseAsyncTaskSetWebSiteCollection, _
	@IPrepareErrorResponseAsyncTaskGetRemoteAddress, _
	@IPrepareErrorResponseAsyncTaskSetRemoteAddress, _
	@IPrepareErrorResponseAsyncTaskGetBaseStream, _
	@IPrepareErrorResponseAsyncTaskSetBaseStream, _
	@IPrepareErrorResponseAsyncTaskGetHttpReader, _
	@IPrepareErrorResponseAsyncTaskSetHttpReader, _
	@IPrepareErrorResponseAsyncTaskGetClientRequest, _
	@IPrepareErrorResponseAsyncTaskSetClientRequest, _
	@IPrepareErrorResponseAsyncTaskSetErrorCode, _
	@IPrepareErrorResponseAsyncTaskGetHttpProcessorCollection, _
	@IPrepareErrorResponseAsyncTaskSetHttpProcessorCollection _
)
