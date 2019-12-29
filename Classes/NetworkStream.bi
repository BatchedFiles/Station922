#ifndef NETWORKSTREAM_BI
#define NETWORKSTREAM_BI

#include "INetworkStream.bi"

Extern CLSID_NETWORKSTREAM Alias "CLSID_NETWORKSTREAM" As Const CLSID

Type NetworkStream
	Dim pVirtualTable As INetworkStreamVirtualTable Ptr
	Dim ReferenceCounter As ULONG
	Dim ExistsInStack As Boolean
	
	Dim m_Socket As SOCKET
	
End Type

Declare Sub InitializeNetworkStreamVirtualTable()

Declare Function InitializeNetworkStreamOfINetworkStream( _
	ByVal pNetworkStream As NetworkStream Ptr _
)As INetworkStream Ptr

Declare Function NetworkStreamQueryInterface( _
	ByVal pNetworkStream As NetworkStream Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function NetworkStreamAddRef( _
	ByVal pNetworkStream As NetworkStream Ptr _
)As ULONG

Declare Function NetworkStreamRelease( _
	ByVal pNetworkStream As NetworkStream Ptr _
)As ULONG

Declare Function NetworkStreamCanRead( _
	ByVal pNetworkStream As NetworkStream Ptr, _
	ByVal pResult As Boolean Ptr _
)As HRESULT

Declare Function NetworkStreamCanSeek( _
	ByVal pNetworkStream As NetworkStream Ptr, _
	ByVal pResult As Boolean Ptr _
)As HRESULT

Declare Function NetworkStreamCanWrite( _
	ByVal pNetworkStream As NetworkStream Ptr, _
	ByVal pResult As Boolean Ptr _
)As HRESULT

Declare Function NetworkStreamFlush( _
	ByVal pNetworkStream As NetworkStream Ptr _
)As HRESULT

Declare Function NetworkStreamGetLength( _
	ByVal pNetworkStream As NetworkStream Ptr, _
	ByVal pResult As LongInt Ptr _
)As HRESULT

Declare Function NetworkStreamPosition( _
	ByVal pNetworkStream As NetworkStream Ptr, _
	ByVal pResult As LongInt Ptr _
)As HRESULT

Declare Function NetworkStreamRead( _
	ByVal pNetworkStream As NetworkStream Ptr, _
	ByVal buffer As UByte Ptr, _
	ByVal offset As Integer, _
	ByVal Count As Integer, _
	ByVal pReadedBytes As LongInt Ptr _
)As HRESULT

Declare Function NetworkStreamSeek( _
	ByVal pNetworkStream As NetworkStream Ptr, _
	ByVal offset As LongInt, _
	ByVal origin As SeekOrigin _
)As HRESULT

Declare Function NetworkStreamSetLength( _
	ByVal pNetworkStream As NetworkStream Ptr, _
	ByVal length As LongInt _
)As HRESULT

Declare Function NetworkStreamWrite( _
	ByVal pNetworkStream As NetworkStream Ptr, _
	ByVal buffer As UByte Ptr, _
	ByVal offset As Integer, _
	ByVal Count As Integer, _
	ByVal pWritedBytes As Integer Ptr _
)As HRESULT

Declare Function NetworkStreamGetSocket( _
	ByVal pNetworkStream As NetworkStream Ptr, _
	ByVal pResult As SOCKET Ptr _
)As HRESULT
	
Declare Function NetworkStreamSetSocket( _
	ByVal pNetworkStream As NetworkStream Ptr, _
	ByVal sock As SOCKET _
)As HRESULT

#define NetworkStream_NonVirtualQueryInterface(pINetworkStream, riid, ppv) NetworkStreamQueryInterface(CPtr(NetworkStream Ptr, pINetworkStream), riid, ppv)
#define NetworkStream_NonVirtualAddRef(pINetworkStream) NetworkStreamAddRef(CPtr(NetworkStream Ptr, pINetworkStream))
#define NetworkStream_NonVirtualRelease(pINetworkStream) NetworkStreamRelease(CPtr(NetworkStream Ptr, pINetworkStream))
#define NetworkStream_NonVirtualCanRead(pINetworkStream, pResult) NetworkStreamCanRead(CPtr(NetworkStream Ptr, pINetworkStream), pResult)
#define NetworkStream_NonVirtualCanSeek(pINetworkStream, pResult) NetworkStreamCanSeek(CPtr(NetworkStream Ptr, pINetworkStream), pResult)
#define NetworkStream_NonVirtualCanWrite(pINetworkStream, pResult) NetworkStreamCanWrite(CPtr(NetworkStream Ptr, pINetworkStream), pResult)
#define NetworkStream_NonVirtualCloseStream(pINetworkStream) NetworkStreamCloseStream(CPtr(NetworkStream Ptr, pINetworkStream))
#define NetworkStream_NonVirtualFlush(pINetworkStream) NetworkStreamFlush(CPtr(NetworkStream Ptr, pINetworkStream))
#define NetworkStream_NonVirtualGetLength(pINetworkStream, pResult) NetworkStreamGetLength(CPtr(NetworkStream Ptr, pINetworkStream), pResult)
#define NetworkStream_NonVirtualOpenStream(pINetworkStream) NetworkStreamOpenStream(CPtr(NetworkStream Ptr, pINetworkStream))
#define NetworkStream_NonVirtualPosition(pINetworkStream, pResult) NetworkStreamPosition(CPtr(NetworkStream Ptr, pINetworkStream), pResult)
#define NetworkStream_NonVirtualRead(pINetworkStream, Buffer, Offset, Count, pReadedBytes) NetworkStreamRead(CPtr(NetworkStream Ptr, pINetworkStream), Buffer, Offset, Count, pReadedBytes)
#define NetworkStream_NonVirtualSeek(pINetworkStream, Offset, Origin) NetworkStreamSeek(CPtr(NetworkStream Ptr, pINetworkStream), Offset, Origin)
#define NetworkStream_NonVirtualSetLength(pINetworkStream, Length) NetworkStreamSetLength(CPtr(NetworkStream Ptr, pINetworkStream), Length)
#define NetworkStream_NonVirtualWrite(pINetworkStream, Buffer, Offset, Count, pWritedBytes) NetworkStreamWrite(CPtr(NetworkStream Ptr, pINetworkStream), Buffer, Offset, Count, pWritedBytes)
#define NetworkStream_NonVirtualGetSocket(pINetworkStream, pResult) NetworkStreamGetSocket(CPtr(NetworkStream Ptr, pINetworkStream), pResult)
#define NetworkStream_NonVirtualSetSocket(pINetworkStream, sock) NetworkStreamSetSocket(CPtr(NetworkStream Ptr, pINetworkStream), sock)

#endif
