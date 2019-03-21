#include "WebServer.bi"
#include "win\shlwapi.bi"
#include "ThreadProc.bi"
#include "Network.bi"
#include "WebUtils.bi"
#include "IniConst.bi"
#include "WriteHttpError.bi"
#include "NetworkStream.bi"
#include "Configuration.bi"
#include "ClientRequest.bi"
#include "WebResponse.bi"

Common Shared GlobalWebServerVirtualTable As IRunnableVirtualTable

Sub InitializeWebServer( _
		ByVal pWebServer As WebServer Ptr _
	)
	
	pWebServer->pVirtualTable = @GlobalWebServerVirtualTable
	pWebServer->ReferenceCounter = 0
	
	Dim ExeFileName As WString * (MAX_PATH + 1) = Any
	Dim ExeFileNameLength As DWORD = GetModuleFileName(0, @ExeFileName, MAX_PATH)
	If ExeFileNameLength = 0 Then
		' Return 4
	End If
	
	lstrcpy(@pWebServer->ExeDir, @ExeFileName)
	PathRemoveFileSpec(@pWebServer->ExeDir)
	
	PathCombine(@pWebServer->SettingsFileName, @pWebServer->ExeDir, @WebServerIniFileString)
	
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
	
	WebSiteContainer_NonVirtualLoadWebSites(pIWebSites, @pWebServer->ExeDir)
	
	pWebServer->ListenSocket = CreateSocketAndListen(@pWebServer->ListenAddress, @pWebServer->ListenPort)
	
	If pWebServer->ListenSocket = INVALID_SOCKET Then
		WSACleanup()
		Return E_FAIL
	End If
	
	Dim hHeap As HANDLE = GetProcessHeap()
	
	If hHeap = NULL Then
		WSACleanup()
		Return E_FAIL
	End If
	
#ifndef service
		
		Dim m_frequency As LARGE_INTEGER
		QueryPerformanceFrequency(@m_frequency)
		
#endif
	
	Dim param As ThreadParam Ptr = HeapAlloc( _
		hHeap, _
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
			
			Dim response As WebResponse = Any
			InitializeWebResponse(@response)
			
			WriteHttpNotEnoughMemory(pIClientRequest, @response, CPtr(IBaseStream Ptr, pINetworkStream), 0)
			
			IClientRequest_Release(pIClientRequest)
			
			NetworkStream_NonVirtualRelease(pINetworkStream)
			
			Goto TDLoop
		End If
		
#ifndef service
		
		param->m_frequency.QuadPart = m_frequency.QuadPart
		QueryPerformanceCounter(@param->m_startTicks)
		
#endif
		
		param->pINetworkStream = InitializeNetworkStreamOfINetworkStream(@param->tcpStream)
		NetworkStream_NonVirtualSetSocket(param->pINetworkStream, ClientSocket)
		
		If param->hThread = NULL Then
			' TODO Узнать ошибку и обработать
			Dim request As ClientRequest = Any
			Dim pIClientRequest As IClientRequest Ptr = InitializeClientRequestOfIClientRequest(@request)
			
			Dim response As WebResponse = Any
			InitializeWebResponse(@response)
			
			WriteHttpCannotCreateThread(pIClientRequest, @response, CPtr(IBaseStream Ptr, param->pINetworkStream), 0)
			
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
		param->pExeDir = @pWebServer->ExeDir
		param->pIWebSites = pIWebSites
		
		ResumeThread(param->hThread)
		
TDLoop:
		param = HeapAlloc( _
			hHeap, _
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
