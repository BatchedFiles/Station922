#include once "windows.bi"
#include once "win\winsock2.bi"
#include once "win\mswsock.bi"

Common Shared lpfnAcceptEx As LPFN_ACCEPTEX
Common Shared lpfnGetAcceptExSockaddrs As LPFN_GETACCEPTEXSOCKADDRS

#ifdef WSAID_ACCEPTEX
#undef WSAID_ACCEPTEX
#define WSAID_ACCEPTEX &hb5367df1, &hcbac, &h11cf, {&h95, &hca, &h00, &h80, &h5f, &h48, &ha1, &h92}
#endif

#ifdef WSAID_GETACCEPTEXSOCKADDRS
#undef WSAID_GETACCEPTEXSOCKADDRS
#define WSAID_GETACCEPTEXSOCKADDRS &hb5367df2, &hcbac, &h11cf, {&h95, &hca, &h00, &h80, &h5f, &h48, &ha1, &h92}
#endif

Declare Function wMain()As Long

Function LoadWsaFunctions()As Long
	
	Dim ListenSocket As SOCKET = socket_( _
		AF_INET, _
		SOCK_STREAM, _
		IPPROTO_TCP _
	)
	If ListenSocket = INVALID_SOCKET Then
		Return 1
	End If
	
	Scope
		Dim dwBytes As DWORD = Any
		Dim GuidAcceptEx As GUID = Type(WSAID_ACCEPTEX)
		
		Dim resLoadAcceptEx As Long = WSAIoctl( _
			ListenSocket, _
			SIO_GET_EXTENSION_FUNCTION_POINTER, _
			@GuidAcceptEx, _
			SizeOf(GUID), _
			@lpfnAcceptEx, _
			SizeOf(lpfnAcceptEx), _
			@dwBytes, _
			NULL, _
			NULL _
		)
		If resLoadAcceptEx = SOCKET_ERROR Then
			closesocket(ListenSocket)
			return 1
		End If
	End Scope
	
	Scope
		Dim dwBytes As DWORD = Any
		Dim GuidGetAcceptExSockaddrs As GUID = Type(WSAID_GETACCEPTEXSOCKADDRS)
		
		Dim resGetAcceptExSockaddrs As Long = WSAIoctl( _
			ListenSocket, _
			SIO_GET_EXTENSION_FUNCTION_POINTER, _
			@GuidGetAcceptExSockaddrs, _
			SizeOf(GUID), _
			@lpfnGetAcceptExSockaddrs, _
			SizeOf(lpfnGetAcceptExSockaddrs), _
			@dwBytes, _
			NULL, _
			NULL _
		)
		If resGetAcceptExSockaddrs = SOCKET_ERROR Then
			closesocket(ListenSocket)
			return 1
		End If
	End Scope
	
	closesocket(ListenSocket)
	
	Return 0
	
End Function

#ifdef WITHOUT_RUNTIME
Function EntryPoint()As Integer
#else
Function main Alias "main"()As Long
#endif
	
	Scope
		Dim wsa As WSAData = Any
		Dim resWsaStartup As Long = WSAStartup(MAKEWORD(2, 2), @wsa)
		If resWsaStartup <> NO_ERROR Then
			Return 1
		End If
	End Scope
	
	Dim resLoadWsa As Long = LoadWsaFunctions()
	If resLoadWsa Then
		Return 1
	End If
	
	Dim RetCode As Long = wMain()
	
	WSACleanup()
	
	Return RetCode
	
#ifdef WITHOUT_RUNTIME
End Function
#else
End Function
#endif
