#ifndef IFILESTREAM_BI
#define IFILESTREAM_BI

#include once "IAttributedStream.bi"

Extern IID_IFileStream Alias "IID_IFileStream" As Const IID

Type IFileStream As IFileStream_

Type IFileStreamVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IFileStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IFileStream Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IFileStream Ptr _
	)As ULONG
	
	BeginGetSlice As Function( _
		ByVal this As IFileStream Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndGetSlice As Function( _
		ByVal this As IFileStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	
	GetContentType As Function( _
		ByVal this As IFileStream Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT
	
	GetEncoding As Function( _
		ByVal this As IFileStream Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	
	GetLanguage As Function( _
		ByVal this As IFileStream Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT
	
	GetETag As Function( _
		ByVal this As IFileStream Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT
	
	GetLastFileModifiedDate As Function( _
		ByVal this As IFileStream Ptr, _
		ByVal ppDate As FILETIME Ptr _
	)As HRESULT
	
	GetLength As Function( _
		ByVal this As IFileStream Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT
	
	GetFilePath As Function( _
		ByVal this As IFileStream Ptr, _
		ByVal ppFilePath As HeapBSTR Ptr _
	)As HRESULT
	
	SetFilePath As Function( _
		ByVal this As IFileStream Ptr, _
		ByVal FilePath As HeapBSTR _
	)As HRESULT
	
	GetFileHandle As Function( _
		ByVal this As IFileStream Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	
	SetFileHandle As Function( _
		ByVal this As IFileStream Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	
	GetZipFileHandle As Function( _
		ByVal this As IFileStream Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	
	SetZipFileHandle As Function( _
		ByVal this As IFileStream Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	
	SetContentType As Function( _
		ByVal this As IFileStream Ptr, _
		ByVal pType As MimeType Ptr _
	)As HRESULT
	
	SetFileOffset As Function( _
		ByVal this As IFileStream Ptr, _
		ByVal Offset As LongInt _
	)As HRESULT
	
	SetFileSize As Function( _
		ByVal this As IFileStream Ptr, _
		ByVal FileSize As LongInt _
	)As HRESULT
	
	SetEncoding As Function( _
		ByVal this As IFileStream Ptr, _
		ByVal ZipMode As ZipModes _
	)As HRESULT
	
	SetFileTime As Function( _
		ByVal this As IFileStream Ptr, _
		ByVal pTime As FILETIME Ptr _
	)As HRESULT
	
	SetETag As Function( _
		ByVal this As IFileStream Ptr, _
		ByVal ETag As HeapBSTR _
	)As HRESULT
	
End Type

Type IFileStream_
	lpVtbl As IFileStreamVirtualTable Ptr
End Type

#define IFileStream_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IFileStream_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IFileStream_Release(this) (this)->lpVtbl->Release(this)
#define IFileStream_BeginRead(this, Buffer, Count, callback, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginRead(this, Buffer, Count, callback, StateObject, ppIAsyncResult)
#define IFileStream_BeginWrite(this, Buffer, Count, callback, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginWrite(this, Buffer, Count, callback, StateObject, ppIAsyncResult)
#define IFileStream_EndRead(this, pIAsyncResult, pReadedBytes) (this)->lpVtbl->EndRead(this, pIAsyncResult, pReadedBytes)
#define IFileStream_EndWrite(this, pIAsyncResult, pWritedBytes) (this)->lpVtbl->EndWrite(this, pIAsyncResult, pWritedBytes)
#define IFileStream_BeginReadScatter(this, pBuffer, Count, callback, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginReadScatter(this, pBuffer, Count, callback, StateObject, ppIAsyncResult)
#define IFileStream_BeginWriteGather(this, pBuffer, Count, callback, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginWriteGather(this, pBuffer, Count, callback, StateObject, ppIAsyncResult)
#define IFileStream_BeginWriteGatherAndShutdown(this, pBuffer, Count, callback, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginWriteGatherAndShutdown(this, pBuffer, Count, callback, StateObject, ppIAsyncResult)
#define IFileStream_GetContentType(this, ppType) (this)->lpVtbl->GetContentType(this, ppType)
#define IFileStream_GetEncoding(this, ppEncoding) (this)->lpVtbl->GetEncoding(this, ppEncoding)
#define IFileStream_GetLanguage(this, ppLanguage) (this)->lpVtbl->GetLanguage(this, ppLanguage)
#define IFileStream_GetETag(this, ppETag) (this)->lpVtbl->GetETag(this, ppETag)
#define IFileStream_GetLastFileModifiedDate(this, ppDate) (this)->lpVtbl->GetLastFileModifiedDate(this, ppDate)
#define IFileStream_GetLength(this, pLength) (this)->lpVtbl->GetLength(this, pLength)
#define IFileStream_GetSlice(this, StartIndex, Length, pSlice) (this)->lpVtbl->GetSlice(this, StartIndex, Length, pSlice)
#define IFileStream_GetFilePath(this, ppFilePath) (this)->lpVtbl->GetFilePath(this, ppFilePath)
#define IFileStream_SetFilePath(this, FilePath) (this)->lpVtbl->SetFilePath(this, FilePath)
#define IFileStream_GetFileHandle(this, pResult) (this)->lpVtbl->GetFileHandle(this, pResult)
#define IFileStream_SetFileHandle(this, hFile) (this)->lpVtbl->SetFileHandle(this, hFile)
#define IFileStream_GetZipFileHandle(this, pResult) (this)->lpVtbl->GetZipFileHandle(this, pResult)
#define IFileStream_SetZipFileHandle(this, hFile) (this)->lpVtbl->SetZipFileHandle(this, hFile)
#define IFileStream_SetContentType(this, pType) (this)->lpVtbl->SetContentType(this, pType)
#define IFileStream_SetFileOffset(this, Offset) (this)->lpVtbl->SetFileOffset(this, Offset)
#define IFileStream_SetFileSize(this, FileSize) (this)->lpVtbl->SetFileSize(this, FileSize)
#define IFileStream_SetEncoding(this, ZipMode) (this)->lpVtbl->SetEncoding(this, ZipMode)
#define IFileStream_SetFileTime(this, pTime) (this)->lpVtbl->SetFileTime(this, pTime)
#define IFileStream_SetETag(this, ETag) (this)->lpVtbl->SetETag(this, ETag)

#endif
