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
	Length As UInteger
End Type

Type IAttributedAsyncStream As IAttributedAsyncStream_

Type IAttributedAsyncStreamVirtualTable

	QueryInterface As Function( _
		ByVal self As IAttributedAsyncStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IAttributedAsyncStream Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IAttributedAsyncStream Ptr _
	)As ULONG

	BeginReadSlice As Function( _
		ByVal self As IAttributedAsyncStream Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As LongInt, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	EndReadSlice As Function( _
		ByVal self As IAttributedAsyncStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT

	GetContentType As Function( _
		ByVal self As IAttributedAsyncStream Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT

	GetEncoding As Function( _
		ByVal self As IAttributedAsyncStream Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT

	GetLanguage As Function( _
		ByVal self As IAttributedAsyncStream Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT

	GetETag As Function( _
		ByVal self As IAttributedAsyncStream Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT

	GetLastFileModifiedDate As Function( _
		ByVal self As IAttributedAsyncStream Ptr, _
		ByVal ppDate As FILETIME Ptr _
	)As HRESULT

	GetLength As Function( _
		ByVal self As IAttributedAsyncStream Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT

	GetPreloadedBytes As Function( _
		ByVal self As IAttributedAsyncStream Ptr, _
		ByVal pPreloadedBytesLength As UInteger Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As HRESULT

End Type

Type IAttributedAsyncStream_
	lpVtbl As IAttributedAsyncStreamVirtualTable Ptr
End Type

#define IAttributedAsyncStream_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define IAttributedAsyncStream_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IAttributedAsyncStream_Release(self) (self)->lpVtbl->Release(self)
#define IAttributedAsyncStream_BeginReadSlice(self, StartIndex, Length, pcb, StateObject, ppIAsyncResult) (self)->lpVtbl->BeginReadSlice(self, StartIndex, Length, pcb, StateObject, ppIAsyncResult)
#define IAttributedAsyncStream_EndReadSlice(self, pIAsyncResult, pBufferSlice) (self)->lpVtbl->EndReadSlice(self, pIAsyncResult, pBufferSlice)
#define IAttributedAsyncStream_GetContentType(self, ppType) (self)->lpVtbl->GetContentType(self, ppType)
#define IAttributedAsyncStream_GetEncoding(self, ppEncoding) (self)->lpVtbl->GetEncoding(self, ppEncoding)
#define IAttributedAsyncStream_GetLanguage(self, ppLanguage) (self)->lpVtbl->GetLanguage(self, ppLanguage)
#define IAttributedAsyncStream_GetETag(self, ppETag) (self)->lpVtbl->GetETag(self, ppETag)
#define IAttributedAsyncStream_GetLastFileModifiedDate(self, ppDate) (self)->lpVtbl->GetLastFileModifiedDate(self, ppDate)
#define IAttributedAsyncStream_GetLength(self, pLength) (self)->lpVtbl->GetLength(self, pLength)
#define IAttributedAsyncStream_GetPreloadedBytes(self, pPreloadedBytesLength, ppPreloadedBytes) (self)->lpVtbl->GetPreloadedBytes(self, pPreloadedBytesLength, ppPreloadedBytes)

#endif
