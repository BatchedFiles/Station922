#include "WriteHttpError.bi"
#include "ArrayStringWriter.bi"
#include "HttpConst.bi"
#include "WebUtils.bi"

' TODO Описания ошибок перевести на эсперанто

' Размер буфера в символах для записи в него кода html страницы с ошибкой
Const MaxHttpErrorBuffer As Integer = 16 * 1024 - 1

Const DefaultContentLanguage = "ru"
Const HttpErrorHead1 = "<!DOCTYPE html><html xmlns=""http://www.w3.org/1999/xhtml""><head><meta name=""viewport"" content=""width=device-width, initial-scale=1"" /><title>"
Const HttpErrorHead2 = "</title></head>"
Const HttpErrorBody1 = "<body><h1>"
Const HttpErrorBody3 = "</h1><h2>Код ответа HTTP "
Const HttpErrorBody4 = " — "
Const HttpErrorBody5 = "</h2><p>"
Const HttpErrorBody6 = "</p><p>Посетить <a href=""/"">главную страницу</a> сайта.</p></body></html>"

Const ClientCreatedString = "Ресурс создан"
Const ClientMovedString = "Ресурс перенаправлен"
Const ClientErrorString = "Клиентская ошибка"
Const ServerErrorString = "Серверная ошибка"
Const HttpErrorBody2 = " в приложении "

' TODO Исправить для ошибок HttpCreated и HttpCreatedUpdated, которые на самом деле не ошибки
Const HttpCreated201_1 = "Ресурс успешно создан."
Const HttpCreated201_2 = "Ресурс успешно обновлён."

Const HttpError400BadRequest = "Что за чушь ты несёшь?! Язык без костей — что хочет то и лопочет."
Const HttpError400BadPath = "Что за чушь ты запрашиваешь?! Язык без костей — что хочет, то и лопочет? Убирайся‐ка отсюда подобру‐поздорову, холоп."
Const HttpError400Host = "Холоп, при обращении к благородным господам этикет требует вежливо указывать заголовок Host."
Const HttpError403Forbidden = "У тебя нет привилегий доступа к этому файлу, простолюдин. Файлы такого типа предназначены только для благородных господ, а ты, как я вижу, простой холоп."
Const HttpError404FileNotFound = "Запрошенный тобою файл — это несуществующая, смешная и глупая фантазия. Отправляйся‐ка восвояси, холоп, и не докучай благородных господ своими вздорными просьбами."
Const HttpError404SiteNotFound = "Запрошенный тобою сайт — это несуществующая, смешная и глупая фантазия. Отправляйся‐ка восвояси, холоп, и не докучай благородных господ своими вздорными просьбами."
Const HttpError405NotAllowed = "Метод не применим к такому файлу."
Const HttpError410Gone = "По указанию благородных господ я удалил файл насовсем. Полностью. Он никогда не будет найден. А тебе, холоп, я приказываю удалить все ссылки на него. И больше не ходить по этому адресу."
Const HttpError411LengthRequired = "Холоп, когда ты мне отправляешь данные, то тебе следует вежливо указывать длину тела запроса."
Const HttpError413RequestEntityTooLarge = "Холоп, длина тела запроса слишком большая. Не утомляй благородных господ просьбами длиннее 4194304 байт."
Const HttpError414RequestUrlTooLarge = "Холоп, длина URL слишком большая. Больше не утомляй благородных господ досужими URL."
Const HttpError431RequestRequestHeaderFieldsTooLarge = "Холоп, длина заголовков слишком большая. Больше не утомляй благородных господ досужими заголовками."

Const HttpError500InternalServerError = "Внутренняя ошибка сервера."
Const HttpError500FileNotAvailable = "В данный момент слуги не могут получить доступ к файлу, так как его обрабатывают слуги по приказу благородных господ."
Const HttpError500CannotCreateChildProcess = "Не могу создать дочерний процесс."
Const HttpError500CannotCreatePipe = "Не могу создать трубу для чтения и записи данных дочернего процесса."
Const HttpError501NotImplemented = "Благородные господы не хотят содержать крепостных, которые бы обрабатывали этот метод. Отправляйся‐ка восвояси."
Const HttpError501ContentTypeEmpty = "Холоп, ты не указал тип содержимого. Элементарная вежливость требует указывать что ты отправляешь на сервер."
Const HttpError501ContentEncoding = "Холоп, больше не отправляй сжатое содержимое. Благородные господы не хотят содержать крепостных, разжимающих твои смешные данные."
Const HttpError502BadGateway = "Удалённый сервер не отвечает."
Const HttpError503ThreadError = "Внутренняя ошибка сервера: не могу создать поток для обработки запроса."
Const HttpError503Memory = "В данный момент все крепостные заняты выполнением запросов, куча переполнена."
Const HttpError504GatewayTimeout = "Не могу соединиться с удалённым сервером"
Const HttpError505VersionNotSupported = "Холоп, ты используешь версию протокола, которую я не поддерживаю. Благородные господы поддерживают только версии HTTP/1.0 и HTTP/1.1."

Const NeedUsernamePasswordString = "Требуется логин и пароль для доступа"
Const NeedUsernamePasswordString1 = "Параметры авторизации неверны"
Const NeedUsernamePasswordString2 = "Требуется Basic‐авторизация"
Const NeedUsernamePasswordString3 = "Пароль не может быть пустым"

Const MovedPermanently = "Ресурс перекатился на другой адрес."

Const DefaultHeaderWwwAuthenticate = "Basic realm=""Need username and password"""
Const DefaultHeaderWwwAuthenticate1 = "Basic realm=""Authorization"""
Const DefaultHeaderWwwAuthenticate2 = "Basic realm=""Use Basic auth"""

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
	
	lstrcpy(@buf, MovedUrl)
	
	Dim ClientURI As Station922Uri = Any
	IClientRequest_GetUri(pIRequest, @ClientURI)
	
	lstrcat(@buf, ClientURI.pUrl)
	
	IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderLocation, @buf)
	
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
	IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderWwwAuthenticate, @DefaultHeaderWwwAuthenticate)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.Unauthorized)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @NeedUsernamePasswordString)
End Sub

Sub WriteHttpBadAuthenticateParam( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderWwwAuthenticate, @DefaultHeaderWwwAuthenticate1)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.Unauthorized)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @NeedUsernamePasswordString1)
End Sub

Sub WriteHttpNeedBasicAuthenticate( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderWwwAuthenticate, @DefaultHeaderWwwAuthenticate2)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.Unauthorized)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @NeedUsernamePasswordString2)
End Sub

Sub WriteHttpEmptyPassword( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderWwwAuthenticate, @DefaultHeaderWwwAuthenticate)
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.Unauthorized)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @NeedUsernamePasswordString3)
End Sub

Sub WriteHttpBadUserNamePassword( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderWwwAuthenticate, @DefaultHeaderWwwAuthenticate)
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
	IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderRetryAfter, @"Retry-After: 300")
	IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.ServiceUnavailable)
	WriteHttpResponse(pIRequest, pIResponse, pStream, pIWebSite, @HttpError503Memory)
End Sub

Sub WriteHttpCannotCreateThread( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pStream As IBaseStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)
	IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderRetryAfter, @"Retry-After: 300")
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
	
	Dim Mime As MimeType = Any
	With Mime
		.ContentType = ContentTypes.TextHtml
		.IsTextFormat = True
		.Charset = DocumentCharsets.Utf8BOM
	End With
	
	IServerResponse_SetMimeType(pIResponse, @Mime)
	
	IServerResponse_SetKeepAlive(pIResponse, False)
	IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderContentLanguage, @DefaultContentLanguage)
	
	Dim BodyWriter As ArrayStringWriter = Any
	Dim pIWriter As IArrayStringWriter Ptr = InitializeArrayStringWriterOfIArrayStringWriter(@BodyWriter)
	
	Dim BodyBuffer As WString * (MaxHttpErrorBuffer + 1) = Any
	ArrayStringWriter_NonVirtualSetBuffer(pIWriter, @BodyBuffer, MaxHttpErrorBuffer)
	
	Scope
		
		Dim VirtualPath As WString Ptr = Any
		
		If pIWebSite = 0 Then
			VirtualPath = @DefaultVirtualPath
		Else
			IWebSite_GetVirtualPath(pIWebSite, @VirtualPath)
		End If
		
		Dim StatusCode As HttpStatusCodes = Any
		IServerResponse_GetStatusCode(pIResponse, @StatusCode)
		
		FormatErrorMessageBody(pIWriter, StatusCode, VirtualPath, BodyText)
		
	End Scope
	
	Dim Utf8Body As ZString * (MaxResponseBufferLength + 1) = Any
	Dim ContentBodyLength As Integer = WideCharToMultiByte( _
		CP_UTF8, _
		0, _
		@BodyBuffer, _
		-1, _
		@Utf8Body, _
		MaxResponseBufferLength + 1, _
		0, _
		0 _
	) - 1
	
	Dim SendBuffer As ZString * (MaxResponseBufferLength * 2 + 1) = Any
	Dim SendBufferLength As Integer = AllResponseHeadersToBytes(pIRequest, pIResponse, @SendBuffer, ContentBodyLength)
	
	RtlCopyMemory(@SendBuffer + SendBufferLength, @Utf8Body, ContentBodyLength)
	SendBufferLength += ContentBodyLength
	
	Dim BytesWrited As Integer = Any
	pStream->pVirtualTable->Write(pStream, @SendBuffer, 0, SendBufferLength, @BytesWrited)
	
	ArrayStringWriter_NonVirtualRelease(pIWriter)
	
End Sub

Sub FormatErrorMessageBody( _
		ByVal pIWriter As IArrayStringWriter Ptr, _
		ByVal StatusCode As HttpStatusCodes, _
		ByVal VirtualPath As WString Ptr, _
		ByVal BodyText As WString Ptr _
	)
	
	Dim DescriptionBuffer As WString Ptr = GetStatusDescription(StatusCode, 0)
	
	ArrayStringWriter_NonVirtualWriteString(pIWriter, HttpErrorHead1)
	ArrayStringWriter_NonVirtualWriteString(pIWriter, DescriptionBuffer)
	ArrayStringWriter_NonVirtualWriteString(pIWriter, HttpErrorHead2)
	
	ArrayStringWriter_NonVirtualWriteString(pIWriter, HttpErrorBody1)
	
	' Заголовок <h1>
	Select Case StatusCode
		Case 200 To 299
			ArrayStringWriter_NonVirtualWriteString(pIWriter, ClientCreatedString)
			
		Case 300 To 399
			ArrayStringWriter_NonVirtualWriteString(pIWriter, ClientMovedString)
			
		Case 400 To 499
			ArrayStringWriter_NonVirtualWriteString(pIWriter, ClientErrorString)
			
		Case 500 To 599
			ArrayStringWriter_NonVirtualWriteString(pIWriter, ServerErrorString)
			
	End Select
	
	ArrayStringWriter_NonVirtualWriteString(pIWriter, HttpErrorBody2)
	
	' Имя приложения в заголовке <h1>
	ArrayStringWriter_NonVirtualWriteString(pIWriter, VirtualPath)
	ArrayStringWriter_NonVirtualWriteString(pIWriter, HttpErrorBody3)
	
	' Код статуса в заголовке <h2>
	ArrayStringWriter_NonVirtualWriteInt32(pIWriter, StatusCode)
	ArrayStringWriter_NonVirtualWriteString(pIWriter, HttpErrorBody4)
	
	' Описание ошибки в заголовке <h2>
	ArrayStringWriter_NonVirtualWriteString(pIWriter, DescriptionBuffer)
	ArrayStringWriter_NonVirtualWriteString(pIWriter, HttpErrorBody5)
	
	' Текст сообщения между <p></p>
	ArrayStringWriter_NonVirtualWriteString(pIWriter, BodyText)
	ArrayStringWriter_NonVirtualWriteString(pIWriter, HttpErrorBody6)
	
End Sub
