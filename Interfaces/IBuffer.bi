#ifndef IBUFFER_BI
#define IBUFFER_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Type BufferSlice
	pSlice As LPVOID
	Length As LongInt
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
	
	GetCapacity As Function( _
		ByVal this As IBuffer Ptr, _
		ByVal pCapacity As LongInt Ptr _
	)As HRESULT
	
	GetLength As Function( _
		ByVal this As IBuffer Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT
	
	GetSlice As Function( _
		ByVal this As IBuffer Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As LongInt, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	
End Type

Type IBuffer_
	lpVtbl As IBufferVirtualTable Ptr
End Type

#define IBuffer_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IBuffer_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IBuffer_Release(this) (this)->lpVtbl->Release(this)
#define IBuffer_GetCapacity(this, pCapacity) (this)->lpVtbl->GetCapacity(this, pCapacity)
#define IBuffer_GetLength(this, pLength) (this)->lpVtbl->GetLength(this, pLength)
#define IBuffer_GetSlice(this, StartIndex, Length, pSlice) (this)->lpVtbl->GetSlice(this, StartIndex, Length, pSlice)

#endif
