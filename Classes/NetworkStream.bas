#include "NetworkStream.bi"
#include "Network.bi"

Extern IID_IUnknown_WithoutMinGW As Const IID

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
		ByVal pStream As NetworkStream Ptr _
	)
	
	pStream->pVirtualTable = @GlobalNetworkStreamVirtualTable
	pStream->ReferenceCounter = 0
	pStream->m_Socket = INVALID_SOCKET
	
End Sub

Function InitializeNetworkStreamOfINetworkStream( _
		ByVal pStream As NetworkStream Ptr _
	)As INetworkStream Ptr
	
	InitializeNetworkStream(pStream)
	pStream->ExistsInStack = True
	
	Dim pINetworkStream As INetworkStream Ptr = Any
	
	NetworkStreamQueryInterface( _
		pStream, @IID_INetworkStream, @pINetworkStream _
	)
	
	Return pINetworkStream
	
End Function

Function NetworkStreamQueryInterface( _
		ByVal pNetworkStream As NetworkStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_INetworkStream, riid) Then
		*ppv = @pNetworkStream->pVirtualTable
	Else
		If IsEqualIID(@IID_IBaseStream, riid) Then
			*ppv = @pNetworkStream->pVirtualTable
		Else
			If IsEqualIID(@IID_IUnknown_WithoutMinGW, riid) Then
				*ppv = @pNetworkStream->pVirtualTable
			Else
				*ppv = NULL
				Return E_NOINTERFACE
			End If
		End If
	End If
	
	NetworkStreamAddRef(pNetworkStream)
	
	Return S_OK
	
End Function

Function NetworkStreamAddRef( _
		ByVal pNetworkStream As NetworkStream Ptr _
	)As ULONG
	
	pNetworkStream->ReferenceCounter += 1
	
	Return pNetworkStream->ReferenceCounter
	
End Function

Function NetworkStreamRelease( _
		ByVal pNetworkStream As NetworkStream Ptr _
	)As ULONG
	
	pNetworkStream->ReferenceCounter -= 1
	
	If pNetworkStream->ReferenceCounter = 0 Then
		
		CloseSocketConnection(pNetworkStream->m_Socket)
		
		If pNetworkStream->ExistsInStack = False Then
		
		End If
		
		Return 0
	End If
	
	Return pNetworkStream->ReferenceCounter
	
End Function

Function NetworkStreamCanRead( _
		ByVal pNetworkStream As NetworkStream Ptr, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
	*pResult = True
	
	Return S_OK
	
End Function

Function NetworkStreamCanSeek( _
		ByVal pNetworkStream As NetworkStream Ptr, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
	*pResult = False
	
	Return S_OK
	
End Function

Function NetworkStreamCanWrite( _
		ByVal pNetworkStream As NetworkStream Ptr, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
	*pResult = True
	
	Return S_OK
	
End Function

Function NetworkStreamFlush( _
		ByVal pNetworkStream As NetworkStream Ptr _
	)As HRESULT
	
	Return S_OK
	
End Function

Function NetworkStreamGetLength( _
		ByVal pNetworkStream As NetworkStream Ptr, _
		ByVal pResult As LongInt Ptr _
	)As HRESULT
	
	*pResult = 0
	
	Return S_FALSE
	
End Function

Function NetworkStreamPosition( _
		ByVal pNetworkStream As NetworkStream Ptr, _
		ByVal pResult As LongInt Ptr _
	)As HRESULT
	
	*pResult = 0
	
	Return S_FALSE
	
End Function

Function StartRecvOverlapped( _
		ByVal pNetworkStream As NetworkStream Ptr _
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
		ByVal pNetworkStream As NetworkStream Ptr, _
		ByVal buffer As UByte Ptr, _
		ByVal offset As Integer, _
		ByVal Count As Integer, _
		ByVal pReadedBytes As LongInt Ptr _
	)As HRESULT
	
	Dim ReadedBytes As Integer = recv(pNetworkStream->m_Socket, @buffer[offset], Count, 0)
	
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
		ByVal pNetworkStream As NetworkStream Ptr, _
		ByVal Buffer As UByte Ptr, _
		ByVal Offset As Integer, _
		ByVal Count As Integer, _
		ByVal pWritedBytes As Integer Ptr _
	)As HRESULT
	
	Dim WritedBytes As Integer = send(pNetworkStream->m_Socket, @Buffer[Offset], Count - Offset, 0)
	
	If WritedBytes = SOCKET_ERROR Then	
		Dim intError As Integer = WSAGetLastError()
		*pWritedBytes = 0
		Return HRESULT_FROM_WIN32(intError)
	End If
	
	*pWritedBytes = WritedBytes
	
	Return S_OK
	
End Function

Function NetworkStreamSeek( _
		ByVal pNetworkStream As NetworkStream Ptr, _
		ByVal offset As LongInt, _
		ByVal origin As SeekOrigin _
	)As HRESULT
	
	Return S_FALSE
	
End Function

Function NetworkStreamSetLength( _
		ByVal pNetworkStream As NetworkStream Ptr, _
		ByVal length As LongInt _
	)As HRESULT
	
	Return S_FALSE
	
End Function

Function NetworkStreamGetSocket( _
		ByVal pNetworkStream As NetworkStream Ptr, _
		ByVal pResult As SOCKET Ptr _
	)As HRESULT
	
	*pResult = pNetworkStream->m_Socket
	
	Return S_OK
	
End Function
	
Function NetworkStreamSetSocket( _
		ByVal pNetworkStream As NetworkStream Ptr, _
		ByVal sock As SOCKET _
	)As HRESULT
	
	pNetworkStream->m_Socket = sock
	
	Return S_OK
	
End Function
