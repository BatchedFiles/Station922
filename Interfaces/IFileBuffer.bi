#ifndef IFILEBUFFER_BI
#define IFILEBUFFER_BI

#include once "IBuffer.bi"

Enum RequestedFileState
	Exist
	NotFound
	Gone
End Enum

Type IFileBuffer As IFileBuffer_

Type LPIFILEBUFFER As IFileBuffer Ptr

Extern IID_IFileBuffer Alias "IID_IFileBuffer" As Const IID

Type IFileBufferVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IFileBuffer Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IFileBuffer Ptr _
	)As ULONG
	
	GetCapacity As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal pCapacity As LongInt Ptr _
	)As HRESULT
	
	GetLength As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT
	
	GetSlice As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	
	GetFilePath As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal ppFilePath As WString Ptr Ptr _
	)As HRESULT
	
	SetFilePath As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal FilePath As WString Ptr _
	)As HRESULT
	
	GetPathTranslated As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal ppPathTranslated As WString Ptr Ptr _
	)As HRESULT
	
	SetPathTranslated As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal PathTranslated As WString Ptr _
	)As HRESULT
	
	FileExists As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal pResult As RequestedFileState Ptr _
	)As HRESULT
	
	GetFileHandle As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	
	SetFileHandle As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	
	GetLastFileModifiedDate As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal pResult As FILETIME Ptr _
	)As HRESULT
	
	GetFileLength As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal pResult As ULongInt Ptr _
	)As HRESULT
	
End Type

Type IFileBuffer_
	lpVtbl As IFileBufferVirtualTable Ptr
End Type

#define IFileBuffer_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IFileBuffer_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IFileBuffer_Release(this) (this)->lpVtbl->Release(this)
#define IFileBuffer_GetCapacity(this, pCapacity) (this)->lpVtbl->GetCapacity(this, pCapacity)
#define IFileBuffer_GetLength(this, pLength) (this)->lpVtbl->GetLength(this, pLength)
#define IFileBuffer_GetSlice(this, StartIndex, Length, pSlice) (this)->lpVtbl->GetSlice(this, StartIndex, Length, pSlice)
#define IFileBuffer_GetFilePath(this, ppFilePath) (this)->lpVtbl->GetFilePath(this, ppFilePath)
#define IFileBuffer_SetFilePath(this, FilePath) (this)->lpVtbl->SetFilePath(this, FilePath)
#define IFileBuffer_GetPathTranslated(this, ppPathTranslated) (this)->lpVtbl->GetPathTranslated(this, ppPathTranslated)
#define IFileBuffer_SetPathTranslated(this, PathTranslated) (this)->lpVtbl->SetPathTranslated(this, PathTranslated)
#define IFileBuffer_FileExists(this, pResult) (this)->lpVtbl->FileExists(this, pResult)
#define IFileBuffer_GetFileHandle(this, pResult) (this)->lpVtbl->GetFileHandle(this, pResult)
#define IFileBuffer_SetFileHandle(this, hFile) (this)->lpVtbl->SetFileHandle(this, hFile)
#define IFileBuffer_GetLastFileModifiedDate(this, pResult) (this)->lpVtbl->GetLastFileModifiedDate(this, pResult)
#define IFileBuffer_GetFileLength(this, pResult) (this)->lpVtbl->GetFileLength(this, pResult)

#endif
