#ifndef IATTRIBUTEDSTREAM_BI
#define IATTRIBUTEDSTREAM_BI

#include once "Http.bi"
#include once "IAsyncResult.bi"
#include once "IString.bi"
#include once "Mime.bi"

Extern IID_IAttributedStream Alias "IID_IAttributedStream" As Const IID

Const ATTRIBUTEDSTREAM_S_IO_PENDING As HRESULT = MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0201)

Const BUFFERSLICECHUNK_SIZE As DWORD = 64 * 1024

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
	
	BeginReadSlice As Function( _
		ByVal this As IAttributedStream Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndReadSlice As Function( _
		ByVal this As IAttributedStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr _
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
	
	GetPreloadedBytes As Function( _
		ByVal this As IAttributedStream Ptr, _
		ByVal pPreloadedBytesLength As Integer Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As HRESULT
	
End Type

Type IAttributedStream_
	lpVtbl As IAttributedStreamVirtualTable Ptr
End Type

#define IAttributedStream_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IAttributedStream_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IAttributedStream_Release(this) (this)->lpVtbl->Release(this)
#define IAttributedStream_BeginReadSlice(this, StartIndex, Length, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginReadSlice(this, StartIndex, Length, StateObject, ppIAsyncResult)
#define IAttributedStream_EndReadSlice(this, pIAsyncResult, pBufferSlice) (this)->lpVtbl->EndReadSlice(this, pIAsyncResult, pBufferSlice)
#define IAttributedStream_GetContentType(this, ppType) (this)->lpVtbl->GetContentType(this, ppType)
#define IAttributedStream_GetEncoding(this, ppEncoding) (this)->lpVtbl->GetEncoding(this, ppEncoding)
#define IAttributedStream_GetLanguage(this, ppLanguage) (this)->lpVtbl->GetLanguage(this, ppLanguage)
#define IAttributedStream_GetETag(this, ppETag) (this)->lpVtbl->GetETag(this, ppETag)
#define IAttributedStream_GetLastFileModifiedDate(this, ppDate) (this)->lpVtbl->GetLastFileModifiedDate(this, ppDate)
#define IAttributedStream_GetLength(this, pLength) (this)->lpVtbl->GetLength(this, pLength)
#define IAttributedStream_GetPreloadedBytes(this, pPreloadedBytesLength, ppPreloadedBytes) (this)->lpVtbl->GetPreloadedBytes(this, pPreloadedBytesLength, ppPreloadedBytes)

#endif
