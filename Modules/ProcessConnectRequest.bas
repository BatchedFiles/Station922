#include "ProcessConnectRequest.bi"
#include "CharacterConstants.bi"
#include "IConfiguration.bi"
#include "CreateInstance.bi"
#include "IniConst.bi"
#include "Network.bi"
#include "NetworkClient.bi"
#include "INetworkStream.bi"
#include "WebUtils.bi"
#include "WriteHttpError.bi"
#include "win\shlwapi.bi"

Extern CLSID_CONFIGURATION Alias "CLSID_CONFIGURATION" As Const CLSID
Extern CLSID_NETWORKSTREAM Alias "CLSID_NETWORKSTREAM" As Const CLSID

Type ClientServerSocket
	Dim pIStreamIn As INetworkStream Ptr
	Dim pIStreamOut As INetworkStream Ptr
	Dim ThreadId As DWord
End Type

Declare Sub SendReceiveData( _
	ByVal pIStreamIn As INetworkStream Ptr, _
	ByVal pIStreamOut As INetworkStream Ptr _
)

Declare Function SendReceiveDataThreadProc( _
	ByVal lpParam As LPVOID _
)As DWORD

Function ProcessConnectRequest( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pINetworkStream As INetworkStream Ptr, _
		ByVal pIWebSite As IWebSite Ptr, _
		ByVal pIClientReader As IHttpReader Ptr, _
		ByVal pIRequestedFile As IRequestedFile Ptr _
	)As Boolean
	
	' Проверка заголовка Authorization
	If HttpAuthUtil(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), pIWebSite, True) = False Then
		Return False
	End If
	
	Dim SettingsFileName As WString * (MAX_PATH + 1) = Any
	
	Dim ExecutableDirectory As WString Ptr = Any
	IWebSite_GetExecutableDirectory(pIWebSite, @ExecutableDirectory)
	
	PathCombine(@SettingsFileName, ExecutableDirectory, @WebServerIniFileString)
	
	Dim pIConfig As IConfiguration Ptr = Any
	Dim hr As HRESULT = CreateInstance(GetProcessHeap(), @CLSID_CONFIGURATION, @IID_IConfiguration, @pIConfig)
	
	If FAILED(hr) Then
		Return False
	End If
	
	IConfiguration_SetIniFilename(pIConfig, @SettingsFileName)
	
	Dim ConnectBindAddress As WString * 256 = Any
	Dim ConnectBindPort As WString * 16 = Any
	
	Dim ValueLength As Integer = Any
	
	IConfiguration_GetStringValue(pIConfig, _
		@WebServerSectionString, _
		@ConnectBindAddressKeyString, _
		@DefaultAddressString, _
		255, _
		@ConnectBindAddress, _
		@ValueLength _
	)
	
	IConfiguration_GetStringValue(pIConfig, _
		@WebServerSectionString, _
		@ConnectBindPortKeyString, _
		@ConnectBindDefaultPort, _
		15, _
		@ConnectBindPort, _
		@ValueLength _
	)
	
	IConfiguration_Release(pIConfig)
	
	Dim pHeaderHost As WString Ptr = Any
	IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderHost, @pHeaderHost)
	
	Dim ServiceName As WString Ptr = Any
	Dim wColon As WString Ptr = StrChr(pHeaderHost, Characters.Colon)
	
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
	
	Dim ServerSocket2 As SOCKET = Any
	
	Scope
		Dim hrConnect As HRESULT = E_FAIL
		
		For i As Integer = 0 To 9
			hrConnect = ConnectToServer( _
				@ConnectBindAddress, _
				@ConnectBindPort, _
				pHeaderHost, _
				ServiceName, _
				@ServerSocket2 _
			)
			If SUCCEEDED(hrConnect) Then
				Exit For
			End If
		Next
		
		If FAILED(hrConnect) Then
			WriteHttpGatewayTimeout(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), pIWebSite)
			Return False
		End If
	End Scope
	
	IServerResponse_SetKeepAlive(pIResponse, True)
	
	Dim SendBuffer As ZString * (MaxResponseBufferLength + 1) = Any
	' send(ClientSocket, @SendBuffer, AllResponseHeadersToBytes(pRequest, pIResponse, @SendBuffer, 0), 0)
	Dim WritedBytes As Integer = Any
	hr = INetworkStream_Write(pINetworkStream, _
		@SendBuffer, 0, AllResponseHeadersToBytes(pIRequest, pIResponse, @SendBuffer, 0), @WritedBytes _
	)
	
	If FAILED(hr) Then
		CloseSocketConnection(ServerSocket2)
		Return False
	End If
	
	Dim pINetworkStreamOut As INetworkStream Ptr = Any
	hr = CreateInstance( _
		GetProcessHeap(), _
		@CLSID_NETWORKSTREAM, _
		@IID_INetworkStream, _
		@pINetworkStreamOut _
	)
	If FAILED(hr) Then
		CloseSocketConnection(ServerSocket2)
		Return False
	End If
	
	INetworkStream_SetSocket(pINetworkStreamOut, ServerSocket2)
	
	Dim CSS As ClientServerSocket = Any
	With CSS
		.pIStreamIn = pINetworkStream
		.pIStreamOut = pINetworkStreamOut
	End With
	
	Dim hThread As HANDLE = CreateThread(NULL, 0, @SendReceiveDataThreadProc, @CSS, 0, @CSS.ThreadId)
	
	If hThread <> NULL Then
		SendReceiveData(pINetworkStream, pINetworkStreamOut)
		
		WaitForSingleObject(hThread, INFINITE)
		
		CloseHandle(hThread)
	End If
	
	INetworkStream_Release(pINetworkStreamOut)
	
	IServerResponse_SetKeepAlive(pIResponse, False)
	
	Return True
	
End Function

Sub SendReceiveData( _
		ByVal pIStreamIn As INetworkStream Ptr, _
		ByVal pIStreamOut As INetworkStream Ptr _
	)
	' Читать данные из входящего сокета, отправлять на исходящий
	Const MaxBytesCount As Integer = 20 * 4096
	Dim ReceiveBuffer As ZString * (MaxBytesCount) = Any
	
	' Dim intReceivedBytesCount As Integer = recv(InSock, ReceiveBuffer, MaxBytesCount, 0)
	Dim ReadedBytes As Integer = Any
	Dim hrIn As HRESULT = INetworkStream_Read(pIStreamIn, _
		@ReceiveBuffer, 0, MaxBytesCount, @ReadedBytes _
	)
	
	If FAILED(hrIn) Then
		Exit Sub
	End If
	
	If ReadedBytes = 0 Then
		Exit Sub
	End If
	
	Do
		Dim WritedBytes As Integer = Any
		Dim hrOut As HRESULT = INetworkStream_Write(pIStreamOut, _
			@ReceiveBuffer, 0, ReadedBytes, @WritedBytes _
		)
		
		If FAILED(hrOut) Then
			Exit Sub
		End If
		
		hrIn = INetworkStream_Read(pIStreamIn, _
			@ReceiveBuffer, 0, MaxBytesCount, @ReadedBytes _
		)
		
		If FAILED(hrIn) Then
			Exit Sub
		End If
		
		If ReadedBytes = 0 Then
			Exit Sub
		End If
		
	Loop
End Sub

Function SendReceiveDataThreadProc( _
		ByVal lpParam As LPVOID _
	)As DWORD
	
	Dim pClientServerSocket As ClientServerSocket Ptr = CPtr(ClientServerSocket Ptr, lpParam)
	SendReceiveData(pClientServerSocket->pIStreamOut, pClientServerSocket->pIStreamIn)
	
	Return 0
End Function
