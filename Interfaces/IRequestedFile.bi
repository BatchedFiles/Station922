#ifndef IREQUESTEDFILE_BI
#define IREQUESTEDFILE_BI

#include once "windows.bi"
#include once "win\ole2.bi"
#include once "Http.bi"

Enum RequestedFileState
	Exist
	NotFound
	Gone
End Enum

Type IRequestedFile As IRequestedFile_

Type LPIREQUESTEDFILE As IRequestedFile Ptr

Extern IID_IRequestedFile Alias "IID_IRequestedFile" As Const IID

Type IRequestedFileVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IRequestedFile Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IRequestedFile Ptr _
	)As ULONG
	
	GetFilePath As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal ppFilePath As WString Ptr Ptr _
	)As HRESULT
	
	SetFilePath As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal FilePath As WString Ptr _
	)As HRESULT
	
	GetPathTranslated As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal ppPathTranslated As WString Ptr Ptr _
	)As HRESULT
	
	SetPathTranslated As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal PathTranslated As WString Ptr _
	)As HRESULT
	
	FileExists As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal pResult As RequestedFileState Ptr _
	)As HRESULT
	
	GetFileHandle As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	
	SetFileHandle As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	
	GetLastFileModifiedDate As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal pResult As FILETIME Ptr _
	)As HRESULT
	
	GetFileLength As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal pResult As ULongInt Ptr _
	)As HRESULT
	
	GetVaryHeaders As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal pHeadersLength As Integer Ptr, _
		ByVal ppHeaders As HttpRequestHeaders Ptr Ptr _
	)As HRESULT
	
End Type

Type IRequestedFile_
	lpVtbl As IRequestedFileVirtualTable Ptr
End Type

#define IRequestedFile_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IRequestedFile_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IRequestedFile_Release(this) (this)->lpVtbl->Release(this)
#define IRequestedFile_GetFilePath(this, ppFilePath) (this)->lpVtbl->GetFilePath(this, ppFilePath)
#define IRequestedFile_SetFilePath(this, FilePath) (this)->lpVtbl->SetFilePath(this, FilePath)
#define IRequestedFile_GetPathTranslated(this, ppPathTranslated) (this)->lpVtbl->GetPathTranslated(this, ppPathTranslated)
#define IRequestedFile_SetPathTranslated(this, PathTranslated) (this)->lpVtbl->SetPathTranslated(this, PathTranslated)
#define IRequestedFile_FileExists(this, pResult) (this)->lpVtbl->FileExists(this, pResult)
#define IRequestedFile_GetFileHandle(this, pResult) (this)->lpVtbl->GetFileHandle(this, pResult)
#define IRequestedFile_SetFileHandle(this, hFile) (this)->lpVtbl->SetFileHandle(this, hFile)
#define IRequestedFile_GetLastFileModifiedDate(this, pResult) (this)->lpVtbl->GetLastFileModifiedDate(this, pResult)
#define IRequestedFile_GetFileLength(this, pResult) (this)->lpVtbl->GetFileLength(this, pResult)
' #define IRequestedFile_GetVaryHeaders(this, pHeadersLength, ppHeaders) (this)->lpVtbl->GetVaryHeaders(this, pHeadersLength, ppHeaders)

#endif
