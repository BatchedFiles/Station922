#ifndef IMEMORYBUFFER_BI
#define IMEMORYBUFFER_BI

#include once "IBuffer.bi"

Type IMemoryBuffer As IMemoryBuffer_

Type LPIMEMORYBUFFER As IMemoryBuffer Ptr

Extern IID_IMemoryBuffer Alias "IID_IMemoryBuffer" As Const IID

Type IMemoryBufferVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IMemoryBuffer Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IMemoryBuffer Ptr _
	)As ULONG
	
	GetContentType As Function( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT
	
	GetEncoding As Function( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	
	GetCharset As Function( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal ppCharset As HeapBSTR Ptr _
	)As HRESULT
	
	GetLanguage As Function( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT
	
	GetETag As Function( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT
	
	GetLastFileModifiedDate As Function( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal ppDate As FILETIME Ptr _
	)As HRESULT
	
	GetLength As Function( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT
	
	GetSlice As Function( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	
	SetContentType As Function( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal pType As MimeType Ptr _
	)As HRESULT
	
	AllocBuffer As Function( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal Length As LongInt, _
		ByVal ppBuffer As Any Ptr Ptr _
	)As HRESULT
	
End Type

Type IMemoryBuffer_
	lpVtbl As IMemoryBufferVirtualTable Ptr
End Type

#define IMemoryBuffer_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IMemoryBuffer_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IMemoryBuffer_Release(this) (this)->lpVtbl->Release(this)
#define IMemoryBuffer_GetContentType(this, ppType) (this)->lpVtbl->GetContentType(this, ppType)
#define IMemoryBuffer_GetEncoding(this, ppEncoding) (this)->lpVtbl->GetEncoding(this, ppEncoding)
#define IMemoryBuffer_GetCharset(this, ppCharset) (this)->lpVtbl->GetCharset(this, ppCharset)
#define IMemoryBuffer_GetLanguage(this, ppLanguage) (this)->lpVtbl->GetLanguage(this, ppLanguage)
#define IMemoryBuffer_GetETag(this, ppETag) (this)->lpVtbl->GetETag(this, ppETag)
#define IMemoryBuffer_GetLastFileModifiedDate(this, ppDate) (this)->lpVtbl->GetLastFileModifiedDate(this, ppDate)
#define IMemoryBuffer_GetLength(this, pLength) (this)->lpVtbl->GetLength(this, pLength)
#define IMemoryBuffer_GetSlice(this, StartIndex, Length, pSlice) (this)->lpVtbl->GetSlice(this, StartIndex, Length, pSlice)
#define IMemoryBuffer_SetContentType(this, pType) (this)->lpVtbl->SetContentType(this, pType)
#define IMemoryBuffer_AllocBuffer(this, Length, ppBuffer) (this)->lpVtbl->AllocBuffer(this, Length, ppBuffer)

#endif
