#ifndef REQUESTEDFILE_BI
#define REQUESTEDFILE_BI

#include "IRequestedFile.bi"
#include "ISendable.bi"

Extern CLSID_REQUESTEDFILE Alias "CLSID_REQUESTEDFILE" As Const CLSID

Type RequestedFile
	Const MaxFilePathLength As Integer = 4095 + 32
	Const MaxFilePathTranslatedLength As Integer = MaxFilePathLength + 256
	
	Dim pRequestedFileVirtualTable As IRequestedFileVirtualTable Ptr
	Dim pSendableVirtualTable As ISendableVirtualTable Ptr
	Dim ReferenceCounter As ULONG
	
	Dim FilePath As WString * (MaxFilePathLength + 1)
	Dim PathTranslated As WString * (MaxFilePathTranslatedLength + 1)
	
	Dim LastFileModifiedDate As FILETIME
	
	Dim FileHandle As Handle
	Dim FileDataLength As ULongInt
	
	Dim GZipFileHandle As Handle
	Dim GZipFileDataLength As ULongInt
	
	Dim DeflateFileHandle As Handle
	Dim DeflateFileDataLength As ULongInt
	
End Type

Declare Function CreateRequestedFile( _
)As RequestedFile Ptr

Declare Sub DestroyRequestedFile( _
	ByVal pRequestedFile As RequestedFile Ptr _
)

Declare Function RequestedFileQueryInterface( _
	ByVal pRequestedFile As RequestedFile Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function RequestedFileAddRef( _
	ByVal pRequestedFile As RequestedFile Ptr _
)As ULONG

Declare Function RequestedFileRelease( _
	ByVal pRequestedFile As RequestedFile Ptr _
)As ULONG

Declare Function RequestedFileChoiseFile( _
	ByVal pRequestedFile As RequestedFile Ptr, _
	ByVal pUri As Station922Uri Ptr _
)As HRESULT

Declare Function RequestedFileGetFilePath( _
	ByVal pRequestedFile As RequestedFile Ptr, _
	ByVal ppFilePath As WString Ptr Ptr _
)As HRESULT

Declare Function RequestedFileSetFilePath( _
	ByVal pRequestedFile As RequestedFile Ptr, _
	ByVal FilePath As WString Ptr _
)As HRESULT

Declare Function RequestedFileGetPathTranslated( _
	ByVal pRequestedFile As RequestedFile Ptr, _
	ByVal ppPathTranslated As WString Ptr Ptr _
)As HRESULT

Declare Function RequestedFileSetPathTranslated( _
	ByVal pRequestedFile As RequestedFile Ptr, _
	ByVal PathTranslated As WString Ptr Ptr _
)As HRESULT

Declare Function RequestedFileFileExists( _
	ByVal pRequestedFile As RequestedFile Ptr, _
	ByVal pResult As RequestedFileState Ptr _
)As HRESULT

Declare Function RequestedFileGetFileHandle( _
	ByVal pRequestedFile As RequestedFile Ptr, _
	ByVal pResult As HANDLE Ptr _
)As HRESULT

Declare Function RequestedFileGetLastFileModifiedDate( _
	ByVal pRequestedFile As RequestedFile Ptr, _
	ByVal pResult As FILETIME Ptr _
)As HRESULT

Declare Function RequestedFileGetFileLength( _
	ByVal pRequestedFile As RequestedFile Ptr, _
	ByVal pResult As ULongInt Ptr _
)As HRESULT

Declare Function RequestedFileGetVaryHeaders( _
	ByVal pRequestedFile As RequestedFile Ptr, _
	ByVal pHeadersLength As Integer Ptr, _
	ByVal ppHeaders As HttpRequestHeaders Ptr Ptr _
)As HRESULT

#define RequestedFile_NonVirtualQueryInterface(pIRequestedFile, riid, ppv) RequestedFileQueryInterface(CPtr(RequestedFile Ptr, pIRequestedFile), riid, ppv)
#define RequestedFile_NonVirtualAddRef(pIRequestedFile) RequestedFileAddRef(CPtr(RequestedFile Ptr, pIRequestedFile))
#define RequestedFile_NonVirtualRelease(pIRequestedFile) RequestedFileRelease(CPtr(RequestedFile Ptr, pIRequestedFile))
#define RequestedFile_NonVirtualChoiseFile(pIRequestedFile, pUri) RequestedFileChoiseFile(CPtr(RequestedFile Ptr, pIRequestedFile), pUri)
#define RequestedFile_NonVirtualGetFilePath(pIRequestedFile, ppFilePath) RequestedFileGetFilePath(CPtr(RequestedFile Ptr, pIRequestedFile), ppFilePath)
#define RequestedFile_NonVirtualSetFilePath(pIRequestedFile, FilePath) RequestedFileSetFilePath(CPtr(RequestedFile Ptr, pIRequestedFile), FilePath)
#define RequestedFile_NonVirtualGetPathTranslated(pIRequestedFile, ppPathTranslated) RequestedFileGetPathTranslated(CPtr(RequestedFile Ptr, pIRequestedFile), ppPathTranslated)
#define RequestedFile_NonVirtualSetPathTranslated(pIRequestedFile, PathTranslated) RequestedFileSetPathTranslated(CPtr(RequestedFile Ptr, pIRequestedFile), PathTranslated)
#define RequestedFile_NonVirtualFileExists(pIRequestedFile, pResult) FileExists(CPtr(RequestedFile Ptr, pIRequestedFile), pResult)
#define RequestedFile_NonVirtualGetFileHandle(pIRequestedFile, pResult) RequestedFileGetFileHandle(CPtr(RequestedFile Ptr, pIRequestedFile), pResult)
#define RequestedFile_NonVirtualGetLastFileModifiedDate(pIRequestedFile, pResult) RequestedFileGetLastFileModifiedDate(CPtr(RequestedFile Ptr, pIRequestedFile), pResult)
#define RequestedFile_NonVirtualGetVaryHeaders(pIRequestedFile, pHeadersLength, ppHeaders) RequestedFileGetVaryHeaders(CPtr(RequestedFile Ptr, pIRequestedFile), pHeadersLength, ppHeaders)

#endif
