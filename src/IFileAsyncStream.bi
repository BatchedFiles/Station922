#ifndef IFILEASYNCSTREAM_BI
#define IFILEASYNCSTREAM_BI

#include once "IAttributedAsyncStream.bi"

Extern IID_IFileAsyncStream Alias "IID_IFileAsyncStream" As Const IID

Type IFileAsyncStream As IFileAsyncStream_

Type IFileAsyncStreamVirtualTable

	QueryInterface As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IFileAsyncStream Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IFileAsyncStream Ptr _
	)As ULONG

	BeginReadSlice As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As LongInt, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	EndReadSlice As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT

	GetContentType As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT

	GetEncoding As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT

	GetLanguage As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT

	GetETag As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT

	GetLastFileModifiedDate As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal ppDate As FILETIME Ptr _
	)As HRESULT

	GetLength As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT

	GetPreloadedBytes As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal pPreloadedBytesLength As UInteger Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As HRESULT

	GetFilePath As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal ppFilePath As HeapBSTR Ptr _
	)As HRESULT

	SetFilePath As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal FilePath As HeapBSTR _
	)As HRESULT

	GetFileHandle As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT

	SetFileHandle As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT

	GetZipFileHandle As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT

	SetZipFileHandle As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT

	SetContentType As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal pType As MimeType Ptr _
	)As HRESULT

	SetFileOffset As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal Offset As LongInt _
	)As HRESULT

	SetFileSize As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal FileSize As LongInt _
	)As HRESULT

	SetEncoding As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal ZipMode As ZipModes _
	)As HRESULT

	SetFileTime As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal pTime As FILETIME Ptr _
	)As HRESULT

	SetETag As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal ETag As HeapBSTR _
	)As HRESULT

	SetReservedFileBytes As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal ReservedFileBytes As UInteger _
	)As HRESULT

	SetPreloadedBytes As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal PreloadedBytesLength As UInteger, _
		ByVal pPreloadedBytes As UByte Ptr _
	)As HRESULT

	AllocSlice As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal DesiredLength As UInteger, _
		ByVal pSlice As BufferSlice Ptr _
	)As HRESULT

	BeginWriteSlice As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr, _
		ByVal Offset As LongInt, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	EndWriteSlice As Function( _
		ByVal self As IFileAsyncStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pWritedBytes As DWORD Ptr _
	)As HRESULT

End Type

Type IFileAsyncStream_
	lpVtbl As IFileAsyncStreamVirtualTable Ptr
End Type

#define IFileAsyncStream_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define IFileAsyncStream_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IFileAsyncStream_Release(self) (self)->lpVtbl->Release(self)
#define IFileAsyncStream_BeginReadSlice(self, Buffer, Count, callback, StateObject, ppIAsyncResult) (self)->lpVtbl->BeginReadSlice(self, Buffer, Count, callback, StateObject, ppIAsyncResult)
#define IFileAsyncStream_EndReadSlice(self, pIAsyncResult, pReadedBytes) (self)->lpVtbl->EndReadSlice(self, pIAsyncResult, pReadedBytes)
#define IFileAsyncStream_GetContentType(self, ppType) (self)->lpVtbl->GetContentType(self, ppType)
#define IFileAsyncStream_GetEncoding(self, ppEncoding) (self)->lpVtbl->GetEncoding(self, ppEncoding)
#define IFileAsyncStream_GetLanguage(self, ppLanguage) (self)->lpVtbl->GetLanguage(self, ppLanguage)
#define IFileAsyncStream_GetETag(self, ppETag) (self)->lpVtbl->GetETag(self, ppETag)
#define IFileAsyncStream_GetLastFileModifiedDate(self, ppDate) (self)->lpVtbl->GetLastFileModifiedDate(self, ppDate)
#define IFileAsyncStream_GetLength(self, pLength) (self)->lpVtbl->GetLength(self, pLength)
#define IFileAsyncStream_GetPreloadedBytes(self, pPreloadedBytesLength, ppPreloadedBytes) (self)->lpVtbl->GetPreloadedBytes(self, pPreloadedBytesLength, ppPreloadedBytes)
#define IFileAsyncStream_GetFilePath(self, ppFilePath) (self)->lpVtbl->GetFilePath(self, ppFilePath)
#define IFileAsyncStream_SetFilePath(self, FilePath) (self)->lpVtbl->SetFilePath(self, FilePath)
#define IFileAsyncStream_GetFileHandle(self, pResult) (self)->lpVtbl->GetFileHandle(self, pResult)
#define IFileAsyncStream_SetFileHandle(self, hFile) (self)->lpVtbl->SetFileHandle(self, hFile)
#define IFileAsyncStream_GetZipFileHandle(self, pResult) (self)->lpVtbl->GetZipFileHandle(self, pResult)
#define IFileAsyncStream_SetZipFileHandle(self, hFile) (self)->lpVtbl->SetZipFileHandle(self, hFile)
#define IFileAsyncStream_SetContentType(self, pType) (self)->lpVtbl->SetContentType(self, pType)
#define IFileAsyncStream_SetFileOffset(self, Offset) (self)->lpVtbl->SetFileOffset(self, Offset)
#define IFileAsyncStream_SetFileSize(self, FileSize) (self)->lpVtbl->SetFileSize(self, FileSize)
#define IFileAsyncStream_SetEncoding(self, ZipMode) (self)->lpVtbl->SetEncoding(self, ZipMode)
#define IFileAsyncStream_SetFileTime(self, pTime) (self)->lpVtbl->SetFileTime(self, pTime)
#define IFileAsyncStream_SetETag(self, ETag) (self)->lpVtbl->SetETag(self, ETag)
#define IFileAsyncStream_SetReservedFileBytes(self, ReservedFileBytes) (self)->lpVtbl->SetReservedFileBytes(self, ReservedFileBytes)
#define IFileAsyncStream_SetPreloadedBytes(self, PreloadedBytesLength, pPreloadedBytes) (self)->lpVtbl->SetPreloadedBytes(self, PreloadedBytesLength, pPreloadedBytes)
#define IFileAsyncStream_AllocSlice(self, DesiredLength, pSlice) (self)->lpVtbl->AllocSlice(self, DesiredLength, pSlice)
#define IFileAsyncStream_BeginWriteSlice(self, pBufferSlice, Offset, pcb, StateObject, ppIAsyncResult) (self)->lpVtbl->BeginWriteSlice(self, pBufferSlice, Offset, pcb, StateObject, ppIAsyncResult)
#define IFileAsyncStream_EndWriteSlice(self, pIAsyncResult, pWritedBytes) (self)->lpVtbl->EndWriteSlice(self, pIAsyncResult, pWritedBytes)

#endif
