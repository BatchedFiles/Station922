#include once "NetworkStream.bi"
#include once "IMutableAsyncResult.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "Network.bi"
#include once "ReferenceCounter.bi"

Extern GlobalNetworkStreamVirtualTable As Const INetworkStreamVirtualTable

Extern CLSID_ASYNCRESULT Alias "CLSID_ASYNCRESULT" As Const CLSID

Type _NetworkStream
	lpVtbl As Const INetworkStreamVirtualTable Ptr
	RefCounter As ReferenceCounter
	pILogger As ILogger Ptr
	pIMemoryAllocator As IMalloc Ptr
	ClientSocket As SOCKET
End Type

Sub InitializeNetworkStream( _
		ByVal this As NetworkStream Ptr, _
		ByVal pILogger As ILogger Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	this->lpVtbl = @GlobalNetworkStreamVirtualTable
	ReferenceCounterInitialize(@this->RefCounter)
	ILogger_AddRef(pILogger)
	this->pILogger = pILogger
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->ClientSocket = INVALID_SOCKET
	
End Sub

Sub UnInitializeNetworkStream( _
		ByVal this As NetworkStream Ptr _
	)
	
	If this->ClientSocket <> INVALID_SOCKET Then
		CloseSocketConnection(this->ClientSocket)
	End If
	
	ReferenceCounterUnInitialize(@this->RefCounter)
	IMalloc_Release(this->pIMemoryAllocator)
	ILogger_Release(this->pILogger)
	
End Sub

Function CreateNetworkStream( _
		ByVal pILogger As ILogger Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As NetworkStream Ptr
	
#if __FB_DEBUG__
	Dim vtAllocatedBytes As VARIANT = Any
	vtAllocatedBytes.vt = VT_I4
	vtAllocatedBytes.lVal = SizeOf(NetworkStream)
	ILogger_LogDebug(pILogger, WStr(!"NetworkStream creating\t"), vtAllocatedBytes)
#endif
	
	Dim this As NetworkStream Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(NetworkStream) _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializeNetworkStream(this, pILogger, pIMemoryAllocator)
	
#if __FB_DEBUG__
	Dim vtEmpty As VARIANT = Any
	vtEmpty.vt = VT_EMPTY
	ILogger_LogDebug(pILogger, WStr("NetworkStream created"), vtEmpty)
#endif
	
	Return this
	
End Function

Sub DestroyNetworkStream( _
		ByVal this As NetworkStream Ptr _
	)
	
#if __FB_DEBUG__
	Dim vtEmpty As VARIANT = Any
	vtEmpty.vt = VT_EMPTY
	ILogger_LogDebug(this->pILogger, WStr("NetworkStream destroying"), vtEmpty)
#endif
	
	ILogger_AddRef(this->pILogger)
	Dim pILogger As ILogger Ptr = this->pILogger
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeNetworkStream(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
#if __FB_DEBUG__
	ILogger_LogDebug(pILogger, WStr("NetworkStream destroyed"), vtEmpty)
#endif
	
	IMalloc_Release(pIMemoryAllocator)
	ILogger_Release(pILogger)
	
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
	
	ReferenceCounterIncrement(@this->RefCounter)
	
	Return 1
	
End Function

Function NetworkStreamRelease( _
		ByVal this As NetworkStream Ptr _
	)As ULONG
	
	If ReferenceCounterDecrement(@this->RefCounter) Then
		Return 1
	End If
	
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

Function NetworkStreamRead( _
		ByVal this As NetworkStream Ptr, _
		ByVal buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal pReadedBytes As DWORD Ptr _
	)As HRESULT
	
	Dim ReadedBytes As Long = recv(this->ClientSocket, buffer, Count, 0)
	
	Select Case ReadedBytes
		
		Case SOCKET_ERROR
			Dim intError As Long = WSAGetLastError()
			*pReadedBytes = 0
			Return HRESULT_FROM_WIN32(intError)
			
		Case 0
			*pReadedBytes = 0
			Return S_FALSE
			
		Case Else
			*pReadedBytes = ReadedBytes
			Return S_OK
			
	End Select
	
End Function

Function NetworkStreamWrite( _
		ByVal this As NetworkStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal pWritedBytes As DWORD Ptr _
	)As HRESULT
	
	Dim WritedBytes As Long = send(this->ClientSocket, Buffer, Count, 0)
	
	If WritedBytes = SOCKET_ERROR Then	
		Dim intError As Long = WSAGetLastError()
		*pWritedBytes = 0
		Return HRESULT_FROM_WIN32(intError)
	End If
	
	*pWritedBytes = WritedBytes
	
	Return S_OK
	
End Function

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
		ByVal Count As DWORD, _
		ByVal callback As AsyncCallback, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	*ppIAsyncResult = NULL
	
	Dim pINewAsyncResult As IMutableAsyncResult Ptr = Any
	Dim hr As HRESULT = CreateInstance( _
		this->pILogger, _
		this->pIMemoryAllocator, _
		@CLSID_ASYNCRESULT, _
		@IID_IMutableAsyncResult, _
		@pINewAsyncResult _
	)
	If FAILED(hr) Then
		Return E_OUTOFMEMORY
	End If
	
	Dim lpReceiveCompletionROUTINE As LPWSAOVERLAPPED_COMPLETION_ROUTINE = Any
	
	Dim lpRecvOverlapped As ASYNCRESULTOVERLAPPED Ptr = Any
	IMutableAsyncResult_GetWsaOverlapped(pINewAsyncResult, @lpRecvOverlapped)
	' TODO Запросить интерфейс вместо конвертирования указателя
	lpRecvOverlapped->pIAsync = CPtr(IAsyncResult Ptr, pINewAsyncResult)
	
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
		lpReceiveCompletionROUTINE = NULL
	Else
		' TODO Реализовать для функции завершения ввода-вывода
		' lpRecvOverlapped->hEvent = pINewAsyncResult
		lpReceiveCompletionROUTINE = NULL
	End If
	
	Dim ReceiveBuffer As WSABUF = Any
	ReceiveBuffer.len = Cast(ULONG, Count)
	ReceiveBuffer.buf = Buffer
	
	IMutableAsyncResult_SetAsyncState(pINewAsyncResult, StateObject)
	IMutableAsyncResult_SetAsyncCallback(pINewAsyncResult, callback)
	
	Const MaxReceiveBuffersCount As Integer = 1
	Dim Flags As DWORD = 0
	
	Dim WSARecvResult As Long = WSARecv( _
		this->ClientSocket, _
		@ReceiveBuffer, _
		MaxReceiveBuffersCount, _
		NULL, _
		@Flags, _
		CPtr(WSAOVERLAPPED Ptr, lpRecvOverlapped), _
		lpReceiveCompletionROUTINE _
	)
	If WSARecvResult <> 0 Then
		
		Dim intError As Long = WSAGetLastError()
		If intError <> WSA_IO_PENDING Then
			IMutableAsyncResult_Release(pINewAsyncResult)
			Return HRESULT_FROM_WIN32(intError)
		End If
		
		IMutableAsyncResult_SetCompletedSynchronously(pINewAsyncResult, False)
		' TODO Запросить интерфейс вместо конвертирования указателя
		*ppIAsyncResult = CPtr(IAsyncResult Ptr, pINewAsyncResult)
		
		Return BASESTREAM_S_IO_PENDING
	End If
	
	IMutableAsyncResult_SetCompletedSynchronously(pINewAsyncResult, True)
	' TODO Запросить интерфейс вместо конвертирования указателя
	*ppIAsyncResult = CPtr(IAsyncResult Ptr, pINewAsyncResult)
	
	Return S_OK
	
End Function

Function NetworkStreamEndRead( _
		ByVal this As NetworkStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pReadedBytes As DWORD Ptr _
	)As HRESULT
	
	*pReadedBytes = 0
	
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
		
		Return HRESULT_FROM_WIN32(intError)
	End If
	
	*pReadedBytes = cbTransfer
	
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
	
	If this->ClientSocket <> INVALID_SOCKET Then
		CloseSocketConnection(this->ClientSocket)
	End If
	
	this->ClientSocket = ClientSocket
	
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

' Function StartRecvOverlapped( _
		' ByVal this As NetworkStream Ptr _
	' )As HRESULT
	
	' memset(@pIrcClient->RecvOverlapped, 0, SizeOf(WSAOVERLAPPED))
	' pIrcClient->RecvOverlapped.hEvent = pIrcClient
	' pIrcClient->RecvBuf(0).len = IRCPROTOCOL_BYTESPERMESSAGEMAXIMUM - pIrcClient->ClientRawBufferLength
	' pIrcClient->RecvBuf(0).buf = @pIrcClient->ClientRawBuffer[pIrcClient->ClientRawBufferLength]
	
	' Const lpNumberOfBytesRecvd As LPDWORD = NULL
	' Dim Flags As DWORD = 0
	
	' Dim WSARecvResult As Integer = WSARecv( _
		' pIrcClient->ClientSocket, _
		' @pIrcClient->RecvBuf(0), _
		' IrcClient.MaxReceivedBuffersCount, _
		' lpNumberOfBytesRecvd, _
		' @Flags, _
		' @pIrcClient->RecvOverlapped, _
		' @ReceiveCompletionROUTINE _
	' )
	
	' If WSARecvResult <> 0 Then
		
		' If WSAGetLastError() <> WSA_IO_PENDING Then
			' CloseIrcClient(pIrcClient)
			' Return E_FAIL
		' End If
		
	' End If
	
	' Return S_OK
	
' End Function


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

' Function INetworkStreamCanRead( _
		' ByVal this As INetworkStream Ptr, _
		' ByVal pResult As WINBOOLEAN Ptr _
	' )As HRESULT
	' Return NetworkStreamCanRead(ContainerOf(this, NetworkStream, lpVtbl), pResult)
' End Function

' Function INetworkStreamCanSeek( _
		' ByVal this As INetworkStream Ptr, _
		' ByVal pResult As WINBOOLEAN Ptr _
	' )As HRESULT
	' Return NetworkStreamCanSeek(ContainerOf(this, NetworkStream, lpVtbl), pResult)
' End Function

' Function INetworkStreamCanWrite( _
		' ByVal this As INetworkStream Ptr, _
		' ByVal pResult As WINBOOLEAN Ptr _
	' )As HRESULT
	' Return NetworkStreamCanWrite(ContainerOf(this, NetworkStream, lpVtbl), pResult)
' End Function

' Function INetworkStreamFlush( _
		' ByVal this As INetworkStream Ptr _
	' )As HRESULT
	' Return NetworkStreamFlush(ContainerOf(this, NetworkStream, lpVtbl))
' End Function

' Function INetworkStreamGetLength( _
		' ByVal this As INetworkStream Ptr, _
		' ByVal pResult As LARGE_INTEGER Ptr _
	' )As HRESULT
	' Return NetworkStreamGetLength(ContainerOf(this, NetworkStream, lpVtbl), pResult)
' End Function

' Function INetworkStreamPosition( _
		' ByVal this As INetworkStream Ptr, _
		' ByVal pResult As LARGE_INTEGER Ptr _
	' )As HRESULT
	' Return NetworkStreamPosition(ContainerOf(this, NetworkStream, lpVtbl), pResult)
' End Function

Function INetworkStreamRead( _
		ByVal this As INetworkStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal pReadedBytes As DWORD Ptr _
	)As HRESULT
	Return NetworkStreamRead(ContainerOf(this, NetworkStream, lpVtbl), Buffer, Count, pReadedBytes)
End Function

' Function INetworkStreamSeek( _
		' ByVal this As INetworkStream Ptr, _
		' ByVal Offset As LARGE_INTEGER, _
		' ByVal Origin As SeekOrigin _
	' )As HRESULT
	' Return NetworkStreamSeek(ContainerOf(this, NetworkStream, lpVtbl), Offset, Origin)
' End Function

' Function INetworkStreamSetLength( _
		' ByVal this As INetworkStream Ptr, _
		' ByVal Length As LARGE_INTEGER _
	' )As HRESULT
	' Return NetworkStreamSetLength(ContainerOf(this, NetworkStream, lpVtbl), Length)
' End Function

Function INetworkStreamWrite( _
		ByVal this As INetworkStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal pWritedBytes As DWORD Ptr _
	)As HRESULT
	Return NetworkStreamWrite(ContainerOf(this, NetworkStream, lpVtbl), Buffer, Count, pWritedBytes)
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

' Function INetworkStreamBeginWrite( _
		' ByVal this As INetworkStream Ptr, _
		' ByVal Buffer As LPVOID, _
		' ByVal Count As DWORD, _
		' ByVal callback As AsyncCallback, _
		' ByVal StateObject As IUnknown Ptr, _
		' ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	' )As HRESULT
' End Function

Function INetworkStreamEndRead( _
		ByVal this As INetworkStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pReadedBytes As DWORD Ptr _
	)As HRESULT
	Return NetworkStreamEndRead(ContainerOf(this, NetworkStream, lpVtbl), pIAsyncResult, pReadedBytes)
End Function

' Function INetworkStreamEndWrite( _
		' ByVal this As INetworkStream Ptr, _
		' ByVal pIAsyncResult As IAsyncResult Ptr, _
		' ByVal pWritedBytes As DWORD Ptr _
	' )As HRESULT
' End Function

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
	@INetworkStreamRead, _
	NULL, _ /' @INetworkStreamSeek, _ '/
	NULL, _ /' @INetworkStreamSetLength, _ '/
	@INetworkStreamWrite, _
	@INetworkStreamBeginRead, _
	NULL, _ /' INetworkStreamBeginWrite '/
	@INetworkStreamEndRead, _
	NULL, _ /' INetworkStreamEndWrite '/
	@INetworkStreamGetSocket, _
	@INetworkStreamSetSocket, _
	@INetworkStreamClose _
)
