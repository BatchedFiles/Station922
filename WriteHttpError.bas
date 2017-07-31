#include once "WriteHttpError.bi"
#include once "HttpConst.bi"
#include once "WebUtils.bi"

' Размер буфера в символах для записи в него кода html страницы с ошибкой
Const MaxHttpErrorBuffer As Integer = 16 * 1024 - 1

Sub WriteHttpError(ByVal state As ReadHeadersResult Ptr, ByVal ClientSocket As SOCKET, ByVal strMessage As WString Ptr, ByVal VirtualPath As WString Ptr, ByVal hOutput As Handle)
	state->ResponseHeaders(HttpResponseHeaderIndices.HeaderContentType) = @HttpErrorContentType
	state->ResponseHeaders(HttpResponseHeaderIndices.HeaderContentLanguage) = @DefaultContentLanguage
	state->KeepAlive = False
	
	Dim Body As ZString * (MaxHttpErrorBuffer * SizeOf(WString) + SizeOf(WString) + 1) = Any
	' Метка BOM (FFFE) для utf-16 LE
	Body[0] = 255
	Body[1] = 254
	Dim ContentLength As LongInt = FormatErrorMessageBody(CPtr(WString Ptr, @Body[2]), state->StatusCode, VirtualPath, strMessage) * SizeOf(WString) + 2
	
	' Заголовки
	Dim SendBuffer As ZString * (ReadHeadersResult.MaxResponseHeaderBuffer + 1) = Any
	send(ClientSocket, @SendBuffer, state->MakeResponseHeaders(@SendBuffer, ContentLength, hOutput), 0)
	' Тело
	send(ClientSocket, @Body, ContentLength, 0)
End Sub

Sub WriteHttp201(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal hOutput As Handle)
	
	Dim MovedMessage As WString * (URI.MaxUrlLength * 7 + 1) = Any
	If state->StatusCode = 201 Then
		lstrcpy(@MovedMessage, @HttpCreated201_1)
	Else
		lstrcpy(@MovedMessage, @HttpCreated201_2)
	End If
	
	WriteHttpError(state, ClientSocket, @MovedMessage, www->VirtualPath, hOutput)
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
	
	WriteHttpError(state, ClientSocket, @MovedMessage, www->VirtualPath, hOutput)
End Sub

Sub WriteNotFoundError(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal hOutput As Handle)
	Dim buf410 As WString * (WebSite.MaxFilePathTranslatedLength + 1) = Any
	lstrcpy(buf410, @www->PathTranslated)
	lstrcat(buf410, ".410")
	
	Dim strSafe As WString * (WebSite.MaxFilePathTranslatedLength * 6 + 1) = Any
	GetSafeString(@strSafe, @www->FilePath)
	
	Dim hFile410 As HANDLE = CreateFile(@buf410, 0, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL)
	If hFile410 = INVALID_HANDLE_VALUE Then
		' Файлы не существует, но она может появиться позже
		state->StatusCode = 404
		Dim bufFileNotFound As WString * (WebSite.MaxFilePathTranslatedLength * 10 + 1) = Any
		lstrcpy(@bufFileNotFound, @HttpError404FileNotFound1)
		lstrcat(@bufFileNotFound, @strSafe)
		lstrcat(@bufFileNotFound, @HttpError404FileNotFound2)
		WriteHttpError(state, ClientSocket, @bufFileNotFound, www->VirtualPath, hOutput)
	Else
		' Файла раньше существовала, но теперь удалена навсегда
		CloseHandle(hFile410)
		state->StatusCode = 410
		Dim bufFileNotFound As WString * (WebSite.MaxFilePathTranslatedLength * 10 + 1) = Any
		lstrcpy(@bufFileNotFound, @HttpError410Gone1)
		lstrcat(@bufFileNotFound, @strSafe)
		lstrcat(@bufFileNotFound, @HttpError410Gone2)
		WriteHttpError(state, ClientSocket, @bufFileNotFound, www->VirtualPath, hOutput)
	End If
End Sub
