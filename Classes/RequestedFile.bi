#ifndef REQUESTEDFILE_BI
#define REQUESTEDFILE_BI

#include once "IRequestedFile.bi"

Extern CLSID_REQUESTEDFILE Alias "CLSID_REQUESTEDFILE" As Const CLSID

Type RequestedFile As _RequestedFile

Type LPRequestedFile As _RequestedFile Ptr

Declare Function CreateRequestedFile( _
	ByVal pIMemoryAllocator As IMalloc Ptr _
)As RequestedFile Ptr

Declare Sub DestroyRequestedFile( _
	ByVal this As RequestedFile Ptr _
)

Declare Function RequestedFileQueryInterface( _
	ByVal this As RequestedFile Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function RequestedFileAddRef( _
	ByVal this As RequestedFile Ptr _
)As ULONG

Declare Function RequestedFileRelease( _
	ByVal this As RequestedFile Ptr _
)As ULONG

Declare Function RequestedFileGetFilePath( _
	ByVal this As RequestedFile Ptr, _
	ByVal ppFilePath As WString Ptr Ptr _
)As HRESULT

Declare Function RequestedFileSetFilePath( _
	ByVal this As RequestedFile Ptr, _
	ByVal FilePath As WString Ptr _
)As HRESULT

Declare Function RequestedFileGetPathTranslated( _
	ByVal this As RequestedFile Ptr, _
	ByVal ppPathTranslated As WString Ptr Ptr _
)As HRESULT

Declare Function RequestedFileSetPathTranslated( _
	ByVal this As RequestedFile Ptr, _
	ByVal PathTranslated As WString Ptr _
)As HRESULT

Declare Function RequestedFileFileExists( _
	ByVal this As RequestedFile Ptr, _
	ByVal pResult As RequestedFileState Ptr _
)As HRESULT

Declare Function RequestedFileGetFileHandle( _
	ByVal this As RequestedFile Ptr, _
	ByVal pResult As HANDLE Ptr _
)As HRESULT

Declare Function RequestedFileSetFileHandle( _
	ByVal this As RequestedFile Ptr, _
	ByVal hFile As HANDLE _
)As HRESULT

Declare Function RequestedFileGetLastFileModifiedDate( _
	ByVal this As RequestedFile Ptr, _
	ByVal pResult As FILETIME Ptr _
)As HRESULT

Declare Function RequestedFileGetFileLength( _
	ByVal this As RequestedFile Ptr, _
	ByVal pResult As ULongInt Ptr _
)As HRESULT

Declare Function RequestedFileGetVaryHeaders( _
	ByVal this As RequestedFile Ptr, _
	ByVal pHeadersLength As Integer Ptr, _
	ByVal ppHeaders As HttpRequestHeaders Ptr Ptr _
)As HRESULT

#endif
