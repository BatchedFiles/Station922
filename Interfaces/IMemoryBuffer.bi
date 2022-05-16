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
	
	GetCapacity As Function( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal pCapacity As LongInt Ptr _
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
#define IMemoryBuffer_GetCapacity(this, pCapacity) (this)->lpVtbl->GetCapacity(this, pCapacity)
#define IMemoryBuffer_GetLength(this, pLength) (this)->lpVtbl->GetLength(this, pLength)
#define IMemoryBuffer_GetSlice(this, StartIndex, Length, pSlice) (this)->lpVtbl->GetSlice(this, StartIndex, Length, pSlice)
#define IMemoryBuffer_AllocBuffer(this, Length, ppBuffer) (this)->lpVtbl->AllocBuffer(this, Length, ppBuffer)

#endif
