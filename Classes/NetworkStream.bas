#include "NetworkStream.bi"
#include "Network.bi"

Dim Shared GlobalNetworkStreamVirtualTable As INetworkStreamVirtualTable

Sub InitializeNetworkStreamVirtualTable()
	GlobalNetworkStreamVirtualTable.InheritedTable.InheritedTable.QueryInterface = Cast(Any Ptr, @NetworkStreamQueryInterface)
	GlobalNetworkStreamVirtualTable.InheritedTable.InheritedTable.AddRef = Cast(Any Ptr, @NetworkStreamAddRef)
	GlobalNetworkStreamVirtualTable.InheritedTable.InheritedTable.Release = Cast(Any Ptr, @NetworkStreamRelease)
	GlobalNetworkStreamVirtualTable.InheritedTable.CanRead = Cast(Any Ptr, @NetworkStreamCanRead)
	GlobalNetworkStreamVirtualTable.InheritedTable.CanSeek = Cast(Any Ptr, @NetworkStreamCanSeek)
	GlobalNetworkStreamVirtualTable.InheritedTable.CanWrite = Cast(Any Ptr, @NetworkStreamCanWrite)
	GlobalNetworkStreamVirtualTable.InheritedTable.Flush = Cast(Any Ptr, @NetworkStreamFlush)
	GlobalNetworkStreamVirtualTable.InheritedTable.GetLength = Cast(Any Ptr, @NetworkStreamGetLength)
	GlobalNetworkStreamVirtualTable.InheritedTable.Position = Cast(Any Ptr, @NetworkStreamPosition)
	GlobalNetworkStreamVirtualTable.InheritedTable.Read = Cast(Any Ptr, @NetworkStreamRead)
	GlobalNetworkStreamVirtualTable.InheritedTable.Seek = Cast(Any Ptr, @NetworkStreamSeek)
	GlobalNetworkStreamVirtualTable.InheritedTable.SetLength = Cast(Any Ptr, @NetworkStreamSetLength)
	GlobalNetworkStreamVirtualTable.InheritedTable.Write = Cast(Any Ptr, @NetworkStreamWrite)
	GlobalNetworkStreamVirtualTable.GetSocket = Cast(Any Ptr, @NetworkStreamGetSocket)
	GlobalNetworkStreamVirtualTable.SetSocket = Cast(Any Ptr, @NetworkStreamSetSocket)
End Sub

Sub InitializeNetworkStream( _
		ByVal this As NetworkStream Ptr _
	)
	
	this->pVirtualTable = @GlobalNetworkStreamVirtualTable
	this->ReferenceCounter = 0
	this->m_Socket = INVALID_SOCKET
	
End Sub

Sub UnInitializeNetworkStream( _
		ByVal this As NetworkStream Ptr _
	)
	
	If this->m_Socket <> INVALID_SOCKET Then
		CloseSocketConnection(this->m_Socket)
	End If
	
End Sub

Function CreateNetworkStream( _
	)As NetworkStream Ptr
	
	Dim this As NetworkStream Ptr = HeapAlloc( _
		GetProcessHeap(), _
		0, _
		SizeOf(NetworkStream) _
	)
	
	If this = NULL Then
		Return NULL
	End If
	
	InitializeNetworkStream(this)
	
	Return this
	
End Function

Sub DestroyNetworkStream( _
		ByVal this As NetworkStream Ptr _
	)
	
	UnInitializeNetworkStream(this)
	
	HeapFree(GetProcessHeap(), 0, this)
	
End Sub

Function NetworkStreamQueryInterface( _
		ByVal this As NetworkStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_INetworkStream, riid) Then
		*ppv = @this->pVirtualTable
	Else
		If IsEqualIID(@IID_IBaseStream, riid) Then
			*ppv = @this->pVirtualTable
		Else
			If IsEqualIID(@IID_IUnknown, riid) Then
				*ppv = @this->pVirtualTable
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
	
	Return this->ReferenceCounter
	
End Function

Function NetworkStreamRelease( _
		ByVal this As NetworkStream Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter = 0 Then
		
		DestroyNetworkStream(this)
		
		Return 0
	End If
	
	Return this->ReferenceCounter
	
End Function

Function NetworkStreamCanRead( _
		ByVal this As NetworkStream Ptr, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
	*pResult = True
	
	Return S_OK
	
End Function

Function NetworkStreamCanSeek( _
		ByVal this As NetworkStream Ptr, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
	*pResult = False
	
	Return S_OK
	
End Function

Function NetworkStreamCanWrite( _
		ByVal this As NetworkStream Ptr, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
	*pResult = True
	
	Return S_OK
	
End Function

Function NetworkStreamFlush( _
		ByVal this As NetworkStream Ptr _
	)As HRESULT
	
	Return S_OK
	
End Function

Function NetworkStreamGetLength( _
		ByVal this As NetworkStream Ptr, _
		ByVal pResult As LongInt Ptr _
	)As HRESULT
	
	*pResult = 0
	
	Return S_FALSE
	
End Function

Function NetworkStreamPosition( _
		ByVal this As NetworkStream Ptr, _
		ByVal pResult As LongInt Ptr _
	)As HRESULT
	
	*pResult = 0
	
	Return S_FALSE
	
End Function

Function StartRecvOverlapped( _
		ByVal this As NetworkStream Ptr _
	)As HRESULT
	
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
	
	Return S_OK
	
End Function

Function NetworkStreamRead( _
		ByVal this As NetworkStream Ptr, _
		ByVal buffer As UByte Ptr, _
		ByVal offset As Integer, _
		ByVal Count As Integer, _
		ByVal pReadedBytes As LongInt Ptr _
	)As HRESULT
	
	Dim ReadedBytes As Integer = recv(this->m_Socket, @buffer[offset], Count, 0)
	
	Select Case ReadedBytes
		
		Case SOCKET_ERROR
			Dim intError As Integer = WSAGetLastError()
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
		ByVal Buffer As UByte Ptr, _
		ByVal Offset As Integer, _
		ByVal Count As Integer, _
		ByVal pWritedBytes As Integer Ptr _
	)As HRESULT
	
	Dim WritedBytes As Integer = send(this->m_Socket, @Buffer[Offset], Count - Offset, 0)
	
	If WritedBytes = SOCKET_ERROR Then	
		Dim intError As Integer = WSAGetLastError()
		*pWritedBytes = 0
		Return HRESULT_FROM_WIN32(intError)
	End If
	
	*pWritedBytes = WritedBytes
	
	Return S_OK
	
End Function

Function NetworkStreamSeek( _
		ByVal this As NetworkStream Ptr, _
		ByVal offset As LongInt, _
		ByVal origin As SeekOrigin _
	)As HRESULT
	
	Return S_FALSE
	
End Function

Function NetworkStreamSetLength( _
		ByVal this As NetworkStream Ptr, _
		ByVal length As LongInt _
	)As HRESULT
	
	Return S_FALSE
	
End Function

Function NetworkStreamGetSocket( _
		ByVal this As NetworkStream Ptr, _
		ByVal pResult As SOCKET Ptr _
	)As HRESULT
	
	*pResult = this->m_Socket
	
	Return S_OK
	
End Function
	
Function NetworkStreamSetSocket( _
		ByVal this As NetworkStream Ptr, _
		ByVal sock As SOCKET _
	)As HRESULT
	
	If this->m_Socket <> INVALID_SOCKET Then
		CloseSocketConnection(this->m_Socket)
	End If
	
	this->m_Socket = sock
	
	Return S_OK
	
End Function
