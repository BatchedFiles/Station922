#include once "ThreadProc.bi"
#include once "ReadHeadersResult.bi"
#include once "WebUtils.bi"
#include once "ProcessRequests.bi"
#include once "Http.bi"
#include once "HttpConst.bi"
#include once "HeapOnArray.bi"

Function ThreadProc(ByVal lpParam As LPVOID)As DWORD
	Dim param As ThreadParam Ptr = CPtr(ThreadParam Ptr, lpParam)
	' Ожидать чтения данных с клиента 5 минут
	Dim ReceiveTimeOut As DWORD = 300 * 1000
	setsockopt(param->ClientSocket, SOL_SOCKET, SO_RCVTIMEO, CPtr(ZString Ptr, @ReceiveTimeOut), SizeOf(DWORD))
	
	#if __FB_DEBUG__ <> 0
		Print "Поток стартовал", param->ThreadId
	#endif
	
	Dim state As ReadHeadersResult = Any
	
	Do
		' Инициализация объекта состояния в начальное значение
		state.Initialize()
		
		#if __FB_DEBUG__ <> 0
			' Измерение производительности
			Dim m_frequency As LARGE_INTEGER = Any
			Dim m_startTicks As LARGE_INTEGER = Any
			Dim nowTicks As LARGE_INTEGER = Any
			Dim TickCount As LongInt = Any
			Dim MicroSeconds As Double = Any
			Dim MilliSeconds As Double = Any
			' получим частоту работы высокоточного счетчика
			QueryPerformanceFrequency(@m_frequency)
		#endif
		
		#if __FB_DEBUG__ <> 0
			' получим winapi функцией значение времени высокоточного счетчика
			QueryPerformanceCounter(@m_startTicks)
		#endif
		' Читать запрос клиента
		Select Case state.ReadAllHeaders(param->ClientSocket)
			Case ParseRequestLineResult.Success
				' Всё правильно, продолжаем работать дальше
			Case ParseRequestLineResult.HTTPVersionNotSupported
				' Версия не поддерживается
				state.StatusCode = 505
				WriteHttpError(@state, param->ClientSocket, @HttpError505VersionNotSupported, @SlashString, param->hOutput)
				Exit Do
			Case ParseRequestLineResult.MethodNotSupported
				' Метод не поддерживается сервером
				state.StatusCode = 501
				state.ResponseHeaders(HttpResponseHeaderIndices.HeaderAllow) = @AllSupportHttpMethodsServer 
				WriteHttpError(@state, param->ClientSocket, @HttpError501MethodNotAllowed, @SlashString, param->hOutput)
				Exit Do
			Case ParseRequestLineResult.BadRequest
				' Плохой запрос
				state.StatusCode = 400
				WriteHttpError(@state, param->ClientSocket, @HttpError400BadRequest, @SlashString, param->hOutput)
				Exit Do
			Case ParseRequestLineResult.BadPath
				' Плохой путь
				state.StatusCode = 400
				WriteHttpError(@state, param->ClientSocket, @HttpError400BadPath, @SlashString, param->hOutput)
				Exit Do
			Case ParseRequestLineResult.EmptyRequest
				' Пустой запрос, клиент закрыл соединение
				Exit Do
			Case ParseRequestLineResult.RequestUrlTooLong
				' Запрошенный Url слишкой длинный
				state.StatusCode = 414
				WriteHttpError(@state, param->ClientSocket, @HttpError414RequestUrlTooLarge, @SlashString, param->hOutput)
				Exit Do
			Case ParseRequestLineResult.RequestHeaderFieldsTooLarge
				' Превышена допустимая длина заголовков
				state.StatusCode = 431
				WriteHttpError(@state, param->ClientSocket, @HttpError431RequestRequestHeaderFieldsTooLarge, @SlashString, param->hOutput)
				Exit Do
		End Select
		#if __FB_DEBUG__ <> 0
			QueryPerformanceCounter(@nowTicks)
			' возвращаем разницу
			TickCount = nowTicks.QuadPart - m_startTicks.QuadPart
			' получение времени
			MicroSeconds = ((nowTicks.QuadPart - m_startTicks.QuadPart) / m_frequency.QuadPart) * 1.e6
			MilliSeconds = ((nowTicks.QuadPart - m_startTicks.QuadPart) / m_frequency.QuadPart) * 1.e3
			Print "Функция state.ProcessReadHeadersHost выполнялась миллисекунд", MilliSeconds
		#endif
		
		' TODO Заголовок Host может не быть в версии 1.0
		If lstrlen(state.RequestHeaders(HttpRequestHeaderIndices.HeaderHost)) = 0 Then
			state.StatusCode = 400
			WriteHttpError(@state, param->ClientSocket, @HttpError400Host, @SlashString, param->hOutput)
			Exit Do
		Else
			If state.HttpMethod <> HttpMethods.HttpConnect Then
				If WebSiteExists(param->ExeDir, state.RequestHeaders(HttpRequestHeaderIndices.HeaderHost)) = False Then
					state.StatusCode = 400
					WriteHttpError(@state, param->ClientSocket, @HttpError400Host, @SlashString, param->hOutput)
					Exit Do
				End If
			End If
		End If
		
		#if __FB_DEBUG__ <> 0
			' Распечатать весь запрос
			' Установить конец строки (для винапи)
			Dim nTemp As Integer = state.HeaderBytes[state.EndHeadersOffset]
			state.HeaderBytes[state.EndHeadersOffset] = 0
			Print state.HeaderBytes
			state.HeaderBytes[state.EndHeadersOffset] = nTemp
		#endif
		
		#if __FB_DEBUG__ <> 0
			' получим winapi функцией значение времени высокоточного счетчика
			QueryPerformanceCounter(@m_startTicks)
		#endif
		' Найти сайт по его имени
		Dim www As WebSite = Any
		GetWebSite(param->ExeDir, @www, state.RequestHeaders(HttpRequestHeaderIndices.HeaderHost))
		#if __FB_DEBUG__ <> 0
			QueryPerformanceCounter(@nowTicks)
			' возвращаем разницу
			TickCount = nowTicks.QuadPart - m_startTicks.QuadPart
			' получение времени
			MicroSeconds = ((nowTicks.QuadPart - m_startTicks.QuadPart) / m_frequency.QuadPart) * 1.e6
			MilliSeconds = ((nowTicks.QuadPart - m_startTicks.QuadPart) / m_frequency.QuadPart) * 1.e3
			Print "Функция GetWebSite выполнялась миллисекунд", MilliSeconds
		#endif
		
		If www.IsMoved <> False Then
			' Сайт перемещён на другой ресурс
			' если запрошен документ /robots.txt то не перенаправлять
			If lstrcmpi(state.URI.Url, "/robots.txt") <> 0 Then
				WriteHttp301Error(param->ClientSocket, @state, @www, param->hOutput)
				Exit Do
			End If
		End If
		
		' Обработка запроса
		
		#if __FB_DEBUG__ <> 0
			' получим winapi функцией значение времени высокоточного счетчика
			QueryPerformanceCounter(@m_startTicks)
		#endif
		Dim ProcessResult As Boolean = Any
		Select Case state.HttpMethod
			Case HttpMethods.HttpGet, HttpMethods.HttpHead
				www.GetFilePath(@state.URI.Path)
				ProcessResult = ProcessGetHeadRequest(param->ClientSocket, @state, @www, PathFindExtension(@www.PathTranslated), param->hOutput)
			Case HttpMethods.HttpPut
				www.GetFilePath(@state.URI.Path)
				ProcessResult = ProcessPutRequest(param->ClientSocket, @state, @www, PathFindExtension(@www.PathTranslated), param->hOutput)
			Case HttpMethods.HttpDelete
				www.GetFilePath(@state.URI.Path)
				ProcessResult = ProcessDeleteRequest(param->ClientSocket, @state, @www, PathFindExtension(@www.PathTranslated), param->hOutput)
			Case HttpMethods.HttpOptions
				ProcessResult = ProcessOptionsRequest(param->ClientSocket, @state, @www, PathFindExtension(@www.PathTranslated), param->hOutput)
			Case HttpMethods.HttpTrace
				ProcessResult = ProcessTraceRequest(param->ClientSocket, @state, @www, param->hOutput)
			Case HttpMethods.HttpConnect
				lstrcpy(www.PhysicalDirectory, param->ExeDir)
				lstrcpy(www.VirtualPath, @SlashString)
				www.IsMoved = False
				ProcessResult = ProcessConnectRequest(param->ClientSocket, @state, @www, param->hOutput)
			Case Else
				ProcessResult = False
		End Select
		#if __FB_DEBUG__ <> 0
			QueryPerformanceCounter(@nowTicks)
			' возвращаем разницу
			TickCount = nowTicks.QuadPart - m_startTicks.QuadPart
			' получение времени
			MicroSeconds = ((nowTicks.QuadPart - m_startTicks.QuadPart) / m_frequency.QuadPart) * 1.e6
			MilliSeconds = ((nowTicks.QuadPart - m_startTicks.QuadPart) / m_frequency.QuadPart) * 1.e3
			Print "Обработка запроса выполнялась миллисекунд", MilliSeconds
		#endif
		
		' Если ни один из методов не обработал запрос, то вернуть ошибку
		If ProcessResult = False Then
			' Этот тип файла не обслуживается
			state.StatusCode = 403
			WriteHttpError(@state, param->ClientSocket, @HttpError403File, @www.VirtualPath, param->hOutput)
		End If
		
	Loop While state.KeepAlive
	#if __FB_DEBUG__ <> 0
		Print "Закрываю соединение: "; state.KeepAlive
	#endif
	
	CloseSocketConnection(param->ClientSocket)
	CloseHandle(param->hThread)
	MyHeapFree(param)
	
	Return 0
End Function
