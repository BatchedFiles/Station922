#include once "ProcessRequests.bi"
#include once "Mime.bi"
#include once "HttpConst.bi"
#include once "WebUtils.bi"
#include once "Network.bi"
#include once "IniConst.bi"
#include once "URI.bi"
#include once "CharConstants.bi"
#include once "WriteHttpError.bi"
#include once "ServerState.bi"
#include once "win\shlwapi.bi"

Function DllCgiGetRequestHeader(ByVal objState As ServerState_ Ptr, ByVal Value As WString Ptr, ByVal BufferLength As Integer, ByVal HeaderIndex As HttpRequestHeaderIndices)As Integer
	Dim HeaderLength As Integer = lstrlen(objState->state->ClientRequest.RequestHeaders(HeaderIndex))
	If HeaderLength > BufferLength Then
		SetLastError(ERROR_INSUFFICIENT_BUFFER)
		Return -1
	End If
	
	SetLastError(ERROR_SUCCESS)
	lstrcpy(Value, objState->state->ClientRequest.RequestHeaders(HeaderIndex))
	Return HeaderLength
End Function

Function DllCgiGetHttpMethod(ByVal objState As ServerState_ Ptr)As HttpMethods
	SetLastError(ERROR_SUCCESS)
	Return objState->state->ClientRequest.HttpMethod
End Function

Function DllCgiGetHttpVersion(ByVal objState As ServerState_ Ptr)As HttpVersions
	SetLastError(ERROR_SUCCESS)
	Return objState->state->ClientRequest.HttpVersion
End Function

Sub DllCgiSetStatusCode(ByVal objState As ServerState_ Ptr, ByVal Code As Integer)
	objState->state->ServerResponse.StatusCode = Code
End Sub

Sub DllCgiSetStatusDescription(ByVal objState As ServerState_ Ptr, ByVal Description As WString Ptr)
	' TODO Устранить потенциальное переполнение буфера
	objState->state->ServerResponse.SetStatusDescription(Description)
End Sub

Sub DllCgiSetResponseHeader(ByVal objState As ServerState_ Ptr, ByVal HeaderIndex As HttpResponseHeaderIndices, ByVal Value As WString Ptr)
	' TODO Устранить потенциальное переполнение буфера
	objState->state->ServerResponse.AddKnownResponseHeader(HeaderIndex, Value)
End Sub

Function DllCgiWriteData(ByVal objState As ServerState_ Ptr, ByVal Buffer As Any Ptr, ByVal BytesCount As Integer)As Boolean
	If BytesCount > MaxClientBufferLength - objState->BufferLength Then
		SetLastError(ERROR_BUFFER_OVERFLOW)
		Return False
	End If
	
	RtlCopyMemory(objState->ClientBuffer, Buffer, BytesCount)
	objState->BufferLength += BytesCount
	SetLastError(ERROR_SUCCESS)
	
	Return True
End Function

Function DllCgiReadData(ByVal objState As ServerState_ Ptr, ByVal Buffer As Any Ptr, ByVal BufferLength As Integer, ByVal ReadedBytesCount As Integer Ptr)As Boolean
	Return False
End Function

Function ProcessDllCgiRequest(ByVal ClientSocket As SOCKET, ByVal state As ReadHeadersResult Ptr, ByVal www As WebSite Ptr, ByVal fileExtention As WString Ptr, ByVal hOutput As Handle)As Boolean
	' Создать клиентский буфер
	Dim hMapFile As HANDLE = CreateFileMapping(INVALID_HANDLE_VALUE, 0, PAGE_READWRITE, 0, MaxClientBufferLength, NULL)
	If hMapFile = 0 Then
		Dim intError As DWORD = GetLastError()
		#if __FB_DEBUG__ <> 0
			Print "Ошибка CreateFileMapping", intError
		#endif
		state->ServerResponse.StatusCode = 503
		state->ServerResponse.ResponseHeaders(HttpResponseHeaderIndices.HeaderRetryAfter) = @"Retry-After: 300"
		WriteHttpError(state, ClientSocket, HttpErrors.HttpError503Memory, @www->VirtualPath, hOutput)
		Return False
	End If
	
	Dim ClientBuffer As Any Ptr = MapViewOfFile(hMapFile, FILE_MAP_ALL_ACCESS, 0, 0, MaxClientBufferLength)
	If ClientBuffer = 0 Then
		Dim intError As DWORD = GetLastError()
		#if __FB_DEBUG__ <> 0
			Print "Ошибка MapViewOfFile", intError
		#endif
		CloseHandle(hMapFile)
		state->ServerResponse.StatusCode = 503
		state->ServerResponse.ResponseHeaders(HttpResponseHeaderIndices.HeaderRetryAfter) = @"Retry-After: 300"
		WriteHttpError(state, ClientSocket, HttpErrors.HttpError503Memory, @www->VirtualPath, hOutput)
		Return False
	End If
	
	Dim hModule As HINSTANCE = LoadLibrary(@www->PathTranslated)
	If hModule = NULL Then
		Dim intError As DWORD = GetLastError()
		#if __FB_DEBUG__ <> 0
			Print "Ошибка загрузки DLL", intError
		#endif
		state->ServerResponse.StatusCode = 503
		state->ServerResponse.ResponseHeaders(HttpResponseHeaderIndices.HeaderRetryAfter) = @"Retry-After: 300"
		WriteHttpError(state, ClientSocket, HttpErrors.HttpError503Memory, @www->VirtualPath, hOutput)
		Return False
	End If
	
	Dim ProcessDllRequest As Function(ByVal objServerState As ServerState Ptr)As Boolean
	
	Dim DllFunction As Any Ptr = GetProcAddress(hModule, "ProcessDllRequest")
	If DllFunction = 0 Then
		Dim intError As DWORD = GetLastError()
		#if __FB_DEBUG__ <> 0
			Print "Ошибка поиска функции ProcessDllRequest", intError
		#endif
		FreeLibrary(hModule)
		state->ServerResponse.StatusCode = 502
		WriteHttpError(state, ClientSocket, HttpErrors.HttpError502BadGateway, @www->VirtualPath, hOutput)
		Return False
	End If
	
	ProcessDllRequest = DllFunction
	
	Dim objVirtualTable As IServerState = Any
	objVirtualTable.GetRequestHeader = @DllCgiGetRequestHeader
	objVirtualTable.GetHttpMethod = @DllCgiGetHttpMethod
	objVirtualTable.GetHttpVersion = @DllCgiGetHttpVersion
	objVirtualTable.SetStatusCode = @DllCgiSetStatusCode
	objVirtualTable.SetStatusDescription = @DllCgiSetStatusDescription
	objVirtualTable.SetResponseHeader = @DllCgiSetResponseHeader
	objVirtualTable.GetSafeString = @GetSafeString
	objVirtualTable.WriteData = @DllCgiWriteData
	objVirtualTable.ReadData = @DllCgiReadData
	
	Dim objServerState As ServerState = Any
	objServerState.VirtualTable = @objVirtualTable
	objServerState.ClientSocket = ClientSocket
	objServerState.state = state
	objServerState.www = www
	objServerState.hMapFile = hMapFile
	objServerState.ClientBuffer = ClientBuffer
	objServerState.BufferLength = 0
	
	Dim Result As Boolean = ProcessDllRequest(@objServerState)
	If Result = False Then
		Dim intError As DWORD = GetLastError()
		#if __FB_DEBUG__ <> 0
			Print "Функция ProcessDllRequest завершилась ошибкой", intError
		#endif
		UnmapViewOfFile(objServerState.ClientBuffer)
		CloseHandle(hMapFile)
		state->ServerResponse.StatusCode = 503
		WriteHttpError(state, ClientSocket, HttpErrors.HttpError503Memory, @www->VirtualPath, hOutput)
		Return False
	End If
	
	' Создать и отправить заголовки ответа
	Dim SendBuffer As ZString * (WebResponse.MaxResponseHeaderBuffer + 1) = Any
	If send(ClientSocket, @SendBuffer, state->AllResponseHeadersToBytes(@SendBuffer, objServerState.BufferLength, hOutput), 0) = SOCKET_ERROR Then
		UnmapViewOfFile(objServerState.ClientBuffer)
		CloseHandle(hMapFile)
		Return False
	End If
	
	' Тело
	If state->ServerResponse.SendOnlyHeaders = False Then
		If send(ClientSocket, objServerState.ClientBuffer, objServerState.BufferLength, 0) = SOCKET_ERROR Then
			UnmapViewOfFile(objServerState.ClientBuffer)
			CloseHandle(hMapFile)
			Return False
		End If
	End If
	
	UnmapViewOfFile(objServerState.ClientBuffer)
	CloseHandle(hMapFile)
	FreeLibrary(hModule)
	Return True
End Function





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
