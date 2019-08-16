#include "WebServer.bi"
#include "win\shlwapi.bi"
#include "ClientRequest.bi"
#include "Configuration.bi"
#include "IniConst.bi"
#include "Network.bi"
#include "NetworkServer.bi"
#include "NetworkStream.bi"
#include "ServerResponse.bi"
#include "ThreadProc.bi"
#include "WebUtils.bi"
#include "WriteHttpError.bi"

Common Shared GlobalWebServerVirtualTable As IRunnableVirtualTable

Sub InitializeWebServerVirtualTable()
	GlobalWebServerVirtualTable.InheritedTable.QueryInterface = Cast(Any Ptr, @WebServerQueryInterface)
	GlobalWebServerVirtualTable.InheritedTable.Addref = Cast(Any Ptr, @WebServerAddRef)
	GlobalWebServerVirtualTable.InheritedTable.Release = Cast(Any Ptr, @WebServerRelease)
	GlobalWebServerVirtualTable.Run = Cast(Any Ptr, @WebServerRun)
	GlobalWebServerVirtualTable.Stop = Cast(Any Ptr, @WebServerStop)
End Sub

Sub InitializeWebServer( _
		ByVal pWebServer As WebServer Ptr _
	)
	
	pWebServer->pVirtualTable = @GlobalWebServerVirtualTable
	pWebServer->ReferenceCounter = 0
	
	pWebServer->hHeap = GetProcessHeap()
	
	Dim ExeFileName As WString * (MAX_PATH + 1) = Any
	Dim ExeFileNameLength As DWORD = GetModuleFileName(0, @ExeFileName, MAX_PATH)
	If ExeFileNameLength = 0 Then
		' Return 4
	End If
	
	' TODO Придумать как очистить память
	pWebServer->pExeDir = HeapAlloc( _
		pWebServer->hHeap, _
		0, _
		(MAX_PATH + 1) * SizeOf(WString) _
	)
	
	lstrcpy(pWebServer->pExeDir, @ExeFileName)
	PathRemoveFileSpec(pWebServer->pExeDir)
	
	PathCombine(@pWebServer->SettingsFileName, pWebServer->pExeDir, @WebServerIniFileString)
	
	Scope
		Dim objWsaData As WSAData = Any
		If WSAStartup(MAKEWORD(2, 2), @objWsaData) <> NO_ERROR Then
			' Return 1
		End If
	End Scope
	
	pWebServer->ReListenSocket = True
	
End Sub

Function InitializeWebServerOfIRunnable( _
		ByVal pWebServer As WebServer Ptr _
	)As IRunnable Ptr
	
	InitializeWebServer(pWebServer)
	pWebServer->ExistsInStack = True
	
	Dim pIWebServer As IRunnable Ptr = Any
	
	WebServerQueryInterface( _
		pWebServer, @IID_IRUNNABLE, @pIWebServer _
	)
	
	Return pIWebServer
	
End Function

Function WebServerQueryInterface( _
		ByVal pWebServer As WebServer Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	*ppv = 0
	
	If IsEqualIID(@IID_IUnknown, riid) Then
		*ppv = CPtr(IUnknown Ptr, @pWebServer->pVirtualTable)
	End If
	
	If IsEqualIID(@IID_IRUNNABLE, riid) Then
		*ppv = CPtr(IRunnable Ptr, @pWebServer->pVirtualTable)
	End If
	
	If *ppv = 0 Then
		Return E_NOINTERFACE
	End If
	
	WebServerAddRef(pWebServer)
	
	Return S_OK
	
End Function

Function WebServerAddRef( _
		ByVal pWebServer As WebServer Ptr _
	)As ULONG
	
	Return InterlockedIncrement(@pWebServer->ReferenceCounter)
	
End Function

Function WebServerRelease( _
		ByVal pWebServer As WebServer Ptr _
	)As ULONG
	
	InterlockedDecrement(@pWebServer->ReferenceCounter)
	
	If pWebServer->ReferenceCounter = 0 Then
		
		If pWebServer->ExistsInStack = False Then
		
		End If
		
		Return 0
	End If
	
	Return pWebServer->ReferenceCounter
	
End Function

Function WebServerRun( _
		ByVal pWebServer As WebServer Ptr _
	)As HRESULT
	
	Dim Config As Configuration = Any
	Dim pIConfig As IConfiguration Ptr = InitializeConfigurationOfIConfiguration(@Config)
	
	Configuration_NonVirtualSetIniFilename(pIConfig, @pWebServer->SettingsFileName)
	
	Dim ValueLength As Integer = Any
	
	Configuration_NonVirtualGetStringValue(pIConfig, _
		@WebServerSectionString, _
		@ListenAddressKeyString, _
		@DefaultAddressString, _
		WebServer.ListenAddressLengthMaximum, _
		@pWebServer->ListenAddress, _
		@ValueLength _
	)
	
	Configuration_NonVirtualGetStringValue(pIConfig, _
		@WebServerSectionString, _
		@PortKeyString, _
		@DefaultHttpPort, _
		WebServer.ListenPortLengthMaximum, _
		@pWebServer->ListenPort, _
		@ValueLength _
	)
	
	Configuration_NonVirtualRelease(pIConfig)
	
	Dim pIWebSites As IWebSiteContainer Ptr = CreateWebSiteContainerOfIWebSiteContainer()
	
	If pIWebSites = NULL Then
		WSACleanup()
		Return E_FAIL
	End If
	
	WebSiteContainer_NonVirtualLoadWebSites(pIWebSites, pWebServer->pExeDir)
	
	Dim hrCreateSocket As HRESULT = CreateSocketAndListen(@pWebServer->ListenAddress, @pWebServer->ListenPort, @pWebServer->ListenSocket)
	
	If FAILED(hrCreateSocket) Then
		WSACleanup()
		Return hrCreateSocket
	End If
	
	Dim m_frequency As LARGE_INTEGER
	QueryPerformanceFrequency(@m_frequency)
	
	Dim param As ThreadParam Ptr = HeapAlloc( _
		pWebServer->hHeap, _
		0, _
		SizeOf(ThreadParam) _
	)
	
	If param <> 0 Then
		param->hThread = CreateThread( _
			NULL, _
			0, _
			@ThreadProc, _
			param, _
			CREATE_SUSPENDED, _
			@param->ThreadId _
		)
	End If
	
	Dim RemoteAddress As SOCKADDR_IN = Any
	Dim RemoteAddressLength As Long = SizeOf(RemoteAddress)
	
	Dim ClientSocket As SOCKET = accept( _
		pWebServer->ListenSocket, _
		CPtr(SOCKADDR Ptr, @RemoteAddress), _
		@RemoteAddressLength _
	)
	
	Do While pWebServer->ReListenSocket
		
		If ClientSocket = INVALID_SOCKET Then
			SleepEx(60 * 1000, True)
			
			Goto TDLoop
		End If
		
		If param = 0 Then
			Dim tcpStream As NetworkStream = Any
			Dim pINetworkStream As INetworkStream Ptr = InitializeNetworkStreamOfINetworkStream(@tcpStream)
			
			NetworkStream_NonVirtualSetSocket(pINetworkStream, ClientSocket)
			
			Dim request As ClientRequest = Any
			Dim pIClientRequest As IClientRequest Ptr = InitializeClientRequestOfIClientRequest(@request)
			
			Dim response As ServerResponse = Any
			Dim pIResponse As IServerResponse Ptr = InitializeServerResponseOfIServerResponse(@response)
			
			WriteHttpNotEnoughMemory(pIClientRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), 0)
			
			IServerResponse_Release(pIResponse)
			IClientRequest_Release(pIClientRequest)
			
			NetworkStream_NonVirtualRelease(pINetworkStream)
			
			Goto TDLoop
		End If
		
		param->m_frequency.QuadPart = m_frequency.QuadPart
		QueryPerformanceCounter(@param->m_startTicks)
		
		param->pINetworkStream = InitializeNetworkStreamOfINetworkStream(@param->tcpStream)
		NetworkStream_NonVirtualSetSocket(param->pINetworkStream, ClientSocket)
		
		If param->hThread = NULL Then
			' TODO Узнать ошибку и обработать
			Dim request As ClientRequest = Any
			Dim pIClientRequest As IClientRequest Ptr = InitializeClientRequestOfIClientRequest(@request)
			
			Dim response As ServerResponse = Any
			Dim pIResponse As IServerResponse Ptr = InitializeServerResponseOfIServerResponse(@response)
			
			WriteHttpCannotCreateThread(pIClientRequest, pIResponse, CPtr(IBaseStream Ptr, param->pINetworkStream), 0)
			
			IServerResponse_Release(pIResponse)
			IClientRequest_Release(pIClientRequest)
			
			NetworkStream_NonVirtualRelease(param->pINetworkStream)
			
			VirtualFree(param, 0, MEM_RELEASE)
			
			Goto TDLoop
		End If
		
		WebSiteContainer_NonVirtualAddRef(pIWebSites)
		
		param->ClientSocket = ClientSocket
		param->RemoteAddress = RemoteAddress
		param->RemoteAddressLength = RemoteAddressLength
		param->ServerSocket = pWebServer->ListenSocket
		param->pExeDir = pWebServer->pExeDir
		param->pIWebSites = pIWebSites
		
		ResumeThread(param->hThread)
		
TDLoop:
		param = HeapAlloc( _
			pWebServer->hHeap, _
			0, _
			SizeOf(ThreadParam) _
		)
		
		If param <> 0 Then
			param->hThread = CreateThread( _
				NULL, _
				0, _
				@ThreadProc, _
				param, _
				CREATE_SUSPENDED, _
				@param->ThreadId _
			)
		End If
		
		ClientSocket = accept( _
			pWebServer->ListenSocket, _
			CPtr(SOCKADDR Ptr, @RemoteAddress), _
			@RemoteAddressLength _
		)
	Loop
	
	WebSiteContainer_NonVirtualRelease(pIWebSites)
	
	Return S_OK
	
End Function

Function WebServerStop( _
		ByVal pWebServer As WebServer Ptr _
	)As HRESULT
	
	pWebServer->ReListenSocket = False
	CloseSocketConnection(pWebServer->ListenSocket)
	WSACleanup()
	
	Return S_OK
	
End Function
