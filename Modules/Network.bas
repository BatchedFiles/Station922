#include once "Network.bi"

Function ResolveHostW Alias "ResolveHostW"( _
		ByVal Host As PCWSTR, _
		ByVal Port As PCWSTR, _
		ByVal ppAddressList As ADDRINFOW Ptr Ptr _
	)As HRESULT
	
	Dim hints As ADDRINFOW
	With hints
		.ai_family = AF_UNSPEC ' AF_INET или AF_INET6
		.ai_socktype = SOCK_STREAM
		.ai_protocol = IPPROTO_TCP
	End With
	
	*ppAddressList = NULL
	
	If GetAddrInfoW(Host, Port, @hints, ppAddressList) = 0 Then
		
		Return S_OK
		
	End If
	
	Dim dwError As Long = WSAGetLastError()
	Return HRESULT_FROM_WIN32(dwError)
	
End Function

Function CreateSocketAndBindW Alias "CreateSocketAndBindW"( _
		ByVal LocalAddress As PCWSTR, _
		ByVal LocalPort As PCWSTR, _
		ByVal pSocketList As SocketNode Ptr, _
		ByVal Count As Integer, _
		ByVal pSockets As Integer Ptr _
	)As HRESULT
	
	Dim pAddressList As ADDRINFOW Ptr = NULL
	Dim hr As HRESULT = ResolveHostW(LocalAddress, LocalPort, @pAddressList)
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
		
		Dim ClientSocket As SOCKET = WSASocket( _
			pAddressNode->ai_family, _
			pAddressNode->ai_socktype, _
			pAddressNode->ai_protocol, _
			CPtr(WSAPROTOCOL_INFO Ptr, NULL), _
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
		If BindResult <> 0 Then
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
		
	Loop While pAddressNode <> NULL
	
	FreeAddrInfoW(pAddressList)
	
	If BindResult <> 0 Then
		
		*pSockets = 0
		Return HRESULT_FROM_WIN32(e)
		
	End If
	
	*pSockets = SocketCount
	Return S_OK
	
End Function

Function CloseSocketConnection( _
		ByVal ClientSocket As SOCKET _
	)As HRESULT
	
	shutdown(ClientSocket, SD_BOTH)
	closesocket(ClientSocket)
	
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
		If listen(pSocketList[i].ClientSocket, SOMAXCONN) <> 0 Then
			Dim dwError As Long = WSAGetLastError()
			
			closesocket(pSocketList[i].ClientSocket)
			
			Return HRESULT_FROM_WIN32(dwError)
			
		End If
		
	Next
	
	Return S_OK
	
End Function
