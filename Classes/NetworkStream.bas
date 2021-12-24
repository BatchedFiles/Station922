#include once "NetworkStream.bi"
#include once "IMutableAsyncResult.bi"
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
	lpVtbl As Const INetworkStreamVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	RemoteAddress As SOCKADDR_STORAGE
	RemoteAddressLength As Integer
	ClientSocket As SOCKET
End Type

Sub InitializeNetworkStream( _
		ByVal this As NetworkStream Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory(@this->IdString, @Str("Network___Stream"), 16)
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
	
	IMalloc_Release(this->pIMemoryAllocator)
	
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
	
	IMalloc_AddRef(this->pIMemoryAllocator)
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
	
	#ifdef __FB_64BIT__
		InterlockedIncrement64(@this->ReferenceCounter)
	#else
		InterlockedIncrement(@this->ReferenceCounter)
	#endif
	
	Return 1
	
End Function

Function NetworkStreamRelease( _
		ByVal this As NetworkStream Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		If InterlockedDecrement64(@this->ReferenceCounter) Then
			Return 1
		End If
	#else
		If InterlockedDecrement(@this->ReferenceCounter) Then
			Return 1
		End If
	#endif
	
	DestroyNetworkStream(this)
	
	Return 0
	
End Function

' Function NetworkStreamCanRead( _
		' ByVal this As NetworkStream Ptr, _
		' ByVal pResult As WINBOOLEAN Ptr _
	' )As HRESULT
	
	' *pResult = True
	
	' Return S_OK
	
' End Function

' Function NetworkStreamCanSeek( _
		' ByVal this As NetworkStream Ptr, _
		' ByVal pResult As WINBOOLEAN Ptr _
	' )As HRESULT
	
	' *pResult = False
	
	' Return S_OK
	
' End Function

' Function NetworkStreamCanWrite( _
		' ByVal this As NetworkStream Ptr, _
		' ByVal pResult As WINBOOLEAN Ptr _
	' )As HRESULT
	
	' *pResult = True
	
	' Return S_OK
	
' End Function

' Function NetworkStreamFlush( _
		' ByVal this As NetworkStream Ptr _
	' )As HRESULT
	
	' Return S_OK
	
' End Function

' Function NetworkStreamGetLength( _
		' ByVal this As NetworkStream Ptr, _
		' ByVal pResult As LARGE_INTEGER Ptr _
	' )As HRESULT
	
	' *pResult = 0
	
	' Return S_FALSE
	
' End Function

' Function NetworkStreamPosition( _
		' ByVal this As NetworkStream Ptr, _
		' ByVal pResult As LARGE_INTEGER Ptr _
	' )As HRESULT
	
	' *pResult = 0
	
	' Return S_FALSE
	
' End Function

' Function NetworkStreamRead( _
' 		ByVal this As NetworkStream Ptr, _
' 		ByVal buffer As LPVOID, _
' 		ByVal Count As DWORD, _
' 		ByVal pReadedBytes As DWORD Ptr _
' 	)As HRESULT
	
' 	Dim ReadedBytes As Long = recv(this->ClientSocket, buffer, Count, 0)
	
' 	Select Case ReadedBytes
		
' 		Case SOCKET_ERROR
' 			Dim intError As Long = WSAGetLastError()
' 			*pReadedBytes = 0
' 			Return HRESULT_FROM_WIN32(intError)
			
' 		Case 0
' 			*pReadedBytes = 0
' 			Return S_FALSE
			
' 		Case Else
' 			*pReadedBytes = ReadedBytes
' 			Return S_OK
			
' 	End Select
	
' End Function

' Function NetworkStreamWrite( _
' 		ByVal this As NetworkStream Ptr, _
' 		ByVal Buffer As LPVOID, _
' 		ByVal Count As DWORD, _
' 		ByVal pWritedBytes As DWORD Ptr _
' 	)As HRESULT
	
' 	Dim WritedBytes As Long = send(this->ClientSocket, Buffer, Count, 0)
	
' 	If WritedBytes = SOCKET_ERROR Then	
' 		Dim intError As Long = WSAGetLastError()
' 		*pWritedBytes = 0
' 		Return HRESULT_FROM_WIN32(intError)
' 	End If
	
' 	*pWritedBytes = WritedBytes
	
' 	Return S_OK
	
' End Function

' Function NetworkStreamSeek( _
		' ByVal this As NetworkStream Ptr, _
		' ByVal offset As LARGE_INTEGER, _
		' ByVal origin As SeekOrigin _
	' )As HRESULT
	
	' Return S_FALSE
	
' End Function

' Function NetworkStreamSetLength( _
		' ByVal this As NetworkStream Ptr, _
		' ByVal length As LARGE_INTEGER _
	' )As HRESULT
	
	' Return S_FALSE
	
' End Function

Function NetworkStreamBeginRead( _
		ByVal this As NetworkStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal BufferLength As DWORD, _
		ByVal callback As AsyncCallback, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Dim pINewAsyncResult As IMutableAsyncResult Ptr = Any
	Dim hr As HRESULT = CreateInstance( _
		this->pIMemoryAllocator, _
		@CLSID_ASYNCRESULT, _
		@IID_IMutableAsyncResult, _
		@pINewAsyncResult _
	)
	If FAILED(hr) Then
		*ppIAsyncResult = NULL
		Return E_OUTOFMEMORY
	End If
	
	Dim lpRecvOverlapped As ASYNCRESULTOVERLAPPED Ptr = Any
	IMutableAsyncResult_GetWsaOverlapped(pINewAsyncResult, @lpRecvOverlapped)
	
	' TODO Запросить интерфейс вместо конвертирования указателя
	lpRecvOverlapped->pIAsync = CPtr(IAsyncResult Ptr, pINewAsyncResult)
	
	IMutableAsyncResult_SetAsyncState(pINewAsyncResult, StateObject)
	IMutableAsyncResult_SetAsyncCallback(pINewAsyncResult, callback)
	
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
	
	Dim ReceiveBuffer As WSABUF = Any
	ReceiveBuffer.len = Cast(ULONG, BufferLength)
	ReceiveBuffer.buf = CPtr(ZString Ptr, Buffer)
	
	Const BuffersCount As DWORD = 1
	Const lpNumberOfBytesRecvd As LPDWORD = NULL
	Dim Flags As DWORD = 0
	
	Dim WSARecvResult As Long = WSARecv( _
		this->ClientSocket, _
		@ReceiveBuffer, _
		BuffersCount, _
		lpNumberOfBytesRecvd, _
		@Flags, _
		CPtr(WSAOVERLAPPED Ptr, lpRecvOverlapped), _
		lpCompletionRoutine _
	)
	If WSARecvResult <> 0 Then
		
		Dim intError As Long = WSAGetLastError()
		If intError <> WSA_IO_PENDING Then
			*ppIAsyncResult = NULL
			IMutableAsyncResult_Release(pINewAsyncResult)
			Return HRESULT_FROM_WIN32(intError)
		End If
		
	End If
	
	' TODO Запросить интерфейс вместо конвертирования указателя
	*ppIAsyncResult = CPtr(IAsyncResult Ptr, pINewAsyncResult)
	
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
	
	Dim pINewAsyncResult As IMutableAsyncResult Ptr = Any
	Dim hr As HRESULT = CreateInstance( _
		this->pIMemoryAllocator, _
		@CLSID_ASYNCRESULT, _
		@IID_IMutableAsyncResult, _
		@pINewAsyncResult _
	)
	If FAILED(hr) Then
		*ppIAsyncResult = NULL
		Return E_OUTOFMEMORY
	End If
	
	Dim lpRecvOverlapped As ASYNCRESULTOVERLAPPED Ptr = Any
	IMutableAsyncResult_GetWsaOverlapped(pINewAsyncResult, @lpRecvOverlapped)
	
	' TODO Запросить интерфейс вместо конвертирования указателя
	lpRecvOverlapped->pIAsync = CPtr(IAsyncResult Ptr, pINewAsyncResult)
	
	IMutableAsyncResult_SetAsyncState(pINewAsyncResult, StateObject)
	IMutableAsyncResult_SetAsyncCallback(pINewAsyncResult, callback)
	
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
	
	Dim SendBuffer As WSABUF = Any
	SendBuffer.len = Cast(ULONG, Count)
	SendBuffer.buf = CPtr(ZString Ptr, Buffer)
	
	Const BuffersCount As DWORD = 1
	Const lpNumberOfBytesSend As LPDWORD = NULL
	Dim Flags As DWORD = 0
	
	Dim WSASendResult As Long = WSASend( _
		this->ClientSocket, _
		@SendBuffer, _
		BuffersCount, _
		lpNumberOfBytesSend, _
		Flags, _
		CPtr(WSAOVERLAPPED Ptr, lpRecvOverlapped), _
		lpCompletionRoutine _
	)
	
	If WSASendResult <> 0 Then
		
		Dim intError As Long = WSAGetLastError()
		If intError <> WSA_IO_PENDING Then
			*ppIAsyncResult = NULL
			IMutableAsyncResult_Release(pINewAsyncResult)
			Return HRESULT_FROM_WIN32(intError)
		End If
		
	End If
	
	' TODO Запросить интерфейс вместо конвертирования указателя
	*ppIAsyncResult = CPtr(IAsyncResult Ptr, pINewAsyncResult)
	
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
	
	' TODO Запросить интерфейс вместо конвертирования указателя
	Dim pINewAsyncResult As IMutableAsyncResult Ptr = CPtr(IMutableAsyncResult Ptr, pIAsyncResult)
	
	Dim lpRecvOverlapped As ASYNCRESULTOVERLAPPED Ptr = Any
	IMutableAsyncResult_GetWsaOverlapped(pINewAsyncResult, @lpRecvOverlapped)
	
	Const fNoWait As BOOL = False
	Dim cbTransfer As DWORD = Any
	Dim dwFlags As DWORD = Any
	
	Dim OverlappedResult As BOOL = WSAGetOverlappedResult( _
		this->ClientSocket, _
		CPtr(WSAOVERLAPPED Ptr, lpRecvOverlapped), _
		@cbTransfer, _
		fNoWait, _
		@dwFlags _
	)
	If OverlappedResult = False Then
		
		Dim intError As Long = WSAGetLastError()
		
		If intError = WSA_IO_INCOMPLETE OrElse intError = WSA_IO_PENDING Then
			Return BASESTREAM_S_IO_PENDING
		End If
		
		*pReadedBytes = 0
		Return HRESULT_FROM_WIN32(intError)
	End If
	
	*pReadedBytes = cbTransfer
	
	If cbTransfer = 0 Then
		Return S_FALSE
	End If
	
	Return S_OK
	
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
	
	' TODO Запросить интерфейс вместо конвертирования указателя
	Dim pINewAsyncResult As IMutableAsyncResult Ptr = CPtr(IMutableAsyncResult Ptr, pIAsyncResult)
	
	Dim lpRecvOverlapped As ASYNCRESULTOVERLAPPED Ptr = Any
	IMutableAsyncResult_GetWsaOverlapped(pINewAsyncResult, @lpRecvOverlapped)
	
	Const fNoWait As BOOL = False
	Dim cbTransfer As DWORD = Any
	Dim dwFlags As DWORD = Any
	
	Dim OverlappedResult As BOOL = WSAGetOverlappedResult( _
		this->ClientSocket, _
		CPtr(WSAOVERLAPPED Ptr, lpRecvOverlapped), _
		@cbTransfer, _
		fNoWait, _
		@dwFlags _
	)
	If OverlappedResult = False Then
		
		Dim intError As Long = WSAGetLastError()
		
		If intError = WSA_IO_INCOMPLETE OrElse intError = WSA_IO_PENDING Then
			Return BASESTREAM_S_IO_PENDING
		End If
		
		*pWritedBytes = 0
		Return HRESULT_FROM_WIN32(intError)
	End If
	
	*pWritedBytes = cbTransfer
	
	If cbTransfer = 0 Then
		Return S_FALSE
	End If
	
	Return S_OK
	
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
	@INetworkStreamGetSocket, _
	@INetworkStreamSetSocket, _
	@INetworkStreamGetRemoteAddress, _
	@INetworkStreamSetRemoteAddress, _
	@INetworkStreamClose _
)
