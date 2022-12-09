#ifndef IATTRIBUTEDSTREAM_BI
#define IATTRIBUTEDSTREAM_BI

#include once "Http.bi"
#include once "IAsyncResult.bi"
#include once "IBaseStream.bi"
#include once "IString.bi"
#include once "Mime.bi"

#if __FB_DEBUG__
Const BUFFERSLICECHUNK_SIZE As DWORD = 64 * 1024
#else
Const BUFFERSLICECHUNK_SIZE As DWORD = 64 * 1024 * 128
#endif

Enum FileAccess
	CreateAccess
	ReadAccess
	UpdateAccess
	DeleteAccess
End Enum

Type BufferSlice
	pSlice As ZString Ptr
	Length As Integer
End Type

Type IAttributedStream As IAttributedStream_

Type LPIATTRIBUTEDSTREAM As IAttributedStream Ptr

Extern IID_IAttributedStream Alias "IID_IAttributedStream" As Const IID

Type IAttributedStreamVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IAttributedStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IAttributedStream Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IAttributedStream Ptr _
	)As ULONG
	
	BeginRead As Function( _
		ByVal this As IAttributedStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal callback As AsyncCallback, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	BeginWrite As Function( _
		ByVal this As IAttributedStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal callback As AsyncCallback, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndRead As Function( _
		ByVal this As IAttributedStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pReadedBytes As DWORD Ptr _
	)As HRESULT
	
	EndWrite As Function( _
		ByVal this As IAttributedStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pWritedBytes As DWORD Ptr _
	)As HRESULT
	
	BeginReadScatter As Function( _
		ByVal this As IAttributedStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal Count As DWORD, _
		ByVal callback As AsyncCallback, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	BeginWriteGather As Function( _
		ByVal this As IAttributedStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal Count As DWORD, _
		ByVal callback As AsyncCallback, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	BeginWriteGatherAndShutdown As Function( _
		ByVal this As IAttributedStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal Count As DWORD, _
		ByVal callback As AsyncCallback, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	GetContentType As Function( _
		ByVal this As IAttributedStream Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT
	
	GetEncoding As Function( _
		ByVal this As IAttributedStream Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	
	GetLanguage As Function( _
		ByVal this As IAttributedStream Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT
	
	GetETag As Function( _
		ByVal this As IAttributedStream Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT
	
	GetLastFileModifiedDate As Function( _
		ByVal this As IAttributedStream Ptr, _
		ByVal ppDate As FILETIME Ptr _
	)As HRESULT
	
	GetLength As Function( _
		ByVal this As IAttributedStream Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT
	
	GetSlice As Function( _
		ByVal this As IAttributedStream Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	
	BeginGetSlice As Function( _
		ByVal this As IAttributedStream Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndGetSlice As Function( _
		ByVal this As IAttributedStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	
End Type

Type IAttributedStream_
	lpVtbl As IAttributedStreamVirtualTable Ptr
End Type

#define IAttributedStream_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IAttributedStream_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IAttributedStream_Release(this) (this)->lpVtbl->Release(this)
#define IAttributedStream_BeginRead(this, Buffer, Count, callback, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginRead(this, Buffer, Count, callback, StateObject, ppIAsyncResult)
#define IAttributedStream_BeginWrite(this, Buffer, Count, callback, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginWrite(this, Buffer, Count, callback, StateObject, ppIAsyncResult)
#define IAttributedStream_EndRead(this, pIAsyncResult, pReadedBytes) (this)->lpVtbl->EndRead(this, pIAsyncResult, pReadedBytes)
#define IAttributedStream_EndWrite(this, pIAsyncResult, pWritedBytes) (this)->lpVtbl->EndWrite(this, pIAsyncResult, pWritedBytes)
#define IAttributedStream_BeginReadScatter(this, pBuffer, Count, callback, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginReadScatter(this, pBuffer, Count, callback, StateObject, ppIAsyncResult)
#define IAttributedStream_BeginWriteGather(this, pBuffer, Count, callback, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginWriteGather(this, pBuffer, Count, callback, StateObject, ppIAsyncResult)
#define IAttributedStream_BeginWriteGatherAndShutdown(this, pBuffer, Count, callback, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginWriteGatherAndShutdown(this, pBuffer, Count, callback, StateObject, ppIAsyncResult)
#define IAttributedStream_GetContentType(this, ppType) (this)->lpVtbl->GetContentType(this, ppType)
#define IAttributedStream_GetEncoding(this, ppEncoding) (this)->lpVtbl->GetEncoding(this, ppEncoding)
#define IAttributedStream_GetLanguage(this, ppLanguage) (this)->lpVtbl->GetLanguage(this, ppLanguage)
#define IAttributedStream_GetETag(this, ppETag) (this)->lpVtbl->GetETag(this, ppETag)
#define IAttributedStream_GetLastFileModifiedDate(this, ppDate) (this)->lpVtbl->GetLastFileModifiedDate(this, ppDate)
#define IAttributedStream_GetLength(this, pLength) (this)->lpVtbl->GetLength(this, pLength)
#define IAttributedStream_GetSlice(this, StartIndex, Length, pSlice) (this)->lpVtbl->GetSlice(this, StartIndex, Length, pSlice)

#endif
