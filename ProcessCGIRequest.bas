Function ProcessCGIRequest(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal fileExtention As WString Ptr, ByVal hOutput As Handle)As Boolean
	Const MaxBufferLength As Integer = 4096 - 1
	Const MaxMapBuffer As Integer = 8 * ReadHeadersResult.MaxResponseHeaderBuffer
	
	Dim Buffer As ZString * (MaxBufferLength + 1) = Any
	
	' Длина содержимого по заголовку Content-Length слишком большая
	Dim RequestBodyContentLength As LARGE_INTEGER = Any
	RequestBodyContentLength.QuadPart = wtol(state->ClientRequest.RequestHeaders(HttpRequestHeaderIndices.HeaderContentLength))
	If RequestBodyContentLength.QuadPart > MaxRequestBodyContentLength Then
		state->StatusCode = 413
		WriteHttpError(state, ClientSocket, HttpErrors.HttpError413RequestEntityTooLarge, @www->VirtualPath, hOutput)
		Return False
	End If
	
	' Создать блок переменных окружения
	Dim hMapFile As HANDLE = CreateFileMapping(INVALID_HANDLE_VALUE, 0, PAGE_READWRITE, 0, MaxMapBuffer, NULL)
	If hMapFile = 0 Then
		state->StatusCode = 503
		state->ResponseHeaders(HttpResponseHeaderIndices.HeaderRetryAfter) = @"Retry-After: 300"
		WriteHttpError(state, ClientSocket, HttpErrors.HttpError503Memory, @www->VirtualPath, hOutput)
		Return False
	End If
	
	Dim EnvironmentBlock As WString Ptr = CPtr(WString Ptr, MapViewOfFile(hMapFile, FILE_MAP_ALL_ACCESS, 0, 0, MaxMapBuffer))
	If EnvironmentBlock = 0 Then
		CloseHandle(hMapFile)
		state->StatusCode = 503
		state->ResponseHeaders(HttpResponseHeaderIndices.HeaderRetryAfter) = @"Retry-After: 300"
		WriteHttpError(state, ClientSocket, HttpErrors.HttpError503Memory, @www->VirtualPath, hOutput)
		Return False
	End If
	EnvironmentBlock[0] = 0
	EnvironmentBlock[1] = 0
	EnvironmentBlock[2] = 0
	EnvironmentBlock[3] = 0
	'
	Scope
		Dim wStart As WString Ptr = EnvironmentBlock
		
		lstrcpy(wStart, "SCRIPT_FILENAME=")
		lstrcat(wStart, @www->PathTranslated)
		wStart += lstrlen(wStart) + 1
		
		lstrcpy(wStart, "PATH_INFO=")
		lstrcat(wStart, @"")
		wStart += lstrlen(wStart) + 1
		
		lstrcpy(wStart, "SCRIPT_NAME=")
		lstrcat(wStart, @"")
		wStart += lstrlen(wStart) + 1
		
		lstrcpy(wStart, "REQUEST_LINE=")
		lstrcat(wStart, state->ClientRequest.ClientURI.Url)
		wStart += lstrlen(wStart) + 1
		
		lstrcpy(wStart, "QUERY_STRING=")
		lstrcat(wStart, state->ClientRequest.ClientURI.QueryString)
		wStart += lstrlen(wStart) + 1
		
		lstrcpy(wStart, "SERVER_SOFTWARE=")
		lstrcat(wStart, @HttpServerNameString)
		wStart += lstrlen(wStart) + 1
		
		lstrcpy(wStart, "SERVER_NAME=")
		lstrcat(wStart, @www->HostName)
		wStart += lstrlen(wStart) + 1
		
		lstrcpy(wStart, "SERVER_PROTOCOL=")
		' TODO Указать правильную версию
		lstrcat(wStart, @HttpVersion11)
		wStart += lstrlen(wStart) + 1
		
		lstrcpy(wStart, "SERVER_PORT=80")
		REM lstrcat(wStart, @www->HostName)
		wStart += lstrlen(wStart) + 1
		
		lstrcpy(wStart, "GATEWAY_INTERFACE=")
		lstrcat(wStart, @"CGI/1.1")
		wStart += lstrlen(wStart) + 1
		
		
		lstrcpy(wStart, "REMOTE_ADDR=")
		lstrcat(wStart, @"")
		wStart += lstrlen(wStart) + 1
		
		lstrcpy(wStart, "REMOTE_HOST=")
		lstrcat(wStart, @"")
		wStart += lstrlen(wStart) + 1
		
		lstrcpy(wStart, "REQUEST_METHOD=")
		Scope
			Dim HttpMethod As WString * 64 = Any
			GetHttpMethodString(@HttpMethod, state->ClientRequest.HttpMethod)
			lstrcat(wStart, @HttpMethod)
		End Scope
		wStart += lstrlen(wStart) + 1
		
		For i As Integer = 0 To WebRequest.RequestHeaderMaximum - 1
			lstrcpy(wStart, GetKnownRequestHeaderNameCGI(i))
			lstrcat(wStart, "=")
			If state->ClientRequest.RequestHeaders(i) <> 0 Then
				lstrcat(wStart, state->ClientRequest.RequestHeaders(i))
			End If
			wStart += lstrlen(wStart) + 1
		Next
		
		' Завершить брок переменных окружения
		wStart[0] = 0
	End Scope
	
	' Текущая директория дочернего процесса
	Dim CurrentChildProcessDirectory As WString * (MAX_PATH + 1) = Any
	lstrcpy(@CurrentChildProcessDirectory, @www->PathTranslated)
	PathRemoveFileSpec(@CurrentChildProcessDirectory)
	
	' Скопировать в буфер имя исполняемого файла
	Dim ApplicationNameBuffer As WString * (WebSite.MaxFilePathTranslatedLength + 1) = Any
	lstrcpy(@ApplicationNameBuffer, @www->PathTranslated)
	
	' Атрибуты защиты
	Dim saAttr As SECURITY_ATTRIBUTES = Any
	saAttr.nLength = SizeOf(SECURITY_ATTRIBUTES)
	saAttr.bInheritHandle = TRUE
	saAttr.lpSecurityDescriptor = NULL
	
	Dim hRead As Handle = Any
	Dim hWrite As Handle = Any
	
	' Каналы чтения‐записи
	If CreatePipe(@hRead, @hWrite, @saAttr, 0) = 0 Then
		Dim intError As DWORD = GetLastError()
		UnmapViewOfFile(EnvironmentBlock)
		CloseHandle(hMapFile)
		state->StatusCode = 503
		WriteHttpError(state, ClientSocket, HttpErrors.HttpError503Memory, @www->VirtualPath, hOutput)
		Return False
	End If
	
	' Информация о процессе
	Dim siStartInfo As STARTUPINFO
	siStartInfo.cb = SizeOf(STARTUPINFO)
	siStartInfo.hStdOutput = hWrite
	siStartInfo.hStdInput = hRead
	siStartInfo.dwFlags = STARTF_USESTDHANDLES
	
	Dim piProcInfo As PROCESS_INFORMATION
	
	If CreateProcess(@ApplicationNameBuffer, NULL, NULL, NULL, True, CREATE_UNICODE_ENVIRONMENT, EnvironmentBlock, @CurrentChildProcessDirectory, @siStartInfo, @piProcInfo) = 0 Then
		Dim intError As DWORD = GetLastError()
		UnmapViewOfFile(EnvironmentBlock)
		CloseHandle(hMapFile)
		CloseHandle(hRead)
		CloseHandle(hWrite)
		state->StatusCode = 504
		WriteHttpError(state, ClientSocket, HttpErrors.HttpError504GatewayTimeout, @www->VirtualPath, hOutput)
		Return False
	End If
	
	If state->ClientRequest.HttpMethod = HttpMethods.HttpPost Then
		
		Dim WriteBytesCount As DWORD = Any
		
		' Записать предварительно загруженные данные
		Dim PreloadedContentLength As Integer = state->ClientReader.BufferLength - state->ClientReader.Start
		If PreloadedContentLength > 0 Then
			WriteFile(hWrite, @state->ClientReader.Buffer[state->ClientReader.Start], PreloadedContentLength, @WriteBytesCount, NULL)
			' TODO Проверить на ошибки записи
			state->ClientReader.Flush()
		End If
		
		' Записать всё остальное
		Do While PreloadedContentLength < RequestBodyContentLength.QuadPart
			Dim numReceived As Integer = recv(ClientSocket, @Buffer, MaxBufferLength, 0)
			
			' TODO Проверить на ошибки записи
			Select Case numReceived
				
				Case SOCKET_ERROR
					Exit Do
					
				Case 0
					Exit Do
					
				Case Else
					' Сколько байт получили, на столько и увеличили буфер
					PreloadedContentLength += numReceived
					WriteFile(hWrite, @Buffer, numReceived, @WriteBytesCount, NULL)
					
			End Select
			
		Loop
	End If
	
	CloseHandle(hWrite)
	
	Do
		Dim ReadBytesCount As DWORD = Any
		If ReadFile(hRead, @Buffer, MaxBufferLength, @ReadBytesCount, NULL) = 0 Then
			Exit Do
		End If
		
		If ReadBytesCount = 0 Then
			Exit Do
		End If
		
		Buffer[ReadBytesCount] = 0
		If send(ClientSocket, @Buffer, ReadBytesCount, 0) = SOCKET_ERROR Then
			Exit Do
		End If
	Loop
	
	UnmapViewOfFile(EnvironmentBlock)
	CloseHandle(hMapFile)
	CloseHandle(piProcInfo.hProcess)
	CloseHandle(piProcInfo.hThread)
	CloseHandle(hRead)
	
	Return True
End Function
