#ifndef IBUFFER_BI
#define IBUFFER_BI

#include once "IString.bi"
#include once "Mime.bi"

Type BufferSlice
	pSlice As LPVOID
	Length As DWORD
End Type

Type IBuffer As IBuffer_

Type LPIBUFFER As IBuffer Ptr

Extern IID_IBuffer Alias "IID_IBuffer" As Const IID

Type IBufferVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IBuffer Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IBuffer Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IBuffer Ptr _
	)As ULONG
	
	GetContentType As Function( _
		ByVal this As IBuffer Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT
	
	GetEncoding As Function( _
		ByVal this As IBuffer Ptr, _
		ByVal ppEncoding As HeapBSTR Ptr _
	)As HRESULT
	
	GetCharset As Function( _
		ByVal this As IBuffer Ptr, _
		ByVal ppCharset As HeapBSTR Ptr _
	)As HRESULT
	
	GetLanguage As Function( _
		ByVal this As IBuffer Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT
	
	GetETag As Function( _
		ByVal this As IBuffer Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT
	
	GetLastFileModifiedDate As Function( _
		ByVal this As IBuffer Ptr, _
		ByVal ppDate As FILETIME Ptr _
	)As HRESULT
	
	GetLength As Function( _
		ByVal this As IBuffer Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT
	
	GetSlice As Function( _
		ByVal this As IBuffer Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	
End Type

Type IBuffer_
	lpVtbl As IBufferVirtualTable Ptr
End Type

#define IBuffer_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IBuffer_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IBuffer_Release(this) (this)->lpVtbl->Release(this)
#define IBuffer_GetContentType(this, ppType) (this)->lpVtbl->GetContentType(this, ppType)
#define IBuffer_GetEncoding(this, ppEncoding) (this)->lpVtbl->GetEncoding(this, ppEncoding)
#define IBuffer_GetCharset(this, ppCharset) (this)->lpVtbl->GetCharset(this, ppCharset)
#define IBuffer_GetLanguage(this, ppLanguage) (this)->lpVtbl->GetLanguage(this, ppLanguage)
#define IBuffer_GetETag(this, ppETag) (this)->lpVtbl->GetETag(this, ppETag)
#define IBuffer_GetLastFileModifiedDate(this, ppDate) (this)->lpVtbl->GetLastFileModifiedDate(this, ppDate)
#define IBuffer_GetLength(this, pLength) (this)->lpVtbl->GetLength(this, pLength)
#define IBuffer_GetSlice(this, StartIndex, Length, pSlice) (this)->lpVtbl->GetSlice(this, StartIndex, Length, pSlice)

#endif
