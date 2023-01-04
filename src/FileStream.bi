#ifndef FILESTREAM_BI
#define FILESTREAM_BI

#include once "IFileStream.bi"

Extern CLSID_FILESTREAM Alias "CLSID_FILESTREAM" As Const CLSID

Const RTTI_ID_FILESTREAM              = !"\001File____Stream\001"
Const RTTI_ID_FILEBYTES              = !"\001File_____Bytes\001"

Type FileStream As _FileStream

Type LPFileStream As _FileStream Ptr

Declare Function CreateFileStream( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Sub DestroyFileStream( _
	ByVal this As FileStream Ptr _
)

Declare Function FileStreamQueryInterface( _
	ByVal this As FileStream Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function FileStreamAddRef( _
	ByVal this As FileStream Ptr _
)As ULONG

Declare Function FileStreamRelease( _
	ByVal this As FileStream Ptr _
)As ULONG

Declare Function FileStreamBeginGetSlice( _
	ByVal this As FileStream Ptr, _
	ByVal StartIndex As LongInt, _
	ByVal Length As DWORD, _
	ByVal StateObject As IUnknown Ptr, _
	ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
)As HRESULT

Declare Function FileStreamEndGetSlice( _
	ByVal this As FileStream Ptr, _
	ByVal pIAsyncResult As IAsyncResult Ptr, _
	ByVal pBufferSlice As BufferSlice Ptr _
)As HRESULT

Declare Function FileStreamGetContentType( _
	ByVal this As FileStream Ptr, _
	ByVal ppType As MimeType Ptr _
)As HRESULT

Declare Function FileStreamGetEncoding( _
	ByVal this As FileStream Ptr, _
	ByVal pZipMode As ZipModes Ptr _
)As HRESULT

Declare Function FileStreamGetLanguage( _
	ByVal this As FileStream Ptr, _
	ByVal ppLanguage As HeapBSTR Ptr _
)As HRESULT

Declare Function FileStreamGetETag( _
	ByVal this As FileStream Ptr, _
	ByVal ppETag As HeapBSTR Ptr _
)As HRESULT

Declare Function FileStreamGetLastFileModifiedDate( _
	ByVal this As FileStream Ptr, _
	ByVal ppDate As FILETIME Ptr _
)As HRESULT

Declare Function FileStreamGetLength( _
	ByVal this As FileStream Ptr, _
	ByVal pLength As LongInt Ptr _
)As HRESULT

Declare Function FileStreamGetFilePath( _
	ByVal this As FileStream Ptr, _
	ByVal ppFilePath As HeapBSTR Ptr _
)As HRESULT

Declare Function FileStreamSetFilePath( _
	ByVal this As FileStream Ptr, _
	ByVal FilePath As HeapBSTR _
)As HRESULT

Declare Function FileStreamGetFileHandle( _
	ByVal this As FileStream Ptr, _
	ByVal pResult As HANDLE Ptr _
)As HRESULT

Declare Function FileStreamSetFileHandle( _
	ByVal this As FileStream Ptr, _
	ByVal hFile As HANDLE _
)As HRESULT

Declare Function FileStreamGetZipFileHandle( _
	ByVal this As FileStream Ptr, _
	ByVal pResult As HANDLE Ptr _
)As HRESULT

Declare Function FileStreamSetZipFileHandle( _
	ByVal this As FileStream Ptr, _
	ByVal hFile As HANDLE _
)As HRESULT

Declare Function FileStreamSetContentType( _
	ByVal this As FileStream Ptr, _
	ByVal pType As MimeType Ptr _
)As HRESULT

Declare Function FileStreamSetFileOffset( _
	ByVal this As FileStream Ptr, _
	ByVal Offset As LongInt _
)As HRESULT

Declare Function FileStreamSetFileSize( _
	ByVal this As FileStream Ptr, _
	ByVal FileSize As LongInt _
)As HRESULT

Declare Function FileStreamSetEncoding( _
	ByVal this As FileStream Ptr, _
	ByVal ZipMode As ZipModes _
)As HRESULT

Declare Function FileStreamSetFileTime( _
	ByVal this As FileStream Ptr, _
	ByVal pTime As FILETIME Ptr _
)As HRESULT

Declare Function FileStreamSetETag( _
	ByVal this As FileStream Ptr, _
	ByVal ETag As HeapBSTR _
)As HRESULT

#endif
