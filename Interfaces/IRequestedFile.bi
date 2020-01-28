#ifndef IREQUESTEDFILE_BI
#define IREQUESTEDFILE_BI

#ifndef unicode
#define unicode
#endif
#include "windows.bi"
#include "win\ole2.bi"
#include "Http.bi"
' #include "Station922Uri.bi"

Enum RequestedFileState
	Exist
	NotFound
	Gone
End Enum

Type IRequestedFile As IRequestedFile_

Type LPIREQUESTEDFILE As IRequestedFile Ptr

Extern IID_IRequestedFile Alias "IID_IRequestedFile" As Const IID

Type IRequestedFileVirtualTable
	Dim InheritedTable As IUnknownVtbl
	
	Dim GetFilePath As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal ppFilePath As WString Ptr Ptr _
	)As HRESULT
	
	Dim SetFilePath As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal FilePath As WString Ptr _
	)As HRESULT
	
	Dim GetPathTranslated As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal ppPathTranslated As WString Ptr Ptr _
	)As HRESULT
	
	Dim SetPathTranslated As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal PathTranslated As WString Ptr _
	)As HRESULT
	
	Dim FileExists As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal pResult As RequestedFileState Ptr _
	)As HRESULT
	
	Dim GetFileHandle As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	
	Dim SetFileHandle As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	
	Dim GetLastFileModifiedDate As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal pResult As FILETIME Ptr _
	)As HRESULT
	
	Dim GetFileLength As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal pResult As ULongInt Ptr _
	)As HRESULT
	
	Dim GetVaryHeaders As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal pHeadersLength As Integer Ptr, _
		ByVal ppHeaders As HttpRequestHeaders Ptr Ptr _
	)As HRESULT
	
End Type

Type IRequestedFile_
	Dim pVirtualTable As IRequestedFileVirtualTable Ptr
End Type

#define IRequestedFile_QueryInterface(this, riid, ppv) (this)->pVirtualTable->InheritedTable.QueryInterface(CPtr(IUnknown Ptr, this), riid, ppv)
#define IRequestedFile_AddRef(this) (this)->pVirtualTable->InheritedTable.AddRef(CPtr(IUnknown Ptr, this))
#define IRequestedFile_Release(this) (this)->pVirtualTable->InheritedTable.Release(CPtr(IUnknown Ptr, this))
#define IRequestedFile_GetFilePath(this, ppFilePath) (this)->pVirtualTable->GetFilePath(this, ppFilePath)
#define IRequestedFile_SetFilePath(this, FilePath) (this)->pVirtualTable->SetFilePath(this, FilePath)
#define IRequestedFile_GetPathTranslated(this, ppPathTranslated) (this)->pVirtualTable->GetPathTranslated(this, ppPathTranslated)
#define IRequestedFile_SetPathTranslated(this, PathTranslated) (this)->pVirtualTable->SetPathTranslated(this, PathTranslated)
#define IRequestedFile_FileExists(this, pResult) (this)->pVirtualTable->FileExists(this, pResult)
#define IRequestedFile_GetFileHandle(this, pResult) (this)->pVirtualTable->GetFileHandle(this, pResult)
#define IRequestedFile_SetFileHandle(this, hFile) (this)->pVirtualTable->GetFileHandle(this, hFile)
#define IRequestedFile_GetLastFileModifiedDate(this, pResult) (this)->pVirtualTable->GetLastFileModifiedDate(this, pResult)
#define IRequestedFile_GetFileLength(this, pResult) (this)->pVirtualTable->GetFileLength(this, pResult)
#define IRequestedFile_GetVaryHeaders(this, pHeadersLength, ppHeaders) (this)->pVirtualTable->GetVaryHeaders(this, pHeadersLength, ppHeaders)

#endif
