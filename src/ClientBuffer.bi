#ifndef CLIENTBUFFER_BI
#define CLIENTBUFFER_BI

#include once "IString.bi"

Const RTTI_ID_CLIENTREQUESTBUFFER        = !"\001Request_Buffer\001"

Const MEMORYPAGE_SIZE As Integer = 4096
Const SOCKET_ADDRESS_STORAGE_LENGTH As Integer = 128

#if __FB_DEBUG__
Const RAWBUFFER_MEMORYPAGE_COUNT As Integer = 2
#else
Const RAWBUFFER_MEMORYPAGE_COUNT As Integer = 4
#endif

#if __FB_DEBUG__
Const RAWBUFFER_CAPACITY As Integer = (RAWBUFFER_MEMORYPAGE_COUNT * MEMORYPAGE_SIZE) - (8 * SizeOf(Integer)) - 2 * SOCKET_ADDRESS_STORAGE_LENGTH - SizeOf(ZString) * 16
#else
Const RAWBUFFER_CAPACITY As Integer = (RAWBUFFER_MEMORYPAGE_COUNT * MEMORYPAGE_SIZE) - (8 * SizeOf(Integer)) - 2 * SOCKET_ADDRESS_STORAGE_LENGTH
#endif

Type ClientRequestBuffer
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	cbLength As Integer
	EndOfHeaders As Integer
	StartLine As Integer
	LocalAddressLength As Integer
	RemoteAddressLength As Integer
	Padding6 As Integer
	Padding7 As Integer
	Padding8 As Integer
	Bytes(0 To RAWBUFFER_CAPACITY - 1) As UByte
	LocalAddress As ZString * SOCKET_ADDRESS_STORAGE_LENGTH
	RemoteAddress As ZString * SOCKET_ADDRESS_STORAGE_LENGTH
End Type

Declare Sub InitializeClientRequestBuffer( _
	ByVal this As ClientRequestBuffer Ptr _
)

Declare Function ClientRequestBufferGetFreeSpaceLength( _
	ByVal this As ClientRequestBuffer Ptr _
)As Integer

Declare Function ClientRequestBufferFindDoubleCrLfIndexA( _
	ByVal this As ClientRequestBuffer Ptr, _
	ByVal pFindIndex As Integer Ptr _
)As Boolean

Declare Function ClientRequestBufferFindCrLfIndexA( _
	ByVal this As ClientRequestBuffer Ptr, _
	ByVal pFindIndex As Integer Ptr _
)As Boolean

Declare Function ClientRequestBufferGetLine( _
	ByVal this As ClientRequestBuffer Ptr, _
	ByVal pIMemoryAllocator As IMalloc Ptr _
)As HeapBSTR

#endif
