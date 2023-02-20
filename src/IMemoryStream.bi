#ifndef IMEMORYSTREAM_BI
#define IMEMORYSTREAM_BI

#include once "IAttributedStream.bi"

Extern IID_IMemoryStream Alias "IID_IMemoryStream" As Const IID

Type IMemoryStream As IMemoryStream_

Type IMemoryStreamVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IMemoryStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IMemoryStream Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IMemoryStream Ptr _
	)As ULONG
	
	BeginGetSlice As Function( _
		ByVal this As IMemoryStream Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndGetSlice As Function( _
		ByVal this As IMemoryStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	
	GetContentType As Function( _
		ByVal this As IMemoryStream Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT
	
	GetEncoding As Function( _
		ByVal this As IMemoryStream Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	
	GetLanguage As Function( _
		ByVal this As IMemoryStream Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT
	
	GetETag As Function( _
		ByVal this As IMemoryStream Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT
	
	GetLastFileModifiedDate As Function( _
		ByVal this As IMemoryStream Ptr, _
		ByVal ppDate As FILETIME Ptr _
	)As HRESULT
	
	GetLength As Function( _
		ByVal this As IMemoryStream Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT
	
	SetContentType As Function( _
		ByVal this As IMemoryStream Ptr, _
		ByVal pType As MimeType Ptr _
	)As HRESULT
	
	AllocBuffer As Function( _
		ByVal this As IMemoryStream Ptr, _
		ByVal Length As LongInt, _
		ByVal ppBuffer As Any Ptr Ptr _
	)As HRESULT
	
	SetBuffer As Function( _
		ByVal this As IMemoryStream Ptr, _
		ByVal pBuffer As Any Ptr, _
		ByVal Length As LongInt _
	)As HRESULT
	
End Type

Type IMemoryStream_
	lpVtbl As IMemoryStreamVirtualTable Ptr
End Type

#define IMemoryStream_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IMemoryStream_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IMemoryStream_Release(this) (this)->lpVtbl->Release(this)
#define IMemoryStream_GetContentType(this, ppType) (this)->lpVtbl->GetContentType(this, ppType)
#define IMemoryStream_GetEncoding(this, ppEncoding) (this)->lpVtbl->GetEncoding(this, ppEncoding)
#define IMemoryStream_GetLanguage(this, ppLanguage) (this)->lpVtbl->GetLanguage(this, ppLanguage)
#define IMemoryStream_GetETag(this, ppETag) (this)->lpVtbl->GetETag(this, ppETag)
#define IMemoryStream_GetLastFileModifiedDate(this, ppDate) (this)->lpVtbl->GetLastFileModifiedDate(this, ppDate)
#define IMemoryStream_GetLength(this, pLength) (this)->lpVtbl->GetLength(this, pLength)
#define IMemoryStream_SetContentType(this, pType) (this)->lpVtbl->SetContentType(this, pType)
#define IMemoryStream_AllocBuffer(this, Length, ppBuffer) (this)->lpVtbl->AllocBuffer(this, Length, ppBuffer)
#define IMemoryStream_SetBuffer(this, pBuffer, Length) (this)->lpVtbl->SetBuffer(this, pBuffer, Length)

#endif
