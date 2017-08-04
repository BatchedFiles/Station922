#include once "ThreadProc.bi"
#include once "win\winsock2.bi"
#include once "win\ws2tcpip.bi"
#include once "Network.bi"

#include once "ReadHeadersResult.bi"
#include once "WebUtils.bi"
#include once "ProcessRequests.bi"
#include once "Http.bi"
#include once "HeapOnArray.bi"
#include once "WriteHttpError.bi"

Function ThreadProc(ByVal lpParam As LPVOID)As DWORD
	Dim param As ThreadParam Ptr = CPtr(ThreadParam Ptr, lpParam)
	' Ожидать чтения данных с клиента 5 минут
	Scope
		Dim ReceiveTimeOut As DWORD = 300 * 1000
		setsockopt(param->ClientSocket, SOL_SOCKET, SO_RCVTIMEO, CPtr(ZString Ptr, @ReceiveTimeOut), SizeOf(DWORD))
	End Scope
	
	#if __FB_DEBUG__ <> 0
		Print "Поток стартовал", param->ThreadId
	#endif
	
	Dim state As ReadHeadersResult = Any
	state.ClientReader.Initialize()
	state.ClientReader.ClientSocket = param->ClientSocket
	
	Do
		state.Initialize()
		
		' Читать запрос клиента
		Select Case state.ReadAllHeaders()
			
			Case ParseRequestLineResult.Success
				' Всё правильно, продолжаем работать дальше
				
			Case ParseRequestLineResult.HTTPVersionNotSupported
				' Версия не поддерживается
				state.StatusCode = 505
				WriteHttpError(@state, param->ClientSocket, HttpErrors.HttpError505VersionNotSupported, @SlashString, param->hOutput)
				Exit Do
				
			Case ParseRequestLineResult.BadRequest
				' Плохой запрос
				state.StatusCode = 400
				WriteHttpError(@state, param->ClientSocket, HttpErrors.HttpError400BadRequest, @SlashString, param->hOutput)
				Exit Do
				
			Case ParseRequestLineResult.BadPath
				' Плохой путь
				state.StatusCode = 400
				WriteHttpError(@state, param->ClientSocket, HttpErrors.HttpError400BadPath, @SlashString, param->hOutput)
				Exit Do
				
			Case ParseRequestLineResult.EmptyRequest
				' Пустой запрос, клиент закрыл соединение
				Exit Do
				
			Case ParseRequestLineResult.SocketError
				' Ошибка сокета
				Exit Do
				
			Case ParseRequestLineResult.RequestUrlTooLong
				' Запрошенный Url слишкой длинный
				state.StatusCode = 414
				WriteHttpError(@state, param->ClientSocket, HttpErrors.HttpError414RequestUrlTooLarge, @SlashString, param->hOutput)
				Exit Do
				
			Case ParseRequestLineResult.RequestHeaderFieldsTooLarge
				' Превышена допустимая длина заголовков
				state.StatusCode = 431
				WriteHttpError(@state, param->ClientSocket, HttpErrors.HttpError431RequestRequestHeaderFieldsTooLarge, @SlashString, param->hOutput)
				Exit Do
				
		End Select
		
		' TODO Заголовок Host может не быть в версии 1.0
		If lstrlen(state.RequestHeaders(HttpRequestHeaderIndices.HeaderHost)) = 0 Then
			state.StatusCode = 400
			WriteHttpError(@state, param->ClientSocket, HttpErrors.HttpError400Host, @SlashString, param->hOutput)
			Exit Do
		End If
		
		#if __FB_DEBUG__ <> 0
			' Распечатать весь запрос
			Print "Распечатываю весь запрос"
			Print state.ClientReader.Buffer
		#endif
		
		' Найти сайт по его имени
		Dim www As WebSite = Any
		If GetWebSite(@www, state.RequestHeaders(HttpRequestHeaderIndices.HeaderHost)) = False Then
			If state.HttpMethod <> HttpMethods.HttpConnect Then
				state.StatusCode = 400
				WriteHttpError(@state, param->ClientSocket, HttpErrors.HttpError400Host, @SlashString, param->hOutput)
				Exit Do
			End If
		End If
		
		If www.IsMoved <> False Then
			' Сайт перемещён на другой ресурс
			' если запрошен документ /robots.txt то не перенаправлять
			If lstrcmpi(state.URI.Url, "/robots.txt") <> 0 Then
				WriteHttp301Error(param->ClientSocket, @state, @www, param->hOutput)
				Exit Do
			End If
		End If
		
		/'
		' Кеширование
		Dim MapFileName As WString * (MAX_PATH + 1) = Any
		lstrcpy(@MapFileName, "FreeBASICWebServer")
		lstrcat(@MapFileName, @www.VirtualPath)
		
		Dim hMapFile As HANDLE = OpenFileMapping(GENERIC_READ + GENERIC_WRITE, False, @MapFileName)
		If hMapFile = 0 Then
			#if __FB_DEBUG__ <> 0
				Print "Создаю отображение файла"
			#endif
			hMapFile = CreateFileMapping(INVALID_HANDLE_VALUE, 0, PAGE_READWRITE, 0, 1024 * 1024, @MapFileName)
			If hMapFile <> 0 Then
				Dim b As WString Ptr = CPtr(WString Ptr, MapViewOfFile(hMapFile, FILE_MAP_ALL_ACCESS, 0, 0, 1024 * 1024))
				' Записать данные в память
				lstrcpy(b, "Сообщение из первого процесса")
				' Выгрузить
				If b <> 0 Then
					UnmapViewOfFile(b)
				End If
			End If
			' Не закрывать hMapFile, чтобы отображение существовало
		Else
			#if __FB_DEBUG__ <> 0
				Print "Открыл отображённый файл"
			#endif
			Dim b As WString Ptr = CPtr(WString Ptr, MapViewOfFile(hMapFile, FILE_MAP_ALL_ACCESS, 0, 0, 1024 * 1024))
			' Прочитать данные из памяти
			Print *b
			' Выгрузить
			If b <> 0 Then
				UnmapViewOfFile(b)
			End If
			CloseHandle(hMapFile)
		End If
		'/
		
		' Обработка запроса
		
		Select Case state.HttpMethod
			
			Case HttpMethods.HttpGet, HttpMethods.HttpHead
				' Отправлять только заголовки
				If state.HttpMethod = HttpMethods.HttpHead Then
					state.SendOnlyHeaders = True
				End If
				ProcessGetHeadRequest( _
						param->ClientSocket, _
						@state, _
						@www, _
						PathFindExtension(@www.PathTranslated), _
						param->hOutput, _
						www.GetFilePath(@state.URI.Path, FileAccess.ForGetHead) _
				)
				
			Case HttpMethods.HttpPut
				www.GetFilePath(@state.URI.Path, FileAccess.ForPut)
				ProcessPutRequest( _
						param->ClientSocket, _
						@state, _
						@www, _
						PathFindExtension(@www.PathTranslated), param->hOutput _
				)
				
			Case HttpMethods.HttpDelete
				ProcessDeleteRequest( _
						param->ClientSocket, _
						@state, _
						@www, _
						PathFindExtension(@www.PathTranslated), _
						param->hOutput, _
						www.GetFilePath(@state.URI.Path, FileAccess.ForDelete) _
				)
				
			Case HttpMethods.HttpOptions
				ProcessOptionsRequest( _
						param->ClientSocket, _
						@state, _
						@www, _
						param->hOutput _
				)
				
			Case HttpMethods.HttpTrace
				ProcessTraceRequest( _
						param->ClientSocket, _
						@state, _
						@www, _
						param->hOutput _
				)
				
			Case HttpMethods.HttpConnect
				lstrcpy(www.PhysicalDirectory, param->ExeDir)
				lstrcpy(www.VirtualPath, @SlashString)
				www.IsMoved = False
				ProcessConnectRequest( _
						param->ClientSocket, _
						@state, _
						@www, _
						param->hOutput _
				)
				
			Case Else
				' Метод не поддерживается сервером
				state.StatusCode = 501
				state.ResponseHeaders(HttpResponseHeaderIndices.HeaderAllow) = @AllSupportHttpMethodsServer 
				WriteHttpError(@state, param->ClientSocket, HttpErrors.HttpError501MethodNotAllowed, @SlashString, param->hOutput)
				
		End Select
		
	Loop While state.KeepAlive
	
	CloseSocketConnection(param->ClientSocket)
	CloseHandle(param->hThread)
	#if __FB_DEBUG__ <> 0
		Print "Закрываю поток:", param->hThread, state.KeepAlive
	#endif
	MyHeapFree(param)
	
	Return 0
End Function
