#include "WebServer.bi"
#include "win\shlwapi.bi"
#include "IClientRequest.bi"
#include "IConfiguration.bi"
#include "IWorkerThreadContext.bi"
#include "CreateInstance.bi"
#include "IniConst.bi"
#include "Network.bi"
#include "NetworkServer.bi"
#include "IServerResponse.bi"
#include "ThreadProc.bi"
#include "WebUtils.bi"
#include "WriteHttpError.bi"

Const ClientSocketReceiveTimeout As DWORD = 90 * 1000
Const DefaultStackSize As SIZE_T_ = 0
Const SleepTimeout As DWORD = 60 * 1000

Declare Function WebServerReadConfiguration( _
	ByVal this As WebServer Ptr _
)As HRESULT

Extern CLSID_CLIENTREQUEST Alias "CLSID_CLIENTREQUEST" As Const CLSID
Extern CLSID_CONFIGURATION Alias "CLSID_CONFIGURATION" As Const CLSID
Extern CLSID_NETWORKSTREAM Alias "CLSID_NETWORKSTREAM" As Const CLSID
Extern CLSID_SERVERRESPONSE Alias "CLSID_SERVERRESPONSE" As Const CLSID
Extern CLSID_WEBSITECONTAINER Alias "CLSID_WEBSITECONTAINER" As Const CLSID
Extern CLSID_WORKERTHREADCONTEXT Alias "CLSID_WORKERTHREADCONTEXT" As Const CLSID

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
		ByVal this As WebServer Ptr _
	)
	
	this->pVirtualTable = @GlobalWebServerVirtualTable
	this->ReferenceCounter = 0
	
	this->hThreadContextHeap = HeapCreate(0, 0, 0)
	
	Dim ExeFileName As WString * (MAX_PATH + 1) = Any
	Dim ExeFileNameLength As DWORD = GetModuleFileName(0, @ExeFileName, MAX_PATH)
	If ExeFileNameLength = 0 Then
		' Return 4
	End If
	
	lstrcpy(@ExecutableDirectory, @ExeFileName)
	PathRemoveFileSpec(@ExecutableDirectory)
	
	PathCombine(@this->SettingsFileName, @ExecutableDirectory, @WebServerIniFileString)
	
	this->ListenSocket = INVALID_SOCKET
	this->ReListenSocket = True
	
	QueryPerformanceFrequency(@this->Frequency)
	
End Sub

Sub UnInitializeWebServer( _
		ByVal this As WebServer Ptr _
	)
	
	If this->ListenSocket <> INVALID_SOCKET Then
		closesocket(this->ListenSocket)
	End If
	
End Sub

Function CreateWebServer( _
	)As WebServer Ptr
	
	Dim this As WebServer Ptr = HeapAlloc( _
		GetProcessHeap(), _
		0, _
		SizeOf(WebServer) _
	)
	
	If this = NULL Then
		Return NULL
	End If
	
	InitializeWebServer(this)
	
	Return this
	
End Function

Sub DestroyWebServer( _
		ByVal this As WebServer Ptr _
	)
	
	UnInitializeWebServer(this)
	
	HeapFree(GetProcessHeap(), 0, this)
	
End Sub

Function WebServerQueryInterface( _
		ByVal this As WebServer Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IRunnable, riid) Then
		*ppv = @this->pVirtualTable
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->pVirtualTable
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	WebServerAddRef(this)
	
	Return S_OK
	
End Function

Function WebServerAddRef( _
		ByVal this As WebServer Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return this->ReferenceCounter
	
End Function

Function WebServerRelease( _
		ByVal this As WebServer Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter = 0 Then
		
		DestroyWebServer(this)
		
		Return 0
	End If
	
	Return this->ReferenceCounter
	
End Function

Function WebServerRun( _
		ByVal this As WebServer Ptr _
	)As HRESULT
	
	Dim hr As HRESULT = Any
	
	Dim pINetworkStreamDefault As INetworkStream Ptr = Any
	hr = CreateInstance( _
		GetProcessHeap(), _
		@CLSID_NETWORKSTREAM, _
		@IID_INetworkStream, _
		@pINetworkStreamDefault _
	)
	If FAILED(hr) Then
		Return hr
	End If
	
	Dim pIResponseDefault As IServerResponse Ptr = Any
	hr = CreateInstance( _
		GetProcessHeap(), _
		@CLSID_SERVERRESPONSE, _
		@IID_IServerResponse, _
		@pIResponseDefault _
	)
	If FAILED(hr) Then
		Return hr
	End If
	
	Dim pIWebSites As IWebSiteContainer Ptr = Any
	hr = CreateInstance( _
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
		hr = WebServerReadConfiguration(this)
		If FAILED(hr) Then
			Return hr
		End If
		
		Dim hrCreateSocket As HRESULT = CreateSocketAndListen( _
			@this->ListenAddress, _
			@this->ListenPort, _
			@this->ListenSocket _
		)
		
		If FAILED(hrCreateSocket) Then
			' TODO Обработать ошибку
			If this->ReListenSocket Then
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
		
		Dim pIContext As IWorkerThreadContext Ptr = Any
		Dim hrCreateThreadContext As HRESULT = CreateInstance( _
			GetProcessHeap(), _
			@CLSID_WORKERTHREADCONTEXT, _
			@IID_IWorkerThreadContext, _
			@pIContext _
		)
		
		Dim pIClientRequest As IClientRequest Ptr = Any
		Dim hrCreateClientRequest As HRESULT = CreateInstance( _
			GetProcessHeap(), _
			@CLSID_CLIENTREQUEST, _
			@IID_IClientRequest, _
			@pIClientRequest _
		)
		
		Dim dwThreadId As DWORD = Any
		Dim hThread As HANDLE = CreateThread( _
			NULL, _
			DefaultStackSize, _
			@ThreadProc, _
			pIContext, _
			CREATE_SUSPENDED, _
			@dwThreadId _
		)
		Dim dwCreateThreadErrorCode As DWORD = GetLastError()
		
		Dim RemoteAddress As SOCKADDR_IN = Any
		Dim RemoteAddressLength As Long = SizeOf(RemoteAddress)
		
		Dim ClientSocket As SOCKET = accept( _
			this->ListenSocket, _
			CPtr(SOCKADDR Ptr, @RemoteAddress), _
			@RemoteAddressLength _
		)
		
		If ClientSocket = INVALID_SOCKET Then
			
			If this->ReListenSocket = False Then
				CloseHandle(hThread)
				Exit Do
			End If
			
			' TODO Узнать ошибку и обработать
			Dim SocketErrorCode As Integer = WSAGetLastError()
			SleepEx(SleepTimeout, True)
			CloseHandle(hThread)
			
		Else
			
			Dim FailedFlag As Boolean = FAILED(hrCreateThreadContext) OrElse _
				FAILED(hrCreateClientRequest) OrElse _
			hThread = NULL
			
			If FailedFlag Then
				INetworkStream_SetSocket(pINetworkStreamDefault, ClientSocket)
				
				If hThread = NULL Then
					WriteHttpCannotCreateThread( _
						NULL, _
						pIResponseDefault, _
						CPtr(IBaseStream Ptr, pINetworkStreamDefault), _
						NULL _
					)
				Else
					WriteHttpNotEnoughMemory( _
						NULL, _
						pIResponseDefault, _
						CPtr(IBaseStream Ptr, pINetworkStreamDefault), _
						NULL _
					)
				End If
				
				If pIClientRequest <> NULL Then
					IClientRequest_Release(pIClientRequest)
				End If
				
				If pIContext <> NULL Then
					IWorkerThreadContext_Release(pIContext)
				End If
				
				If hThread <> NULL Then
					CloseHandle(hThread)
				End If
				
			Else
				
				SetReceiveTimeout(ClientSocket, ClientSocketReceiveTimeout)
				
				Dim pINetworkStream As INetworkStream Ptr = Any
				hr = CreateInstance( _
					GetProcessHeap(), _
					@CLSID_NETWORKSTREAM, _
					@IID_INetworkStream, _
					@pINetworkStream _
				)
				If FAILED(hr) Then
					
					CloseHandle(hThread)
				Else
					
					INetworkStream_SetSocket(pINetworkStream, ClientSocket)
					
					IWorkerThreadContext_SetNetworkStream(pIContext, pINetworkStream)
					
					IWorkerThreadContext_SetRemoteAddress(pIContext, RemoteAddress)
					IWorkerThreadContext_SetRemoteAddressLength(pIContext, RemoteAddressLength)
					
					IWorkerThreadContext_SetThreadId(pIContext, dwThreadId)
					IWorkerThreadContext_SetThreadHandle(pIContext, hThread)
					IWorkerThreadContext_SetExecutableDirectory(pIContext, @ExecutableDirectory)
					
					IWorkerThreadContext_SetWebSiteContainer(pIContext, pIWebSites)
					
					IWorkerThreadContext_SetThreadContextHeap(pIContext, this->hThreadContextHeap)
					
					IWorkerThreadContext_SetFrequency(pIContext, this->Frequency) '.QuadPart
					
					Dim StartTicks As LARGE_INTEGER
					QueryPerformanceCounter(@StartTicks)
					
					IWorkerThreadContext_SetStartTicks(pIContext, StartTicks)
					
					IWorkerThreadContext_SetClientRequest(pIContext, pIClientRequest)
					
					Dim dwResume As DWORD = ResumeThread(hThread)
					If dwResume = -1 Then
						' TODO Узнать ошибку и обработать
						Dim dwError As DWORD = GetLastError()
						CloseHandle(hThread)
					End If
					
					INetworkStream_Release(pINetworkStream)
					IClientRequest_Release(pIClientRequest)
					
				End If
			End If
			
		End If
		
	Loop While this->ReListenSocket
	
	IWebSiteContainer_Release(pIWebSites)
	
	IServerResponse_Release(pIResponseDefault)
	INetworkStream_Release(pINetworkStreamDefault)
	
	Return S_OK
	
End Function

Function WebServerStop( _
		ByVal this As WebServer Ptr _
	)As HRESULT
	
	this->ReListenSocket = False
	
	If this->ListenSocket <> INVALID_SOCKET Then
		closesocket(this->ListenSocket)
		this->ListenSocket = INVALID_SOCKET
	End If
	
	Return S_OK
	
End Function

Function WebServerReadConfiguration( _
		ByVal this As WebServer Ptr _
	)As HRESULT
	
	Dim pIConfig As IConfiguration Ptr = Any
	Dim hr As HRESULT = CreateInstance( _
		GetProcessHeap(), _
		@CLSID_CONFIGURATION, _
		@IID_IConfiguration, _
		@pIConfig _
	)
	
	If FAILED(hr) Then
		Return hr
	End If
	
	IConfiguration_SetIniFilename(pIConfig, @this->SettingsFileName)
	
	Dim ValueLength As Integer = Any
	
	IConfiguration_GetStringValue(pIConfig, _
		@WebServerSectionString, _
		@ListenAddressKeyString, _
		@DefaultAddressString, _
		ListenAddressLengthMaximum, _
		@this->ListenAddress, _
		@ValueLength _
	)
	
	IConfiguration_GetStringValue(pIConfig, _
		@WebServerSectionString, _
		@PortKeyString, _
		@DefaultHttpPort, _
		ListenPortLengthMaximum, _
		@this->ListenPort, _
		@ValueLength _
	)
	
	IConfiguration_Release(pIConfig)
	
	Return S_OK
	
End Function
