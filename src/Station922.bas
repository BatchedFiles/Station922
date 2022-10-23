#include once "windows.bi"
#include once "win\shellapi.bi"
#include once "win\winsock2.bi"
#include once "win\mswsock.bi"
#include once "ConsoleMain.bi"
#include once "WindowsServiceMain.bi"

#ifdef WITHOUT_RUNTIME
#define ExitProgram(RetCode) Return RetCode
#else
#define ExitProgram(RetCode) End(RetCode)
#endif

Extern GUID_WSAID_ACCEPTEX Alias "GUID_WSAID_ACCEPTEX" As GUID
Extern GUID_WSAID_GETACCEPTEXSOCKADDRS Alias "GUID_WSAID_GETACCEPTEXSOCKADDRS" As GUID
Extern GUID_WSAID_TRANSMITPACKETS Alias "GUID_WSAID_TRANSMITPACKETS" As GUID

Const ServiceParam = WStr("/service")
Const CompareResultEqual As Long = 0

Common Shared lpfnAcceptEx As LPFN_ACCEPTEX
Common Shared lpfnGetAcceptExSockaddrs As LPFN_GETACCEPTEXSOCKADDRS
Common Shared lpfnTransmitPackets As LPFN_TRANSMITPACKETS

Function LoadWsaFunctions()As Boolean
	
	Dim ListenSocket As SOCKET = WSASocketW( _
		AF_INET6, _
		SOCK_STREAM, _
		IPPROTO_TCP, _
		NULL, _
		0, _
		WSA_FLAG_OVERLAPPED _
	)
	If ListenSocket = INVALID_SOCKET Then
		Return False
	End If
	
	Scope
		Dim dwBytes As DWORD = Any
		Dim resLoadAcceptEx As Long = WSAIoctl( _
			ListenSocket, _
			SIO_GET_EXTENSION_FUNCTION_POINTER, _
			@GUID_WSAID_ACCEPTEX, _
			SizeOf(GUID), _
			@lpfnAcceptEx, _
			SizeOf(lpfnAcceptEx), _
			@dwBytes, _
			NULL, _
			NULL _
		)
		If resLoadAcceptEx = SOCKET_ERROR Then
			closesocket(ListenSocket)
			return False
		End If
	End Scope
	
	Scope
		Dim dwBytes As DWORD = Any
		Dim resGetAcceptExSockaddrs As Long = WSAIoctl( _
			ListenSocket, _
			SIO_GET_EXTENSION_FUNCTION_POINTER, _
			@GUID_WSAID_GETACCEPTEXSOCKADDRS, _
			SizeOf(GUID), _
			@lpfnGetAcceptExSockaddrs, _
			SizeOf(lpfnGetAcceptExSockaddrs), _
			@dwBytes, _
			NULL, _
			NULL _
		)
		If resGetAcceptExSockaddrs = SOCKET_ERROR Then
			closesocket(ListenSocket)
			return False
		End If
	End Scope
	
	Scope
		Dim dwBytes As DWORD = Any
		Dim resGetTransmitPackets As Long = WSAIoctl( _
			ListenSocket, _
			SIO_GET_EXTENSION_FUNCTION_POINTER, _
			@GUID_WSAID_TRANSMITPACKETS, _
			SizeOf(GUID), _
			@lpfnTransmitPackets, _
			SizeOf(lpfnTransmitPackets), _
			@dwBytes, _
			NULL, _
			NULL _
		)
		If resGetTransmitPackets = SOCKET_ERROR Then
			closesocket(ListenSocket)
			return False
		End If
	End Scope
	
	closesocket(ListenSocket)
	
	Return True
	
End Function

#ifdef WITHOUT_RUNTIME
Function EntryPoint()As Integer
#endif
	
	Scope
		Dim wsa As WSAData = Any
		Dim resWsaStartup As Long = WSAStartup(MAKEWORD(2, 2), @wsa)
		If resWsaStartup <> NO_ERROR Then
			ExitProgram(1)
		End If
	End Scope
	
	Scope
		Dim resLoadWsa As Boolean = LoadWsaFunctions()
		If resLoadWsa = False Then
			WSACleanup()
			ExitProgram(1)
		End If
	End Scope
	
	Dim RetCode As Long = Any
	Scope
		Dim pLine As LPWSTR = GetCommandLineW()
		Dim Args As Long = Any
		Dim ppLines As LPWSTR Ptr = CommandLineToArgvW( _
			pLine, _
			@Args _
		)
		
		If Args > 1 Then
			Dim CompareResult As Long = lstrcmpiW(ppLines[1], ServiceParam)
			If CompareResult = CompareResultEqual Then
				RetCode = WindowsServiceMain()
			Else
				RetCode = ConsoleMain()
			End If
		Else
			RetCode = ConsoleMain()
		End If
		
		LocalFree(ppLines)
	End Scope
	
	WSACleanup()
	
	ExitProgram(RetCode)
	
#ifdef WITHOUT_RUNTIME
End Function
#endif
