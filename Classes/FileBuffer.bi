#ifndef FILEBUFFER_BI
#define FILEBUFFER_BI

#include once "IFileBuffer.bi"

Extern CLSID_FILEBUFFER Alias "CLSID_FILEBUFFER" As Const CLSID

Type FileBuffer As _FileBuffer

Type LPFileBuffer As _FileBuffer Ptr

Declare Function CreateFileBuffer( _
	ByVal pIMemoryAllocator As IMalloc Ptr _
)As FileBuffer Ptr

Declare Sub DestroyFileBuffer( _
	ByVal this As FileBuffer Ptr _
)

Declare Function FileBufferQueryInterface( _
	ByVal this As FileBuffer Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function FileBufferAddRef( _
	ByVal this As FileBuffer Ptr _
)As ULONG

Declare Function FileBufferRelease( _
	ByVal this As FileBuffer Ptr _
)As ULONG

Declare Function FileBufferGetContentType( _
	ByVal this As FileBuffer Ptr, _
	ByVal ppType As MimeType Ptr _
)As HRESULT

Declare Function FileBufferGetEncoding( _
	ByVal this As FileBuffer Ptr, _
	ByVal ppEncoding As HeapBSTR Ptr _
)As HRESULT

Declare Function FileBufferGetCharset( _
	ByVal this As FileBuffer Ptr, _
	ByVal ppCharset As HeapBSTR Ptr _
)As HRESULT

Declare Function FileBufferGetLanguage( _
	ByVal this As FileBuffer Ptr, _
	ByVal ppLanguage As HeapBSTR Ptr _
)As HRESULT

Declare Function FileBufferGetETag( _
	ByVal this As FileBuffer Ptr, _
	ByVal ppETag As HeapBSTR Ptr _
)As HRESULT

Declare Function FileBufferGetLastFileModifiedDate( _
	ByVal this As FileBuffer Ptr, _
	ByVal ppDate As FILETIME Ptr _
)As HRESULT

Declare Function FileBufferGetCapacity( _
	ByVal this As FileBuffer Ptr, _
	ByVal pCapacity As LongInt Ptr _
)As HRESULT

Declare Function FileBufferGetLength( _
	ByVal this As FileBuffer Ptr, _
	ByVal pLength As LongInt Ptr _
)As HRESULT

Declare Function FileBufferGetSlice( _
	ByVal this As FileBuffer Ptr, _
	ByVal StartIndex As LongInt, _
	ByVal Length As DWORD, _
	ByVal pBufferSlice As BufferSlice Ptr _
)As HRESULT

Declare Function FileBufferGetFilePath( _
	ByVal this As FileBuffer Ptr, _
	ByVal ppFilePath As HeapBSTR Ptr _
)As HRESULT

Declare Function FileBufferSetFilePath( _
	ByVal this As FileBuffer Ptr, _
	ByVal FilePath As HeapBSTR _
)As HRESULT

Declare Function FileBufferGetPathTranslated( _
	ByVal this As FileBuffer Ptr, _
	ByVal ppPathTranslated As HeapBSTR Ptr _
)As HRESULT

Declare Function FileBufferSetPathTranslated( _
	ByVal this As FileBuffer Ptr, _
	ByVal PathTranslated As HeapBSTR _
)As HRESULT

Declare Function FileBufferFileExists( _
	ByVal this As FileBuffer Ptr, _
	ByVal pResult As RequestedFileState Ptr _
)As HRESULT

Declare Function FileBufferGetFileHandle( _
	ByVal this As FileBuffer Ptr, _
	ByVal pResult As HANDLE Ptr _
)As HRESULT

Declare Function FileBufferSetFileHandle( _
	ByVal this As FileBuffer Ptr, _
	ByVal hFile As HANDLE _
)As HRESULT

Declare Function FileBufferGetFileLength( _
	ByVal this As FileBuffer Ptr, _
	ByVal pResult As ULongInt Ptr _
)As HRESULT

#endif
