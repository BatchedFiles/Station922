#include once "WebServer.bi"
#include once "Network.bi"
#include once "ReadHeadersResult.bi"
#include once "WebUtils.bi"
#include once "ProcessRequests.bi"
#include once "HttpConst.bi"
#include once "IniConst.bi"
#include once "HeapOnArray.bi"
#include once "WriteHttpError.bi"

Const LogDateFormatString = "yyyy.MM.dd.LOG"
Const LogDirectoryString = "logs"
Const ErrorInvalidSocket = !"Получил INVALID_SOCKET от клиента\r\n"

#ifdef service
Function ServiceProc(ByVal lpParam As LPVOID)As DWORD
#else
#ifdef withoutrtl
Function EntryPoint Alias "EntryPoint"()As Integer
#endif
#endif
	' Имя исполняемого файла
	Dim ExeFileName As WString * (MAX_PATH + 1) = Any
	Dim ExeDir As WString * (MAX_PATH + 1) = Any
	Dim ExeFileNameLength As DWORD = GetModuleFileName(0, @ExeFileName, MAX_PATH)
	If ExeFileNameLength = 0 Then
		#ifdef withoutrtl
		Return 4
		#else
			#ifdef service
			Return 4
			#else
			End(4)
			#endif
		#endif
	End If
	lstrcpy(@ExeDir, @ExeFileName)
	' Вырезать имя файла, оставить только путь
	PathRemoveFileSpec(@ExeDir)
	
	' Файл с настройками
	Dim IniFileName As WString * (MAX_PATH + 1) = Any
	PathCombine(@IniFileName, @ExeDir, @WebServerIniFileString)
	
	' Папка с логами сервера
	Dim LogDir As WString * (MAX_PATH + 1) = Any
	PathCombine(@LogDir, @ExeDir, @LogDirectoryString)
	CreateDirectory(@LogDir, NULL)
	
	Dim ListenAddress As WString * 256 = Any
	Dim ListenPort As WString * 16 = Any
	
	GetPrivateProfileString(@WebServerSectionString, @ListenAddressSectionString, @DefaultAddressString, @ListenAddress, 255, @IniFileName)
	GetPrivateProfileString(@WebServerSectionString, @PortSectionString, @DefaultHttpPort, @ListenPort, 15, @IniFileName)
	
	' Инициализация сокетов
	Scope
		Dim objWsaData As WSAData = Any
		If WSAStartup(MAKEWORD(2, 2), @objWsaData) <> NO_ERROR Then
		#ifdef withoutrtl
		Return 1
		#else
			#ifdef service
			Return 1
			#else
			End(1)
			#endif
		#endif
		End If
	End Scope
	
	Dim ListenSocket As SOCKET = CreateSocketAndListen(@ListenAddress, @ListenPort)
	If ListenSocket = INVALID_SOCKET Then
		WSACleanup()
		#ifdef withoutrtl
		Return 2
		#else
			#ifdef service
			Return 2
			#else
			End(2)
			#endif
		#endif
	End If
	
	' Текущая дата
	Dim dtCurrent As SYSTEMTIME = Any
	GetSystemTime(@dtCurrent)
	
	' Сегодняшний идентификатор файла логов
	Dim CurrentLogFile As Handle = GetLogFileHandle(@dtCurrent, @LogDir)
	' Вчерашний идентификатор
	Dim CurrentLogFile2 As Handle = INVALID_HANDLE_VALUE
	' Позавчерашний идентификатор
	Dim CurrentLogFile3 As Handle = INVALID_HANDLE_VALUE
	
	' Инициализация кучи на буфере
	Dim hHeap As ZString * MyHeapSize = Any
	MyHeapCreate(@hHeap)
	
	Dim RemoteAddress As SOCKADDR_IN = Any
	Dim RemoteAddressLength As Long = SizeOf(RemoteAddress)
	Dim ClientSocket As SOCKET = accept(ListenSocket, CPtr(SOCKADDR Ptr, @RemoteAddress), @RemoteAddressLength)
	
	Do Until ClientSocket = INVALID_SOCKET
		' Определить идентификатор вывода для логов
		Dim dtNow As SYSTEMTIME = Any
		GetSystemTime(@dtNow)
		If dtNow.wDay <> dtCurrent.wDay Then
			' Сохранить дату
			dtCurrent = dtNow
			' Закрыть позавчера
			CloseHandle(CurrentLogFile3)
			' Вчера → позавчера
			CurrentLogFile3 = CurrentLogFile2
			' Сегодня → вчера
			CurrentLogFile2 = CurrentLogFile
			' Получить новый сегодняшний идентификатор
			CurrentLogFile = GetLogFileHandle(@dtNow, @LogDir)
		End If
			
		Dim param As ThreadParam Ptr = MyHeapAlloc(@hHeap)
		If param = 0 Then
			' Отправить клиенту ошибку, что не хватает памяти
			Dim state As ReadHeadersResult = Any
			state.Initialize()
			state.StatusCode = 503
			state.ResponseHeaders(HttpResponseHeaderIndices.HeaderRetryAfter) = @"Retry-After: 300"
			WriteHttpError(@state, ClientSocket, @HttpError503Memory, @SlashString, CurrentLogFile)
			CloseSocketConnection(param->ClientSocket)
		Else
			param->ClientSocket = ClientSocket
			param->RemoteAddress = RemoteAddress
			param->RemoteAddressLength = RemoteAddressLength
			param->ServerSocket = ListenSocket
			param->hOutput = CurrentLogFile
			param->ExeDir = @ExeDir
			
			' Запустить поток, в котором будет происходить обработка запроса
			param->hThread = CreateThread(NULL, 0, @ThreadProc, param, 0, @param->ThreadId)
			If param->hThread = NULL Then
				' Отправить клиенту ошибку, что не хватает памяти
				Dim state As ReadHeadersResult = Any
				state.Initialize()
				state.StatusCode = 500
				state.ResponseHeaders(HttpResponseHeaderIndices.HeaderRetryAfter) = @"Retry-After: 300"
				WriteHttpError(@state, ClientSocket, @HttpError500ThreadError, @SlashString, CurrentLogFile)
				CloseSocketConnection(param->ClientSocket)
				MyHeapFree(param)
			End If
		End If
		' Принять соединение
		ClientSocket = accept(ListenSocket, CPtr(SOCKADDR Ptr, @RemoteAddress), @RemoteAddressLength)
	Loop
	MyHeapDestroy(CPtr(ThreadParam Ptr, @hHeap))
	
	CloseSocketConnection(ListenSocket)
	WSACleanup()
#ifdef service
End Function
#else
#ifdef withoutrtl
End Function
#endif
#endif

Function GetLogFileHandle(ByVal dtCurrent As SYSTEMTIME Ptr, ByVal LogDir As WString Ptr)As Handle
	Dim FileName As WString * (MAX_PATH + 1) = Any
	' Дату в строку
	GetDateFormat(LOCALE_INVARIANT, 0, dtCurrent, @LogDateFormatString, @FileName, MAX_PATH)
	' Полное имя файла
	Dim LogFile As WString * (MAX_PATH + 1) = Any
	PathCombine(@LogFile, LogDir, @FileName)
	' Открыть
	Dim hAppend As Handle = CreateFile(@LogFile, GENERIC_WRITE, FILE_SHARE_READ, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL)
	SetFilePointer(hAppend, 0, NULL, FILE_END)
	Return hAppend
End Function
