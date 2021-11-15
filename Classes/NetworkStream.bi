#ifndef NETWORKSTREAM_BI
#define NETWORKSTREAM_BI

#include once "INetworkStream.bi"

Extern CLSID_NETWORKSTREAM Alias "CLSID_NETWORKSTREAM" As Const CLSID

Type NetworkStream As _NetworkStream

Type LPNetworkStream As _NetworkStream Ptr

Declare Function CreateNetworkStream( _
	ByVal pIMemoryAllocator As IMalloc Ptr _
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
	ByVal pResult As WINBOOLEAN Ptr _
)As HRESULT

Declare Function NetworkStreamCanSeek( _
	ByVal this As NetworkStream Ptr, _
	ByVal pResult As WINBOOLEAN Ptr _
)As HRESULT

Declare Function NetworkStreamCanWrite( _
	ByVal this As NetworkStream Ptr, _
	ByVal pResult As WINBOOLEAN Ptr _
)As HRESULT

Declare Function NetworkStreamFlush( _
	ByVal this As NetworkStream Ptr _
)As HRESULT

Declare Function NetworkStreamGetLength( _
	ByVal this As NetworkStream Ptr, _
	ByVal pResult As LARGE_INTEGER Ptr _
)As HRESULT

Declare Function NetworkStreamPosition( _
	ByVal this As NetworkStream Ptr, _
	ByVal pResult As LARGE_INTEGER Ptr _
)As HRESULT

Declare Function NetworkStreamRead( _
	ByVal this As NetworkStream Ptr, _
	ByVal buffer As LPVOID, _
	ByVal Count As DWORD, _
	ByVal pReadedBytes As DWORD Ptr _
)As HRESULT

Declare Function NetworkStreamSeek( _
	ByVal this As NetworkStream Ptr, _
	ByVal offset As LARGE_INTEGER, _
	ByVal origin As SeekOrigin _
)As HRESULT

Declare Function NetworkStreamSetLength( _
	ByVal this As NetworkStream Ptr, _
	ByVal length As LARGE_INTEGER _
)As HRESULT

Declare Function NetworkStreamWrite( _
	ByVal this As NetworkStream Ptr, _
	ByVal buffer As LPVOID, _
	ByVal Count As DWORD, _
	ByVal pWritedBytes As DWORD Ptr _
)As HRESULT

Declare Function NetworkStreamBeginRead( _
	ByVal this As NetworkStream Ptr, _
	ByVal Buffer As LPVOID, _
	ByVal Count As DWORD, _
	ByVal callback As AsyncCallback, _
	ByVal StateObject As IUnknown Ptr, _
	ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
)As HRESULT

Declare Function NetworkStreamBeginWrite( _
	ByVal this As NetworkStream Ptr, _
	ByVal Buffer As LPVOID, _
	ByVal Count As DWORD, _
	ByVal callback As AsyncCallback, _
	ByVal StateObject As IUnknown Ptr, _
	ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
)As HRESULT

Declare Function NetworkStreamEndRead( _
	ByVal this As NetworkStream Ptr, _
	ByVal pIAsyncResult As IAsyncResult Ptr, _
	ByVal pReadedBytes As DWORD Ptr _
)As HRESULT

Declare Function NetworkStreamEndWrite( _
	ByVal this As NetworkStream Ptr, _
	ByVal pIAsyncResult As IAsyncResult Ptr, _
	ByVal pWritedBytes As DWORD Ptr _
)As HRESULT

Declare Function NetworkStreamGetSocket( _
	ByVal this As NetworkStream Ptr, _
	ByVal pResult As SOCKET Ptr _
)As HRESULT
	
Declare Function NetworkStreamSetSocket( _
	ByVal this As NetworkStream Ptr, _
	ByVal sock As SOCKET _
)As HRESULT

Declare Function NetworkStreamClose( _
	ByVal this As NetworkStream Ptr _
)As HRESULT

#endif
