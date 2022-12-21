#ifndef MEMORYSTREAM_BI
#define MEMORYSTREAM_BI

#include once "IMemoryStream.bi"

Const RTTI_ID_MEMORYSTREAM            = !"\001Memory__Stream\001"
Const RTTI_ID_MEMORYBODY        = !"\001Body____Buffer\001"

Extern CLSID_MEMORYSTREAM Alias "CLSID_MEMORYSTREAM" As Const CLSID

Type MemoryStream As _MemoryStream

Type LPMemoryStream As _MemoryStream Ptr

Declare Function CreateMemoryStream( _
	ByVal pIMemoryAllocator As IMalloc Ptr _
)As MemoryStream Ptr

Declare Sub DestroyMemoryStream( _
	ByVal this As MemoryStream Ptr _
)

Declare Function MemoryStreamQueryInterface( _
	ByVal this As MemoryStream Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function MemoryStreamAddRef( _
	ByVal this As MemoryStream Ptr _
)As ULONG

Declare Function MemoryStreamRelease( _
	ByVal this As MemoryStream Ptr _
)As ULONG

Declare Function MemoryStreamBeginGetSlice( _
	ByVal this As MemoryStream Ptr, _
	ByVal StartIndex As LongInt, _
	ByVal Length As DWORD, _
	ByVal StateObject As IUnknown Ptr, _
	ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
)As HRESULT

Declare Function MemoryStreamEndGetSlice( _
	ByVal this As MemoryStream Ptr, _
	ByVal pIAsyncResult As IAsyncResult Ptr, _
	ByVal pBufferSlice As BufferSlice Ptr _
)As HRESULT

Declare Function MemoryStreamGetContentType( _
	ByVal this As MemoryStream Ptr, _
	ByVal ppType As MimeType Ptr _
)As HRESULT

Declare Function MemoryStreamGetEncoding( _
	ByVal this As MemoryStream Ptr, _
	ByVal pZipMode As ZipModes Ptr _
)As HRESULT

Declare Function MemoryStreamGetLanguage( _
	ByVal this As MemoryStream Ptr, _
	ByVal ppLanguage As HeapBSTR Ptr _
)As HRESULT

Declare Function MemoryStreamGetETag( _
	ByVal this As MemoryStream Ptr, _
	ByVal ppETag As HeapBSTR Ptr _
)As HRESULT

Declare Function MemoryStreamGetLastFileModifiedDate( _
	ByVal this As MemoryStream Ptr, _
	ByVal ppDate As FILETIME Ptr _
)As HRESULT

Declare Function MemoryStreamGetLength( _
	ByVal this As MemoryStream Ptr, _
	ByVal pLength As LongInt Ptr _
)As HRESULT

Declare Function MemoryStreamSetContentType( _
	ByVal this As MemoryStream Ptr, _
	ByVal pType As MimeType Ptr _
)As HRESULT

Declare Function MemoryStreamAllocBuffer( _
	ByVal this As MemoryStream Ptr, _
	ByVal Length As LongInt, _
	ByVal ppBuffer As Any Ptr Ptr _
)As HRESULT

Declare Function MemoryStreamSetBuffer( _
	ByVal this As MemoryStream Ptr, _
	ByVal pBuffer As Any Ptr, _
	ByVal Length As LongInt _
)As HRESULT

#endif
