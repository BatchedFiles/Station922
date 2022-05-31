#ifndef IFILEBUFFER_BI
#define IFILEBUFFER_BI

#include once "IBuffer.bi"
#include once "IString.bi"

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
	
	GetContentType As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT
	
	GetEncoding As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	
	GetLanguage As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT
	
	GetETag As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT
	
	GetLastFileModifiedDate As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal ppDate As FILETIME Ptr _
	)As HRESULT
	
	GetLength As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT
	
	SetByteRange As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal Offset As LongInt, _
		ByVal Length As LongInt _
	)As HRESULT
	
	GetSlice As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	
	GetFilePath As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal ppFilePath As HeapBSTR Ptr _
	)As HRESULT
	
	SetFilePath As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal FilePath As HeapBSTR _
	)As HRESULT
	
	GetFileHandle As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	
	SetFileHandle As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	
	GetZipFileHandle As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	
	SetZipFileHandle As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	
	SetFileMappingHandle As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal fAccess As FileAccess, _
		ByVal hFile As HANDLE _
	)As HRESULT
	
	SetContentType As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal pType As MimeType Ptr _
	)As HRESULT
	
	SetFileOffset As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal Offset As LongInt _
	)As HRESULT
	
	SetFileSize As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal FileSize As LongInt _
	)As HRESULT
	
	SetEncoding As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal ZipMode As ZipModes _
	)As HRESULT
	
	SetFileTime As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal pTime As FILETIME Ptr _
	)As HRESULT
	
	SetETag As Function( _
		ByVal this As IFileBuffer Ptr, _
		ByVal ETag As HeapBSTR _
	)As HRESULT
	
End Type

Type IFileBuffer_
	lpVtbl As IFileBufferVirtualTable Ptr
End Type

#define IFileBuffer_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IFileBuffer_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IFileBuffer_Release(this) (this)->lpVtbl->Release(this)
#define IFileBuffer_GetContentType(this, ppType) (this)->lpVtbl->GetContentType(this, ppType)
#define IFileBuffer_GetEncoding(this, ppEncoding) (this)->lpVtbl->GetEncoding(this, ppEncoding)
#define IFileBuffer_GetLanguage(this, ppLanguage) (this)->lpVtbl->GetLanguage(this, ppLanguage)
#define IFileBuffer_GetETag(this, ppETag) (this)->lpVtbl->GetETag(this, ppETag)
#define IFileBuffer_GetLastFileModifiedDate(this, ppDate) (this)->lpVtbl->GetLastFileModifiedDate(this, ppDate)
#define IFileBuffer_GetLength(this, pLength) (this)->lpVtbl->GetLength(this, pLength)
#define IFileBuffer_SetByteRange(this, Offset, Length) (this)->lpVtbl->SetByteRange(this, Offset, Length)
#define IFileBuffer_GetSlice(this, StartIndex, Length, pSlice) (this)->lpVtbl->GetSlice(this, StartIndex, Length, pSlice)
#define IFileBuffer_GetFilePath(this, ppFilePath) (this)->lpVtbl->GetFilePath(this, ppFilePath)
#define IFileBuffer_SetFilePath(this, FilePath) (this)->lpVtbl->SetFilePath(this, FilePath)
#define IFileBuffer_GetFileHandle(this, pResult) (this)->lpVtbl->GetFileHandle(this, pResult)
#define IFileBuffer_SetFileHandle(this, hFile) (this)->lpVtbl->SetFileHandle(this, hFile)
#define IFileBuffer_GetZipFileHandle(this, pResult) (this)->lpVtbl->GetZipFileHandle(this, pResult)
#define IFileBuffer_SetZipFileHandle(this, hFile) (this)->lpVtbl->SetZipFileHandle(this, hFile)
#define IFileBuffer_SetFileMappingHandle(this, fAccess, hFile) (this)->lpVtbl->SetFileMappingHandle(this, fAccess, hFile)
#define IFileBuffer_SetContentType(this, pType) (this)->lpVtbl->SetContentType(this, pType)
#define IFileBuffer_SetFileOffset(this, Offset) (this)->lpVtbl->SetFileOffset(this, Offset)
#define IFileBuffer_SetFileSize(this, FileSize) (this)->lpVtbl->SetFileSize(this, FileSize)
#define IFileBuffer_SetEncoding(this, ZipMode) (this)->lpVtbl->SetEncoding(this, ZipMode)
#define IFileBuffer_SetFileTime(this, pTime) (this)->lpVtbl->SetFileTime(this, pTime)
#define IFileBuffer_SetETag(this, ETag) (this)->lpVtbl->SetETag(this, ETag)

#endif
