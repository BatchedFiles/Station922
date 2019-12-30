#include "WebServer.bi"
#include "win\shlwapi.bi"
#include "ClientRequest.bi"
#include "IConfiguration.bi"
#include "CreateInstance.bi"
#include "IniConst.bi"
#include "Network.bi"
#include "NetworkServer.bi"
#include "NetworkStream.bi"
#include "ServerResponse.bi"
#include "ThreadProc.bi"
#include "WebUtils.bi"
#include "WriteHttpError.bi"

Const ClientSocketReceiveTimeout As DWORD = 90 * 1000
Const DefaultStackSize As SIZE_T_ = 0
Const SleepTimeout As DWORD = 60 * 1000

Extern IID_IUnknown_WithoutMinGW As Const IID
Extern CLSID_CONFIGURATION Alias "CLSID_CONFIGURATION" As Const CLSID
Extern CLSID_WEBSITECONTAINER Alias "CLSID_WEBSITECONTAINER" As Const CLSID

Dim Shared ExecutableDirectory As WString * (MAX_PATH + 1)

Dim Shared GlobalWebServerVirtualTable As IRunnableVirtualTable = Type( _
	Type<IUnknownVtbl>( _
		@WebServerQueryInterface, _
		@WebServerAddRef, _
		@WebServerRelease _
	), _
	@WebServerRun, _
	@WebServerStop _
)

Sub InitializeWebServer( _
		ByVal pWebServer As WebServer Ptr _
	)
	
	pWebServer->pVirtualTable = @GlobalWebServerVirtualTable
	pWebServer->ReferenceCounter = 0
	
	pWebServer->hThreadContextHeap = HeapCreate(0, 0, 0)
	
	Dim ExeFileName As WString * (MAX_PATH + 1) = Any
	Dim ExeFileNameLength As DWORD = GetModuleFileName(0, @ExeFileName, MAX_PATH)
	If ExeFileNameLength = 0 Then
		' Return 4
	End If
	
	lstrcpy(@ExecutableDirectory, @ExeFileName)
	PathRemoveFileSpec(@ExecutableDirectory)
	
	PathCombine(@pWebServer->SettingsFileName, @ExecutableDirectory, @WebServerIniFileString)
	
	pWebServer->ReListenSocket = True
	QueryPerformanceFrequency(@pWebServer->Frequency)
	
End Sub

Sub UnInitializeWebServer( _
		ByVal pWebServer As WebServer Ptr _
	)
	
End Sub

Function CreateWebServer( _
	)As WebServer Ptr
	
	Dim pWebServer As WebServer Ptr = HeapAlloc( _
		GetProcessHeap(), _
		0, _
		SizeOf(WebServer) _
	)
	
	If pWebServer = NULL Then
		Return NULL
	End If
	
	InitializeWebServer(pWebServer)
	
	Return pWebServer
	
End Function

Sub DestroyWebServer( _
		ByVal this As WebServer Ptr _
	)
	
	UnInitializeWebServer(this)
	
	HeapFree(GetProcessHeap(), 0, this)
	
End Sub

Function WebServerQueryInterface( _
		ByVal pWebServer As WebServer Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IRunnable, riid) Then
		*ppv = @pWebServer->pVirtualTable
	Else
		If IsEqualIID(@IID_IUnknown_WithoutMinGW, riid) Then
			*ppv = @pWebServer->pVirtualTable
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	WebServerAddRef(pWebServer)
	
	Return S_OK
	
End Function

Function WebServerAddRef( _
		ByVal pWebServer As WebServer Ptr _
	)As ULONG
	
	pWebServer->ReferenceCounter += 1
	
	Return pWebServer->ReferenceCounter
	
End Function

Function WebServerRelease( _
		ByVal pWebServer As WebServer Ptr _
	)As ULONG
	
	pWebServer->ReferenceCounter -= 1
	
	If pWebServer->ReferenceCounter = 0 Then
		
		DestroyWebServer(pWebServer)
		
		Return 0
	End If
	
	Return pWebServer->ReferenceCounter
	
End Function

Function WebServerRun( _
		ByVal pWebServer As WebServer Ptr _
	)As HRESULT
	
	Dim pIWebSites As IWebSiteContainer Ptr = Any
	
	Dim hr As HRESULT = CreateInstance( _
		GetProcessHeap(), _
		@CLSID_WEBSITECONTAINER, _
		@IID_IWebSiteContainer, _
		@pIWebSites _
	)
	
	If FAILED(hr) Then
		Return hr
	End If
	
	IWebSiteContainer_LoadWebSites(pIWebSites, @ExecutableDirectory)
	
	Do
		
		Dim pIConfig As IConfiguration Ptr = Any
		hr = CreateInstance(GetProcessHeap(), @CLSID_CONFIGURATION, @IID_IConfiguration, @pIConfig)
		
		If FAILED(hr) Then
			Return hr
		End If
		
		IConfiguration_SetIniFilename(pIConfig, @pWebServer->SettingsFileName)
		
		Dim ValueLength As Integer = Any
		
		IConfiguration_GetStringValue(pIConfig, _
			@WebServerSectionString, _
			@ListenAddressKeyString, _
			@DefaultAddressString, _
			WebServer.ListenAddressLengthMaximum, _
			@pWebServer->ListenAddress, _
			@ValueLength _
		)
		
		IConfiguration_GetStringValue(pIConfig, _
			@WebServerSectionString, _
			@PortKeyString, _
			@DefaultHttpPort, _
			WebServer.ListenPortLengthMaximum, _
			@pWebServer->ListenPort, _
			@ValueLength _
		)
		
		IConfiguration_Release(pIConfig)
		
		Dim hrCreateSocket As HRESULT = CreateSocketAndListen( _
			@pWebServer->ListenAddress, _
			@pWebServer->ListenPort, _
			@pWebServer->ListenSocket _
		)
		
		If FAILED(hrCreateSocket) Then
			' TODO Обработать ошибку
			If pWebServer->ReListenSocket Then
				SleepEx(SleepTimeout, True)
			Else
				IWebSiteContainer_Release(pIWebSites)
				Return S_OK
			End If
		Else
			Exit Do
		End If
		
	Loop
	
	Do
		
		Dim pContext As ThreadContext Ptr = HeapAlloc( _
			pWebServer->hThreadContextHeap, _
			0, _
			SizeOf(ThreadContext) _
		)
		
		Dim dwThreadId As DWORD = Any
		Dim hThread As HANDLE = CreateThread( _
			NULL, _
			DefaultStackSize, _
			@ThreadProc, _
			pContext, _
			CREATE_SUSPENDED, _
			@dwThreadId _
		)
		Dim dwCreateThreadErrorCode As DWORD = GetLastError()
		
		Dim RemoteAddress As SOCKADDR_IN = Any
		Dim RemoteAddressLength As Long = SizeOf(RemoteAddress)
		
		Dim ClientSocket As SOCKET = accept( _
			pWebServer->ListenSocket, _
			CPtr(SOCKADDR Ptr, @RemoteAddress), _
			@RemoteAddressLength _
		)
		
		If ClientSocket = INVALID_SOCKET Then
			
			If pWebServer->ReListenSocket = False Then
				Exit Do
			End If
			
			' TODO Узнать ошибку и обработать
			Dim SocketErrorCode As Integer = WSAGetLastError()
			SleepEx(SleepTimeout, True)
			
		Else
			
			If pContext = NULL OrElse hThread = NULL Then
				Dim tcpStream As NetworkStream = Any
				Dim pINetworkStream As INetworkStream Ptr = InitializeNetworkStreamOfINetworkStream(@tcpStream)
				
				NetworkStream_NonVirtualSetSocket(pINetworkStream, ClientSocket)
				
				Dim request As ClientRequest = Any
				Dim pIClientRequest As IClientRequest Ptr = InitializeClientRequestOfIClientRequest(@request)
				
				Dim response As ServerResponse = Any
				Dim pIResponse As IServerResponse Ptr = InitializeServerResponseOfIServerResponse(@response)
				
				If pContext = NULL Then
					WriteHttpNotEnoughMemory( _
						pIClientRequest, _
						pIResponse, _
						CPtr(IBaseStream Ptr, pINetworkStream), _
						NULL _
					)
				Else
					WriteHttpCannotCreateThread( _
						pIClientRequest, _
						pIResponse, _
						CPtr(IBaseStream Ptr, pINetworkStream), _
						NULL _
					)
				End If
				
				IServerResponse_Release(pIResponse)
				IClientRequest_Release(pIClientRequest)
				
				NetworkStream_NonVirtualRelease(pINetworkStream)
				
				If pContext <> NULL Then
					HeapFree(pWebServer->hThreadContextHeap, 0, pContext)
				End If
				
				If hThread <> NULL Then
					CloseHandle(hThread)
				End If
				
			Else
				
				SetReceiveTimeout(ClientSocket, ClientSocketReceiveTimeout)
				
				pContext->ClientSocket = ClientSocket
				
				pContext->pINetworkStream = InitializeNetworkStreamOfINetworkStream(@pContext->tcpStream)
				NetworkStream_NonVirtualSetSocket(pContext->pINetworkStream, ClientSocket)
				
				pContext->RemoteAddress = RemoteAddress
				pContext->RemoteAddressLength = RemoteAddressLength
				
				pContext->ThreadId = dwThreadId
				pContext->hThread = hThread
				pContext->pExeDir = @ExecutableDirectory
				
				IWebSiteContainer_AddRef(pIWebSites)
				pContext->pIWebSites = pIWebSites
				
				pContext->hThreadContextHeap = pWebServer->hThreadContextHeap
				
				pContext->Frequency.QuadPart = pWebServer->Frequency.QuadPart
				QueryPerformanceCounter(@pContext->m_startTicks)
				
				ResumeThread(hThread)
				
			End If
			
		End If
		
	Loop While pWebServer->ReListenSocket
	
	IWebSiteContainer_Release(pIWebSites)
	
	Return S_OK
	
End Function

Function WebServerStop( _
		ByVal pWebServer As WebServer Ptr _
	)As HRESULT
	
	pWebServer->ReListenSocket = False
	closesocket(pWebServer->ListenSocket)
	
	Return S_OK
	
End Function
