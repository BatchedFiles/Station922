#include once "WriteErrorAsyncTask.bi"
#include once "ArrayStringWriter.bi"
#include once "ReadRequestAsyncTask.bi"
#include once "ClientRequest.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "HeapBSTR.bi"
#include once "INetworkStream.bi"
#include once "Logger.bi"
#include once "ServerResponse.bi"
#include once "WebUtils.bi"

Extern GlobalWriteErrorAsyncIoTaskVirtualTable As Const IWriteErrorAsyncIoTaskVirtualTable

' Размер буфера в символах для записи в него кода html страницы с ошибкой
Const MaxHttpErrorBuffer As Integer = 16 * 1024 - 1

Const DefaultContentLanguage = WStr("en")
Const DefaultCacheControlNoCache = WStr("no-cache")
Const DefaultRetryAfterString = WStr("300")

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

Type _WriteErrorAsyncTask
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IWriteErrorAsyncIoTaskVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	pIWebSites As IWebSiteCollection Ptr
	pIProcessors As IHttpProcessorCollection Ptr
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
		ByVal this As WriteErrorAsyncTask Ptr, _
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

Sub InitializeWriteErrorAsyncTask( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pIResponse As IServerResponse Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory(@this->IdString, @Str("WriteError__Task"), 16)
	#endif
	this->lpVtbl = @GlobalWriteErrorAsyncIoTaskVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIWebSites = NULL
	this->pIProcessors = NULL
	this->pIStream = NULL
	this->pIHttpReader = NULL
	this->pIRequest = NULL
	this->pIResponse = pIResponse
	this->pSendBuffer = NULL
	this->HttpError = ResponseErrorCode.InternalServerError
	this->hrCode = E_UNEXPECTED
	
End Sub

Sub UnInitializeWriteErrorAsyncTask( _
		ByVal this As WriteErrorAsyncTask Ptr _
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

Function CreateWriteErrorAsyncTask( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As WriteErrorAsyncTask Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(WriteErrorAsyncTask)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"WriteErrorAsyncTask creating\t"), _
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
		
		Dim this As WriteErrorAsyncTask Ptr = IMalloc_Alloc( _
			pIMemoryAllocator, _
			SizeOf(WriteErrorAsyncTask) _
		)
		
		If this <> NULL Then
			InitializeWriteErrorAsyncTask( _
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
					WStr("WriteErrorAsyncTask created"), _
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

Sub DestroyWriteErrorAsyncTask( _
		ByVal this As WriteErrorAsyncTask Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("WriteErrorAsyncTask destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeWriteErrorAsyncTask(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("WriteErrorAsyncTask destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function WriteErrorAsyncTaskQueryInterface( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IWriteErrorAsyncIoTask, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IHttpAsyncIoTask, riid) Then
			*ppv = @this->lpVtbl
		Else
			If IsEqualIID(@IID_IAsyncIoTask, riid) Then
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
	End If
	
	WriteErrorAsyncTaskAddRef(this)
	
	Return S_OK
	
End Function

Function WriteErrorAsyncTaskAddRef( _
		ByVal this As WriteErrorAsyncTask Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		InterlockedIncrement64(@this->ReferenceCounter)
	#else
		InterlockedIncrement(@this->ReferenceCounter)
	#endif
	
	Return 1
	
End Function

Function WriteErrorAsyncTaskRelease( _
		ByVal this As WriteErrorAsyncTask Ptr _
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
	
	DestroyWriteErrorAsyncTask(this)
	
	Return 0
	
End Function

Function WriteErrorAsyncTaskBeginExecute( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Dim pBodyText As WString Ptr = Any
	
	Select Case this->HttpError
		
		Case ResponseErrorCode.MovedPermanently
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.MovedPermanently _
			)
			pBodyText = @MovedPermanently
			
			' Dim MovedUrl As WString Ptr = Any
			' IWebSite_GetMovedUrl(pIWebSite, @MovedUrl)
			
			' Dim buf As WString * (URI_BUFFER_CAPACITY * 2 + 1) = Any
			' lstrcpyW(@buf, MovedUrl)
			
			' Dim ClientURI As Station922Uri = Any
			' IClientRequest_GetUri(pIRequest, @ClientURI)
			
			' lstrcatW(@buf, ClientURI.Uri)
			
			' IServerResponse_AddKnownResponseHeader(pIResponse, HttpResponseHeaders.HeaderLocation, @buf)
			
		Case ResponseErrorCode.BadRequest
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.BadRequest _
			)
			pBodyText = @HttpError400BadRequest
			
		Case ResponseErrorCode.PathNotValid
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.BadRequest _
			)
			pBodyText = @HttpError400BadPath
			
		Case ResponseErrorCode.HostNotFound
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.BadRequest _
			)
			pBodyText = @HttpError400Host
			
		Case ResponseErrorCode.SiteNotFound
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.NotFound _
			)
			pBodyText = @HttpError404SiteNotFound
			
		Case ResponseErrorCode.NeedAuthenticate
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				this->pIResponse, _
				HttpResponseHeaders.HeaderWwwAuthenticate, _
				@DefaultHeaderWwwAuthenticate, _
				Len(DefaultHeaderWwwAuthenticate) _
			)
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.Unauthorized _
			)
			pBodyText = @NeedUsernamePasswordString
			
		Case ResponseErrorCode.BadAuthenticateParam
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				this->pIResponse, _
				HttpResponseHeaders.HeaderWwwAuthenticate, _
				@DefaultHeaderWwwAuthenticate1, _
				Len(DefaultHeaderWwwAuthenticate1) _
			)
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.Unauthorized _
			)
			pBodyText = @NeedUsernamePasswordString1
			
		Case ResponseErrorCode.NeedBasicAuthenticate
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				this->pIResponse, _
				HttpResponseHeaders.HeaderWwwAuthenticate, _
				@DefaultHeaderWwwAuthenticate2, _
				Len(DefaultHeaderWwwAuthenticate2) _
			)
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.Unauthorized _
			)
			pBodyText = @NeedUsernamePasswordString2
			
		Case ResponseErrorCode.EmptyPassword
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				this->pIResponse, _
				HttpResponseHeaders.HeaderWwwAuthenticate, _
				@DefaultHeaderWwwAuthenticate, _
				Len(DefaultHeaderWwwAuthenticate) _
			)
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.Unauthorized _
			)
			pBodyText = @NeedUsernamePasswordString3
			
		Case ResponseErrorCode.BadUserNamePassword
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				this->pIResponse, _
				HttpResponseHeaders.HeaderWwwAuthenticate, _
				@DefaultHeaderWwwAuthenticate, _
				Len(DefaultHeaderWwwAuthenticate) _
			)
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.Unauthorized _
			)
			pBodyText = @NeedUsernamePasswordString
			
		Case ResponseErrorCode.Forbidden
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.Forbidden _
			)
			pBodyText = @HttpError403Forbidden
			
		Case ResponseErrorCode.FileNotFound
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.NotFound _
			)
			pBodyText = @HttpError404FileNotFound
			
		Case ResponseErrorCode.MethodNotAllowed
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.MethodNotAllowed _
			)
			pBodyText = @HttpError405NotAllowed
			
		Case ResponseErrorCode.FileGone
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.Gone _
			)
			pBodyText = @HttpError410Gone
			
		Case ResponseErrorCode.LengthRequired
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.LengthRequired _
			)
			pBodyText = @HttpError411LengthRequired
			
		Case ResponseErrorCode.RequestEntityTooLarge
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.RequestEntityTooLarge _
			)
			pBodyText = @HttpError413RequestEntityTooLarge
			
		Case ResponseErrorCode.RequestUrlTooLarge
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.RequestURITooLarge _
			)
			pBodyText = @HttpError414RequestUrlTooLarge
			
		Case ResponseErrorCode.RequestRangeNotSatisfiable
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.RangeNotSatisfiable _
			)
			pBodyText = @HttpError416RangeNotSatisfiable
			
		Case ResponseErrorCode.RequestHeaderFieldsTooLarge
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.RequestHeaderFieldsTooLarge _
			)
			pBodyText = @HttpError431RequestRequestHeaderFieldsTooLarge
			
		Case ResponseErrorCode.InternalServerError
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.InternalServerError _
			)
			pBodyText = @HttpError500InternalServerError
			
		Case ResponseErrorCode.FileNotAvailable
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.InternalServerError _
			)
			pBodyText = @HttpError500FileNotAvailable
			
		Case ResponseErrorCode.CannotCreateChildProcess
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.InternalServerError _
			)
			pBodyText = @HttpError500CannotCreateChildProcess
			
		Case ResponseErrorCode.CannotCreatePipe
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.InternalServerError _
			)
			pBodyText = @HttpError500CannotCreatePipe
			
		Case ResponseErrorCode.NotImplemented
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.NotImplemented _
			)
			pBodyText = @HttpError501NotImplemented
			
		Case ResponseErrorCode.ContentTypeEmpty
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.NotImplemented _
			)
			pBodyText = @HttpError501ContentTypeEmpty
			
		Case ResponseErrorCode.ContentEncodingNotEmpty
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.NotImplemented _
			)
			pBodyText = @HttpError501ContentEncoding
			
		Case ResponseErrorCode.BadGateway
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.BadGateway _
			)
			pBodyText = @HttpError502BadGateway
			
		Case ResponseErrorCode.NotEnoughMemory
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				this->pIResponse, _
				HttpResponseHeaders.HeaderRetryAfter, _
				@DefaultRetryAfterString, _
				Len(DefaultRetryAfterString) _
			)
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.ServiceUnavailable _
			)
			pBodyText = @HttpError503Memory
			
		Case ResponseErrorCode.CannotCreateThread
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				this->pIResponse, _
				HttpResponseHeaders.HeaderRetryAfter, _
				@DefaultRetryAfterString, _
				Len(DefaultRetryAfterString) _
			)
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.ServiceUnavailable _
			)
			pBodyText = @HttpError503ThreadError
			
		Case ResponseErrorCode.GatewayTimeout
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.GatewayTimeout _
			)
			pBodyText = @HttpError504GatewayTimeout
			
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

Function WriteErrorAsyncTaskEndExecute( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD _
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
			
			Dim pTask As IReadRequestAsyncIoTask Ptr = Any
			Dim hrCreateTask As HRESULT = CreateInstance( _
				this->pIMemoryAllocator, _
				@CLSID_READREQUESTASYNCTASK, _
				@IID_IReadRequestAsyncIoTask, _
				@pTask _
			)
			If FAILED(hrCreateTask) Then
				Return hrCreateTask
			End If
			
			IHttpReader_Clear(this->pIHttpReader)
			IReadRequestAsyncIoTask_SetBaseStream(pTask, this->pIStream)
			IReadRequestAsyncIoTask_SetHttpReader(pTask, this->pIHttpReader)
			IReadRequestAsyncIoTask_SetWebSiteCollection(pTask, this->pIWebSites)
			IReadRequestAsyncIoTask_SetHttpProcessorCollection(pTask, this->pIProcessors)
			
			Dim ppIResult As IAsyncResult Ptr = Any
			Dim hrBeginExecute As HRESULT = IReadRequestAsyncIoTask_BeginExecute( _
				pTask, _
				@ppIResult _
			)
			If FAILED(hrBeginExecute) Then
				IReadRequestAsyncIoTask_Release(pTask)
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
			' WriteErrorAsyncTaskAddRef(this)
			/'
			Dim pIAsyncResult As IAsyncResult Ptr = Any
			Dim hrBeginWrite As HRESULT = IBaseStream_BeginWrite( _
				this->pIRequest, _
				CPtr(IUnknown Ptr, @this->lpVtbl), _
				@pIAsyncResult _
			)
			If FAILED(hrBeginWrite) Then
				WriteErrorAsyncTaskRelease(this)
				Return hrBeginWrite
			End If
			
			' Ссылка на this сохранена в pIAsyncResult
			' Ссылка на pIAsyncResult сохранена в унаследованной от OVERLAPPED структуре
			' Ссылку на OVERLAPPED возвратит функция GetQueuedCompletionStatus бассейну потоков
			'/
			Return ASYNCTASK_S_IO_PENDING
			
	End Select
	
End Function

Function WriteErrorAsyncTaskGetFileHandle( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal pFileHandle As HANDLE Ptr _
	)As HRESULT
	
	Dim ns As INetworkStream Ptr = Any
	IBaseStream_QueryInterface(this->pIStream, @IID_INetworkStream, @ns)
	
	Dim s As SOCKET = Any
	INetworkStream_GetSocket(ns, @s)
	
	*pFileHandle = Cast(HANDLE, s)
	
	INetworkStream_Release(ns)
	
	Return S_OK
	
End Function

Function WriteErrorAsyncTaskGetWebSiteCollection( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	
	If this->pIWebSites <> NULL Then
		IWebSiteCollection_AddRef(this->pIWebSites)
	End If
	
	*ppIWebSites = this->pIWebSites
	
	Return S_OK
	
End Function

Function WriteErrorAsyncTaskSetWebSiteCollection( _
		ByVal this As WriteErrorAsyncTask Ptr, _
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

Function WriteErrorAsyncTaskGetBaseStream( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	
	If this->pIStream <> NULL Then
		IBaseStream_AddRef(this->pIStream)
	End If
	
	*ppStream = this->pIStream
	
	Return S_OK
	
End Function

Function WriteErrorAsyncTaskSetBaseStream( _
		ByVal this As WriteErrorAsyncTask Ptr, _
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

Function WriteErrorAsyncTaskGetHttpReader( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	If this->pIHttpReader <> NULL Then
		IHttpReader_AddRef(this->pIHttpReader)
	End If
	
	*ppReader = this->pIHttpReader
	
	Return S_OK
	
End Function

Function WriteErrorAsyncTaskSetHttpReader( _
		ByVal this As WriteErrorAsyncTask Ptr, _
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

Function WriteErrorAsyncTaskSetErrorCode( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal HttpError As ResponseErrorCode, _
		ByVal hrCode As HRESULT _
	)As HRESULT
	
	this->HttpError = HttpError
	this->hrCode = hrCode
	
	Return S_OK
	
End Function

Function WriteErrorAsyncTaskGetClientRequest( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	
	If this->pIRequest <> NULL Then
		IClientRequest_AddRef(this->pIRequest)
	End If
	
	*ppIRequest = this->pIRequest
	
	Return S_OK
	
End Function

Function WriteErrorAsyncTaskSetClientRequest( _
		ByVal this As WriteErrorAsyncTask Ptr, _
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

Function WriteErrorAsyncTaskGetHttpProcessorCollection( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	
	If this->pIProcessors <> NULL Then
		IHttpReader_AddRef(this->pIProcessors)
	End If
	
	*ppIProcessors = this->pIProcessors
	
	Return S_OK
	
End Function

Function WriteErrorAsyncTaskSetHttpProcessorCollection( _
		ByVal this As WriteErrorAsyncTask Ptr, _
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


Function IWriteErrorAsyncTaskQueryInterface( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskQueryInterface(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), riid, ppv)
End Function

Function IWriteErrorAsyncTaskAddRef( _
		ByVal this As IWriteErrorAsyncIoTask Ptr _
	)As ULONG
	Return WriteErrorAsyncTaskAddRef(ContainerOf(this, WriteErrorAsyncTask, lpVtbl))
End Function

Function IWriteErrorAsyncTaskRelease( _
		ByVal this As IWriteErrorAsyncIoTask Ptr _
	)As ULONG
	Return WriteErrorAsyncTaskRelease(ContainerOf(this, WriteErrorAsyncTask, lpVtbl))
End Function

Function IWriteErrorAsyncTaskBeginExecute( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As ULONG
	Return WriteErrorAsyncTaskBeginExecute(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), ppIResult)
End Function

Function IWriteErrorAsyncTaskEndExecute( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD _
	)As ULONG
	Return WriteErrorAsyncTaskEndExecute(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), pIResult, BytesTransferred)
End Function

Function IWriteErrorAsyncTaskGetFileHandle( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal pFileHandle As HANDLE Ptr _
	)As ULONG
	Return WriteErrorAsyncTaskGetFileHandle(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), pFileHandle)
End Function

Function IWriteErrorAsyncTaskGetWebSiteCollection( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskGetWebSiteCollection(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), ppIWebSites)
End Function

Function IWriteErrorAsyncTaskSetWebSiteCollection( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskSetWebSiteCollection(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), pIWebSites)
End Function

Function IWriteErrorAsyncTaskGetBaseStream( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskGetBaseStream(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), ppStream)
End Function

Function IWriteErrorAsyncTaskSetBaseStream( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		byVal pStream As IBaseStream Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskSetBaseStream(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), pStream)
End Function

Function IWriteErrorAsyncTaskGetHttpReader( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskGetHttpReader(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), ppReader)
End Function

Function IWriteErrorAsyncTaskSetHttpReader( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskSetHttpReader(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), pReader)
End Function

Function IWriteErrorAsyncTaskGetClientRequest( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskGetClientRequest(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), ppIRequest)
End Function

Function IWriteErrorAsyncTaskSetClientRequest( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskSetClientRequest(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), pIRequest)
End Function

Function IWriteErrorAsyncTaskSetErrorCode( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal HttpError As ResponseErrorCode, _
		ByVal hrCode As HRESULT _
	)As HRESULT
	Return WriteErrorAsyncTaskSetErrorCode(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), HttpError, hrCode)
End Function

Function IWriteErrorAsyncTaskGetHttpProcessorCollection( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskGetHttpProcessorCollection(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), ppIProcessors)
End Function

Function IWriteErrorAsyncTaskSetHttpProcessorCollection( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal pIProcessors As IHttpProcessorCollection Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskSetHttpProcessorCollection(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), pIProcessors)
End Function

Dim GlobalWriteErrorAsyncIoTaskVirtualTable As Const IWriteErrorAsyncIoTaskVirtualTable = Type( _
	@IWriteErrorAsyncTaskQueryInterface, _
	@IWriteErrorAsyncTaskAddRef, _
	@IWriteErrorAsyncTaskRelease, _
	@IWriteErrorAsyncTaskBeginExecute, _
	@IWriteErrorAsyncTaskEndExecute, _
	@IWriteErrorAsyncTaskGetFileHandle, _
	@IWriteErrorAsyncTaskGetWebSiteCollection, _
	@IWriteErrorAsyncTaskSetWebSiteCollection, _
	@IWriteErrorAsyncTaskGetBaseStream, _
	@IWriteErrorAsyncTaskSetBaseStream, _
	@IWriteErrorAsyncTaskGetHttpReader, _
	@IWriteErrorAsyncTaskSetHttpReader, _
	@IWriteErrorAsyncTaskGetHttpProcessorCollection, _
	@IWriteErrorAsyncTaskSetHttpProcessorCollection, _
	@IWriteErrorAsyncTaskGetClientRequest, _
	@IWriteErrorAsyncTaskSetClientRequest, _
	@IWriteErrorAsyncTaskSetErrorCode _
)
