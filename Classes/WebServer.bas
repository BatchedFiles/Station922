﻿#include "WebServer.bi"
#include "win\shlwapi.bi"
#include "IConfiguration.bi"
#include "IClientContext.bi"
#include "CreateInstance.bi"
#include "IniConst.bi"
#include "Network.bi"
#include "NetworkServer.bi"
#include "ThreadProc.bi"
#include "WebUtils.bi"
#include "WriteHttpError.bi"

Const ListenAddressLengthMaximum As Integer = 255
Const ListenPortLengthMaximum As Integer = 15

Type _WebServer
	Dim pVirtualTable As IRunnableVirtualTable Ptr
	Dim ReferenceCounter As ULONG
	
	' Dim pExeDir As WString Ptr
	Dim LogDir As WString * (MAX_PATH + 1)
	Dim SettingsFileName As WString * (MAX_PATH + 1)
	
	Dim ListenAddress As WString * (ListenAddressLengthMaximum + 1)
	Dim ListenPort As WString * (ListenPortLengthMaximum + 1)
	
	Dim ListenSocket As SOCKET
	Dim ReListenSocket As Boolean
	
	#ifdef PERFORMANCE_TESTING
		Dim Frequency As LARGE_INTEGER
	#endif
	
End Type

Const CLIENTSOCKET_RECEIVE_TIMEOUT As DWORD = 90 * 1000
Const THREAD_STACK_SIZE As SIZE_T_ = 0
Const THREAD_SLEEPING_TIME As DWORD = 60 * 1000
Const ThreadContextHeapInitialSize As DWORD = 256000
Const ThreadContextHeapMaximumSize As DWORD = 256000

#define CreateSuspendedThread(lpThreadProc, pIContext, lpThreadId) CreateThread(NULL, THREAD_STACK_SIZE, (lpThreadProc), (pIContext), CREATE_SUSPENDED, (lpThreadId))

Declare Function WebServerReadConfiguration( _
	ByVal this As WebServer Ptr _
)As HRESULT

Extern CLSID_CONFIGURATION Alias "CLSID_CONFIGURATION" As Const CLSID
Extern CLSID_NETWORKSTREAM Alias "CLSID_NETWORKSTREAM" As Const CLSID
Extern CLSID_SERVERRESPONSE Alias "CLSID_SERVERRESPONSE" As Const CLSID
Extern CLSID_WEBSITECONTAINER Alias "CLSID_WEBSITECONTAINER" As Const CLSID
Extern CLSID_CLIENTCONTEXT Alias "CLSID_CLIENTCONTEXT" As Const CLSID

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
	
	#ifdef PERFORMANCE_TESTING
		QueryPerformanceFrequency(@this->Frequency)
	#endif
	
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
	
	' Dim pINetworkStreamDefault As INetworkStream Ptr = Any
	' hr = CreateInstance( _
		' GetProcessHeap(), _
		' @CLSID_NETWORKSTREAM, _
		' @IID_INetworkStream, _
		' @pINetworkStreamDefault _
	' )
	' If FAILED(hr) Then
		' Return hr
	' End If
	
	' Dim pIResponseDefault As IServerResponse Ptr = Any
	' hr = CreateInstance( _
		' GetProcessHeap(), _
		' @CLSID_SERVERRESPONSE, _
		' @IID_IServerResponse, _
		' @pIResponseDefault _
	' )
	' If FAILED(hr) Then
		' Return hr
	' End If
	
	
	' INetworkStream_SetSocket(pINetworkStreamDefault, ClientSocket)
	
	' If hThread = NULL Then
		' TODO Использовать код ошибки создания потока dwCreateThreadErrorCode
		' WriteHttpCannotCreateThread( _
			' NULL, _
			' pIResponseDefault, _
			' CPtr(IBaseStream Ptr, pINetworkStreamDefault), _
			' NULL _
		' )
	' Else
		' TODO Использовать код ошибки создания кучи dwCreateClientContextHeapErrorCode и выделения памяти hrCreateClientContext
		' WriteHttpNotEnoughMemory( _
			' NULL, _
			' pIResponseDefault, _
			' CPtr(IBaseStream Ptr, pINetworkStreamDefault), _
			' NULL _
		' )
	' End If
	
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
	
	Dim hClientContextHeap As HANDLE = HeapCreate( _
		HEAP_NO_SERIALIZE, _
		ThreadContextHeapInitialSize, _
		ThreadContextHeapMaximumSize _
	)
	Dim dwCreateClientContextHeapErrorCode As DWORD = GetLastError()
	
	Dim pIContext As IClientContext Ptr = NULL
	Dim hrCreateClientContext As HRESULT = E_FAIL
	If hClientContextHeap <> NULL Then
		hrCreateClientContext = CreateInstance( _
			hClientContextHeap, _
			@CLSID_CLIENTCONTEXT, _
			@IID_IClientContext, _
			@pIContext _
		)
	End If
			
	Dim dwThreadId As DWORD = Any
	Dim hThread As HANDLE = CreateSuspendedThread(@ThreadProc, pIContext, @dwThreadId)
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
		
		Dim FailedFlag As Boolean = (hClientContextHeap = NULL) OrElse _
			FAILED(hrCreateClientContext) OrElse _
			(hThread = NULL) OrElse _
		(ClientSocket = INVALID_SOCKET)
		
		If FailedFlag Then
			' TODO Отправить клиенту сообщение об ошибке сервера
			
			' Очистка
			If ClientSocket <> INVALID_SOCKET Then
				CloseSocketConnection(ClientSocket)
			End If
			
			If hThread <> NULL Then
				CloseHandle(hThread)
			End If
			
			If pIContext <> NULL Then
				IClientContext_Release(pIContext)
			End If
			
			If hClientContextHeap <> NULL Then
				HeapDestroy(hClientContextHeap)
			End If
			
			If this->ReListenSocket = False Then
				Exit Do
			End If
			
			SleepEx(THREAD_SLEEPING_TIME, True)
			
		Else
			SetReceiveTimeout(ClientSocket, CLIENTSOCKET_RECEIVE_TIMEOUT)
			
			Dim pIClientRequest As IClientRequest Ptr = Any
			IClientContext_GetClientRequest(pIContext, @pIClientRequest)
			
			Dim pINetworkStream As INetworkStream Ptr = Any
			IClientContext_GetNetworkStream(pIContext, @pINetworkStream)
			
			INetworkStream_SetSocket(pINetworkStream, ClientSocket)
			
			IClientContext_SetRemoteAddress(pIContext, RemoteAddress)
			IClientContext_SetRemoteAddressLength(pIContext, RemoteAddressLength)
			
			IClientContext_SetThreadId(pIContext, dwThreadId)
			IClientContext_SetThreadHandle(pIContext, hThread)
			IClientContext_SetClientContextHeap(pIContext, hClientContextHeap)
			IClientContext_SetExecutableDirectory(pIContext, @ExecutableDirectory)
			
			IClientContext_SetWebSiteContainer(pIContext, pIWebSites)
			
			INetworkStream_Release(pINetworkStream)
			IClientRequest_Release(pIClientRequest)
			
			#ifdef PERFORMANCE_TESTING
				IClientContext_SetFrequency(pIContext, this->Frequency)
				
				Dim StartTicks As LARGE_INTEGER
				QueryPerformanceCounter(@StartTicks)
				
				IClientContext_SetStartTicks(pIContext, StartTicks)
			#endif
			
			Dim dwResume As DWORD = ResumeThread(hThread)
			If dwResume = -1 Then
				' TODO Узнать ошибку и обработать
				Dim dwResumeThreadError As DWORD = GetLastError()
				
				' TODO Отправить клиенту сообщение об ошибке сервера
				
				CloseSocketConnection(ClientSocket)
				' CloseHandle(hThread)
				IClientContext_Release(pIContext)
				HeapDestroy(hClientContextHeap)
				
			End If
			
		End If
		
		hClientContextHeap = HeapCreate( _
			HEAP_NO_SERIALIZE, _
			ThreadContextHeapInitialSize, _
			ThreadContextHeapMaximumSize _
		)
		dwCreateClientContextHeapErrorCode = GetLastError()
		
		pIContext = NULL
		hrCreateClientContext = E_FAIL
		If hClientContextHeap <> NULL Then
			hrCreateClientContext = CreateInstance( _
				hClientContextHeap, _
				@CLSID_CLIENTCONTEXT, _
				@IID_IClientContext, _
				@pIContext _
			)
		End If
		
		hThread = CreateSuspendedThread(@ThreadProc, pIContext, @dwThreadId)
		dwCreateThreadErrorCode = GetLastError()
		
	Loop While this->ReListenSocket
	
	If hThread <> NULL Then
		CloseHandle(hThread)
	End If
	
	If hClientContextHeap <> NULL Then
		HeapDestroy(hClientContextHeap)
	End If
	
	IWebSiteContainer_Release(pIWebSites)
	
	' IServerResponse_Release(pIResponseDefault)
	' INetworkStream_Release(pINetworkStreamDefault)
	
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
