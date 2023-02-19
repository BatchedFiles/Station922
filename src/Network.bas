#include once "Network.bi"
#include once "win\mswsock.bi"

Function NetworkStartUp()As HRESULT
	
	Dim WsaVersion22 As WORD = MAKEWORD(2, 2)
	Dim wsa As WSADATA = Any
	
	Dim resWsaStartup As Long = WSAStartup(WsaVersion22, @wsa)
	If resWsaStartup <> NO_ERROR Then
		Dim dwError As Long = WSAGetLastError()
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Return S_OK
	
End Function

Function NetworkCleanUp()As HRESULT
	
	Dim resStartup As Long = WSACleanup()
	If resStartup <> 0 Then
		Dim dwError As Long = WSAGetLastError()
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Return S_OK
	
End Function

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

Function ResolveHostW Alias "ResolveHostW"( _
		ByVal Host As PCWSTR, _
		ByVal Port As PCWSTR, _
		ByVal ppAddressList As ADDRINFOW Ptr Ptr _
	)As HRESULT
	
	Dim hints As ADDRINFOW
	With hints
		.ai_family = AF_UNSPEC ' AF_INET, AF_INET6
		.ai_socktype = SOCK_STREAM
		.ai_protocol = IPPROTO_TCP
	End With
	
	*ppAddressList = NULL
	
	Dim resAddrInfo As INT_ = GetAddrInfoW( _
		Host, _
		Port, _
		@hints, _
		ppAddressList _
	)
	If resAddrInfo Then
		Return HRESULT_FROM_WIN32(resAddrInfo)
	End If
	
	Return S_OK
	
End Function

Function CreateSocketAndBindW Alias "CreateSocketAndBindW"( _
		ByVal LocalAddress As PCWSTR, _
		ByVal LocalPort As PCWSTR, _
		ByVal pSocketList As SocketNode Ptr, _
		ByVal Count As Integer, _
		ByVal pSockets As Integer Ptr _
	)As HRESULT
	
	Dim pAddressList As ADDRINFOW Ptr = NULL
	Dim hr As HRESULT = ResolveHostW( _
		LocalAddress, _
		LocalPort, _
		@pAddressList _
	)
	If FAILED(hr) Then
		*pSockets = 0
		Return hr
	End If
	
	Dim pAddressNode As ADDRINFOW Ptr = pAddressList
	Dim BindResult As Long = 0
	Dim SocketCount As Integer = 0
	
	Dim e As Long = 0
	Do
		If SocketCount > Count Then
			e = ERROR_INSUFFICIENT_BUFFER
			Exit Do
		End If
		
		Dim ClientSocket As SOCKET = WSASocketW( _
			pAddressNode->ai_family, _
			pAddressNode->ai_socktype, _
			pAddressNode->ai_protocol, _
			CPtr(WSAPROTOCOL_INFOW Ptr, NULL), _
			0, _
			WSA_FLAG_OVERLAPPED _
		)
		If ClientSocket = INVALID_SOCKET Then
			e = WSAGetLastError()
			pAddressNode = pAddressNode->ai_next
			Continue Do
		End If
		
		BindResult = bind( _
			ClientSocket, _
			Cast(LPSOCKADDR, pAddressNode->ai_addr), _
			pAddressNode->ai_addrlen _
		)
		If BindResult Then
			e = WSAGetLastError()
			closesocket(ClientSocket)
			pAddressNode = pAddressNode->ai_next
			Continue Do
		End If
		
		pSocketList[SocketCount].ClientSocket = ClientSocket
		pSocketList[SocketCount].AddressFamily = pAddressNode->ai_family
		pSocketList[SocketCount].SocketType = pAddressNode->ai_socktype
		pSocketList[SocketCount].Protocol = pAddressNode->ai_protocol
		
		SocketCount += 1
		pAddressNode = pAddressNode->ai_next
		
	Loop While pAddressNode
	
	FreeAddrInfoW(pAddressList)
	
	If BindResult Then
		
		*pSockets = 0
		Return HRESULT_FROM_WIN32(e)
		
	End If
	
	*pSockets = SocketCount
	
	Return S_OK
	
End Function

Function CreateSocketAndListenW Alias "CreateSocketAndListenW"( _
		ByVal LocalAddress As PCWSTR, _
		ByVal LocalPort As PCWSTR, _
		ByVal pSocketList As SocketNode Ptr, _
		ByVal Count As Integer, _
		ByVal pSockets As Integer Ptr _
	)As HRESULT
	
	Dim hr As HRESULT = CreateSocketAndBindW( _
		LocalAddress, _
		LocalPort, _
		pSocketList, _
		Count, _
		pSockets _
	)
	If FAILED(hr) Then
		*pSockets = 0
		Return hr
	End If
	
	For i As Integer = 0 To *pSockets - 1
		
		Dim resListen As Long = listen(pSocketList[i].ClientSocket, SOMAXCONN)
		If resListen Then
			Dim dwError As Long = WSAGetLastError()
			closesocket(pSocketList[i].ClientSocket)
			Return HRESULT_FROM_WIN32(dwError)
		End If
		
	Next
	
	Return S_OK
	
End Function

Dim lpfnAcceptEx As LPFN_ACCEPTEX
Dim lpfnGetAcceptExSockaddrs As LPFN_GETACCEPTEXSOCKADDRS
Dim lpfnTransmitPackets As LPFN_TRANSMITPACKETS
