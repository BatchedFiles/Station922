#include once "ProcessDeleteRequest.bi"
#include once "HttpConst.bi"
#include once "WriteHttpError.bi"
#include once "WebUtils.bi"

Function ProcessDeleteRequest( _
		ByVal state As ReadHeadersResult Ptr, _
		ByVal ClientSocket As SOCKET, _
		ByVal www As WebSite Ptr, _
		ByVal hOutput As Handle, _
		ByVal hFile As Handle _
	)As Boolean
	If hFile = INVALID_HANDLE_VALUE Then
		' TODO Проверить код ошибки через GetLastError, могут быть не только File Not Found.
		' Файла не существет, записать ошибку клиенту
		Dim buf410 As WString * (WebSite.MaxFilePathTranslatedLength + 1) = Any
		lstrcpy(buf410, @www->PathTranslated)
		lstrcat(buf410, @FileGoneExtension)
		
		Dim hFile410 As HANDLE = CreateFile(@buf410, 0, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL)
		If hFile410 = INVALID_HANDLE_VALUE Then
			' Файлы не существует, но она может появиться позже
			state->ServerResponse.StatusCode = 404
			WriteHttpError(state, ClientSocket, HttpErrors.HttpError404FileNotFound, www->VirtualPath, hOutput)
		Else
			' Файла раньше существовала, но теперь удалена навсегда
			CloseHandle(hFile410)
			state->ServerResponse.StatusCode = 410
			WriteHttpError(state, ClientSocket, HttpErrors.HttpError410Gone, www->VirtualPath, hOutput)
		End If
		Return False
	End If
	CloseHandle(hFile)
	
	' Проверка заголовка Authorization
	If HttpAuthUtil(state, ClientSocket, www, hOutput) = False Then
		Return False
	End If
	
	' Необходимо удалить файл
	If DeleteFile(@www->PathTranslated) <> 0 Then
		' Удалить возможные заголовочные файлы
		Dim sExtHeadersFile As WString * (WebSite.MaxFilePathTranslatedLength + 1) = Any
		lstrcpy(@sExtHeadersFile, @www->PathTranslated)
		lstrcat(@sExtHeadersFile, @HeadersExtensionString)
		DeleteFile(@sExtHeadersFile)
		
		' Создать файл «.410», показывающий, что файл был удалён
		lstrcpy(@sExtHeadersFile, @www->PathTranslated)
		lstrcat(@sExtHeadersFile, @FileGoneExtension)
		Dim hFile As HANDLE = CreateFile(@sExtHeadersFile, GENERIC_WRITE, 0, NULL, CREATE_NEW, FILE_ATTRIBUTE_NORMAL, NULL)
		CloseHandle(hFile)
	Else
		' Ошибка
		' TODO Узнать код ошибки и отправить его клиенту
		state->ServerResponse.StatusCode = 500
		WriteHttpError(state, ClientSocket, HttpErrors.HttpError500NotAvailable, @www->VirtualPath, hOutput)
		Return False
	End If
	' Отправить заголовки, что нет содержимого
	state->ServerResponse.StatusCode = 204
	Dim SendBuffer As ZString * (WebResponse.MaxResponseHeaderBuffer + 1) = Any
	If send(ClientSocket, @SendBuffer, state->AllResponseHeadersToBytes(@SendBuffer, 0, hOutput), 0) = SOCKET_ERROR Then
		Return False
	End If
	
	Return True
End Function
