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

Declare Function FileBufferGetFilePath( _
	ByVal this As FileBuffer Ptr, _
	ByVal ppFilePath As WString Ptr Ptr _
)As HRESULT

Declare Function FileBufferSetFilePath( _
	ByVal this As FileBuffer Ptr, _
	ByVal FilePath As WString Ptr _
)As HRESULT

Declare Function FileBufferGetPathTranslated( _
	ByVal this As FileBuffer Ptr, _
	ByVal ppPathTranslated As WString Ptr Ptr _
)As HRESULT

Declare Function FileBufferSetPathTranslated( _
	ByVal this As FileBuffer Ptr, _
	ByVal PathTranslated As WString Ptr _
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

Declare Function FileBufferGetLastFileModifiedDate( _
	ByVal this As FileBuffer Ptr, _
	ByVal pResult As FILETIME Ptr _
)As HRESULT

Declare Function FileBufferGetFileLength( _
	ByVal this As FileBuffer Ptr, _
	ByVal pResult As ULongInt Ptr _
)As HRESULT

#endif
