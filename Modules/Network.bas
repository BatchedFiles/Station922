#include once "Network.bi"

Function SocketListCreateNode( _
		ByVal ClientSocket As SOCKET, _
		ByVal AddressFamily As Long, _
		ByVal SocketType As Long, _
		ByVal Protocol As Long _
	)As SocketNode Ptr
	
	Dim pNode As SocketNode Ptr = Allocate(SizeOf(SocketNode))
	If pNode = NULL Then
		Return NULL
	End If
	
	pNode->ClientSocket = ClientSocket
	pNode->AddressFamily = AddressFamily
	pNode->SocketType = SocketType
	pNode->Protocol = Protocol
	pNode->pNext = NULL
	
	Return pNode
	
End Function

Sub SocketListAddNode( _
		ByVal pList As SocketNode Ptr, _
		ByVal ClientSocket As SOCKET, _
		ByVal AddressFamily As Long, _
		ByVal SocketType As Long, _
		ByVal Protocol As Long _
	)
	
	If pList->pNext <> NULL Then
		SocketListAddNode( _
			pList->pNext, _
			ClientSocket, _
			AddressFamily, _
			SocketType, _
			Protocol _
		)
	Else
		Dim pNode As SocketNode Ptr = SocketListCreateNode( _
			ClientSocket, _
			AddressFamily, _
			SocketType, _
			Protocol _
		)
		pList->pNext = pNode
	End If
	
End Sub

' Function ResolveHostA Alias "ResolveHostA"( _
		' ByVal Host As PCSTR, _
		' ByVal Port As PCSTR, _
		' ByVal ppAddressList As addrinfo Ptr Ptr _
	' )As HRESULT
	
	' Dim hints As addrinfo
	' With hints
		' .ai_family = AF_UNSPEC ' AF_INET или AF_INET6
		' .ai_socktype = SOCK_STREAM
		' .ai_protocol = IPPROTO_TCP
	' End With
	
	' *ppAddressList = NULL
	
	' If getaddrinfoA(Host, Port, @hints, ppAddressList) = 0 Then
		
		' Return S_OK
		
	' End If
	
	' Dim dwError As Long = WSAGetLastError()
	' Return HRESULT_FROM_WIN32(dwError)
	
' End Function

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

' Function CreateSocketAndBindA Alias "CreateSocketAndBindA"( _
		' ByVal LocalAddress As PCSTR, _
		' ByVal LocalPort As PCSTR, _
		' ByVal pSocket As SOCKET Ptr _
	' )As HRESULT
	
	' Dim ClientSocket As SOCKET = WSASocket( _
		' AF_INET6, _
		' SOCK_STREAM, _
		' IPPROTO_TCP, _
		' CPtr(WSAPROTOCOL_INFO Ptr, NULL), _
		' 0, _
		' WSA_FLAG_OVERLAPPED _
	' )
	
	' If ClientSocket = INVALID_SOCKET Then
		
		' Return HRESULT_FROM_WIN32(WSAGetLastError())
		
	' End If
	
	' Dim pAddressList As addrinfo Ptr = NULL
	' Dim hr As HRESULT = ResolveHostA(LocalAddress, LocalPort, @pAddressList)
	
	' If FAILED(hr) Then
		
		' Return HRESULT_FROM_WIN32(WSAGetLastError())
		
	' End If
	
	' Dim pAddress As addrinfo Ptr = pAddressList
	' Dim BindResult As Integer = Any
	
	' Dim e As Long = 0
	' Do
		' BindResult = bind(ClientSocket, Cast(LPSOCKADDR, pAddress->ai_addr), pAddress->ai_addrlen)
		' e = WSAGetLastError()
		
		' If BindResult = 0 Then
			' Exit Do
		' End If
		
		' pAddress = pAddress->ai_next
		
	' Loop Until pAddress = 0
	
	' FreeAddrInfoA(pAddressList)
	
	' If BindResult <> 0 Then
		
		' Return HRESULT_FROM_WIN32(e)
		
	' End If
	
	' *pSocket = ClientSocket
	' Return S_OK
	
' End Function

Function CreateSocketAndBindW Alias "CreateSocketAndBindW"( _
		ByVal LocalAddress As PCWSTR, _
		ByVal LocalPort As PCWSTR, _
		ByVal ppSocketList As SocketNode Ptr Ptr _
	)As HRESULT
	
	Dim pAddressList As ADDRINFOW Ptr = NULL
	Dim hr As HRESULT = ResolveHostW(LocalAddress, LocalPort, @pAddressList)
	If FAILED(hr) Then
		*ppSocketList = NULL
		Return hr
	End If
	
	Dim pAddressNode As ADDRINFOW Ptr = pAddressList
	Dim BindResult As Long = 0
	
	Dim pSocketList As SocketNode Ptr = NULL
	
	Dim e As Long = 0
	Do
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
		
		If pSocketList = NULL Then
			pSocketList = SocketListCreateNode( _
				ClientSocket, _
				pAddressNode->ai_family, _
				pAddressNode->ai_socktype, _
				pAddressNode->ai_protocol _
			)
		Else
			SocketListAddNode( _
				pSocketList, _
				ClientSocket, _
				pAddressNode->ai_family, _
				pAddressNode->ai_socktype, _
				pAddressNode->ai_protocol _
			)
		End If
		
		pAddressNode = pAddressNode->ai_next
		
	Loop While pAddressNode <> NULL
	
	FreeAddrInfoW(pAddressList)
	
	If BindResult <> 0 Then
		
		*ppSocketList = NULL
		Return HRESULT_FROM_WIN32(e)
		
	End If
	
	*ppSocketList = pSocketList
	Return S_OK
	
End Function

Function CloseSocketConnection( _
		ByVal ClientSocket As SOCKET _
	)As HRESULT
	
	Dim res As Integer = shutdown(ClientSocket, SD_BOTH)
	
	If res <> 0 Then
		
		Dim e As ULONG = WSAGetLastError()
		Dim hr As HRESULT = HRESULT_FROM_WIN32(e)
		
		Return hr
		
	End If
	
	res = closesocket(ClientSocket)
	
	If res <> 0 Then
		
		Dim e As ULONG = WSAGetLastError()
		Dim hr As HRESULT = HRESULT_FROM_WIN32(e)
		
		Return hr
		
	End If
	
	Return S_OK
	
End Function

Function SetReceiveTimeout( _
		ByVal ClientSocket As SOCKET, _
		ByVal dwMilliseconds As DWORD _
	)As HRESULT
	
	Dim res As Integer = setsockopt( _
		ClientSocket, _
		SOL_SOCKET, _
		SO_RCVTIMEO, _
		CPtr(ZString Ptr, @dwMilliseconds), _
		SizeOf(DWORD) _
	)
	
	If res <> 0 Then
		
		Dim e As Integer = WSAGetLastError()
		Dim hr As HRESULT = HRESULT_FROM_WIN32(e)
		
		Return hr
		
	End If
	
	Return S_OK
	
End Function

' Function ConnectToServerA Alias "ConnectToServerA"( _
		' ByVal LocalAddress As PCSTR, _
		' ByVal LocalPort As PCSTR, _
		' ByVal RemoteAddress As PCSTR, _
		' ByVal RemotePort As PCSTR, _
		' ByVal pSocket As SOCKET Ptr _
	' )As HRESULT
	
	' Dim ClientSocket As SOCKET = Any
	' Dim hr As HRESULT = CreateSocketAndBindA(LocalAddress, LocalPort, @ClientSocket)
	
	' If FAILED(hr) Then
		
		' Return hr
		
	' End If
	
	' Dim pAddressList As addrinfo Ptr = NULL
	' hr = ResolveHostA(RemoteAddress, RemotePort, @pAddressList)
	
	' If FAILED(hr) Then
		
		' closesocket(ClientSocket)
		' Return HRESULT_FROM_WIN32(WSAGetLastError())
		
	' End If
	
	' Dim pAddress As addrinfo Ptr = pAddressList
	' Dim ConnectResult As Integer = Any
	
	' Dim e As Long = 0
	' Do
		' ConnectResult = connect(ClientSocket, Cast(LPSOCKADDR, pAddress->ai_addr), pAddress->ai_addrlen)
		' e = WSAGetLastError()
		
		' If ConnectResult = 0 Then
			' Exit Do
		' End If
		
		' pAddress = pAddress->ai_next
		
	' Loop Until pAddress = 0
	
	' FreeAddrInfoA(pAddressList)
	
	' If ConnectResult <> 0 Then
		
		' closesocket(ClientSocket)
		' Return HRESULT_FROM_WIN32(e)
		
	' End If
	
	' *pSocket = ClientSocket
	' Return S_OK
	
' End Function

' Function ConnectToServerW Alias "ConnectToServerW"( _
		' ByVal LocalAddress As PCWSTR, _
		' ByVal LocalPort As PCWSTR, _
		' ByVal RemoteAddress As PCWSTR, _
		' ByVal RemotePort As PCWSTR, _
		' ByVal pSocket As SOCKET Ptr _
	' )As HRESULT
	
	' Dim ClientSocket As SOCKET = Any
	' Dim hr As HRESULT = CreateSocketAndBindW(LocalAddress, LocalPort, @ClientSocket)
	
	' If FAILED(hr) Then
		
		' Return hr
		
	' End If
	
	' Dim pAddressList As addrinfoW Ptr = NULL
	' hr = ResolveHostW(RemoteAddress, RemotePort, @pAddressList)
	
	' If FAILED(hr) Then
		
		' closesocket(ClientSocket)
		' Return HRESULT_FROM_WIN32(WSAGetLastError())
		
	' End If
	
	' Dim pAddress As addrinfoW Ptr = pAddressList
	' Dim ConnectResult As Integer = Any
	
	' Dim e As Long = 0
	' Do
		' ConnectResult = connect(ClientSocket, Cast(LPSOCKADDR, pAddress->ai_addr), pAddress->ai_addrlen)
		' e = WSAGetLastError()
		
		' If ConnectResult = 0 Then
			' Exit Do
		' End If
		
		' pAddress = pAddress->ai_next
		
	' Loop Until pAddress = 0
	
	' FreeAddrInfoW(pAddressList)
	
	' If ConnectResult <> 0 Then
		
		' closesocket(ClientSocket)
		' Return HRESULT_FROM_WIN32(e)
		
	' End If
	
	' *pSocket = ClientSocket
	' Return S_OK
	
' End Function

' Function CreateSocketAndListenA Alias "CreateSocketAndListenA"( _
		' ByVal LocalAddress As PCSTR, _
		' ByVal LocalPort As PCSTR, _
		' ByVal pSocket As SOCKET Ptr _
	' )As HRESULT
	
	' Dim ServerSocket As SOCKET = Any
	' Dim hr As HRESULT = CreateSocketAndBindA(LocalAddress, LocalPort, @ServerSocket)
	
	' If FAILED(hr) Then
		
		' Return hr
		
	' End If
	
	' If listen(ServerSocket, SOMAXCONN) <> 0 Then
		
		' closesocket(ServerSocket)
		
		' Dim dwError As Long = WSAGetLastError()
		' Return HRESULT_FROM_WIN32(dwError)
		
	' End If
	
	' *pSocket = ServerSocket
	' Return S_OK
	
' End Function

Function CreateSocketAndListenW Alias "CreateSocketAndListenW"( _
		ByVal LocalAddress As PCWSTR, _
		ByVal LocalPort As PCWSTR, _
		ByVal ppSocketList As SocketNode Ptr Ptr _
	)As HRESULT
	
	Dim pSocketList As SocketNode Ptr = Any
	Dim hr As HRESULT = CreateSocketAndBindW(LocalAddress, LocalPort, @pSocketList)
	If FAILED(hr) Then
		ppSocketList = NULL
		Return hr
	End If
	
	Dim pNode As SocketNode Ptr = pSocketList
	Do
		If listen(pNode->ClientSocket, SOMAXCONN) <> 0 Then
			
			closesocket(pNode->ClientSocket)
			
			Dim dwError As Long = WSAGetLastError()
			Return HRESULT_FROM_WIN32(dwError)
			
		End If
		
		pNode = pNode->pNext
	Loop While pNode <> NULL
	
	*ppSocketList = pSocketList
	Return S_OK
	
End Function
