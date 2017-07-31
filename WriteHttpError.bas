#include once "WriteHttpError.bi"
' #include once "HttpConst.bi"
#include once "WebUtils.bi"

' Размер буфера в символах для записи в него кода html страницы с ошибкой
Const MaxHttpErrorBuffer As Integer = 16 * 1024 - 1

Const HttpError400BadRequest = "Что за чушь ты несёшь?! Язык без костей — что хочет то и лопочет."
Const HttpError400BadPath = "Что за чушь ты запрашиваешь?! Язык без костей — что хочет, то и лопочет? Убирайся‐ка отсюда подобру‐поздорову, холоп."
Const HttpError400Host = "Холоп, при обращении к благородным господам этикет требует вежливо указывать заголовок Host."
Const HttpError403File = "У тебя нет привилегий доступа к этому файлу, простолюдин. Файлы такого типа предназначены только для благородных господ, а ты, как я вижу, простой холоп."
Const HttpError404FileNotFound = "Запрошенный тобою файл — это несуществующая, смешная и глупая фантазия. Отправляйся‐ка восвояси, холоп, и не докучай благородных господ своими вздорными просьбами."
Const HttpError410Gone = "По указанию благородных господ я удалил файл насовсем. Полностью. Он никогда не будет найден. А тебе, холоп, я приказываю удалить все ссылки на него. И больше не ходить по этому адресу."
Const HttpError411LengthRequired = "Холоп, когда ты мне отправляешь данные, то тебе следует вежливо указывать длину тела запроса."
Const HttpError413RequestEntityTooLarge = "Холоп, длина тела запроса слишком большая. Не утомляй благородных господ просьбами длиннее 4194304 байт."
Const HttpError414RequestUrlTooLarge = "Холоп, длина URL слишком большая. Больше не утомляй благородных господ досужими URL."
Const HttpError431RequestRequestHeaderFieldsTooLarge = "Холоп, длина заголовков слишком большая. Больше не утомляй благородных господ досужими заголовками."
Const HttpError500ThreadError = "Внутренняя ошибка сервера: не могу создать поток для обработки запроса."
Const HttpError500NotAvailable = "В данный момент слуги не могут получить доступ к файлу, так как его обрабатывают слуги по приказу благородных господ."
Const HttpError501MethodNotAllowed = "Благородные господы не хотят содержать крепостных, которые бы обрабатывали этот метод. Отправляйся‐ка восвояси."
Const HttpError501ContentTypeEmpty = "Холоп, ты не указал тип содержимого. Элементарная вежливость требует указывать что ты отправляешь на сервер."
Const HttpError501ContentEncoding = "Холоп, больше не отправляй сжатое содержимое. Благородные господы не хотят содержать крепостных, разжимающих твои смешные данные."
Const HttpError502BadGateway = "Удалённый сервер не отвечает"
Const HttpError503Memory = "В данный момент все крепостные заняты выполнением запросов, куча переполнена."
Const HttpError504GatewayTimeout = "Не могу соединиться с удалённым сервером"
Const HttpError505VersionNotSupported = "Холоп, ты используешь версию протокола, которую я не поддерживаю. Благородные господы поддерживают только версии HTTP/1.0 и HTTP/1.1."

Const NeedUsernamePasswordString = "Требуется логин и пароль для доступа"
Const NeedUsernamePasswordString1 = "Параметры авторизации неверны"
Const NeedUsernamePasswordString2 = "Требуется Basic‐авторизация"
Const NeedUsernamePasswordString3 = "Пароль не может быть пустым"

Const HttpCreated201_1 = "Ресурс успешно создан."
Const HttpCreated201_2 = "Ресурс успешно обновлён."

Const MovedPermanently1 = "Ресурс перекатился на адрес <a href="""
Const MovedPermanently2 = """>"
Const MovedPermanently3 = "</a>. Тебе нужно идти туда."

Const HttpErrorHead1 = "<!DOCTYPE html><html xmlns=""http://www.w3.org/1999/xhtml""><head><meta name=""viewport"" content=""width=device-width, initial-scale=1"" /><title>"
Const HttpErrorHead2 = "</title></head>"
Const HttpErrorBody1 = "<body><h1>"
Const ServerErrorString = "Серверная"
Const ClientErrorString = "Клиентская"
Const HttpErrorBody2 = " ошибка в приложении «"
Const HttpErrorBody3 = "»</h1><h2>Ошибка HTTP "
Const HttpErrorBody4 = " — "
Const HttpErrorBody5 = "</h2><p>"
Const HttpErrorBody6 = "</p><p>Посетить <a href=""/"">главную страницу</a> сайта.</p></body></html>"

Const HttpErrorContentType = "text/html; charset=utf-16"
Const DefaultContentLanguage = "ru, ru-RU"

Const DefaultHeaderWwwAuthenticate = "Basic realm=""Need username and password"""
Const DefaultHeaderWwwAuthenticate1 = "Basic realm=""Authorization"""
Const DefaultHeaderWwwAuthenticate2 = "Basic realm=""Use Basic auth"""


Function FormatErrorMessageBody(ByVal Buffer As WString Ptr, ByVal StatusCode As Integer, ByVal VirtualPath As WString Ptr, ByVal strMessage As WString Ptr)As LongInt
	Dim strStatusCode As WString * 8 = Any
	itow(StatusCode, @strStatusCode, 10) ' Число в строку
	
	Dim desc As WString * 32 = Any
	GetStatusDescription(@desc, statusCode)
	
	lstrcpy(Buffer, HttpErrorHead1)
	lstrcat(Buffer, @desc) ' тег <title>
	lstrcat(Buffer, HttpErrorHead2)
	
	lstrcat(Buffer, HttpErrorBody1)
	
	' Заголовок <h1>
	If statusCode >= 500 Then
		lstrcat(Buffer, @ServerErrorString)
	Else
		lstrcat(Buffer, @ClientErrorString)
	End If
	
	lstrcat(Buffer, HttpErrorBody2)
	' Имя приложения в заголовке <h1>
	lstrcat(Buffer, VirtualPath)
	lstrcat(Buffer, HttpErrorBody3)
	' Код статуса в заголовке <h2>
	lstrcat(Buffer, @strStatusCode)
	lstrcat(Buffer, HttpErrorBody4)
	' Описание ошибки в заголовке <h2>
	lstrcat(Buffer, desc)
	lstrcat(Buffer, HttpErrorBody5)
	' Текст сообщения между <p></p>
	lstrcat(Buffer, strMessage)
	lstrcat(Buffer, HttpErrorBody6)
	Return lstrlen(Buffer)
End Function

Sub WriteHttpError(ByVal state As ReadHeadersResult Ptr, ByVal ClientSocket As SOCKET, ByVal MessageType As HttpErrors, ByVal VirtualPath As WString Ptr, ByVal hOutput As Handle)
	state->ResponseHeaders(HttpResponseHeaderIndices.HeaderContentType) = @HttpErrorContentType
	state->ResponseHeaders(HttpResponseHeaderIndices.HeaderContentLanguage) = @DefaultContentLanguage
	state->KeepAlive = False
	
	Dim Body As ZString * (MaxHttpErrorBuffer * SizeOf(WString) + SizeOf(WString) + 1) = Any
	' Метка BOM (FFFE) для utf-16 LE
	Body[0] = 255
	Body[1] = 254
	
	Dim strMessage As WString Ptr = Any
	Select Case MessageType
		Case HttpErrors.HttpCreated
			strMessage = @HttpCreated201_1
		Case HttpErrors.HttpCreatedUpdated
			strMessage = @HttpCreated201_2
		Case HttpErrors.HttpError400BadRequest
			strMessage = @HttpError400BadRequest
		Case HttpErrors.HttpError400BadPath
			strMessage = @HttpError400BadPath
		Case HttpErrors.HttpError400Host
			strMessage = @HttpError400Host
		Case HttpErrors.HttpError403File
			strMessage = @HttpError403File
		Case HttpErrors.HttpError411LengthRequired
			strMessage = @HttpError411LengthRequired
		Case HttpErrors.HttpError413RequestEntityTooLarge
			strMessage = @HttpError413RequestEntityTooLarge
		Case HttpErrors.HttpError414RequestUrlTooLarge
			strMessage = @HttpError414RequestUrlTooLarge
		Case HttpErrors.HttpError431RequestRequestHeaderFieldsTooLarge
			strMessage = @HttpError431RequestRequestHeaderFieldsTooLarge
		Case HttpErrors.HttpError500ThreadError
			strMessage = @HttpError500ThreadError
		Case HttpErrors.HttpError500NotAvailable
			strMessage = @HttpError500NotAvailable
		Case HttpErrors.HttpError501MethodNotAllowed
			strMessage = @HttpError501MethodNotAllowed
		Case HttpErrors.HttpError501ContentTypeEmpty
			strMessage = @HttpError501ContentTypeEmpty
		Case HttpErrors.HttpError501ContentEncoding
			strMessage = @HttpError501ContentEncoding
		Case HttpErrors.HttpError502BadGateway
			strMessage = @HttpError502BadGateway
		Case HttpErrors.HttpError503Memory
			strMessage = @HttpError503Memory
		Case HttpErrors.HttpError504GatewayTimeout
			strMessage = @HttpError504GatewayTimeout
		Case HttpErrors.HttpError505VersionNotSupported
			strMessage = @HttpError505VersionNotSupported
		Case HttpErrors.NeedUsernamePasswordString
			strMessage = @NeedUsernamePasswordString
		Case HttpErrors.NeedUsernamePasswordString1
			strMessage = @NeedUsernamePasswordString1
		Case HttpErrors.NeedUsernamePasswordString2
			strMessage = @NeedUsernamePasswordString2
		Case HttpErrors.NeedUsernamePasswordString3
			strMessage = @NeedUsernamePasswordString3
		Case HttpErrors.HttpError404FileNotFound
			strMessage = @HttpError404FileNotFound
		Case HttpErrors.HttpError410Gone
			strMessage = @HttpError410Gone
	End Select
	
	Dim ContentLength As LongInt = FormatErrorMessageBody(CPtr(WString Ptr, @Body[2]), state->StatusCode, VirtualPath, strMessage) * SizeOf(WString) + 2
	
	' Заголовки
	Dim SendBuffer As ZString * (ReadHeadersResult.MaxResponseHeaderBuffer + 1) = Any
	send(ClientSocket, @SendBuffer, state->MakeResponseHeaders(@SendBuffer, ContentLength, hOutput), 0)
	' Тело
	send(ClientSocket, @Body, ContentLength, 0)
End Sub

Sub WriteHttp201(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal hOutput As Handle)
	
	If state->StatusCode = 201 Then
		WriteHttpError(state, ClientSocket, HttpErrors.HttpCreated, www->VirtualPath, hOutput)
	Else
		WriteHttpError(state, ClientSocket, HttpErrors.HttpCreatedUpdated, www->VirtualPath, hOutput)
	End If
	
End Sub

Sub WriteHttp301Error(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal hOutput As Handle)
	state->StatusCode = 301
	Dim buf As WString * (URI.MaxUrlLength * 2 + 1) = Any
	lstrcpy(@buf, www->MovedUrl)
	lstrcat(@buf, state->URI.Url)
	state->ResponseHeaders(HttpResponseHeaderIndices.HeaderLocation) = @buf
	
	' Сделать экранирование символов <>'"&
	Dim strSafe As WString * (URI.MaxUrlLength * 6 + 1) = Any
	GetSafeString(@strSafe, buf)
	
	Dim MovedMessage As WString * (URI.MaxUrlLength * 7 + 1) = Any
	lstrcpy(@MovedMessage, @MovedPermanently1)
	lstrcat(@MovedMessage, @strSafe)
	lstrcat(@MovedMessage, @MovedPermanently2)
	lstrcat(@MovedMessage, @strSafe)
	lstrcat(@MovedMessage, @MovedPermanently3)
	
	' WriteHttpError(state, ClientSocket, @MovedMessage, www->VirtualPath, hOutput)
End Sub

Function HttpAuthUtil(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal hOutput As Handle)As Boolean
	Dim intHttpAuth As HttpAuthResult = state->HttpAuth(www)
	If intHttpAuth <> HttpAuthResult.Success Then
		state->StatusCode = 401
		Select Case intHttpAuth
			Case HttpAuthResult.NeedAuth
				' Требуется авторизация
				state->ResponseHeaders(HttpResponseHeaderIndices.HeaderWwwAuthenticate) = @DefaultHeaderWwwAuthenticate
				WriteHttpError(state, ClientSocket, HttpErrors.NeedUsernamePasswordString, @www->VirtualPath, hOutput)
			Case HttpAuthResult.BadAuth
				' Параметры авторизации неверны
				state->ResponseHeaders(HttpResponseHeaderIndices.HeaderWwwAuthenticate) = @DefaultHeaderWwwAuthenticate1
				WriteHttpError(state, ClientSocket, HttpErrors.NeedUsernamePasswordString1, @www->VirtualPath, hOutput)
			Case HttpAuthResult.NeedBasicAuth
				' Необходимо использовать Basic‐авторизацию
				state->ResponseHeaders(HttpResponseHeaderIndices.HeaderWwwAuthenticate) = @DefaultHeaderWwwAuthenticate2
				WriteHttpError(state, ClientSocket, HttpErrors.NeedUsernamePasswordString2, @www->VirtualPath, hOutput)
			Case HttpAuthResult.EmptyPassword
				' Пароль не может быть пустым
				state->ResponseHeaders(HttpResponseHeaderIndices.HeaderWwwAuthenticate) = @DefaultHeaderWwwAuthenticate
				WriteHttpError(state, ClientSocket, HttpErrors.NeedUsernamePasswordString3, @www->VirtualPath, hOutput)
			Case HttpAuthResult.BadUserNamePassword
				' Имя пользователя или пароль не подходят
				state->ResponseHeaders(HttpResponseHeaderIndices.HeaderWwwAuthenticate) = @DefaultHeaderWwwAuthenticate
				WriteHttpError(state, ClientSocket, HttpErrors.NeedUsernamePasswordString, @www->VirtualPath, hOutput)
		End Select
		Return False
	End If
	Return True
End Function
