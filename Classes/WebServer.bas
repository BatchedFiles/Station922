#include "WebServer.bi"
#include "win\shlwapi.bi"
#include "IConfiguration.bi"
#include "IWorkerThreadContext.bi"
#include "CreateInstance.bi"
#include "IniConst.bi"
#include "Network.bi"
#include "NetworkServer.bi"
#include "ThreadProc.bi"
#include "WebUtils.bi"
#include "WriteHttpError.bi"

Const CLIENTSOCKET_RECEIVE_TIMEOUT As DWORD = 90 * 1000
Const THREAD_STACK_SIZE As SIZE_T_ = 0
Const THREAD_SLEEPING_TIME As DWORD = 60 * 1000

Declare Function WebServerReadConfiguration( _
	ByVal this As WebServer Ptr _
)As HRESULT

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
				SleepEx(THREAD_SLEEPING_TIME, True)
			Else
				IWebSiteContainer_Release(pIWebSites)
				Return S_OK
			End If
		Else
			Exit Do
		End If
		
	Loop
	
	Const dwThreadContextHeapInitialSize As DWORD = 128 * 1024
	Const dwThreadContextHeapMaximumSize As DWORD = 256 * 1024
	
	Dim hWorkerThreadContextHeap As HANDLE = HeapCreate( _
		HEAP_NO_SERIALIZE, _
		dwThreadContextHeapInitialSize, _
		dwThreadContextHeapMaximumSize _
	)
	Dim dwCreateThreadContextHeapErrorCode As DWORD = GetLastError()
	
	Dim pIContext As IWorkerThreadContext Ptr = Any
	Dim hrCreateThreadContext As HRESULT = CreateInstance( _
		hWorkerThreadContextHeap, _
		@CLSID_WORKERTHREADCONTEXT, _
		@IID_IWorkerThreadContext, _
		@pIContext _
	)
	
	Dim dwThreadId As DWORD = Any
	Dim hThread As HANDLE = CreateThread( _
		NULL, _
		THREAD_STACK_SIZE, _
		@ThreadProc, _
		pIContext, _
		CREATE_SUSPENDED, _
		@dwThreadId _
	)
	Dim dwCreateThreadErrorCode As DWORD = GetLastError()
	
	Do
		
		Dim RemoteAddress As SOCKADDR_IN = Any
		Dim RemoteAddressLength As Long = SizeOf(RemoteAddress)
		
		Dim ClientSocket As SOCKET = accept( _
			this->ListenSocket, _
			CPtr(SOCKADDR Ptr, @RemoteAddress), _
			@RemoteAddressLength _
		)
		Dim SocketErrorCode As Integer = WSAGetLastError()
		
		Dim FailedFlag As Boolean = (hWorkerThreadContextHeap = NULL) OrElse _
			(FAILED(hrCreateThreadContext)) OrElse _
			(hThread = NULL) OrElse _
		(ClientSocket = INVALID_SOCKET)
		
		If FailedFlag Then
			
			If this->ReListenSocket = False Then
				Exit Do
			End If
			
			INetworkStream_SetSocket(pINetworkStreamDefault, ClientSocket)
			
			If hThread = NULL Then
				' TODO Использовать код ошибки создания потока dwCreateThreadErrorCode
				WriteHttpCannotCreateThread( _
					NULL, _
					pIResponseDefault, _
					CPtr(IBaseStream Ptr, pINetworkStreamDefault), _
					NULL _
				)
			Else
				' TODO Использовать код ошибки создания кучи dwCreateThreadContextHeapErrorCode и выделения памяти hrCreateThreadContext
				WriteHttpNotEnoughMemory( _
					NULL, _
					pIResponseDefault, _
					CPtr(IBaseStream Ptr, pINetworkStreamDefault), _
					NULL _
				)
			End If
			
			If hThread <> NULL Then
				CloseHandle(hThread)
			End If
			
			If hWorkerThreadContextHeap <> NULL Then
				HeapDestroy(hWorkerThreadContextHeap)
			End If
			
			SleepEx(THREAD_SLEEPING_TIME, True)
			
		Else
			
			SetReceiveTimeout(ClientSocket, CLIENTSOCKET_RECEIVE_TIMEOUT)
			
			Dim pIClientRequest As IClientRequest Ptr = Any
			IWorkerThreadContext_GetClientRequest(pIContext, @pIClientRequest)
			
			Dim pINetworkStream As INetworkStream Ptr = Any
			IWorkerThreadContext_GetNetworkStream(pIContext, @pINetworkStream)
			
			INetworkStream_SetSocket(pINetworkStream, ClientSocket)
			
			IWorkerThreadContext_SetRemoteAddress(pIContext, RemoteAddress)
			IWorkerThreadContext_SetRemoteAddressLength(pIContext, RemoteAddressLength)
			
			IWorkerThreadContext_SetThreadId(pIContext, dwThreadId)
			IWorkerThreadContext_SetThreadHandle(pIContext, hThread)
			IWorkerThreadContext_SetExecutableDirectory(pIContext, @ExecutableDirectory)
			
			IWorkerThreadContext_SetWebSiteContainer(pIContext, pIWebSites)
			
			IWorkerThreadContext_SetFrequency(pIContext, this->Frequency) '.QuadPart
			
			INetworkStream_Release(pINetworkStream)
			IClientRequest_Release(pIClientRequest)
			
			Dim StartTicks As LARGE_INTEGER
			QueryPerformanceCounter(@StartTicks)
			
			IWorkerThreadContext_SetStartTicks(pIContext, StartTicks)
			
			Dim dwResume As DWORD = ResumeThread(hThread)
			If dwResume = -1 Then
				' TODO Узнать ошибку и обработать
				Dim dwError As DWORD = GetLastError()
				IWorkerThreadContext_Release(pIContext)
			End If
			
		End If
		
		hWorkerThreadContextHeap = HeapCreate( _
			HEAP_NO_SERIALIZE, _
			dwThreadContextHeapInitialSize, _
			dwThreadContextHeapMaximumSize _
		)
		dwCreateThreadContextHeapErrorCode = GetLastError()
		
		hrCreateThreadContext = CreateInstance( _
			hWorkerThreadContextHeap, _
			@CLSID_WORKERTHREADCONTEXT, _
			@IID_IWorkerThreadContext, _
			@pIContext _
		)
		
		hThread = CreateThread( _
			NULL, _
			THREAD_STACK_SIZE, _
			@ThreadProc, _
			pIContext, _
			CREATE_SUSPENDED, _
			@dwThreadId _
		)
		dwCreateThreadErrorCode = GetLastError()
		
	Loop While this->ReListenSocket
	
	If hThread <> NULL Then
		CloseHandle(hThread)
	End If
	
	If hWorkerThreadContextHeap <> NULL Then
		HeapDestroy(hWorkerThreadContextHeap)
	End If
	
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
