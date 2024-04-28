#ifndef IATTRIBUTEDASYNCSTREAM_BI
#define IATTRIBUTEDASYNCSTREAM_BI

#include once "Http.bi"
#include once "IAsyncResult.bi"
#include once "IString.bi"
#include once "Mime.bi"

Extern IID_IAttributedAsyncStream Alias "IID_IAttributedAsyncStream" As Const IID

Const ATTRIBUTEDSTREAM_S_IO_PENDING As HRESULT = MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0201)

Enum FileAccess
	CreateAccess
	ReadAccess
	UpdateAccess
	DeleteAccess
	TemporaryAccess
End Enum

Type BufferSlice
	pSlice As ZString Ptr
	Length As Integer
End Type

Type IAttributedAsyncStream As IAttributedAsyncStream_

Type IAttributedAsyncStreamVirtualTable

	QueryInterface As Function( _
		ByVal this As IAttributedAsyncStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal this As IAttributedAsyncStream Ptr _
	)As ULONG

	Release As Function( _
		ByVal this As IAttributedAsyncStream Ptr _
	)As ULONG

	BeginReadSlice As Function( _
		ByVal this As IAttributedAsyncStream Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	EndReadSlice As Function( _
		ByVal this As IAttributedAsyncStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT

	GetContentType As Function( _
		ByVal this As IAttributedAsyncStream Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT

	GetEncoding As Function( _
		ByVal this As IAttributedAsyncStream Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT

	GetLanguage As Function( _
		ByVal this As IAttributedAsyncStream Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT

	GetETag As Function( _
		ByVal this As IAttributedAsyncStream Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT

	GetLastFileModifiedDate As Function( _
		ByVal this As IAttributedAsyncStream Ptr, _
		ByVal ppDate As FILETIME Ptr _
	)As HRESULT

	GetLength As Function( _
		ByVal this As IAttributedAsyncStream Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT

	GetPreloadedBytes As Function( _
		ByVal this As IAttributedAsyncStream Ptr, _
		ByVal pPreloadedBytesLength As Integer Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As HRESULT

End Type

Type IAttributedAsyncStream_
	lpVtbl As IAttributedAsyncStreamVirtualTable Ptr
End Type

#define IAttributedAsyncStream_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IAttributedAsyncStream_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IAttributedAsyncStream_Release(this) (this)->lpVtbl->Release(this)
#define IAttributedAsyncStream_BeginReadSlice(this, StartIndex, Length, pcb, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginReadSlice(this, StartIndex, Length, pcb, StateObject, ppIAsyncResult)
#define IAttributedAsyncStream_EndReadSlice(this, pIAsyncResult, pBufferSlice) (this)->lpVtbl->EndReadSlice(this, pIAsyncResult, pBufferSlice)
#define IAttributedAsyncStream_GetContentType(this, ppType) (this)->lpVtbl->GetContentType(this, ppType)
#define IAttributedAsyncStream_GetEncoding(this, ppEncoding) (this)->lpVtbl->GetEncoding(this, ppEncoding)
#define IAttributedAsyncStream_GetLanguage(this, ppLanguage) (this)->lpVtbl->GetLanguage(this, ppLanguage)
#define IAttributedAsyncStream_GetETag(this, ppETag) (this)->lpVtbl->GetETag(this, ppETag)
#define IAttributedAsyncStream_GetLastFileModifiedDate(this, ppDate) (this)->lpVtbl->GetLastFileModifiedDate(this, ppDate)
#define IAttributedAsyncStream_GetLength(this, pLength) (this)->lpVtbl->GetLength(this, pLength)
#define IAttributedAsyncStream_GetPreloadedBytes(this, pPreloadedBytesLength, ppPreloadedBytes) (this)->lpVtbl->GetPreloadedBytes(this, pPreloadedBytesLength, ppPreloadedBytes)

#endif
