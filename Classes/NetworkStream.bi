#ifndef NETWORKSTREAM_BI
#define NETWORKSTREAM_BI

#include "INetworkStream.bi"

Extern CLSID_NETWORKSTREAM Alias "CLSID_NETWORKSTREAM" As Const CLSID

Type NetworkStream As _NetworkStream

Type LPNetworkStream As _NetworkStream Ptr

Declare Sub InitializeNetworkStreamVirtualTable()

Declare Function CreateNetworkStream( _
	ByVal hHeap As HANDLE _
)As NetworkStream Ptr

Declare Sub DestroyNetworkStream( _
	ByVal this As NetworkStream Ptr _
)

Declare Function NetworkStreamQueryInterface( _
	ByVal this As NetworkStream Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function NetworkStreamAddRef( _
	ByVal this As NetworkStream Ptr _
)As ULONG

Declare Function NetworkStreamRelease( _
	ByVal this As NetworkStream Ptr _
)As ULONG

Declare Function NetworkStreamCanRead( _
	ByVal this As NetworkStream Ptr, _
	ByVal pResult As Boolean Ptr _
)As HRESULT

Declare Function NetworkStreamCanSeek( _
	ByVal this As NetworkStream Ptr, _
	ByVal pResult As Boolean Ptr _
)As HRESULT

Declare Function NetworkStreamCanWrite( _
	ByVal this As NetworkStream Ptr, _
	ByVal pResult As Boolean Ptr _
)As HRESULT

Declare Function NetworkStreamFlush( _
	ByVal this As NetworkStream Ptr _
)As HRESULT

Declare Function NetworkStreamGetLength( _
	ByVal this As NetworkStream Ptr, _
	ByVal pResult As LongInt Ptr _
)As HRESULT

Declare Function NetworkStreamPosition( _
	ByVal this As NetworkStream Ptr, _
	ByVal pResult As LongInt Ptr _
)As HRESULT

Declare Function NetworkStreamRead( _
	ByVal this As NetworkStream Ptr, _
	ByVal buffer As UByte Ptr, _
	ByVal offset As Integer, _
	ByVal Count As Integer, _
	ByVal pReadedBytes As LongInt Ptr _
)As HRESULT

Declare Function NetworkStreamSeek( _
	ByVal this As NetworkStream Ptr, _
	ByVal offset As LongInt, _
	ByVal origin As SeekOrigin _
)As HRESULT

Declare Function NetworkStreamSetLength( _
	ByVal this As NetworkStream Ptr, _
	ByVal length As LongInt _
)As HRESULT

Declare Function NetworkStreamWrite( _
	ByVal this As NetworkStream Ptr, _
	ByVal buffer As UByte Ptr, _
	ByVal offset As Integer, _
	ByVal Count As Integer, _
	ByVal pWritedBytes As Integer Ptr _
)As HRESULT

Declare Function NetworkStreamGetSocket( _
	ByVal this As NetworkStream Ptr, _
	ByVal pResult As SOCKET Ptr _
)As HRESULT
	
Declare Function NetworkStreamSetSocket( _
	ByVal this As NetworkStream Ptr, _
	ByVal sock As SOCKET _
)As HRESULT

#endif
