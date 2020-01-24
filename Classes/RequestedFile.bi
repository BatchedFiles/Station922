#ifndef REQUESTEDFILE_BI
#define REQUESTEDFILE_BI

#include "IRequestedFile.bi"
#include "ISendable.bi"

Extern CLSID_REQUESTEDFILE Alias "CLSID_REQUESTEDFILE" As Const CLSID

Type _RequestedFile
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

Type RequestedFile As _RequestedFile

Type LPRequestedFile As _RequestedFile Ptr

Declare Function CreateRequestedFile( _
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

Declare Function RequestedFileChoiseFile( _
	ByVal this As RequestedFile Ptr, _
	ByVal pUri As Station922Uri Ptr _
)As HRESULT

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
	ByVal PathTranslated As WString Ptr Ptr _
)As HRESULT

Declare Function RequestedFileFileExists( _
	ByVal this As RequestedFile Ptr, _
	ByVal pResult As RequestedFileState Ptr _
)As HRESULT

Declare Function RequestedFileGetFileHandle( _
	ByVal this As RequestedFile Ptr, _
	ByVal pResult As HANDLE Ptr _
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
