#ifndef IENUMHTTPPROCESSOR_BI
#define IENUMHTTPPROCESSOR_BI

#include once "IHttpAsyncProcessor.bi"

Type IEnumHttpProcessor As IEnumHttpProcessor_

Type LPIENUMHTTPPROCESSOR As IEnumHttpProcessor Ptr

Extern IID_IEnumHttpProcessor Alias "IID_IEnumHttpProcessor" As Const IID

Type IEnumHttpProcessorVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IEnumHttpProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IEnumHttpProcessor Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IEnumHttpProcessor Ptr _
	)As ULONG
	
	Next As Function( _
		ByVal this As IEnumHttpProcessor Ptr, _
		ByVal celt As ULONG, _
		ByVal rgelt As IHttpAsyncProcessor Ptr Ptr, _
		ByVal pceltFetched As ULONG Ptr _
	)As HRESULT
	
	Skip As Function( _
		ByVal this As IEnumHttpProcessor Ptr, _
		ByVal celt As ULONG _
	)As HRESULT
	
	Reset As Function( _
		ByVal this As IEnumHttpProcessor Ptr _
	)As HRESULT
	
	Clone As Function( _
		ByVal this As IEnumHttpProcessor Ptr, _
		ByVal ppenum As IEnumHttpProcessor Ptr Ptr _
	)As HRESULT
	
End Type

Type IEnumHttpProcessor_
	lpVtbl As IEnumHttpProcessorVirtualTable Ptr
End Type

#define IEnumHttpProcessor_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IEnumHttpProcessor_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IEnumHttpProcessor_Release(this) (this)->lpVtbl->Release(this)

#endif
