#ifndef MEMORYBUFFER_BI
#define MEMORYBUFFER_BI

#include once "IMemoryBuffer.bi"

Extern CLSID_MEMORYBUFFER Alias "CLSID_MEMORYBUFFER" As Const CLSID

Type MemoryBuffer As _MemoryBuffer

Type LPMemoryBuffer As _MemoryBuffer Ptr

Declare Function CreateMemoryBuffer( _
	ByVal pIMemoryAllocator As IMalloc Ptr _
)As MemoryBuffer Ptr

Declare Sub DestroyMemoryBuffer( _
	ByVal this As MemoryBuffer Ptr _
)

Declare Function MemoryBufferQueryInterface( _
	ByVal this As MemoryBuffer Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function MemoryBufferAddRef( _
	ByVal this As MemoryBuffer Ptr _
)As ULONG

Declare Function MemoryBufferRelease( _
	ByVal this As MemoryBuffer Ptr _
)As ULONG

Declare Function MemoryBufferGetContentType( _
	ByVal this As MemoryBuffer Ptr, _
	ByVal ppType As MimeType Ptr _
)As HRESULT

Declare Function MemoryBufferGetEncoding( _
	ByVal this As MemoryBuffer Ptr, _
	ByVal pZipMode As ZipModes Ptr _
)As HRESULT

Declare Function MemoryBufferGetCharset( _
	ByVal this As MemoryBuffer Ptr, _
	ByVal ppCharset As HeapBSTR Ptr _
)As HRESULT

Declare Function MemoryBufferGetLanguage( _
	ByVal this As MemoryBuffer Ptr, _
	ByVal ppLanguage As HeapBSTR Ptr _
)As HRESULT

Declare Function MemoryBufferGetETag( _
	ByVal this As MemoryBuffer Ptr, _
	ByVal ppETag As HeapBSTR Ptr _
)As HRESULT

Declare Function MemoryBufferGetLastFileModifiedDate( _
	ByVal this As MemoryBuffer Ptr, _
	ByVal ppDate As FILETIME Ptr _
)As HRESULT

Declare Function MemoryBufferGetLength( _
	ByVal this As MemoryBuffer Ptr, _
	ByVal pLength As LongInt Ptr _
)As HRESULT

Declare Function MemoryBufferGetSlice( _
	ByVal this As MemoryBuffer Ptr, _
	ByVal StartIndex As LongInt, _
	ByVal Length As DWORD, _
	ByVal pBufferSlice As BufferSlice Ptr _
)As HRESULT

Declare Function MemoryBufferSetContentType( _
	ByVal this As MemoryBuffer Ptr, _
	ByVal pType As MimeType Ptr _
)As HRESULT

Declare Function MemoryBufferAllocBuffer( _
	ByVal this As MemoryBuffer Ptr, _
	ByVal Length As LongInt, _
	ByVal ppBuffer As Any Ptr Ptr _
)As HRESULT

#endif
