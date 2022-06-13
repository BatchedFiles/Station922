#include once "NetworkStream.bi"
#include once "AsyncResult.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "Logger.bi"
#include once "Network.bi"

Extern GlobalNetworkStreamVirtualTable As Const INetworkStreamVirtualTable

Extern CLSID_ASYNCRESULT Alias "CLSID_ASYNCRESULT" As Const CLSID

Type _NetworkStream
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	RemoteAddress As SOCKADDR_STORAGE
	lpVtbl As Const INetworkStreamVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	RemoteAddressLength As Integer
	ClientSocket As SOCKET
End Type

Sub InitializeNetworkStream( _
		ByVal this As NetworkStream Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_NETWORKSTREAM), _
			Len(NetworkStream.IdString) _
		)
	#endif
	this->lpVtbl = @GlobalNetworkStreamVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->RemoteAddressLength = 0
	this->ClientSocket = INVALID_SOCKET
	
End Sub

Sub UnInitializeNetworkStream( _
		ByVal this As NetworkStream Ptr _
	)
	
	If this->ClientSocket <> INVALID_SOCKET Then
		CloseSocketConnection(this->ClientSocket)
	End If
	#if __FB_DEBUG__
		this->ClientSocket = INVALID_SOCKET
	#endif
	
End Sub

Function CreateNetworkStream( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As NetworkStream Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(NetworkStream)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"NetworkStream creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim this As NetworkStream Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(NetworkStream) _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializeNetworkStream(this, pIMemoryAllocator)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("NetworkStream created"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	Return this
	
End Function

Sub DestroyNetworkStream( _
		ByVal this As NetworkStream Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("NetworkStream destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeNetworkStream(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("NetworkStream destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function NetworkStreamQueryInterface( _
		ByVal this As NetworkStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_INetworkStream, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IBaseStream, riid) Then
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

Function NetworkStreamAddRef( _
		ByVal this As NetworkStream Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return 1
	
End Function

Function NetworkStreamRelease( _
		ByVal this As NetworkStream Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyNetworkStream(this)
	
	Return 0
	
End Function

Function NetworkStreamBeginRead( _
		ByVal this As NetworkStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal BufferLength As DWORD, _
		ByVal callback As AsyncCallback, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Dim pINewAsyncResult As IAsyncResult Ptr = Any
	Dim hrCreateAsyncResult As HRESULT = CreateInstance( _
		this->pIMemoryAllocator, _
		@CLSID_ASYNCRESULT, _
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
		CInt(ReceiveBuffersCount), _
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
	
	IAsyncResult_SetAsyncStateWeakPtr(pINewAsyncResult, StateObject)
	IAsyncResult_SetAsyncCallback(pINewAsyncResult, callback)
	
	Dim lpCompletionRoutine As LPWSAOVERLAPPED_COMPLETION_ROUTINE = Any
	
	If callback = NULL Then
		' Const ManualReset As Boolean = True
		' Const NonsignaledState As Boolean = False
		
		' hEvent = NULL
		'hEvent = CreateEvent(NULL, ManualReset, NonsignaledState, NULL)
		'
		'If hEvent = NULL Then
		'	Dim dwError As DWORD = GetLastError()
		'	INetworkStreamAsyncResult_Release(pINewAsyncResult)
		'	
		'	Return HRESULT_FROM_WIN32(dwError)
		'End If
		
		' lpRecvOverlapped->hEvent = pINewAsyncResult ' WSACreateEvent()  WSACloseEvent()
		' INetworkStreamAsyncResult_SetWaitHandle(pINewAsyncResult, hEvent)
		lpCompletionRoutine = NULL
	Else
		' TODO Реализовать для функции завершения ввода-вывода
		' lpRecvOverlapped->hEvent = pINewAsyncResult
		lpCompletionRoutine = NULL
	End If
	
	Const lpNumberOfBytesReceived As DWORD Ptr = NULL
	Dim Flags As DWORD = 0
	
	Dim resWSARecv As Long = WSARecv( _
		this->ClientSocket, _
		pRecvBuffers, _
		ReceiveBuffersCount, _
		lpNumberOfBytesReceived, _
		@Flags, _
		CPtr(WSAOVERLAPPED Ptr, pOverlap), _
		lpCompletionRoutine _
	)
	If resWSARecv <> 0 Then
		
		Dim intError As Long = WSAGetLastError()
		If intError <> WSA_IO_PENDING Then
			*ppIAsyncResult = NULL
			IAsyncResult_Release(pINewAsyncResult)
			Return HRESULT_FROM_WIN32(intError)
		End If
		
	End If
	
	*ppIAsyncResult = pINewAsyncResult
	
	Return BASESTREAM_S_IO_PENDING
	
End Function

Function NetworkStreamBeginWrite( _
		ByVal this As NetworkStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal callback As AsyncCallback, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Dim buf As BaseStreamBuffer = Any
	buf.Buffer = Buffer
	buf.Length = Count
	
	Return NetworkStreamBeginWriteGather( _
		this, _
		@buf, _
		1, _
		callback, _
		StateObject, _
		ppIAsyncResult _
	)
	
End Function

Function NetworkStreamBeginWriteGather( _
		ByVal this As NetworkStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal BuffersCount As DWORD, _
		ByVal callback As AsyncCallback, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Dim pINewAsyncResult As IAsyncResult Ptr = Any
	Dim hrCreateAsyncResult As HRESULT = CreateInstance( _
		this->pIMemoryAllocator, _
		@CLSID_ASYNCRESULT, _
		@IID_IAsyncResult, _
		@pINewAsyncResult _
	)
	If FAILED(hrCreateAsyncResult) Then
		*ppIAsyncResult = NULL
		Return hrCreateAsyncResult
	End If
	
	Dim pSendBuffers As WSABUF Ptr = Any
	Dim hrAllocBuffer As HRESULT = IAsyncResult_AllocBuffers( _
		pINewAsyncResult, _
		CInt(BuffersCount), _
		@pSendBuffers _
	)
	If FAILED(hrAllocBuffer) Then
		IAsyncResult_Release(pINewAsyncResult)
		*ppIAsyncResult = NULL
		Return hrAllocBuffer
	End If
	
	Dim pOverlap As OVERLAPPED Ptr = Any
	IAsyncResult_GetWsaOverlapped(pINewAsyncResult, @pOverlap)
	
	IAsyncResult_SetAsyncStateWeakPtr(pINewAsyncResult, StateObject)
	IAsyncResult_SetAsyncCallback(pINewAsyncResult, callback)
	
	Dim lpCompletionRoutine As LPWSAOVERLAPPED_COMPLETION_ROUTINE = Any
	
	If callback = NULL Then
		' Const ManualReset As Boolean = True
		' Const NonsignaledState As Boolean = False
		
		' hEvent = NULL
		'hEvent = CreateEvent(NULL, ManualReset, NonsignaledState, NULL)
		'
		'If hEvent = NULL Then
		'	Dim dwError As DWORD = GetLastError()
		'	INetworkStreamAsyncResult_Release(pINewAsyncResult)
		'	
		'	Return HRESULT_FROM_WIN32(dwError)
		'End If
		
		' lpRecvOverlapped->hEvent = pINewAsyncResult ' WSACreateEvent()  WSACloseEvent()
		' INetworkStreamAsyncResult_SetWaitHandle(pINewAsyncResult, hEvent)
		lpCompletionRoutine = NULL
	Else
		' TODO Реализовать для функции завершения ввода-вывода
		' lpRecvOverlapped->hEvent = pINewAsyncResult
		lpCompletionRoutine = NULL
	End If
	
	For i As DWORD = 0 To BuffersCount - 1
		pSendBuffers[i].len = Cast(ULONG, pBuffer[i].Length)
		pSendBuffers[i].buf = Cast(CHAR Ptr, pBuffer[i].Buffer)
	Next
	
	Const lpNumberOfBytesSend As LPDWORD = NULL
	
	Const Flags As DWORD = 0
	
	Dim WSASendResult As Long = WSASend( _
		this->ClientSocket, _
		pSendBuffers, _
		BuffersCount, _
		lpNumberOfBytesSend, _
		Flags, _
		CPtr(WSAOVERLAPPED Ptr, pOverlap), _
		lpCompletionRoutine _
	)
	
	If WSASendResult <> 0 Then
		
		Dim intError As Long = WSAGetLastError()
		If intError <> WSA_IO_PENDING Then
			IAsyncResult_Release(pINewAsyncResult)
			*ppIAsyncResult = NULL
			Return HRESULT_FROM_WIN32(intError)
		End If
		
	End If
	
	*ppIAsyncResult = pINewAsyncResult
	
	Return BASESTREAM_S_IO_PENDING
	
End Function

Function NetworkStreamEndRead( _
		ByVal this As NetworkStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pReadedBytes As DWORD Ptr _
	)As HRESULT
	
	Dim BytesTransferred As DWORD = Any
	Dim Completed As Boolean = Any
	IAsyncResult_GetCompleted( _
		pIAsyncResult, _
		@BytesTransferred, _
		@Completed _
	)
	If Completed Then
		*pReadedBytes = BytesTransferred
		
		If BytesTransferred = 0 Then
			Return S_FALSE
		End If
		
		Return S_OK
	End If
	
	Return HRESULT_FROM_WIN32(WSA_IO_INCOMPLETE)
	
End Function

Function NetworkStreamEndWrite( _
		ByVal this As NetworkStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pWritedBytes As DWORD Ptr _
	)As HRESULT
	
	Dim BytesTransferred As DWORD = Any
	Dim Completed As Boolean = Any
	IAsyncResult_GetCompleted( _
		pIAsyncResult, _
		@BytesTransferred, _
		@Completed _
	)
	If Completed Then
		*pWritedBytes = BytesTransferred
		
		If BytesTransferred = 0 Then
			Return S_FALSE
		End If
		
		Return S_OK
	End If
	
	Return HRESULT_FROM_WIN32(WSA_IO_INCOMPLETE)
	
End Function

Function NetworkStreamGetSocket( _
		ByVal this As NetworkStream Ptr, _
		ByVal pResult As SOCKET Ptr _
	)As HRESULT
	
	*pResult = this->ClientSocket
	
	Return S_OK
	
End Function
	
Function NetworkStreamSetSocket( _
		ByVal this As NetworkStream Ptr, _
		ByVal ClientSocket As SOCKET _
	)As HRESULT
	
	this->ClientSocket = ClientSocket
	
	Return S_OK
	
End Function

Function NetworkStreamGetRemoteAddress( _
		ByVal this As NetworkStream Ptr, _
		ByVal pRemoteAddress As SOCKADDR Ptr, _
		ByVal pRemoteAddressLength As Integer Ptr _
	)As HRESULT
	
	*pRemoteAddressLength = this->RemoteAddressLength
	CopyMemory(pRemoteAddress, @this->RemoteAddress, this->RemoteAddressLength)
	
	Return S_OK
	
End Function

Function NetworkStreamSetRemoteAddress( _
		ByVal this As NetworkStream Ptr, _
		ByVal RemoteAddress As SOCKADDR Ptr, _
		ByVal RemoteAddressLength As Integer _
	)As HRESULT
	
	this->RemoteAddressLength = RemoteAddressLength
	CopyMemory(@this->RemoteAddress, RemoteAddress, RemoteAddressLength)
	
	Return S_OK
	
End Function

Function NetworkStreamClose( _
		ByVal this As NetworkStream Ptr _
	)As HRESULT
	
	If this->ClientSocket <> INVALID_SOCKET Then
		CloseSocketConnection(this->ClientSocket)
		this->ClientSocket = INVALID_SOCKET
	End If
	
	Return S_OK
	
End Function


Function INetworkStreamQueryInterface( _
		ByVal this As INetworkStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return NetworkStreamQueryInterface(ContainerOf(this, NetworkStream, lpVtbl), riid, ppvObject)
End Function

Function INetworkStreamAddRef( _
		ByVal this As INetworkStream Ptr _
	)As ULONG
	Return NetworkStreamAddRef(ContainerOf(this, NetworkStream, lpVtbl))
End Function

Function INetworkStreamRelease( _
		ByVal this As INetworkStream Ptr _
	)As ULONG
	Return NetworkStreamRelease(ContainerOf(this, NetworkStream, lpVtbl))
End Function

Function INetworkStreamBeginRead( _
		ByVal this As INetworkStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal callback As AsyncCallback, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return NetworkStreamBeginRead(ContainerOf(this, NetworkStream, lpVtbl), Buffer, Count, callback, StateObject, ppIAsyncResult)
End Function

Function INetworkStreamBeginWrite( _
		ByVal this As INetworkStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal callback As AsyncCallback, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return NetworkStreamBeginWrite(ContainerOf(this, NetworkStream, lpVtbl), Buffer, Count, callback, StateObject, ppIAsyncResult)
End Function

Function INetworkStreamEndRead( _
		ByVal this As INetworkStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pReadedBytes As DWORD Ptr _
	)As HRESULT
	Return NetworkStreamEndRead(ContainerOf(this, NetworkStream, lpVtbl), pIAsyncResult, pReadedBytes)
End Function

Function INetworkStreamEndWrite( _
		ByVal this As INetworkStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pWritedBytes As DWORD Ptr _
	)As HRESULT
	Return NetworkStreamEndWrite(ContainerOf(this, NetworkStream, lpVtbl), pIAsyncResult, pWritedBytes)
End Function

Function INetworkStreamBeginWriteGather( _
		ByVal this As INetworkStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal Count As DWORD, _
		ByVal callback As AsyncCallback, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return NetworkStreamBeginWriteGather(ContainerOf(this, NetworkStream, lpVtbl), pBuffer, Count, callback, StateObject, ppIAsyncResult)
End Function

Function INetworkStreamGetSocket( _
		ByVal this As INetworkStream Ptr, _
		ByVal pResult As SOCKET Ptr _
	)As HRESULT
	Return NetworkStreamGetSocket(ContainerOf(this, NetworkStream, lpVtbl), pResult)
End Function

Function INetworkStreamSetSocket( _
		ByVal this As INetworkStream Ptr, _
		ByVal sock As SOCKET _
	)As HRESULT
	Return NetworkStreamSetSocket(ContainerOf(this, NetworkStream, lpVtbl), sock)
End Function

Function INetworkStreamGetRemoteAddress( _
		ByVal this As INetworkStream Ptr, _
		ByVal pRemoteAddress As SOCKADDR Ptr, _
		ByVal pRemoteAddressLength As Integer Ptr _
	)As HRESULT
	Return NetworkStreamGetRemoteAddress(ContainerOf(this, NetworkStream, lpVtbl), pRemoteAddress, pRemoteAddressLength)
End Function

Function INetworkStreamSetRemoteAddress( _
		ByVal this As INetworkStream Ptr, _
		ByVal RemoteAddress As SOCKADDR Ptr, _
		ByVal RemoteAddressLength As Integer _
	)As HRESULT
	Return NetworkStreamSetRemoteAddress(ContainerOf(this, NetworkStream, lpVtbl), RemoteAddress, RemoteAddressLength)
End Function

Function INetworkStreamClose( _
		ByVal this As INetworkStream Ptr _
	)As HRESULT
	Return NetworkStreamClose(ContainerOf(this, NetworkStream, lpVtbl))
End Function

Dim GlobalNetworkStreamVirtualTable As Const INetworkStreamVirtualTable = Type( _
	@INetworkStreamQueryInterface, _
	@INetworkStreamAddRef, _
	@INetworkStreamRelease, _
	NULL, _ /' @INetworkStreamCanRead, _ '/
	NULL, _ /' @INetworkStreamCanSeek, _ '/
	NULL, _ /' @INetworkStreamCanWrite, _ '/
	NULL, _ /' @INetworkStreamFlush, _ '/
	NULL, _ /' @INetworkStreamGetLength, _ '/
	NULL, _ /' @INetworkStreamPosition, _ '/
	NULL, _ /' @INetworkStreamRead, _ '/
	NULL, _ /' @INetworkStreamSeek, _ '/
	NULL, _ /' @INetworkStreamSetLength, _ '/
	NULL, _ /' @INetworkStreamWrite, _ '/
	@INetworkStreamBeginRead, _
	@INetworkStreamBeginWrite, _ 
	@INetworkStreamEndRead, _
	@INetworkStreamEndWrite, _
	NULL, _ /' BeginReadScatter '/
	@INetworkStreamBeginWriteGather, _
	@INetworkStreamGetSocket, _
	@INetworkStreamSetSocket, _
	@INetworkStreamGetRemoteAddress, _
	@INetworkStreamSetRemoteAddress, _
	@INetworkStreamClose _
)
