#include once "NetworkAsyncStream.bi"
#include once "win\mswsock.bi"
#include once "AsyncResult.bi"
#include once "ITimeCounter.bi"
#include once "Network.bi"

Extern GlobalNetworkStreamVirtualTable As Const INetworkAsyncStreamVirtualTable

Type NetworkStream
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const INetworkAsyncStreamVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	ClientSocket As SOCKET
	pRemoteAddress As SOCKADDR Ptr
	RemoteAddressLength As Integer
End Type

Private Sub SetStartTime( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)

	Dim pITime As ITimeCounter Ptr = Any
	Dim hrQueryInterface As HRESULT = IMalloc_QueryInterface( _
		pIMemoryAllocator, _
		@IID_ITimeCounter, _
		@pITime _
	)

	If SUCCEEDED(hrQueryInterface) Then
		ITimeCounter_StartWatch(pITime)
		ITimeCounter_Release(pITime)
	End If

End Sub

Private Sub SetEndTime( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)

	Dim pITime As ITimeCounter Ptr = Any
	Dim hrQueryInterface As HRESULT = IMalloc_QueryInterface( _
		pIMemoryAllocator, _
		@IID_ITimeCounter, _
		@pITime _
	)

	If SUCCEEDED(hrQueryInterface) Then
		ITimeCounter_StopWatch(pITime)
		ITimeCounter_Release(pITime)
	End If

End Sub

Private Sub InitializeNetworkStream( _
		ByVal this As NetworkStream Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@this->RttiClassName(0), _
			@Str(RTTI_ID_NETWORKSTREAM), _
			UBound(this->RttiClassName) - LBound(this->RttiClassName) + 1 _
		)
	#endif
	this->lpVtbl = @GlobalNetworkStreamVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->RemoteAddressLength = 0
	this->ClientSocket = INVALID_SOCKET

End Sub

Private Sub UnInitializeNetworkStream( _
		ByVal this As NetworkStream Ptr _
	)

	this->ClientSocket = INVALID_SOCKET

End Sub

Private Sub NetworkStreamCreated( _
		ByVal this As NetworkStream Ptr _
	)

End Sub

Private Sub NetworkStreamDestroyed( _
		ByVal this As NetworkStream Ptr _
	)

End Sub

Private Sub DestroyNetworkStream( _
		ByVal this As NetworkStream Ptr _
	)

	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator

	UnInitializeNetworkStream(this)

	IMalloc_Free(pIMemoryAllocator, this)

	NetworkStreamDestroyed(this)

	IMalloc_Release(pIMemoryAllocator)

End Sub

Private Function NetworkStreamAddRef( _
		ByVal this As NetworkStream Ptr _
	)As ULONG

	this->ReferenceCounter += 1

	Return 1

End Function

Private Function NetworkStreamRelease( _
		ByVal this As NetworkStream Ptr _
	)As ULONG

	this->ReferenceCounter -= 1

	If this->ReferenceCounter Then
		Return 1
	End If

	DestroyNetworkStream(this)

	Return 0

End Function

Private Function NetworkStreamQueryInterface( _
		ByVal this As NetworkStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_INetworkAsyncStream, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IBaseAsyncStream, riid) Then
			*ppv = @this->lpVtbl
		Else
			If IsEqualIID(@IID_IUnknown, riid) Then
				*ppv = @this->lpVtbl
			Else
				*ppv = NULL
				Return E_NOINTERFACE
			End If
		End If
	End If

	NetworkStreamAddRef(this)

	Return S_OK

End Function

Public Function CreateNetworkStream( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	Dim this As NetworkStream Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(NetworkStream) _
	)

	If this Then
		InitializeNetworkStream(this, pIMemoryAllocator)
		NetworkStreamCreated(this)

		Dim hrQueryInterface As HRESULT = NetworkStreamQueryInterface( _
			this, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyNetworkStream(this)
		End If

		Return hrQueryInterface
	End If

	*ppv = NULL
	Return E_OUTOFMEMORY

End Function

Private Function NetworkStreamBeginRead( _
		ByVal this As NetworkStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal BufferLength As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	Dim pINewAsyncResult As IAsyncResult Ptr = Any
	Dim hrCreateAsyncResult As HRESULT = CreateAsyncResult( _
		this->pIMemoryAllocator, _
		@IID_IAsyncResult, _
		@pINewAsyncResult _
	)
	If FAILED(hrCreateAsyncResult) Then
		*ppIAsyncResult = NULL
		Return hrCreateAsyncResult
	End If

	Const ReceiveBuffersCount As DWORD = 1
	Dim pRecvBuffers As WSABUF Ptr = Any
	Dim hrAllocBuffer As HRESULT = IAsyncResult_AllocBuffers( _
		pINewAsyncResult, _
		CInt(ReceiveBuffersCount) * SizeOf(WSABUF), _
		@pRecvBuffers _
	)
	If FAILED(hrAllocBuffer) Then
		IAsyncResult_Release(pINewAsyncResult)
		*ppIAsyncResult = NULL
		Return hrAllocBuffer
	End If

	pRecvBuffers[0].len = Cast(ULONG, BufferLength)
	pRecvBuffers[0].buf = CPtr(ZString Ptr, Buffer)

	Dim pOverlap As OVERLAPPED Ptr = Any
	IAsyncResult_GetWsaOverlapped(pINewAsyncResult, @pOverlap)

	IAsyncResult_SetAsyncStateWeakPtr(pINewAsyncResult, pcb, StateObject)

	Dim lpCompletionRoutine As LPWSAOVERLAPPED_COMPLETION_ROUTINE = Any

	Const lpNumberOfBytesReceived As DWORD Ptr = NULL
	Dim Flags As DWORD = 0

	SetStartTime(this->pIMemoryAllocator)

	Dim resWSARecv As Long = WSARecv( _
		this->ClientSocket, _
		pRecvBuffers, _
		ReceiveBuffersCount, _
		lpNumberOfBytesReceived, _
		@Flags, _
		CPtr(WSAOVERLAPPED Ptr, pOverlap), _
		NULL _
	)
	If resWSARecv Then

		Dim intError As Long = WSAGetLastError()
		If intError <> WSA_IO_PENDING Then
			*ppIAsyncResult = NULL
			IAsyncResult_Release(pINewAsyncResult)
			Return HRESULT_FROM_WIN32(intError)
		End If

	End If

	*ppIAsyncResult = pINewAsyncResult

	Return S_OK

End Function

Private Function NetworkStreamBeginWriteGatherWithFlags( _
		ByVal this As NetworkStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal BuffersCount As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal Flags As DWORD, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	Dim pINewAsyncResult As IAsyncResult Ptr = Any
	Dim hrCreateAsyncResult As HRESULT = CreateAsyncResult( _
		this->pIMemoryAllocator, _
		@IID_IAsyncResult, _
		@pINewAsyncResult _
	)
	If FAILED(hrCreateAsyncResult) Then
		*ppIAsyncResult = NULL
		Return hrCreateAsyncResult
	End If

	Dim pSendBuffers As TRANSMIT_PACKETS_ELEMENT Ptr = Any
	Dim hrAllocBuffer As HRESULT = IAsyncResult_AllocBuffers( _
		pINewAsyncResult, _
		CInt(BuffersCount) * SizeOf(TRANSMIT_PACKETS_ELEMENT), _
		@pSendBuffers _
	)
	If FAILED(hrAllocBuffer) Then
		IAsyncResult_Release(pINewAsyncResult)
		*ppIAsyncResult = NULL
		Return hrAllocBuffer
	End If

	Dim pOverlap As OVERLAPPED Ptr = Any
	IAsyncResult_GetWsaOverlapped(pINewAsyncResult, @pOverlap)

	IAsyncResult_SetAsyncStateWeakPtr(pINewAsyncResult, pcb, StateObject)

	For i As DWORD = 0 To BuffersCount - 1
		pSendBuffers[i].dwElFlags = TP_ELEMENT_MEMORY
		pSendBuffers[i].cLength = Cast(ULONG, pBuffer[i].Length)
		pSendBuffers[i].pBuffer = pBuffer[i].Buffer
	Next

	SetStartTime(this->pIMemoryAllocator)

	Dim resTransmit As BOOL = lpfnTransmitPackets( _
		this->ClientSocket, _
		pSendBuffers, _
		BuffersCount, _
		0, _
		pOverlap, _
		Flags _
	)
	If resTransmit = 0 Then

		Dim intError As Long = WSAGetLastError()
		If intError <> WSA_IO_PENDING OrElse intError <> ERROR_IO_PENDING Then
			IAsyncResult_Release(pINewAsyncResult)
			*ppIAsyncResult = NULL
			Return HRESULT_FROM_WIN32(intError)
		End If

	End If

	*ppIAsyncResult = pINewAsyncResult

	Return S_OK

End Function

Private Function NetworkStreamBeginWrite( _
		ByVal this As NetworkStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	Const dwFlagsNone As DWORD = 0

	Dim buf As BaseStreamBuffer = Any
	buf.Buffer = Buffer
	buf.Length = Count

	Return NetworkStreamBeginWriteGatherWithFlags( _
		this, _
		@buf, _
		1, _
		pcb, _
		StateObject, _
		dwFlagsNone, _
		ppIAsyncResult _
	)

End Function

Private Function NetworkStreamBeginWriteGather( _
		ByVal this As NetworkStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal BuffersCount As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	Const dwFlagsNone As DWORD = 0

	Return NetworkStreamBeginWriteGatherWithFlags( _
		this, _
		pBuffer, _
		BuffersCount, _
		pcb, _
		StateObject, _
		dwFlagsNone, _
		ppIAsyncResult _
	)

End Function

Private Function NetworkStreamBeginWriteGatherAndShutdown( _
		ByVal this As NetworkStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal BuffersCount As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	' Const dwFlags As DWORD = TF_DISCONNECT Or TF_REUSE_SOCKET
	Const dwFlags As DWORD = TF_DISCONNECT

	Return NetworkStreamBeginWriteGatherWithFlags( _
		this, _
		pBuffer, _
		BuffersCount, _
		pcb, _
		StateObject, _
		dwFlags, _
		ppIAsyncResult _
	)

End Function

Private Function NetworkStreamEndRead( _
		ByVal this As NetworkStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pReadedBytes As DWORD Ptr _
	)As HRESULT

	SetEndTime(this->pIMemoryAllocator)

	Dim BytesTransferred As DWORD = Any
	Dim Completed As Boolean = Any
	Dim dwError As DWORD = Any
	IAsyncResult_GetCompleted( _
		pIAsyncResult, _
		@BytesTransferred, _
		@Completed, _
		@dwError _
	)

	If dwError Then
		*pReadedBytes = 0
		Return HRESULT_FROM_WIN32(dwError)
	End If

	If Completed Then
		*pReadedBytes = BytesTransferred

		If BytesTransferred = 0 Then
			Return S_FALSE
		End If

		Return S_OK
	End If

	Return HRESULT_FROM_WIN32(WSA_IO_INCOMPLETE)

End Function

Private Function NetworkStreamEndWrite( _
		ByVal this As NetworkStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pWritedBytes As DWORD Ptr _
	)As HRESULT

	SetEndTime(this->pIMemoryAllocator)

	Dim BytesTransferred As DWORD = Any
	Dim Completed As Boolean = Any
	Dim dwError As DWORD = Any
	IAsyncResult_GetCompleted( _
		pIAsyncResult, _
		@BytesTransferred, _
		@Completed, _
		@dwError _
	)
	If dwError Then

		Select Case dwError

			Case ERROR_CONNECTION_ABORTED
				*pWritedBytes = 0
				Return S_FALSE

		End Select

		Return HRESULT_FROM_WIN32(dwError)
	End If

	If Completed Then
		*pWritedBytes = BytesTransferred

		If BytesTransferred = 0 Then
			Return S_FALSE
		End If

		Return S_OK
	End If

	Return HRESULT_FROM_WIN32(WSA_IO_INCOMPLETE)

End Function

Private Function NetworkStreamGetSocket( _
		ByVal this As NetworkStream Ptr, _
		ByVal pResult As SOCKET Ptr _
	)As HRESULT

	*pResult = this->ClientSocket

	Return S_OK

End Function

Private Function NetworkStreamSetSocket( _
		ByVal this As NetworkStream Ptr, _
		ByVal ClientSocket As SOCKET _
	)As HRESULT

	this->ClientSocket = ClientSocket

	Return S_OK

End Function

Private Function NetworkStreamGetRemoteAddress( _
		ByVal this As NetworkStream Ptr, _
		ByVal pRemoteAddress As SOCKADDR Ptr, _
		ByVal pRemoteAddressLength As Integer Ptr _
	)As HRESULT

	*pRemoteAddressLength = this->RemoteAddressLength
	CopyMemory(pRemoteAddress, @this->pRemoteAddress, this->RemoteAddressLength)

	Return S_OK

End Function

Private Function NetworkStreamSetRemoteAddress( _
		ByVal this As NetworkStream Ptr, _
		ByVal RemoteAddress As SOCKADDR Ptr, _
		ByVal RemoteAddressLength As Integer _
	)As HRESULT

	this->RemoteAddressLength = RemoteAddressLength
	this->pRemoteAddress = RemoteAddress

	Return S_OK

End Function


Private Function INetworkAsyncStreamQueryInterface( _
		ByVal this As INetworkAsyncStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return NetworkStreamQueryInterface(CONTAINING_RECORD(this, NetworkStream, lpVtbl), riid, ppvObject)
End Function

Private Function INetworkAsyncStreamAddRef( _
		ByVal this As INetworkAsyncStream Ptr _
	)As ULONG
	Return NetworkStreamAddRef(CONTAINING_RECORD(this, NetworkStream, lpVtbl))
End Function

Private Function INetworkAsyncStreamRelease( _
		ByVal this As INetworkAsyncStream Ptr _
	)As ULONG
	Return NetworkStreamRelease(CONTAINING_RECORD(this, NetworkStream, lpVtbl))
End Function

Private Function INetworkAsyncStreamBeginRead( _
		ByVal this As INetworkAsyncStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return NetworkStreamBeginRead(CONTAINING_RECORD(this, NetworkStream, lpVtbl), Buffer, Count, pcb, StateObject, ppIAsyncResult)
End Function

Private Function INetworkAsyncStreamBeginWrite( _
		ByVal this As INetworkAsyncStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return NetworkStreamBeginWrite(CONTAINING_RECORD(this, NetworkStream, lpVtbl), Buffer, Count, pcb, StateObject, ppIAsyncResult)
End Function

Private Function INetworkAsyncStreamEndRead( _
		ByVal this As INetworkAsyncStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pReadedBytes As DWORD Ptr _
	)As HRESULT
	Return NetworkStreamEndRead(CONTAINING_RECORD(this, NetworkStream, lpVtbl), pIAsyncResult, pReadedBytes)
End Function

Private Function INetworkAsyncStreamEndWrite( _
		ByVal this As INetworkAsyncStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pWritedBytes As DWORD Ptr _
	)As HRESULT
	Return NetworkStreamEndWrite(CONTAINING_RECORD(this, NetworkStream, lpVtbl), pIAsyncResult, pWritedBytes)
End Function

Private Function INetworkAsyncStreamBeginWriteGather( _
		ByVal this As INetworkAsyncStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal Count As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return NetworkStreamBeginWriteGather(CONTAINING_RECORD(this, NetworkStream, lpVtbl), pBuffer, Count, pcb, StateObject, ppIAsyncResult)
End Function

Private Function INetworkAsyncStreamBeginWriteGatherAndShutdown( _
		ByVal this As INetworkAsyncStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal Count As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return NetworkStreamBeginWriteGatherAndShutdown(CONTAINING_RECORD(this, NetworkStream, lpVtbl), pBuffer, Count, pcb, StateObject, ppIAsyncResult)
End Function

Private Function INetworkAsyncStreamGetSocket( _
		ByVal this As INetworkAsyncStream Ptr, _
		ByVal pResult As SOCKET Ptr _
	)As HRESULT
	Return NetworkStreamGetSocket(CONTAINING_RECORD(this, NetworkStream, lpVtbl), pResult)
End Function

Private Function INetworkAsyncStreamSetSocket( _
		ByVal this As INetworkAsyncStream Ptr, _
		ByVal sock As SOCKET _
	)As HRESULT
	Return NetworkStreamSetSocket(CONTAINING_RECORD(this, NetworkStream, lpVtbl), sock)
End Function

Private Function INetworkAsyncStreamGetRemoteAddress( _
		ByVal this As INetworkAsyncStream Ptr, _
		ByVal pRemoteAddress As SOCKADDR Ptr, _
		ByVal pRemoteAddressLength As Integer Ptr _
	)As HRESULT
	Return NetworkStreamGetRemoteAddress(CONTAINING_RECORD(this, NetworkStream, lpVtbl), pRemoteAddress, pRemoteAddressLength)
End Function

Private Function INetworkAsyncStreamSetRemoteAddress( _
		ByVal this As INetworkAsyncStream Ptr, _
		ByVal RemoteAddress As SOCKADDR Ptr, _
		ByVal RemoteAddressLength As Integer _
	)As HRESULT
	Return NetworkStreamSetRemoteAddress(CONTAINING_RECORD(this, NetworkStream, lpVtbl), RemoteAddress, RemoteAddressLength)
End Function

Dim GlobalNetworkStreamVirtualTable As Const INetworkAsyncStreamVirtualTable = Type( _
	@INetworkAsyncStreamQueryInterface, _
	@INetworkAsyncStreamAddRef, _
	@INetworkAsyncStreamRelease, _
	@INetworkAsyncStreamBeginRead, _
	@INetworkAsyncStreamBeginWrite, _
	@INetworkAsyncStreamEndRead, _
	@INetworkAsyncStreamEndWrite, _
	NULL, _ /' BeginReadScatter '/
	@INetworkAsyncStreamBeginWriteGather, _
	@INetworkAsyncStreamBeginWriteGatherAndShutdown, _
	@INetworkAsyncStreamGetSocket, _
	@INetworkAsyncStreamSetSocket, _
	@INetworkAsyncStreamGetRemoteAddress, _
	@INetworkAsyncStreamSetRemoteAddress _
)
