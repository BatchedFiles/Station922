#include once "ProcessRequests.bi"
#include once "Mime.bi"
#include once "HttpConst.bi"
#include once "WebUtils.bi"
#include once "Network.bi"
#include once "IniConst.bi"
#include once "URI.bi"
#include once "CharConstants.bi"
#include once "WriteHttpError.bi"

/'
	Методы MOVE и COPY
	
	Request
	MOVE /pub2/folder1/ HTTP/1.1
	Destination: http://www.contoso.com/pub2/folder2/
	Host: www.contoso.com
	
	Response
	HTTP/1.1 201 Created
	Location: http://www.contoso.com/pub2/folder2/
	
	Ответы:
	201 The resource was moved successfully and a new resource was created at the specified destination URI.
	204 The resource was moved successfully to a pre-existing destination URI.
	403 The source URI and the destination URI are the same.
	409 (Conflict) A resource cannot be created at the destination URI until one or more intermediate collections are created.
	412 (Precondition Failed) Either the Overwrite header is "F" and the state of the destination resource is not null, or the method was used in a Depth: 0 transaction.
	423 (Locked) The destination resource is locked.
	502 (Bad Gateway) The destination URI is located on a different server, which refuses to accept the resource.
	507 (Insufficient Storage) The destination resource does not have sufficient storage space.
'/

Function ProcessGetHeadRequest(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal fileExtention As WString Ptr, ByVal hOutput As Handle, ByVal hFile As Handle)As Boolean
	If hFile = INVALID_HANDLE_VALUE Then
		' Проверить код ошибки через GetLastError, могут быть не только File Not Found.
		' Файла не существет, записать ошибку клиенту
		WriteNotFoundError(ClientSocket, state, www, hOutput)
		Return True
	End If
	
	' Не обрабатываем файлы с неизвестным типом
	Dim mt As MimeType = GetMimeTypeOfExtension(fileExtention)
	If mt.ContentType = ContentTypes.None Then
		state->StatusCode = 403
		WriteHttpError(state, ClientSocket, @HttpError403File, @www->VirtualPath, hOutput)
		Return False
	End If
	
	' TODO Проверить идентификацию для запароленных ресурсов
	
	' Строка с типом документа
	Dim wContentType As WString * (MaxContentTypeLength + 1) = Any
	GetStringOfContentType(@wContentType, mt.ContentType)
	state->ResponseHeaders(HttpResponseHeaderIndices.HeaderContentType) = @wContentType
	
	Dim hZipFile As Handle = state->SetResponseCompression(mt.IsTextFormat, @www->PathTranslated)
	
	state->AddResponseCacheHeaders(hFile)
	
	' Нельзя отображать файлы нулевого размера
	Dim FileSize As LARGE_INTEGER = Any
	Dim GetFileSizeExResult As Integer = Any
	If hZipFile = INVALID_HANDLE_VALUE Then
		GetFileSizeExResult = GetFileSizeEx(hFile, @FileSize)
	Else
		GetFileSizeExResult = GetFileSizeEx(hZipFile, @FileSize)
	End If
	
	If GetFileSizeExResult = 0 Then
		' TODO узнать причину неудачи через GetLastError() = ERROR_ALREADY_EXISTS
		state->StatusCode = 500
		WriteHttpError(state, ClientSocket, @HttpError500NotAvailable, @www->VirtualPath, hOutput)
	Else
		If FileSize.QuadPart = 0 Then
			' Создать заголовки ответа и отправить клиенту
			Dim SendBuffer As ZString * (ReadHeadersResult.MaxResponseHeaderBuffer + 1) = Any
			send(ClientSocket, @SendBuffer, state->MakeResponseHeaders(@SendBuffer, 0, hOutput), 0)
		Else
			' Отобразить файл
			Dim hFileMap As Handle = Any
			If hZipFile = INVALID_HANDLE_VALUE Then
				hFileMap = CreateFileMapping(hFile, 0, PAGE_READONLY, 0, 0, 0)
			Else
				hFileMap = CreateFileMapping(hZipFile, 0, PAGE_READONLY, 0, 0, 0)
			End If
			If hFileMap = 0 Then
				' TODO узнать причину неудачи через GetLastError() = ERROR_ALREADY_EXISTS
				' Чтение файла завершилось неудачей
				state->StatusCode = 500
				WriteHttpError(state, ClientSocket, @HttpError500NotAvailable, @www->VirtualPath, hOutput)
			Else
				' Всё хорошо
				' Создать представление файла
				Dim b As UByte Ptr = CPtr(UByte Ptr, MapViewOfFile(hFileMap, FILE_MAP_READ, 0, 0, 0))
				If b = 0 Then
					' Чтение файла завершилось неудачей
					' TODO Узнать код ошибки и отправить его клиенту
					state->StatusCode = 500
					WriteHttpError(state, ClientSocket, @HttpError500NotAvailable, @www->VirtualPath, hOutput)
				Else
					' TODO Проверить частичный запрос
					REM If state->RequestHeaders(HttpRequestHeaderIndices.HeaderRange) = 0 Then
						REM ' Выдать всё содержимое от начала до конца
					REM Else
						REM ' Выдать только диапазон
						REM Range: bytes=0-255 — фрагмент от 0-го до 255-го байта включительно.
						REM Range: bytes=42-42 — запрос одного 42-го байта.
						REM Range: bytes=4000-7499,1000-2999 — два фрагмента. Так как первый выходит за пределы, то он интерпретируется как «4000-4999».
						REM Range: bytes=3000-,6000-8055 — первый интерпретируется как «3000-4999», а второй игнорируется.
						REM Range: bytes=-400,-9000 — последние 400 байт (от 4600 до 4999), а второй подгоняется под рамки содержимого (от 0 до 4999) обозначая как фрагмент весь объём.
						REM Range: bytes=500-799,600-1023,800-849 — при пересечениях диапазоны могут объединяться в один (от 500 до 1023).
						
						REM HTTP/1.1 206 Partial Content
						REM Обратите внимание на заголовок Content-Length — в нём указывается размер тела сообщения, то есть передаваемого фрагмента. Если сервер вернёт несколько фрагментов, то Content-Length будет содержать их суммарный объём.
						REM 'Content-Range: bytes 471104-2355520/2355521
						REM 'state.ResponseHeaders(HttpResponseHeaderIndices.HeaderContentRange) = "bytes 471104-2355520/2355521"
					REM End If
					
					Dim Index As Integer = Any ' Смещение относительно начала файла, чтобы не отправлять BOM
					If mt.IsTextFormat Then
						If hZipFile = INVALID_HANDLE_VALUE Then
							' b указывает на настоящий файл
							If FileSize.QuadPart > 3 Then
								Select Case GetDocumentCharset(b)
									Case DocumentCharsets.ASCII
										' Ничего
										Index = 0
									Case DocumentCharsets.Utf8BOM
										lstrcat(wContentType, @ContentCharsetUtf8)
										Index = 3
									Case DocumentCharsets.Utf16LE
										lstrcat(wContentType, @ContentCharsetUtf16)
										Index = 0
									Case DocumentCharsets.Utf16BE
										lstrcat(wContentType, @ContentCharsetUtf16)
										Index = 2
								End Select
							Else
								' Кодировка ASCII
								Index = 0
							End If
						Else
							' b указывает на сжатый файл
							Index = 0
							Dim b2 As ZString * 4 = Any
							Dim BytesCount As DWORD = Any
							ReadFile(hFile, @b2, 3, @BytesCount, 0)
							If BytesCount >= 3 Then
								Select Case GetDocumentCharset(b)
									Case DocumentCharsets.ASCII
										' Ничего
									Case DocumentCharsets.Utf8BOM
										lstrcat(wContentType, @ContentCharsetUtf8)
									Case DocumentCharsets.Utf16LE
										lstrcat(wContentType, @ContentCharsetUtf16)
									Case DocumentCharsets.Utf16BE
										lstrcat(wContentType, @ContentCharsetUtf16)
								End Select
							REM Else
								REM ' Кодировка ASCII
							End If
						End If
					Else
						Index = 0
					End If
					
					' Отправить дополнительные заголовки ответа
					Dim sExtHeadersFile As WString * (WebSite.MaxFilePathTranslatedLength + 1) = Any
					lstrcpy(@sExtHeadersFile, @www->PathTranslated)
					lstrcat(@sExtHeadersFile, @HeadersExtensionString)
					Dim hExtHeadersFile As HANDLE = CreateFile(@sExtHeadersFile, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL)
					If hExtHeadersFile <> INVALID_HANDLE_VALUE Then
						Dim zExtHeaders As ZString * (ReadHeadersResult.MaxResponseHeaderBuffer + 1) = Any
						Dim wExtHeaders As WString * (ReadHeadersResult.MaxResponseHeaderBuffer + 1) = Any
						
						Dim BytesCount As DWORD = Any
						If ReadFile(hExtHeadersFile, @zExtHeaders, ReadHeadersResult.MaxResponseHeaderBuffer, @BytesCount, 0) <> 0 Then
							If BytesCount > 2 Then
								zExtHeaders[BytesCount] = 0
								If MultiByteToWideChar(CP_UTF8, 0, @zExtHeaders, -1, @wExtHeaders, ReadHeadersResult.MaxResponseHeaderBuffer) > 0 Then
									Dim w As WString Ptr = @wExtHeaders
									Do
										Dim wName As WString Ptr = w
										' Найти двоеточие
										Dim wColon As WString Ptr = StrChr(w, ColonChar)
										' Найти vbCrLf и убрать
										w = StrStr(w, NewLineString)
										If w <> 0 Then
											w[0] = 0 ' и ещё w[1] = 0
											' Указываем на следующий символ после vbCrLf, если это ноль — то это конец
											w += 2
										End If
										If wColon > 0 Then
											wColon[0] = 0
											Do
												wColon += 1
											Loop While wColon[0] = 32
											state->AddResponseHeader(wName, wColon)
										End If
									Loop While lstrlen(w) > 0
								End If
							End If
						End If
						CloseHandle(hExtHeadersFile)
						#if __FB_DEBUG__ <> 0
							Print "Закрываю файл заголовков hExtHeadersFile"
						#endif
					End If
					
					' Создать и отправить заголовки ответа
					Dim SendBuffer As ZString * (ReadHeadersResult.MaxResponseHeaderBuffer + 1) = Any
					send(ClientSocket, @SendBuffer, state->MakeResponseHeaders(@SendBuffer, FileSize.QuadPart - CLng(Index), hOutput), 0)
					
					' Тело
					If state->SendOnlyHeaders = False Then
						send(ClientSocket, b + Index, CInt(FileSize.QuadPart - CLng(Index)), 0)
					End If
					
					' Закрыть
					UnmapViewOfFile(b)
				End If
				CloseHandle(hFileMap)
				#if __FB_DEBUG__ <> 0
					Print "Закрываю отображённый в память файл hFileMap"
				#endif
			End If
		End If
	End If
	
	' Закрыть
	If hZipFile <> INVALID_HANDLE_VALUE Then
		CloseHandle(hZipFile)
		#if __FB_DEBUG__ <> 0
			Print "Закрываю сжатый файл hZipFile"
		#endif
	End If
	CloseHandle(hFile)
	#if __FB_DEBUG__ <> 0
		Print "Закрываю файл hFile"
	#endif
	Return True
End Function

Function ProcessDeleteRequest(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal fileExtention As WString Ptr, ByVal hOutput As Handle, ByVal hFile As Handle)As Boolean
	If hFile = INVALID_HANDLE_VALUE Then
		' Файла не существет, записать ошибку клиенту
		WriteNotFoundError(ClientSocket, state, www, hOutput)
		Return True
	End If
	CloseHandle(hFile)
	
	Dim mt As MimeType = GetMimeTypeOfExtension(fileExtention)
	If mt.ContentType = ContentTypes.None Then
		' Не обрабатываем файлы с неизвестным типом
		state->StatusCode = 403
		WriteHttpError(state, ClientSocket, @HttpError403File, @www->VirtualPath, hOutput)
		Return False
	End If
	
	' Проверка заголовка Authorization
	If HttpAuthUtil(ClientSocket, state, www, hOutput) = False Then
		Return True
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
		state->StatusCode = 500
		WriteHttpError(state, ClientSocket, @HttpError500NotAvailable, @www->VirtualPath, hOutput)
		Return True
	End If
	' Отправить заголовки, что нет содержимого
	state->StatusCode = 204
	Dim SendBuffer As ZString * (ReadHeadersResult.MaxResponseHeaderBuffer + 1) = Any
	send(ClientSocket, @SendBuffer, state->MakeResponseHeaders(@SendBuffer, 0, hOutput), 0)
	
	Return True
End Function

Function ProcessPutRequest(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal fileExtention As WString Ptr, ByVal hOutput As Handle)As Boolean
	' Проверка авторизации пользователя
	If HttpAuthUtil(ClientSocket, state, www, hOutput) = False Then
		Return True
	End If
	
	' Если какой-то из переданных серверу заголовков Content-* не опознан или не может быть использован в данной ситуации
	' сервер возвращает статус ошибки 501 (Not Implemented).
	' Если ресурс с указанным URI не может быть создан или модифицирован,
	' должно быть послано соответствующее сообщение об ошибке. 
	
	' Не указан тип содержимого
	If lstrlen(state->RequestHeaders(HttpRequestHeaderIndices.HeaderContentType)) = 0 Then
		state->StatusCode = 501
		WriteHttpError(state, ClientSocket, @HttpError501ContentTypeEmpty, @www->VirtualPath, hOutput)
		Return True
	End If
	' TODO Проверить тип содержимого
	
	' Сжатое содержимое не поддерживается
	If lstrlen(state->RequestHeaders(HttpRequestHeaderIndices.HeaderContentEncoding)) <> 0 Then
		state->StatusCode = 501
		WriteHttpError(state, ClientSocket, @HttpError501ContentEncoding, @www->VirtualPath, hOutput)
		Return True
	End If
	
	' Требуется указание длины
	If lstrlen(state->RequestHeaders(HttpRequestHeaderIndices.HeaderContentLength)) = 0 Then
		state->StatusCode = 411
		WriteHttpError(state, ClientSocket, @HttpError411LengthRequired, @www->VirtualPath, hOutput)
		Return True
	End If
	
	' Длина содержимого по заголовку Content-Length слишком большая
	Dim RequestBodyContentLength As LARGE_INTEGER = Any
	RequestBodyContentLength.QuadPart = wtol(state->RequestHeaders(HttpRequestHeaderIndices.HeaderContentLength))
	If RequestBodyContentLength.QuadPart > MaxRequestBodyContentLength Then
		state->StatusCode = 413
		WriteHttpError(state, ClientSocket, @HttpError413RequestEntityTooLarge, @www->VirtualPath, hOutput)
		Return True
	End If
	
	REM ' Может быть указана кодировка содержимого
	REM Dim contentType() As String = state.RequestHeaders(HttpRequestHeaderIndices.HeaderContentType).Split(";"c)
	REM Dim kvp = m_ContentTypes.Find(Function(x) x.ContentType = contentType(0))
	REM If kvp Is Nothing Then
		REM ' Такое содержимое нельзя загружать
		REM state.StatusCode = 501
		REM state.ResponseHeaders(HttpResponseHeaderIndices.HeaderAllow) = AllSupportHttpMethodsWithoutPut
		REM state.WriteError(objStream, String.Format(MethodNotAllowed, state.HttpMethod), www.VirtualPath)
		REM Exit Do
	REM End If
	
	' TODO Изменить расширение файла на правильное
	REM ' нельзя оставлять отправленное пользователем расширение
	REM ' указать (новое) имя файла в заголовке Location
	REM state.FilePath = Path.ChangeExtension(state.FilePath, kvp.Extension)
	REM state.PathTranslated = state.MapPath(www.VirtualPath, state.FilePath, www.PhysicalDirectory)
	
	' если ресурс присутствовал и был изменен в результате запроса PUT,
	' выдается код статуса 200 (Ok) или 204 (No Content).
	' В случае отсутствия ресурса по указанному в заголовке URI,
	' сервер создает его и возвращает код статуса 201 (Created),
	
	Dim HeaderLocation As WString * (WebSite.MaxFilePathLength + 1) = Any
	
	' Открыть существующий файл для перезаписи
	Dim hFile As HANDLE = CreateFile(@www->PathTranslated, GENERIC_READ + GENERIC_WRITE, 0, NULL, TRUNCATE_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL)
	If hFile = INVALID_HANDLE_VALUE Then
		' Создать каталог, если ещё не создан
		Dim intError As Integer = GetLastError()
		#if __FB_DEBUG__ <> 0
			Print intError
		#endif
		Select Case intError
			Case ERROR_PATH_NOT_FOUND
				Dim FileDir As WString * (WebSite.MaxFilePathTranslatedLength + 1) = Any
				lstrcpy(@FileDir, @www->PathTranslated)
				PathRemoveFileSpec(@FileDir)
				#if __FB_DEBUG__ <> 0
					Print www->PathTranslated
					Print FileDir
				#endif
				CreateDirectory(@FileDir, Null)
				#if __FB_DEBUG__ <> 0
					Print GetLastError()
				#endif
		End Select
		
		' Открыть файл с нуля
		hFile = CreateFile(@www->PathTranslated, GENERIC_READ + GENERIC_WRITE, 0, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL)
		If hFile = INVALID_HANDLE_VALUE Then
			#if __FB_DEBUG__ <> 0
				Print "Нельзя создать файл"
			#endif
			' Нельзя открыть файл для перезаписи
			' TODO Узнать код ошибки и отправить его клиенту
			state->StatusCode = 500
			WriteHttpError(state, ClientSocket, @HttpError500NotAvailable, @www->VirtualPath, hOutput)
			Return True
		End If
		
		state->StatusCode = 201
		lstrcpy(@HeaderLocation, "http://")
		lstrcat(@HeaderLocation, @www->HostName)
		lstrcat(@HeaderLocation, @www->FilePath)
		state->ResponseHeaders(HttpResponseHeaderIndices.HeaderLocation) = @HeaderLocation
	Else
		' Файл уже существует
		#if __FB_DEBUG__ <> 0
			Print "Файл уже существует"
		#endif
		state->StatusCode = 200
	End If
	
	Dim hFileMap As Handle = CreateFileMapping(hFile, 0, PAGE_READWRITE, RequestBodyContentLength.HighPart, RequestBodyContentLength.LowPart, 0)
	If hFileMap = 0 Then
		#if __FB_DEBUG__ <> 0
			Print "Не могу создать отображение файла в память"
		#endif
		' TODO Узнать код ошибки и отправить его клиенту
		state->StatusCode = 500
		WriteHttpError(state, ClientSocket, @HttpError500NotAvailable, @www->VirtualPath, hOutput)
	Else
		Dim b As Byte Ptr = CPtr(Byte Ptr, MapViewOfFile(hFileMap, FILE_MAP_ALL_ACCESS, 0, 0, 0))
		If b = 0 Then
			#if __FB_DEBUG__ <> 0
				Print "Не могу отобразить файл в память"
			#endif
			' TODO Узнать код ошибки и отправить его клиенту
			state->StatusCode = 500
			WriteHttpError(state, ClientSocket, @HttpError500NotAvailable, @www->VirtualPath, hOutput)
		Else
			' TODO Заголовки записать в специальный файл
			REM HeaderContentEncoding
			REM HeaderContentLanguage
			REM HeaderContentLocation
			REM HeaderContentMd5
			REM HeaderContentType
			
			' Записать предварительно загруженные данные
			Dim PreloadedContentLength As Integer = state->HeaderBytesLength - state->EndHeadersOffset
			If PreloadedContentLength > 0 Then
				memcpy(b, @state->HeaderBytes[state->EndHeadersOffset], PreloadedContentLength)
			End If
			
			' Записать всё остальное
			Do While PreloadedContentLength < RequestBodyContentLength.QuadPart
				Dim numReceived As Integer = recv(ClientSocket, @b[PreloadedContentLength], RequestBodyContentLength.QuadPart - PreloadedContentLength, 0)
				If numReceived > 0 Then
					' Сколько байт получили, на столько и увеличили буфер
					PreloadedContentLength += numReceived
				Else
					Exit Do
				End If
			Loop
			
			' Удалить файл 410, если он был
			Dim PathTranslated410 As WString * (WebSite.MaxFilePathTranslatedLength + 4 + 1) = Any
			lstrcpy(@PathTranslated410, @www->PathTranslated)
			lstrcat(@PathTranslated410, @FileGoneExtension)
			DeleteFile(@PathTranslated410) ' не проверяем ошибку удаления
			
			' Отправить клиенту текст, что всё хорошо и закрыть соединение
			WriteHttp201(ClientSocket, state, www, hOutput)
			
			UnmapViewOfFile(b)
		End If
		CloseHandle(hFileMap)
	End If
	CloseHandle(hFile)
	Return True
End Function

Function ProcessTraceRequest(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal hOutput As Handle)As Boolean
	' Собрать все заголовки запроса и сформировать из них тело ответа
	
	' Строка с типом документа
	Dim wContentType As WString * (MaxContentTypeLength + 1) = Any
	GetStringOfContentType(@wContentType, ContentTypes.MessageHttp)
	lstrcat(@wContentType, @ContentCharset8bit)
	
	state->StatusCode = 200
	state->ResponseHeaders(HttpResponseHeaderIndices.HeaderContentType) = @wContentType
	
	' Заголовки
	Dim SendBuffer As ZString * (ReadHeadersResult.MaxResponseHeaderBuffer + 1) = Any
	send(ClientSocket, @SendBuffer, state->MakeResponseHeaders(@SendBuffer, CLng(state->EndHeadersOffset), hOutput), 0)
	
	' Тело
	send(ClientSocket, @state->HeaderBytes, state->EndHeadersOffset, 0)
	Return True
End Function

Function ProcessOptionsRequest(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal hOutput As Handle)As Boolean
	state->StatusCode = 204 ' нет содержимого
	REM ' Если звёздочка, то ко всему серверу
	' If lstrcmp(@state->Path, "*") = 0 Then
		' state->ResponseHeaders(HttpResponseHeaderIndices.HeaderAllow) = @AllSupportHttpMethodsServer
	' Else
		' If hFile = INVALID_HANDLE_VALUE Then
			' Файла не существет, записать ошибку клиенту
			' WriteNotFoundError(ClientSocket, state, www, hOutput)
			' Return True
		' End If
		' К конкретному ресурсу
		REM If m_AspNetProcessingFiles.Contains(fileExtention) Then
			REM ' Файл обрабатывается процессором, значит может обработать разные методы
			REM state.ResponseHeaders(HttpResponseHeaderIndices.HeaderAllow) = AllSupportHttpMethods
		REM Else
			state->ResponseHeaders(HttpResponseHeaderIndices.HeaderAllow) = @AllSupportHttpMethodsServer
		REM End If
	' End If
	' CloseHandle(hFile)
	
	' Заголовки
	Dim SendBuffer As ZString * (ReadHeadersResult.MaxResponseHeaderBuffer + 1) = Any
	send(ClientSocket, @SendBuffer, state->MakeResponseHeaders(@SendBuffer, 0, hOutput), 0)
	Return True
End Function

Function ProcessConnectRequest(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal hOutput As Handle)As Boolean
	' Проверка заголовка Authorization
	If HttpAuthUtil(ClientSocket, state, www, hOutput) = False Then
		Return True
	End If
	
	' Файл с настройками
	Dim IniFileName As WString * (MAX_PATH + 1) = Any
	PathCombine(@IniFileName, @www->PhysicalDirectory, @WebServerIniFileString)
	
	Dim ConnectBindAddress As WString * 256 = Any
	Dim ConnectBindPort As WString * 16 = Any
	GetPrivateProfileString(@WebServerSectionString, @ConnectBindAddressSectionString, @DefaultAddressString, @ConnectBindAddress, 255, @IniFileName)
	GetPrivateProfileString(@WebServerSectionString, @ConnectBindPortSectionString, @ConnectBindDefaultPort, @ConnectBindPort, 15, @IniFileName)
	
	' Соединиться с сервером
	Dim ServiceName As WString Ptr = Any
	Dim wColon As WString Ptr = StrChr(state->RequestHeaders(HttpRequestHeaderIndices.HeaderHost), ColonChar)
	If wColon = 0 Then
		ServiceName = @DefaultHttpPort
	Else
		wColon[0] = 0
		If lstrlen(wColon + 1) = 0 Then
			ServiceName = @DefaultHttpPort
		Else
			ServiceName = wColon + 1
		End If
	End If
	
	Dim ServerSocket2 As SOCKET = ConnectToServer(state->RequestHeaders(HttpRequestHeaderIndices.HeaderHost), ServiceName, @ConnectBindAddress, @ConnectBindPort)
	If ServerSocket2 = INVALID_SOCKET Then
		' Не могу соединиться
		state->StatusCode = 504
		WriteHttpError(state, ClientSocket, @HttpError504GatewayTimeout, @www->VirtualPath, hOutput)
		Return True
	End If

	' Отправить ответ о статусе соединения
	state->StatusCode = 200
	Dim SendBuffer As ZString * (ReadHeadersResult.MaxResponseHeaderBuffer + 1) = Any
	send(ClientSocket, @SendBuffer, state->MakeResponseHeaders(@SendBuffer, 0, hOutput), 0)
	
	' Читать данные от клиента, отправлять на сервер
	Dim CSS As ClientServerSocket = Any
	CSS.OutSock = ServerSocket2
	CSS.InSock = ClientSocket
	CSS.hThread = CreateThread(NULL, 0, @SendReceiveDataThreadProc, @CSS, 0, @CSS.ThreadId)
	
	' Читать данные от сервера, отправлять клиенту
	SendReceiveData(ClientSocket, ServerSocket2)
	
	Return True
	
End Function

Function HttpAuthUtil(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal hOutput As Handle)As Boolean
	Dim intHttpAuth As HttpAuthResult = state->HttpAuth(www)
	If intHttpAuth <> HttpAuthResult.Success Then
		state->StatusCode = 401
		Select Case intHttpAuth
			Case HttpAuthResult.NeedAuth
				' Требуется авторизация
				state->ResponseHeaders(HttpResponseHeaderIndices.HeaderWwwAuthenticate) = @DefaultHeaderWwwAuthenticate
				WriteHttpError(state, ClientSocket, @NeedUsernamePasswordString, @www->VirtualPath, hOutput)
			Case HttpAuthResult.BadAuth
				' Параметры авторизации неверны
				state->ResponseHeaders(HttpResponseHeaderIndices.HeaderWwwAuthenticate) = @DefaultHeaderWwwAuthenticate1
				WriteHttpError(state, ClientSocket, @NeedUsernamePasswordString1, @www->VirtualPath, hOutput)
			Case HttpAuthResult.NeedBasicAuth
				' Необходимо использовать Basic‐авторизацию
				state->ResponseHeaders(HttpResponseHeaderIndices.HeaderWwwAuthenticate) = @DefaultHeaderWwwAuthenticate2
				WriteHttpError(state, ClientSocket, NeedUsernamePasswordString2, @www->VirtualPath, hOutput)
			Case HttpAuthResult.EmptyPassword
				' Пароль не может быть пустым
				state->ResponseHeaders(HttpResponseHeaderIndices.HeaderWwwAuthenticate) = @DefaultHeaderWwwAuthenticate
				WriteHttpError(state, ClientSocket, NeedUsernamePasswordString3, @www->VirtualPath, hOutput)
			Case HttpAuthResult.BadUserNamePassword
				' Имя пользователя или пароль не подходят
				state->ResponseHeaders(HttpResponseHeaderIndices.HeaderWwwAuthenticate) = @DefaultHeaderWwwAuthenticate
				WriteHttpError(state, ClientSocket, NeedUsernamePasswordString, @www->VirtualPath, hOutput)
		End Select
		Return False
	End If
	Return True
End Function