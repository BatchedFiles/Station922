#include once "TcpAsyncListener.bi"
#include once "win\mswsock.bi"
#include once "AsyncResult.bi"
#include once "Network.bi"

Extern GlobalTcpListenerVirtualTable As Const ITcpListenerVirtualTable

Const SOCKET_ADDRESS_STORAGE_LENGTH As Integer = 128

Type TcpListener
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const ITcpListenerVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	ListenSocket As SOCKET
	ClientSocket As SOCKET
	Padding1 As Integer
	Padding2 As Integer
	ProtInfo As WSAPROTOCOL_INFOW
	LocalAddress As ZString * SOCKET_ADDRESS_STORAGE_LENGTH
	RemoteAddress As ZString * SOCKET_ADDRESS_STORAGE_LENGTH
	ProtLength As Long
End Type

Private Sub InitializeTcpListener( _
		ByVal self As TcpListener Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@self->RttiClassName(0), _
			@Str(RTTI_ID_TCPLISTENER), _
			UBound(self->RttiClassName) - LBound(self->RttiClassName) + 1 _
		)
	#endif
	self->lpVtbl = @GlobalTcpListenerVirtualTable
	self->ReferenceCounter = CUInt(-1)
	IMalloc_AddRef(pIMemoryAllocator)
	self->pIMemoryAllocator = pIMemoryAllocator
	self->ListenSocket = INVALID_SOCKET

End Sub

Private Sub UnInitializeTcpListener( _
		ByVal self As TcpListener Ptr _
	)

End Sub

Private Sub TcpListenerCreated( _
		ByVal self As TcpListener Ptr _
	)

End Sub

Private Sub TcpListenerDestroyed( _
		ByVal self As TcpListener Ptr _
	)

End Sub

Private Sub DestroyTcpListener( _
		ByVal self As TcpListener Ptr _
	)

	Dim pIMemoryAllocator As IMalloc Ptr = self->pIMemoryAllocator

	UnInitializeTcpListener(self)

	IMalloc_Free(pIMemoryAllocator, self)

	TcpListenerDestroyed(self)

	IMalloc_Release(pIMemoryAllocator)

End Sub

Private Function TcpListenerAddRef( _
		ByVal self As TcpListener Ptr _
	)As ULONG

	Return 1

End Function

Private Function TcpListenerRelease( _
		ByVal self As TcpListener Ptr _
	)As ULONG

	Return 0

End Function

Private Function TcpListenerQueryInterface( _
		ByVal self As TcpListener Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_ITcpListener, riid) Then
		*ppv = @self->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @self->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If

	TcpListenerAddRef(self)

	Return S_OK

End Function

Public Function CreateTcpListener( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	Dim self As TcpListener Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(TcpListener) _
	)

	If self Then
		InitializeTcpListener(self, pIMemoryAllocator)
		TcpListenerCreated(self)

		Dim hrQueryInterface As HRESULT = TcpListenerQueryInterface( _
			self, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyTcpListener(self)
		End If

		Return hrQueryInterface
	End If

	*ppv = NULL
	Return E_OUTOFMEMORY

End Function

Private Function TcpListenerBeginAccept( _
		ByVal self As TcpListener Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	self->ClientSocket = WSASocketW( _
		0, _ /' AF_INET6 '/
		0, _ /' SOCK_STREAM '/
		0, _ /' IPPROTO_TCP '/
		@self->ProtInfo, _
		0, _
		WSA_FLAG_OVERLAPPED _
	)
	If self->ClientSocket = INVALID_SOCKET Then
		Dim dwError As Long = WSAGetLastError()
		*ppIAsyncResult = NULL
		Return HRESULT_FROM_WIN32(dwError)
	End If

	Dim pINewAsyncResult As IAsyncResult Ptr = Any
	Dim hrCreateAsyncResult As HRESULT = CreateAsyncResult( _
		self->pIMemoryAllocator, _
		@IID_IAsyncResult, _
		@pINewAsyncResult _
	)
	If FAILED(hrCreateAsyncResult) Then
		closesocket(self->ClientSocket)
		*ppIAsyncResult = NULL
		Return hrCreateAsyncResult
	End If

	Dim pOverlap As OVERLAPPED Ptr = Any
	IAsyncResult_GetWsaOverlapped(pINewAsyncResult, @pOverlap)

	IAsyncResult_SetAsyncStateWeakPtr(pINewAsyncResult, pcb, StateObject)

	Const dwReceiveDataLength = 0
	Const lpdwBytesReceived = NULL
	Dim resAccept As BOOL = lpfnAcceptEx( _
		self->ListenSocket, _
		self->ClientSocket, _
		@self->LocalAddress, _
		dwReceiveDataLength, _
		SOCKET_ADDRESS_STORAGE_LENGTH, _
		SOCKET_ADDRESS_STORAGE_LENGTH, _
		lpdwBytesReceived, _
		pOverlap _
	)
	If resAccept = 0 Then
		Dim dwError As Long = WSAGetLastError()
		If dwError <> WSA_IO_PENDING OrElse dwError <> ERROR_IO_PENDING Then
			closesocket(self->ClientSocket)
			IAsyncResult_Release(pINewAsyncResult)
			*ppIAsyncResult = NULL
			Return HRESULT_FROM_WIN32(dwError)
		End If

	End If

	*ppIAsyncResult = pINewAsyncResult

	Return TCPLISTENER_S_IO_PENDING

End Function

Private Function TcpListenerEndAccept( _
		ByVal self As TcpListener Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pClientSocket As SOCKET Ptr _
	)As HRESULT

	Dim pLocalSockaddr As SOCKADDR Ptr = Any
	Dim LocalSockaddrLength As INT_ = Any
	Dim pRemoteSockaddr As SOCKADDR Ptr = Any
	Dim RemoteSockaddrLength As INT_ = Any

	lpfnGetAcceptExSockaddrs( _
		@self->LocalAddress, _
		0, _
		SOCKET_ADDRESS_STORAGE_LENGTH, _
		SOCKET_ADDRESS_STORAGE_LENGTH, _
		@pLocalSockaddr, _
		@LocalSockaddrLength, _
		@pRemoteSockaddr, _
		@RemoteSockaddrLength _
	)

	Dim optval As Zstring Ptr = CPtr(Zstring Ptr, @self->ListenSocket)
	Dim resSetOptions As Long = setsockopt( _
		self->ClientSocket, _
		SOL_SOCKET, _
		SO_UPDATE_ACCEPT_CONTEXT, _
		optval, _
		SizeOf(SOCKET) _
	)
	If resSetOptions = SOCKET_ERROR Then
		Dim dwError As Long = WSAGetLastError()
		closesocket(self->ClientSocket)
		*pClientSocket = INVALID_SOCKET
		Return HRESULT_FROM_WIN32(dwError)
	End If

	*pClientSocket = self->ClientSocket

	Return S_OK

End Function

Private Function TcpListenerGetListenSocket( _
		ByVal self As TcpListener Ptr, _
		ByVal pListenSocket As SOCKET Ptr _
	)As HRESULT

	*pListenSocket = self->ListenSocket

	Return S_OK

End Function

Private Function TcpListenerSetListenSocket( _
		ByVal self As TcpListener Ptr, _
		ByVal ListenSocket As SOCKET _
	)As HRESULT

	self->ProtLength = SizeOf(WSAPROTOCOL_INFOW)
	Dim resOptions As Long = getsockopt( _
		ListenSocket, _
		SOL_SOCKET, _
		SO_PROTOCOL_INFO, _
		CPtr(ZString Ptr, @self->ProtInfo), _
		@self->ProtLength _
	)
	If resOptions = SOCKET_ERROR Then
		Dim dwError As Long = WSAGetLastError()
		Return HRESULT_FROM_WIN32(dwError)
	End If

	self->ListenSocket = ListenSocket

	Return S_OK

End Function


Private Function ITcpListenerQueryInterface( _
		ByVal self As ITcpListener Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return TcpListenerQueryInterface(CONTAINING_RECORD(self, TcpListener, lpVtbl), riid, ppv)
End Function

Private Function ITcpListenerAddRef( _
		ByVal self As ITcpListener Ptr _
	)As ULONG
	Return TcpListenerAddRef(CONTAINING_RECORD(self, TcpListener, lpVtbl))
End Function

Private Function ITcpListenerRelease( _
		ByVal self As ITcpListener Ptr _
	)As ULONG
	Return TcpListenerRelease(CONTAINING_RECORD(self, TcpListener, lpVtbl))
End Function

Private Function ITcpListenerBeginAccept( _
		ByVal self As ITcpListener Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As ULONG
	Return TcpListenerBeginAccept(CONTAINING_RECORD(self, TcpListener, lpVtbl), pcb, StateObject, ppIAsyncResult)
End Function

Private Function ITcpListenerEndAccept( _
		ByVal self As ITcpListener Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pClientSocket As SOCKET Ptr _
	)As ULONG
	Return TcpListenerEndAccept(CONTAINING_RECORD(self, TcpListener, lpVtbl), pIAsyncResult, pClientSocket)
End Function

Private Function ITcpListenerGetListenSocket( _
		ByVal self As ITcpListener Ptr, _
		ByVal pListenSocket As SOCKET Ptr _
	)As ULONG
	Return TcpListenerGetListenSocket(CONTAINING_RECORD(self, TcpListener, lpVtbl), pListenSocket)
End Function

Private Function ITcpListenerSetListenSocket( _
		ByVal self As ITcpListener Ptr, _
		ByVal ListenSocket As SOCKET _
	)As ULONG
	Return TcpListenerSetListenSocket(CONTAINING_RECORD(self, TcpListener, lpVtbl), ListenSocket)
End Function

Dim GlobalTcpListenerVirtualTable As Const ITcpListenerVirtualTable = Type( _
	@ITcpListenerQueryInterface, _
	@ITcpListenerAddRef, _
	@ITcpListenerRelease, _
	@ITcpListenerBeginAccept, _
	@ITcpListenerEndAccept, _
	@ITcpListenerGetListenSocket, _
	@ITcpListenerSetListenSocket _
)
