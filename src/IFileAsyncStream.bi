#ifndef IFILEASYNCSTREAM_BI
#define IFILEASYNCSTREAM_BI

#include once "IAttributedAsyncStream.bi"

Extern IID_IFileAsyncStream Alias "IID_IFileAsyncStream" As Const IID

Type IFileAsyncStream As IFileAsyncStream_

Type IFileAsyncStreamVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IFileAsyncStream Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IFileAsyncStream Ptr _
	)As ULONG
	
	BeginReadSlice As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndReadSlice As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	
	GetContentType As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT
	
	GetEncoding As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	
	GetLanguage As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT
	
	GetETag As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT
	
	GetLastFileModifiedDate As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal ppDate As FILETIME Ptr _
	)As HRESULT
	
	GetLength As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT
	
	GetPreloadedBytes As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal pPreloadedBytesLength As Integer Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As HRESULT
	
	GetFilePath As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal ppFilePath As HeapBSTR Ptr _
	)As HRESULT
	
	SetFilePath As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal FilePath As HeapBSTR _
	)As HRESULT
	
	GetFileHandle As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	
	SetFileHandle As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	
	GetZipFileHandle As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	
	SetZipFileHandle As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	
	SetContentType As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal pType As MimeType Ptr _
	)As HRESULT
	
	SetFileOffset As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal Offset As LongInt _
	)As HRESULT
	
	SetFileSize As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal FileSize As LongInt _
	)As HRESULT
	
	SetEncoding As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal ZipMode As ZipModes _
	)As HRESULT
	
	SetFileTime As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal pTime As FILETIME Ptr _
	)As HRESULT
	
	SetETag As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal ETag As HeapBSTR _
	)As HRESULT
	
	SetReservedFileBytes As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal ReservedFileBytes As UInteger _
	)As HRESULT
	
	SetPreloadedBytes As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal PreloadedBytesLength As UInteger, _
		ByVal pPreloadedBytes As UByte Ptr _
	)As HRESULT
	
	GetReservedBytes As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal pReservedBytesLength As Integer Ptr, _
		ByVal ppReservedBytes As UByte Ptr Ptr _
	)As HRESULT
	
	BeginWriteSlice As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr, _
		ByVal Offset As LongInt, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndWriteSlice As Function( _
		ByVal this As IFileAsyncStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pWritedBytes As DWORD Ptr _
	)As HRESULT
	
End Type

Type IFileAsyncStream_
	lpVtbl As IFileAsyncStreamVirtualTable Ptr
End Type

#define IFileAsyncStream_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IFileAsyncStream_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IFileAsyncStream_Release(this) (this)->lpVtbl->Release(this)
#define IFileAsyncStream_BeginReadSlice(this, Buffer, Count, callback, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginReadSlice(this, Buffer, Count, callback, StateObject, ppIAsyncResult)
#define IFileAsyncStream_EndReadSlice(this, pIAsyncResult, pReadedBytes) (this)->lpVtbl->EndReadSlice(this, pIAsyncResult, pReadedBytes)
#define IFileAsyncStream_GetContentType(this, ppType) (this)->lpVtbl->GetContentType(this, ppType)
#define IFileAsyncStream_GetEncoding(this, ppEncoding) (this)->lpVtbl->GetEncoding(this, ppEncoding)
#define IFileAsyncStream_GetLanguage(this, ppLanguage) (this)->lpVtbl->GetLanguage(this, ppLanguage)
#define IFileAsyncStream_GetETag(this, ppETag) (this)->lpVtbl->GetETag(this, ppETag)
#define IFileAsyncStream_GetLastFileModifiedDate(this, ppDate) (this)->lpVtbl->GetLastFileModifiedDate(this, ppDate)
#define IFileAsyncStream_GetLength(this, pLength) (this)->lpVtbl->GetLength(this, pLength)
#define IFileAsyncStream_GetPreloadedBytes(this, pPreloadedBytesLength, ppPreloadedBytes) (this)->lpVtbl->GetPreloadedBytes(this, pPreloadedBytesLength, ppPreloadedBytes)
#define IFileAsyncStream_GetFilePath(this, ppFilePath) (this)->lpVtbl->GetFilePath(this, ppFilePath)
#define IFileAsyncStream_SetFilePath(this, FilePath) (this)->lpVtbl->SetFilePath(this, FilePath)
#define IFileAsyncStream_GetFileHandle(this, pResult) (this)->lpVtbl->GetFileHandle(this, pResult)
#define IFileAsyncStream_SetFileHandle(this, hFile) (this)->lpVtbl->SetFileHandle(this, hFile)
#define IFileAsyncStream_GetZipFileHandle(this, pResult) (this)->lpVtbl->GetZipFileHandle(this, pResult)
#define IFileAsyncStream_SetZipFileHandle(this, hFile) (this)->lpVtbl->SetZipFileHandle(this, hFile)
#define IFileAsyncStream_SetContentType(this, pType) (this)->lpVtbl->SetContentType(this, pType)
#define IFileAsyncStream_SetFileOffset(this, Offset) (this)->lpVtbl->SetFileOffset(this, Offset)
#define IFileAsyncStream_SetFileSize(this, FileSize) (this)->lpVtbl->SetFileSize(this, FileSize)
#define IFileAsyncStream_SetEncoding(this, ZipMode) (this)->lpVtbl->SetEncoding(this, ZipMode)
#define IFileAsyncStream_SetFileTime(this, pTime) (this)->lpVtbl->SetFileTime(this, pTime)
#define IFileAsyncStream_SetETag(this, ETag) (this)->lpVtbl->SetETag(this, ETag)
#define IFileAsyncStream_SetReservedFileBytes(this, ReservedFileBytes) (this)->lpVtbl->SetReservedFileBytes(this, ReservedFileBytes)
#define IFileAsyncStream_SetPreloadedBytes(this, PreloadedBytesLength, pPreloadedBytes) (this)->lpVtbl->SetPreloadedBytes(this, PreloadedBytesLength, pPreloadedBytes)
#define IFileAsyncStream_GetReservedBytes(this, pReservedBytesLength, ppReservedBytes) (this)->lpVtbl->GetReservedBytes(this, pReservedBytesLength, ppReservedBytes)
#define IFileAsyncStream_BeginWriteSlice(this, pBufferSlice, Offset, pcb, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginWriteSlice(this, pBufferSlice, Offset, pcb, StateObject, ppIAsyncResult)
#define IFileAsyncStream_EndWriteSlice(this, pIAsyncResult, pWritedBytes) (this)->lpVtbl->EndWriteSlice(this, pIAsyncResult, pWritedBytes)

#endif
