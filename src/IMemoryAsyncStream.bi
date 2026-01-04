#ifndef IMEMORYSTREAM_BI
#define IMEMORYSTREAM_BI

#include once "IAttributedAsyncStream.bi"

Extern IID_IMemoryStream Alias "IID_IMemoryStream" As Const IID

Type IMemoryStream As IMemoryStream_

Type IMemoryStreamVirtualTable

	QueryInterface As Function( _
		ByVal self As IMemoryStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IMemoryStream Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IMemoryStream Ptr _
	)As ULONG

	BeginReadSlice As Function( _
		ByVal self As IMemoryStream Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	EndReadSlice As Function( _
		ByVal self As IMemoryStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT

	GetContentType As Function( _
		ByVal self As IMemoryStream Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT

	GetEncoding As Function( _
		ByVal self As IMemoryStream Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT

	GetLanguage As Function( _
		ByVal self As IMemoryStream Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT

	GetETag As Function( _
		ByVal self As IMemoryStream Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT

	GetLastFileModifiedDate As Function( _
		ByVal self As IMemoryStream Ptr, _
		ByVal ppDate As FILETIME Ptr _
	)As HRESULT

	GetLength As Function( _
		ByVal self As IMemoryStream Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT

	GetPreloadedBytes As Function( _
		ByVal self As IMemoryStream Ptr, _
		ByVal pPreloadedBytesLength As Integer Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As HRESULT

	SetContentType As Function( _
		ByVal self As IMemoryStream Ptr, _
		ByVal pType As MimeType Ptr _
	)As HRESULT

	AllocBuffer As Function( _
		ByVal self As IMemoryStream Ptr, _
		ByVal Length As LongInt, _
		ByVal ppBuffer As Any Ptr Ptr _
	)As HRESULT

	SetBuffer As Function( _
		ByVal self As IMemoryStream Ptr, _
		ByVal pBuffer As Any Ptr, _
		ByVal Length As LongInt _
	)As HRESULT

End Type

Type IMemoryStream_
	lpVtbl As IMemoryStreamVirtualTable Ptr
End Type

#define IMemoryStream_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define IMemoryStream_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IMemoryStream_Release(self) (self)->lpVtbl->Release(self)
#define IMemoryStream_BeginReadSlice(self, StartIndex, Length, pcb, StateObject, ppIAsyncResult) (self)->lpVtbl->BeginReadSlice(self, StartIndex, Length, pcb, StateObject, ppIAsyncResult)
#define IMemoryStream_GetContentType(self, ppType) (self)->lpVtbl->GetContentType(self, ppType)
#define IMemoryStream_GetEncoding(self, ppEncoding) (self)->lpVtbl->GetEncoding(self, ppEncoding)
#define IMemoryStream_GetLanguage(self, ppLanguage) (self)->lpVtbl->GetLanguage(self, ppLanguage)
#define IMemoryStream_GetETag(self, ppETag) (self)->lpVtbl->GetETag(self, ppETag)
#define IMemoryStream_GetLastFileModifiedDate(self, ppDate) (self)->lpVtbl->GetLastFileModifiedDate(self, ppDate)
#define IMemoryStream_GetLength(self, pLength) (self)->lpVtbl->GetLength(self, pLength)
#define IMemoryStream_GetPreloadedBytes(self, pPreloadedBytesLength, ppPreloadedBytes) (self)->lpVtbl->GetPreloadedBytes(self, pPreloadedBytesLength, ppPreloadedBytes)
#define IMemoryStream_SetContentType(self, pType) (self)->lpVtbl->SetContentType(self, pType)
#define IMemoryStream_AllocBuffer(self, Length, ppBuffer) (self)->lpVtbl->AllocBuffer(self, Length, ppBuffer)
#define IMemoryStream_SetBuffer(self, pBuffer, Length) (self)->lpVtbl->SetBuffer(self, pBuffer, Length)

#endif
