#include once "WebServer.bi"
#include once "win\shlwapi.bi"
#include once "ThreadProc.bi"
#include once "Network.bi"
#include once "ReadHeadersResult.bi"
#include once "WebUtils.bi"
#include once "IniConst.bi"
#include once "WriteHttpError.bi"
#include once "WebSite.bi"

Declare Function GetLogFileHandle( _
	ByVal dtCurrent As SYSTEMTIME Ptr, _
	ByVal wLogDir As WString Ptr _
)As Handle

Const LogDateFormatString = "yyyy.MM.dd.LOG"
Const LogDirectoryString = "logs"
Const ErrorInvalidSocket = !"Получил INVALID_SOCKET от клиента\r\n"

Function InitializeWebServer( _
		ByVal pWebServer As WebServer Ptr _
	)As Integer
	
	' Имя исполняемого файла
	Dim ExeFileName As WString * (MAX_PATH + 1) = Any
	Dim ExeFileNameLength As DWORD = GetModuleFileName(0, @ExeFileName, MAX_PATH)
	If ExeFileNameLength = 0 Then
		Return 4
	End If
	lstrcpy(@pWebServer->ExeDir, @ExeFileName)
	' Вырезать имя файла, оставить только путь
	PathRemoveFileSpec(@pWebServer->ExeDir)
	
	' Файл с настройками
	Dim IniFileName As WString * (MAX_PATH + 1)
	PathCombine(@IniFileName, @pWebServer->ExeDir, @WebServerIniFileString)
	
	' Папка с логами сервера
	PathCombine(@pWebServer->LogDir, @pWebServer->ExeDir, @LogDirectoryString)
	CreateDirectory(@pWebServer->LogDir, NULL)
	
	Dim ListenAddress As WString * 256 = Any
	Dim ListenPort As WString * 16 = Any
	
	GetPrivateProfileString(@WebServerSectionString, @ListenAddressSectionString, @DefaultAddressString, @ListenAddress, 255, @IniFileName)
	GetPrivateProfileString(@WebServerSectionString, @PortSectionString, @DefaultHttpPort, @ListenPort, 15, @IniFileName)
	
	LoadWebSites(@pWebServer->ExeDir)
	
	' Инициализация сокетов
	Scope
		Dim objWsaData As WSAData = Any
		If WSAStartup(MAKEWORD(2, 2), @objWsaData) <> NO_ERROR Then
			Return 1
		End If
	End Scope
	
	pWebServer->ListenSocket = CreateSocketAndListen(@ListenAddress, @ListenPort)
	If pWebServer->ListenSocket = INVALID_SOCKET Then
		WSACleanup()
		Return 2
	End If
	
	' Инициализация кучи на буфере
	MyHeapCreate(@pWebServer->hHeap)
	
	Return 0
End Function

Sub UninitializeWebServer( _
		ByVal pWebServer As WebServer Ptr _
	)
	
	MyHeapDestroy(CPtr(ThreadParam Ptr, @pWebServer->hHeap))
	CloseSocketConnection(pWebServer->ListenSocket)
	WSACleanup()
End Sub

Function WebServerMainLoop( _
		ByVal lpParam As LPVOID _
	)As DWORD
	
	Dim pWebServer As WebServer Ptr = lpParam
	
	' Текущая дата
	Dim dtCurrent As SYSTEMTIME = Any
	GetSystemTime(@dtCurrent)
	
	' Сегодняшний идентификатор файла логов
	Dim CurrentLogFile As Handle = GetLogFileHandle(@dtCurrent, @pWebServer->LogDir)
	' Вчерашний идентификатор
	Dim CurrentLogFile2 As Handle = INVALID_HANDLE_VALUE
	' Позавчерашний идентификатор
	Dim CurrentLogFile3 As Handle = INVALID_HANDLE_VALUE
	
	Dim RemoteAddress As SOCKADDR_IN = Any
	Dim RemoteAddressLength As Long = SizeOf(RemoteAddress)
	Dim ClientSocket As SOCKET = accept(pWebServer->ListenSocket, CPtr(SOCKADDR Ptr, @RemoteAddress), @RemoteAddressLength)
	
	Do Until ClientSocket = INVALID_SOCKET
		' Определить идентификатор вывода для логов
		Dim dtNow As SYSTEMTIME = Any
		GetSystemTime(@dtNow)
		If dtNow.wDay <> dtCurrent.wDay Then
			dtCurrent = dtNow
			CloseHandle(CurrentLogFile3)
			CurrentLogFile3 = CurrentLogFile2
			CurrentLogFile2 = CurrentLogFile
			CurrentLogFile = GetLogFileHandle(@dtNow, @pWebServer->LogDir)
		End If
			
		Dim param As ThreadParam Ptr = MyHeapAlloc(@pWebServer->hHeap)
		If param = 0 Then
			' Отправить клиенту ошибку, что не хватает памяти
			Dim state As ReadHeadersResult = Any
			InitializeStreamSocketReader(@state.ClientReader)
			state.ClientReader.ClientSocket = param->ClientSocket
			InitializeReadHeadersResult(@state)
			state.ServerResponse.StatusCode = 503
			state.ServerResponse.ResponseHeaders(HttpResponseHeaderIndices.HeaderRetryAfter) = @"Retry-After: 300"
			WriteHttpError(@state, ClientSocket, HttpErrors.HttpError503Memory, @SlashString, CurrentLogFile)
			CloseSocketConnection(param->ClientSocket)
		Else
			param->ClientSocket = ClientSocket
			param->RemoteAddress = RemoteAddress
			param->RemoteAddressLength = RemoteAddressLength
			param->ServerSocket = pWebServer->ListenSocket
			param->hOutput = CurrentLogFile
			param->ExeDir = @pWebServer->ExeDir
			
			' Запустить поток, в котором будет происходить обработка запроса
			param->hThread = CreateThread(NULL, 0, @ThreadProc, param, 0, @param->ThreadId)
			If param->hThread = NULL Then
				' TODO Узнать ошибку и обработать
				' Отправить клиенту ошибку, что не хватает памяти
				Dim state As ReadHeadersResult = Any
				InitializeStreamSocketReader(@state.ClientReader)
				state.ClientReader.ClientSocket = param->ClientSocket
				InitializeReadHeadersResult(@state)
				state.ServerResponse.StatusCode = 503
				state.ServerResponse.ResponseHeaders(HttpResponseHeaderIndices.HeaderRetryAfter) = @"Retry-After: 300"
				WriteHttpError(@state, ClientSocket, HttpErrors.HttpError503ThreadError, @SlashString, CurrentLogFile)
				CloseSocketConnection(param->ClientSocket)
				MyHeapFree(param)
			End If
		End If
		' Принять соединение
		ClientSocket = accept(pWebServer->ListenSocket, CPtr(SOCKADDR Ptr, @RemoteAddress), @RemoteAddressLength)
	Loop
	Return 0
End Function

Function GetLogFileHandle( _
		ByVal pCurrentDate As SYSTEMTIME Ptr, _
		ByVal wLogDir As WString Ptr _
	)As Handle
	
	Dim FileName As WString * (MAX_PATH + 1) = Any
	' Дату в строку
	GetDateFormat(LOCALE_INVARIANT, 0, pCurrentDate, @LogDateFormatString, @FileName, MAX_PATH)
	' Полное имя файла
	Dim LogFile As WString * (MAX_PATH + 1) = Any
	PathCombine(@LogFile, wLogDir, @FileName)
	' Открыть
	Dim hAppend As Handle = CreateFile(@LogFile, GENERIC_WRITE, FILE_SHARE_READ, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL)
	SetFilePointer(hAppend, 0, NULL, FILE_END)
	Return hAppend
End Function

/'
	#ifdef service
	Function ServiceProc(ByVal lpParam As LPVOID)As DWORD
	#else
	#ifdef withoutrtl
	Function EntryPoint Alias "EntryPoint"()As Integer
	#endif
	#endif
		
		
	#ifdef service
	End Function
	#else
	#ifdef withoutrtl
	End Function
	#endif
	#endif
'/
