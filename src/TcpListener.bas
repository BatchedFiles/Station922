#include once "TcpListener.bi"
#include once "win\mswsock.bi"
#include once "AsyncResult.bi"
#include once "ContainerOf.bi"
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
		ByVal this As TcpListener Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->RttiClassName(0), _
			@Str(RTTI_ID_TCPLISTENER), _
			UBound(this->RttiClassName) - LBound(this->RttiClassName) + 1 _
		)
	#endif
	this->lpVtbl = @GlobalTcpListenerVirtualTable
	this->ReferenceCounter = CUInt(-1)
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->ListenSocket = INVALID_SOCKET
	
End Sub

Private Sub UnInitializeTcpListener( _
		ByVal this As TcpListener Ptr _
	)
	
End Sub

Private Sub TcpListenerCreated( _
		ByVal this As TcpListener Ptr _
	)
	
End Sub

Private Sub TcpListenerDestroyed( _
		ByVal this As TcpListener Ptr _
	)
	
End Sub

Private Sub DestroyTcpListener( _
		ByVal this As TcpListener Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeTcpListener(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	TcpListenerDestroyed(this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Private Function TcpListenerAddRef( _
		ByVal this As TcpListener Ptr _
	)As ULONG
	
	Return 1
	
End Function

Private Function TcpListenerRelease( _
		ByVal this As TcpListener Ptr _
	)As ULONG
	
	Return 0
	
End Function

Private Function TcpListenerQueryInterface( _
		ByVal this As TcpListener Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_ITcpListener, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	TcpListenerAddRef(this)
	
	Return S_OK
	
End Function

Public Function CreateTcpListener( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Dim this As TcpListener Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(TcpListener) _
	)
	
	If this Then
		InitializeTcpListener(this, pIMemoryAllocator)
		TcpListenerCreated(this)
		
		Dim hrQueryInterface As HRESULT = TcpListenerQueryInterface( _
			this, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyTcpListener(this)
		End If
		
		Return hrQueryInterface
	End If
	
	*ppv = NULL
	Return E_OUTOFMEMORY
	
End Function

Private Function TcpListenerBeginAccept( _
		ByVal this As TcpListener Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	this->ClientSocket = WSASocketW( _
		0, _ /' AF_INET6 '/
		0, _ /' SOCK_STREAM '/
		0, _ /' IPPROTO_TCP '/
		@this->ProtInfo, _
		0, _
		WSA_FLAG_OVERLAPPED _
	)
	If this->ClientSocket = INVALID_SOCKET Then
		Dim dwError As Long = WSAGetLastError()
		*ppIAsyncResult = NULL
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Dim pINewAsyncResult As IAsyncResult Ptr = Any
	Dim hrCreateAsyncResult As HRESULT = CreateAsyncResult( _
		this->pIMemoryAllocator, _
		@IID_IAsyncResult, _
		@pINewAsyncResult _
	)
	If FAILED(hrCreateAsyncResult) Then
		closesocket(this->ClientSocket)
		*ppIAsyncResult = NULL
		Return hrCreateAsyncResult
	End If
	
	Dim pOverlap As OVERLAPPED Ptr = Any
	IAsyncResult_GetWsaOverlapped(pINewAsyncResult, @pOverlap)
	
	IAsyncResult_SetAsyncStateWeakPtr(pINewAsyncResult, StateObject)
	
	Const dwReceiveDataLength = 0
	Const lpdwBytesReceived = NULL
	Dim resAccept As BOOL = lpfnAcceptEx( _
		this->ListenSocket, _
		this->ClientSocket, _
		@this->LocalAddress, _
		dwReceiveDataLength, _
		SOCKET_ADDRESS_STORAGE_LENGTH, _
		SOCKET_ADDRESS_STORAGE_LENGTH, _
		lpdwBytesReceived, _
		pOverlap _
	)
	If resAccept = 0 Then
		Dim dwError As Long = WSAGetLastError()
		If dwError <> WSA_IO_PENDING OrElse dwError <> ERROR_IO_PENDING Then
			closesocket(this->ClientSocket)
			IAsyncResult_Release(pINewAsyncResult)
			*ppIAsyncResult = NULL
			Return HRESULT_FROM_WIN32(dwError)
		End If
		
	End If
	
	*ppIAsyncResult = pINewAsyncResult
	
	Return TCPLISTENER_S_IO_PENDING
	
End Function

Private Function TcpListenerEndAccept( _
		ByVal this As TcpListener Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal ReadedBytes As DWORD, _
		ByVal pClientSocket As SOCKET Ptr _
	)As HRESULT
	
	/'
	Dim pLocalSockaddr As sockaddr Ptr = Any
	Dim LocalSockaddrLength As INT_ = Any
	Dim pRemoteSockaddr As sockaddr Ptr = Any
	Dim RemoteSockaddrLength As INT_ = Any
	
	lpfnGetAcceptExSockaddrs( _
		@this->Buffer->LocalAddress, _
		0, _
		SOCKET_ADDRESS_STORAGE_LENGTH, _
		SOCKET_ADDRESS_STORAGE_LENGTH, _
		@pLocalSockaddr, _
		@LocalSockaddrLength, _
		@pRemoteSockaddr, _
		@RemoteSockaddrLength _
	)
	
	Dim resSetOptions As Long = setsockopt( _
		this->ClientSocket, _
		SOL_SOCKET, _
		SO_UPDATE_ACCEPT_CONTEXT, _
		CPtr(Zstring Ptr, @this->ListenSocket), _
		SizeOf(SOCKET) _
	)
	If resSetOptions = SOCKET_ERROR Then
		Dim dwError As Long = WSAGetLastError()
		*pClientSocket = INVALID_SOCKET
		Return HRESULT_FROM_WIN32(dwError)
	End If
	'/
	
	*pClientSocket = this->ClientSocket
	
	Return S_OK
	
End Function

Private Function TcpListenerGetListenSocket( _
		ByVal this As TcpListener Ptr, _
		ByVal pListenSocket As SOCKET Ptr _
	)As HRESULT
	
	*pListenSocket = this->ListenSocket
	
	Return S_OK
	
End Function

Private Function TcpListenerSetListenSocket( _
		ByVal this As TcpListener Ptr, _
		ByVal ListenSocket As SOCKET _
	)As HRESULT
	
	this->ProtLength = SizeOf(WSAPROTOCOL_INFOW)
	Dim resOptions As Long = getsockopt( _
		ListenSocket, _
		SOL_SOCKET, _
		SO_PROTOCOL_INFO, _
		CPtr(ZString Ptr, @this->ProtInfo), _
		@this->ProtLength _
	)
	If resOptions = SOCKET_ERROR Then
		Dim dwError As Long = WSAGetLastError()
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	this->ListenSocket = ListenSocket
	
	Return S_OK
	
End Function


Private Function ITcpListenerQueryInterface( _
		ByVal this As ITcpListener Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return TcpListenerQueryInterface(ContainerOf(this, TcpListener, lpVtbl), riid, ppv)
End Function

Private Function ITcpListenerAddRef( _
		ByVal this As ITcpListener Ptr _
	)As ULONG
	Return TcpListenerAddRef(ContainerOf(this, TcpListener, lpVtbl))
End Function

Private Function ITcpListenerRelease( _
		ByVal this As ITcpListener Ptr _
	)As ULONG
	Return TcpListenerRelease(ContainerOf(this, TcpListener, lpVtbl))
End Function

Private Function ITcpListenerBeginAccept( _
		ByVal this As ITcpListener Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As ULONG
	Return TcpListenerBeginAccept(ContainerOf(this, TcpListener, lpVtbl), StateObject, ppIAsyncResult)
End Function

Private Function ITcpListenerEndAccept( _
		ByVal this As ITcpListener Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal ReadedBytes As DWORD, _
		ByVal pClientSocket As SOCKET Ptr _
	)As ULONG
	Return TcpListenerEndAccept(ContainerOf(this, TcpListener, lpVtbl), pIAsyncResult, ReadedBytes, pClientSocket)
End Function

Private Function ITcpListenerGetListenSocket( _
		ByVal this As ITcpListener Ptr, _
		ByVal pListenSocket As SOCKET Ptr _
	)As ULONG
	Return TcpListenerGetListenSocket(ContainerOf(this, TcpListener, lpVtbl), pListenSocket)
End Function

Private Function ITcpListenerSetListenSocket( _
		ByVal this As ITcpListener Ptr, _
		ByVal ListenSocket As SOCKET _
	)As ULONG
	Return TcpListenerSetListenSocket(ContainerOf(this, TcpListener, lpVtbl), ListenSocket)
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
