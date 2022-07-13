#include once "WriteErrorAsyncTask.bi"
#include once "win\wininet.bi"
#include once "ArrayStringWriter.bi"
#include once "ReadRequestAsyncTask.bi"
#include once "ClientRequest.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "HeapBSTR.bi"
#include once "HttpWriter.bi"
#include once "INetworkStream.bi"
#include once "Logger.bi"
#include once "MemoryBuffer.bi"
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

Const DefaultVirtualPath = WStr("/")

Type _WriteErrorAsyncTask
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IWriteErrorAsyncIoTaskVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pIWebSitesWeakPtr As IWebSiteCollection Ptr
	pIProcessorsWeakPtr As IHttpProcessorCollection Ptr
	pIHttpReader As IHttpReader Ptr
	pIStream As IBaseStream Ptr
	pIRequest As IClientRequest Ptr
	pIResponse As IServerResponse Ptr
	pIBuffer As IMemoryBuffer Ptr
	pIHttpWriter As IHttpWriter Ptr
	BodyText As WString Ptr
	HttpError As ResponseErrorCode
	hrCode As HRESULT
End Type

Function ProcessErrorRequestResponse( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr, _
		ByVal pIStream As IBaseStream Ptr, _
		ByVal pIHttpReader As IHttpReader Ptr, _
		ByVal pIProcessors As IHttpProcessorCollection Ptr, _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal hrReadError As HRESULT, _
		ByVal ppTask As IWriteErrorAsyncIoTask Ptr Ptr _
	)As HRESULT
	
	Dim pTask As IWriteErrorAsyncIoTask Ptr = Any
	Dim hrCreateTask As HRESULT = CreateInstance( _
		pIMemoryAllocator, _
		@CLSID_WRITEERRORASYNCTASK, _
		@IID_IWriteErrorAsyncIoTask, _
		@pTask _
	)
	If FAILED(hrCreateTask) Then
		*ppTask = NULL
		Return hrCreateTask
	End If
	
	Dim HttpError As ResponseErrorCode = Any
	
	Select Case hrReadError
		
		Case HTTPREADER_E_INTERNALBUFFEROVERFLOW, HTTPREADER_E_INSUFFICIENT_BUFFER
			HttpError = ResponseErrorCode.RequestHeaderFieldsTooLarge
			
		Case CLIENTURI_E_CONTAINSBADCHAR, CLIENTURI_E_PATHNOTFOUND
			HttpError = ResponseErrorCode.BadRequest
			
		Case HTTPREADER_E_SOCKETERROR
			HttpError = ResponseErrorCode.BadRequest
			
		Case HTTPREADER_E_CLIENTCLOSEDCONNECTION
			HttpError = ResponseErrorCode.BadRequest
			
		Case CLIENTREQUEST_E_BADHOST
			HttpError = ResponseErrorCode.HostNotFound
			
		Case CLIENTREQUEST_E_BADREQUEST
			HttpError = ResponseErrorCode.BadRequest
			
		Case CLIENTREQUEST_E_BADPATH, CLIENTURI_E_PATHNOTFOUND
			HttpError = ResponseErrorCode.PathNotValid
			
		Case CLIENTURI_E_URITOOLARGE, CLIENTREQUEST_E_URITOOLARGE
			HttpError = ResponseErrorCode.RequestUrlTooLarge
			
		Case CLIENTREQUEST_E_HTTPVERSIONNOTSUPPORTED
			HttpError = ResponseErrorCode.VersionNotSupported
			
		Case HTTPASYNCPROCESSOR_E_RANGENOTSATISFIABLE
			HttpError = ResponseErrorCode.RequestRangeNotSatisfiable
			
		Case WEBSITE_E_SITENOTFOUND
			HttpError = ResponseErrorCode.SiteNotFound
			
		Case WEBSITE_E_REDIRECTED
			HttpError = ResponseErrorCode.MovedPermanently
			
		Case WEBSITE_E_FILENOTFOUND
			HttpError = ResponseErrorCode.FileNotFound
			
		Case WEBSITE_E_FILEGONE
			HttpError = ResponseErrorCode.FileGone
			
		Case WEBSITE_E_FORBIDDEN
			HttpError = ResponseErrorCode.Forbidden
			
		Case HTTPPROCESSOR_E_NOTIMPLEMENTED
			HttpError = ResponseErrorCode.NotImplemented
			
		Case E_OUTOFMEMORY
			HttpError = ResponseErrorCode.NotEnoughMemory
			
		Case Else
			HttpError = ResponseErrorCode.InternalServerError
			
	End Select
	
	IWriteErrorAsyncIoTask_SetWebSiteCollectionWeakPtr(pTask, pIWebSites)
	IWriteErrorAsyncIoTask_SetHttpProcessorCollectionWeakPtr(pTask, pIProcessors)
	IWriteErrorAsyncIoTask_SetBaseStream(pTask, pIStream)
	IWriteErrorAsyncIoTask_SetHttpReader(pTask, pIHttpReader)
	
	IWriteErrorAsyncIoTask_SetClientRequest(pTask, pIRequest)
	IWriteErrorAsyncIoTask_SetErrorCode(pTask, HttpError, hrReadError)
	
	Dim hrPrepare As HRESULT = IWriteErrorAsyncIoTask_Prepare(pTask)
	If FAILED(hrPrepare) Then
		IWriteErrorAsyncIoTask_Release(pTask)
		*ppTask = NULL
		Return hrPrepare
	End If
	
	*ppTask = pTask
	
	Return S_OK
	
End Function

Sub FormatErrorMessageBody( _
		ByVal pIWriter As IArrayStringWriter Ptr, _
		ByVal StatusCode As HttpStatusCodes, _
		ByVal VirtualPath As HeapBSTR, _
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
	IArrayStringWriter_WriteLengthString(pIWriter, VirtualPath, SysStringLen(VirtualPath))
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

Sub WriteErrorAsyncTaskSetBodyText( _
		ByVal this As WriteErrorAsyncTask Ptr _
	)
	
	Select Case this->HttpError
		
		Case ResponseErrorCode.MovedPermanently
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.MovedPermanently _
			)
			this->BodyText = @MovedPermanently
			
			Dim pIWebSiteWeakPtr As IWebSite Ptr = Any
			Dim hrFindSite As HRESULT = FindWebSiteWeakPtr( _
				this->pIRequest, _
				this->pIWebSitesWeakPtr, _
				@pIWebSiteWeakPtr _
			)
			
			If SUCCEEDED(hrFindSite) Then
				Dim MovedUrl As HeapBSTR = Any
				IWebSite_GetMovedUrl(pIWebSiteWeakPtr, @MovedUrl)
				
				Dim ClientURI As IClientUri Ptr = Any
				IClientRequest_GetUri(this->pIRequest, @ClientURI)
				
				Dim Path As HeapBSTR = Any
				IClientUri_GetPath(ClientURI, @Path)
				
				Dim buf As WString * (INTERNET_MAX_URL_LENGTH * 2 + 1) = Any
				lstrcpyW(@buf, MovedUrl)
				lstrcatW(@buf, Path)
				
				IServerResponse_AddKnownResponseHeaderWstr( _
					this->pIResponse, _
					HttpResponseHeaders.HeaderLocation, _
					@buf _
				)
				
				HeapSysFreeString(Path)
				IClientUri_Release(ClientURI)
				HeapSysFreeString(MovedUrl)
			End If
			
		Case ResponseErrorCode.BadRequest
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.BadRequest _
			)
			this->BodyText = @HttpError400BadRequest
			
		Case ResponseErrorCode.PathNotValid
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.BadRequest _
			)
			this->BodyText = @HttpError400BadPath
			
		Case ResponseErrorCode.HostNotFound
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.BadRequest _
			)
			this->BodyText = @HttpError400Host
			
		Case ResponseErrorCode.SiteNotFound
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.NotFound _
			)
			this->BodyText = @HttpError404SiteNotFound
			
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
			this->BodyText = @NeedUsernamePasswordString
			
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
			this->BodyText = @NeedUsernamePasswordString1
			
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
			this->BodyText = @NeedUsernamePasswordString2
			
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
			this->BodyText = @NeedUsernamePasswordString3
			
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
			this->BodyText = @NeedUsernamePasswordString
			
		Case ResponseErrorCode.Forbidden
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.Forbidden _
			)
			this->BodyText = @HttpError403Forbidden
			
		Case ResponseErrorCode.FileNotFound
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.NotFound _
			)
			this->BodyText = @HttpError404FileNotFound
			
		Case ResponseErrorCode.MethodNotAllowed
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.MethodNotAllowed _
			)
			this->BodyText = @HttpError405NotAllowed
			
		Case ResponseErrorCode.FileGone
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.Gone _
			)
			this->BodyText = @HttpError410Gone
			
		Case ResponseErrorCode.LengthRequired
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.LengthRequired _
			)
			this->BodyText = @HttpError411LengthRequired
			
		Case ResponseErrorCode.RequestEntityTooLarge
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.RequestEntityTooLarge _
			)
			this->BodyText = @HttpError413RequestEntityTooLarge
			
		Case ResponseErrorCode.RequestUrlTooLarge
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.RequestURITooLarge _
			)
			this->BodyText = @HttpError414RequestUrlTooLarge
			
		Case ResponseErrorCode.RequestRangeNotSatisfiable
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.RangeNotSatisfiable _
			)
			this->BodyText = @HttpError416RangeNotSatisfiable
			
		Case ResponseErrorCode.RequestHeaderFieldsTooLarge
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.RequestHeaderFieldsTooLarge _
			)
			this->BodyText = @HttpError431RequestRequestHeaderFieldsTooLarge
			
		Case ResponseErrorCode.InternalServerError
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.InternalServerError _
			)
			this->BodyText = @HttpError500InternalServerError
			
		Case ResponseErrorCode.FileNotAvailable
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.InternalServerError _
			)
			this->BodyText = @HttpError500FileNotAvailable
			
		Case ResponseErrorCode.CannotCreateChildProcess
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.InternalServerError _
			)
			this->BodyText = @HttpError500CannotCreateChildProcess
			
		Case ResponseErrorCode.CannotCreatePipe
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.InternalServerError _
			)
			this->BodyText = @HttpError500CannotCreatePipe
			
		Case ResponseErrorCode.NotImplemented
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.NotImplemented _
			)
			Dim AllMethods As HeapBSTR = Any
			IHttpProcessorCollection_GetAllMethods( _
				this->pIProcessorsWeakPtr, _
				@AllMethods _
			)
			IServerResponse_AddKnownResponseHeader( _
				this->pIResponse, _
				HttpResponseHeaders.HeaderAllow, _
				AllMethods _
			)
			HeapSysFreeString(AllMethods)
			this->BodyText = @HttpError501NotImplemented
			
		Case ResponseErrorCode.ContentTypeEmpty
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.NotImplemented _
			)
			this->BodyText = @HttpError501ContentTypeEmpty
			
		Case ResponseErrorCode.ContentEncodingNotEmpty
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.NotImplemented _
			)
			this->BodyText = @HttpError501ContentEncoding
			
		Case ResponseErrorCode.BadGateway
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.BadGateway _
			)
			this->BodyText = @HttpError502BadGateway
			
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
			this->BodyText = @HttpError503Memory
			
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
			this->BodyText = @HttpError503ThreadError
			
		Case ResponseErrorCode.GatewayTimeout
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.GatewayTimeout _
			)
			this->BodyText = @HttpError504GatewayTimeout
			
		Case ResponseErrorCode.VersionNotSupported
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.HTTPVersionNotSupported _
			)
			this->BodyText = @HttpError505VersionNotSupported
			
		Case Else
			IServerResponse_SetStatusCode( _
				this->pIResponse, _
				HttpStatusCodes.InternalServerError _
			)
			this->BodyText = @HttpError500InternalServerError
			
	End Select
	
End Sub

Sub InitializeWriteErrorAsyncTask( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pIBuffer As IMemoryBuffer Ptr, _
		ByVal pIHttpWriter As IHttpWriter Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_WRITEERRORASYNCTASK), _
			Len(WriteErrorAsyncTask.IdString) _
		)
	#endif
	this->lpVtbl = @GlobalWriteErrorAsyncIoTaskVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIWebSitesWeakPtr = NULL
	this->pIProcessorsWeakPtr = NULL
	this->pIHttpReader = NULL
	this->pIStream = NULL
	this->pIRequest = NULL
	this->pIResponse = pIResponse
	this->pIBuffer = pIBuffer
	this->pIHttpWriter = pIHttpWriter
	IHttpWriter_SetBuffer(pIHttpWriter, CPtr(IBuffer Ptr, pIBuffer))
	this->HttpError = ResponseErrorCode.InternalServerError
	this->hrCode = E_UNEXPECTED
	
End Sub

Sub UnInitializeWriteErrorAsyncTask( _
		ByVal this As WriteErrorAsyncTask Ptr _
	)
	
	If this->pIRequest <> NULL Then
		IClientRequest_Release(this->pIRequest)
	End If
	
	If this->pIStream <> NULL Then
		IBaseStream_Release(this->pIStream)
	End If
	
	If this->pIHttpReader <> NULL Then
		IHttpReader_Release(this->pIHttpReader)
	End If
	
	If this->pIBuffer <> NULL Then
		IMemoryBuffer_Release(this->pIBuffer)
	End If
	
	If this->pIHttpWriter <> NULL Then
		IHttpWriter_Release(this->pIHttpWriter)
	End If
	
	If this->pIResponse <> NULL Then
		IServerResponse_Release(this->pIResponse)
	End If
	
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
	
	Dim pIHttpWriter As IHttpWriter Ptr = Any
	Dim hrCreateWriter As HRESULT = CreateInstance( _
		pIMemoryAllocator, _
		@CLSID_HTTPWRITER, _
		@IID_IHttpWriter, _
		@pIHttpWriter _
	)
	
	If SUCCEEDED(hrCreateWriter) Then
		
		Dim pIResponse As IServerResponse Ptr = Any
		Dim hrCreateResponse As HRESULT = CreateInstance( _
			pIMemoryAllocator, _
			@CLSID_SERVERRESPONSE, _
			@IID_IServerResponse, _
			@pIResponse _
		)
		
		If SUCCEEDED(hrCreateResponse) Then
			
			Dim pIBuffer As IMemoryBuffer Ptr = Any
			Dim hrCreateBuffer As HRESULT = CreateInstance( _
				pIMemoryAllocator, _
				@CLSID_MEMORYBUFFER, _
				@IID_IMemoryBuffer, _
				@pIBuffer _
			)
			
			If SUCCEEDED(hrCreateBuffer) Then
				
				Dim this As WriteErrorAsyncTask Ptr = IMalloc_Alloc( _
					pIMemoryAllocator, _
					SizeOf(WriteErrorAsyncTask) _
				)
				
				If this <> NULL Then
					InitializeWriteErrorAsyncTask( _
						this, _
						pIMemoryAllocator, _
						pIResponse, _
						pIBuffer, _
						pIHttpWriter _
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
				
				IMemoryBuffer_Release(pIBuffer)
			End If
			
			IServerResponse_Release(pIResponse)
		End If
		
		IHttpWriter_Release(pIHttpWriter)
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
	
	this->ReferenceCounter += 1
	
	Return 1
	
End Function

Function WriteErrorAsyncTaskRelease( _
		ByVal this As WriteErrorAsyncTask Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyWriteErrorAsyncTask(this)
	
	Return 0
	
End Function

Function WriteErrorAsyncTaskBeginExecute( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	' TODO Запросить интерфейс вместо конвертирования указателя
	Dim hrBeginWrite As HRESULT = IHttpWriter_BeginWrite( _
		this->pIHttpWriter, _
		CPtr(IUnknown Ptr, @this->lpVtbl), _
		ppIResult _
	)
	If FAILED(hrBeginWrite) Then
		Return hrBeginWrite
	End If
	
	' Ссылка на this сохранена в pIAsyncResult
	' Ссылка на pIAsyncResult сохранена в унаследованной от OVERLAPPED структуре
	' Ссылку на OVERLAPPED возвратит функция GetQueuedCompletionStatus бассейну потоков
	
	Return ASYNCTASK_S_IO_PENDING
	
End Function

Function WriteErrorAsyncTaskEndExecute( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
	)As HRESULT
	
	Dim hrEndWrite As HRESULT = IHttpWriter_EndWrite( _
		this->pIHttpWriter, _
		pIResult _
	)
	If FAILED(hrEndWrite) Then
		*ppNextTask = NULL
		Return hrEndWrite
	End If
	
	Select Case hrEndWrite
		
		Case S_OK
			
			Dim KeepAlive As Boolean = Any
			IServerResponse_GetKeepAlive(this->pIResponse, @KeepAlive)
			
			If KeepAlive = False Then
				*ppNextTask = NULL
				Return ASYNCTASK_S_KEEPALIVE_FALSE
			End If
			
			Dim pTask As IReadRequestAsyncIoTask Ptr = Any
			Dim hrCreateTask As HRESULT = CreateInstance( _
				this->pIMemoryAllocator, _
				@CLSID_READREQUESTASYNCTASK, _
				@IID_IReadRequestAsyncIoTask, _
				@pTask _
			)
			If FAILED(hrCreateTask) Then
				' Мы не запускаем задачу отправки ошибки
				' Чтобы не войти в бесконечный цикл
				*ppNextTask = NULL
				Return hrCreateTask
			End If
			
			IHttpReader_Clear(this->pIHttpReader)
			
			IReadRequestAsyncIoTask_SetWebSiteCollectionWeakPtr(pTask, this->pIWebSitesWeakPtr)
			IReadRequestAsyncIoTask_SetHttpProcessorCollectionWeakPtr(pTask, this->pIProcessorsWeakPtr)
			IReadRequestAsyncIoTask_SetBaseStream(pTask, this->pIStream)
			IReadRequestAsyncIoTask_SetHttpReader(pTask, this->pIHttpReader)
			
			' Сейчас мы не уменьшаем счётчик ссылок на задачу
			' Счётчик ссылок уменьшим в пуле потоков после функции EndExecute
			*ppNextTask = CPtr(IAsyncIoTask Ptr, pTask)
			Return S_OK
			
		Case S_FALSE
			' Write 0 bytes
			*ppNextTask = NULL
			Return S_FALSE
			
		Case HTTPWRITER_S_IO_PENDING
			' Продолжить отправку ответа
			WriteErrorAsyncTaskAddRef(this)
			*ppNextTask = CPtr(IAsyncIoTask Ptr, @this->lpVtbl)
			Return S_OK
			
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

Function WriteErrorAsyncTaskGetWebSiteCollectionWeakPtr( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	
	*ppIWebSites = this->pIWebSitesWeakPtr
	
	Return S_OK
	
End Function

Function WriteErrorAsyncTaskSetWebSiteCollectionWeakPtr( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	
	this->pIWebSitesWeakPtr = pIWebSites
	
	Return S_OK
	
End Function

Function WriteErrorAsyncTaskGetHttpProcessorCollectionWeakPtr( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	
	*ppIProcessors = this->pIProcessorsWeakPtr
	
	Return S_OK
	
End Function

Function WriteErrorAsyncTaskSetHttpProcessorCollectionWeakPtr( _
		ByVal this As WriteErrorAsyncTask Ptr, _
		ByVal pIProcessors As IHttpProcessorCollection Ptr _
	)As HRESULT
	
	this->pIProcessorsWeakPtr = pIProcessors
	
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
	
	IHttpWriter_SetBaseStream(this->pIHttpWriter, pStream)
	
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

Function WriteErrorAsyncTaskPrepare( _
		ByVal this As WriteErrorAsyncTask Ptr _
	)As HRESULT
	
	Dim pIWriter As IArrayStringWriter Ptr = Any
	Dim hrCreateArrayStringWriter As HRESULT = CreateInstance( _
		this->pIMemoryAllocator, _
		@CLSID_ARRAYSTRINGWRITER, _
		@IID_IArrayStringWriter, _
		@pIWriter _
	)
	If FAILED(hrCreateArrayStringWriter) Then
		Return hrCreateArrayStringWriter
	End If
	
	WriteErrorAsyncTaskSetBodyText(this)
	
	Scope
		Dim KeepAlive As Boolean = True
		IClientRequest_GetKeepAlive(this->pIRequest, @KeepAlive)
		IServerResponse_SetKeepAlive(this->pIResponse, KeepAlive)
		IHttpWriter_SetKeepAlive(this->pIHttpWriter, KeepAlive)
	End Scope
	
	Scope
		Dim Mime As MimeType = Any
		With Mime
			.ContentType = ContentTypes.TextHtml
			.Charset = DocumentCharsets.Utf8BOM
			.IsTextFormat = True
		End With
		IServerResponse_SetMimeType(this->pIResponse, @Mime)
	End Scope
	
	Scope
		Dim HttpMethod As HeapBSTR = Any
		IClientRequest_GetHttpMethod(this->pIRequest, @HttpMethod)
		
		If lstrcmpW(HttpMethod, WStr("HEAD")) = 0 Then
			IServerResponse_SetSendOnlyHeaders(this->pIResponse, True)
		End If
		
		HeapSysFreeString(HttpMethod)
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
	
	Dim SendBufferLength As Integer = Any
	
	Scope
		Dim BodyBuffer As WString * (MaxHttpErrorBuffer + 1) = Any
		IArrayStringWriter_SetBuffer(pIWriter, @BodyBuffer, MaxHttpErrorBuffer)
		
		Scope
			Dim VirtualPath As HeapBSTR = Any
			
			Dim HeaderHost As HeapBSTR = Any
			IClientRequest_GetHttpHeader( _
				this->pIRequest, _
				HttpRequestHeaders.HeaderHost, _
				@HeaderHost _
			)
			
			If SysStringLen(HeaderHost) Then
				
				Dim pIWebSiteWeakPtr As IWebSite Ptr = Any
				Dim hrFindSite As HRESULT = IWebSiteCollection_ItemWeakPtr( _
					this->pIWebSitesWeakPtr, _
					HeaderHost, _
					@pIWebSiteWeakPtr _
				)
				If FAILED(hrFindSite) Then
					VirtualPath = CreateHeapStringLen( _
						this->pIMemoryAllocator, _
						@WStr(DefaultVirtualPath), _
						Len(DefaultVirtualPath) _
					)
				Else
					IWebSite_GetVirtualPath(pIWebSiteWeakPtr, @VirtualPath)
				End If
			Else
				VirtualPath = CreateHeapStringLen( _
					this->pIMemoryAllocator, _
					@WStr(DefaultVirtualPath), _
					Len(DefaultVirtualPath) _
				)
			End If
			
			HeapSysFreeString(HeaderHost)
			
			Dim StatusCode As HttpStatusCodes = Any
			IServerResponse_GetStatusCode(this->pIResponse, @StatusCode)
			
			FormatErrorMessageBody( _
				pIWriter, _
				StatusCode, _
				VirtualPath, _
				this->BodyText, _
				this->hrCode _
			)
			
			HeapSysFreeString(VirtualPath)
		End Scope
		
		Dim BodyLength As Integer = Any
		IArrayStringWriter_GetLength(pIWriter, @BodyLength)
		
		SendBufferLength = WideCharToMultiByte( _
			CP_UTF8, _
			0, _
			@BodyBuffer, _
			BodyLength, _
			NULL, _
			0, _
			0, _
			0 _
		)
		
		Dim pBuffer As Any Ptr = Any
		Dim hrAllocBuffer As HRESULT = IMemoryBuffer_AllocBuffer( _
			this->pIBuffer, _
			SendBufferLength, _
			@pBuffer _
		)
		If FAILED(hrAllocBuffer) Then
			IArrayStringWriter_Release(pIWriter)
			Return E_OUTOFMEMORY
		End If
		
		WideCharToMultiByte( _
			CP_UTF8, _
			0, _
			@BodyBuffer, _
			BodyLength, _
			pBuffer, _
			SendBufferLength, _
			0, _
			0 _
		)
		
	End Scope
	
	IArrayStringWriter_Release(pIWriter)
	
	Dim hrPrepareResponse As HRESULT = IHttpWriter_Prepare( _
		this->pIHttpWriter, _
		this->pIResponse, _
		SendBufferLength _
	)
	If FAILED(hrPrepareResponse) Then
		Return hrPrepareResponse
	End If
	
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
		ByVal BytesTransferred As DWORD, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
	)As ULONG
	Return WriteErrorAsyncTaskEndExecute(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), pIResult, BytesTransferred, ppNextTask)
End Function

Function IWriteErrorAsyncTaskGetFileHandle( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal pFileHandle As HANDLE Ptr _
	)As ULONG
	Return WriteErrorAsyncTaskGetFileHandle(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), pFileHandle)
End Function

Function IWriteErrorAsyncTaskGetWebSiteCollectionWeakPtr( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskGetWebSiteCollectionWeakPtr(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), ppIWebSites)
End Function

Function IWriteErrorAsyncTaskSetWebSiteCollectionWeakPtr( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskSetWebSiteCollectionWeakPtr(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), pIWebSites)
End Function

Function IWriteErrorAsyncTaskGetHttpProcessorCollectionWeakPtr( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskGetHttpProcessorCollectionWeakPtr(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), ppIProcessors)
End Function

Function IWriteErrorAsyncTaskSetHttpProcessorCollectionWeakPtr( _
		ByVal this As IWriteErrorAsyncIoTask Ptr, _
		ByVal pIProcessors As IHttpProcessorCollection Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskSetHttpProcessorCollectionWeakPtr(ContainerOf(this, WriteErrorAsyncTask, lpVtbl), pIProcessors)
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

Function IWriteErrorAsyncTaskPrepare( _
		ByVal this As IWriteErrorAsyncIoTask Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskPrepare(ContainerOf(this, WriteErrorAsyncTask, lpVtbl))
End Function

Dim GlobalWriteErrorAsyncIoTaskVirtualTable As Const IWriteErrorAsyncIoTaskVirtualTable = Type( _
	@IWriteErrorAsyncTaskQueryInterface, _
	@IWriteErrorAsyncTaskAddRef, _
	@IWriteErrorAsyncTaskRelease, _
	@IWriteErrorAsyncTaskBeginExecute, _
	@IWriteErrorAsyncTaskEndExecute, _
	@IWriteErrorAsyncTaskGetFileHandle, _
	@IWriteErrorAsyncTaskGetWebSiteCollectionWeakPtr, _
	@IWriteErrorAsyncTaskSetWebSiteCollectionWeakPtr, _
	@IWriteErrorAsyncTaskGetHttpProcessorCollectionWeakPtr, _
	@IWriteErrorAsyncTaskSetHttpProcessorCollectionWeakPtr, _
	@IWriteErrorAsyncTaskGetBaseStream, _
	@IWriteErrorAsyncTaskSetBaseStream, _
	@IWriteErrorAsyncTaskGetHttpReader, _
	@IWriteErrorAsyncTaskSetHttpReader, _
	@IWriteErrorAsyncTaskGetClientRequest, _
	@IWriteErrorAsyncTaskSetClientRequest, _
	@IWriteErrorAsyncTaskSetErrorCode, _
	@IWriteErrorAsyncTaskPrepare _
)
