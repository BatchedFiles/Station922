#include once "TcpListener.bi"
#include once "win\mswsock.bi"
#include once "AsyncResult.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "Logger.bi"

Extern GlobalTcpListenerVirtualTable As Const ITcpListenerVirtualTable

Common Shared lpfnAcceptEx As LPFN_ACCEPTEX
Common Shared lpfnGetAcceptExSockaddrs As LPFN_GETACCEPTEXSOCKADDRS

Type _TcpListener
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const ITcpListenerVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	ListenSocket As SOCKET
	ClientSocket As SOCKET
	Buffer As ClientRequestBuffer Ptr
End Type

Sub InitializeTcpListener( _
		ByVal this As TcpListener Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_TCPLISTENER), _
			Len(TcpListener.IdString) _
		)
	#endif
	this->lpVtbl = @GlobalTcpListenerVirtualTable
	this->ReferenceCounter = CUInt(-1)
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->ListenSocket = INVALID_SOCKET
	
End Sub

Sub UnInitializeTcpListener( _
		ByVal this As TcpListener Ptr _
	)
	
End Sub

Function CreatePermanentTcpListener( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As TcpListener Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(TcpListener)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"TcpListener creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim this As TcpListener Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(TcpListener) _
	)
	
	If this <> NULL Then
		InitializeTcpListener( _
			this, _
			pIMemoryAllocator _
		)
		
		#if __FB_DEBUG__
		Scope
			Dim vtEmpty As VARIANT = Any
			VariantInit(@vtEmpty)
			LogWriteEntry( _
				LogEntryType.Debug, _
				WStr("TcpListener created"), _
				@vtEmpty _
			)
		End Scope
		#endif
		
		Return this
	End If
	
	Return NULL
	
End Function

Sub DestroyTcpListener( _
		ByVal this As TcpListener Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("TcpListener destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeTcpListener(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("TcpListener destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function TcpListenerQueryInterface( _
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

Function TcpListenerAddRef( _
		ByVal this As TcpListener Ptr _
	)As ULONG
	
	Return 1
	
End Function

Function TcpListenerRelease( _
		ByVal this As TcpListener Ptr _
	)As ULONG
	
	Return 0
	
End Function

Function TcpListenerBeginAccept( _
		ByVal this As TcpListener Ptr, _
		ByVal Buffer As ClientRequestBuffer Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	this->ClientSocket = WSASocket( _
		AF_UNSPEC, _
		SOCK_STREAM, _
		IPPROTO_TCP, _
		NULL, _
		0, _
		WSA_FLAG_OVERLAPPED _
	)
	If this->ClientSocket = INVALID_SOCKET Then
		Dim dwError As Long = WSAGetLastError()
		*ppIAsyncResult = NULL
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Dim pINewAsyncResult As IAsyncResult Ptr = Any
	Dim hrCreateAsyncResult As HRESULT = CreateInstance( _
		this->pIMemoryAllocator, _
		@CLSID_ASYNCRESULT, _
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
	IAsyncResult_SetAsyncCallback(pINewAsyncResult, NULL)
	
	this->Buffer = Buffer
	' Dim dwBytes As DWORD = Any
	Dim resAccept As BOOL = lpfnAcceptEx( _
		this->ListenSocket, _
		this->ClientSocket, _
		@Buffer->LocalAddress, _
		0, _
		SOCKET_ADDRESS_STORAGE_LENGTH, _
		SOCKET_ADDRESS_STORAGE_LENGTH, _
		NULL, _ /' @dwBytes, _ '/
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

Function TcpListenerEndAccept( _
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

Function TcpListenerGetListenSocket( _
		ByVal this As TcpListener Ptr, _
		ByVal pListenSocket As SOCKET Ptr _
	)As HRESULT
	
	*pListenSocket = this->ListenSocket
	
	Return S_OK
	
End Function

Function TcpListenerSetListenSocket( _
		ByVal this As TcpListener Ptr, _
		ByVal ListenSocket As SOCKET _
	)As HRESULT
	
	this->ListenSocket = ListenSocket
	
	Return S_OK
	
End Function


Function ITcpListenerQueryInterface( _
		ByVal this As ITcpListener Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return TcpListenerQueryInterface(ContainerOf(this, TcpListener, lpVtbl), riid, ppv)
End Function

Function ITcpListenerAddRef( _
		ByVal this As ITcpListener Ptr _
	)As ULONG
	Return TcpListenerAddRef(ContainerOf(this, TcpListener, lpVtbl))
End Function

Function ITcpListenerRelease( _
		ByVal this As ITcpListener Ptr _
	)As ULONG
	Return TcpListenerRelease(ContainerOf(this, TcpListener, lpVtbl))
End Function

Function ITcpListenerBeginAccept( _
		ByVal this As ITcpListener Ptr, _
		ByVal Buffer As ClientRequestBuffer Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As ULONG
	Return TcpListenerBeginAccept(ContainerOf(this, TcpListener, lpVtbl), Buffer, StateObject, ppIAsyncResult)
End Function

Function ITcpListenerEndAccept( _
		ByVal this As ITcpListener Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal ReadedBytes As DWORD, _
		ByVal pClientSocket As SOCKET Ptr _
	)As ULONG
	Return TcpListenerEndAccept(ContainerOf(this, TcpListener, lpVtbl), pIAsyncResult, ReadedBytes, pClientSocket)
End Function

Function ITcpListenerGetListenSocket( _
		ByVal this As ITcpListener Ptr, _
		ByVal pListenSocket As SOCKET Ptr _
	)As ULONG
	Return TcpListenerGetListenSocket(ContainerOf(this, TcpListener, lpVtbl), pListenSocket)
End Function

Function ITcpListenerSetListenSocket( _
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
