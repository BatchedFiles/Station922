#ifndef IHTTPPROCESSOR_BI
#define IHTTPPROCESSOR_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Type IHttpProcessor As IHttpProcessor_

Type LPIHTTPPROCESSOR As IHttpProcessor Ptr

Extern IID_IHttpProcessor Alias "IID_IHttpProcessor" As Const IID

Type IHttpProcessorVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IHttpProcessor Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IHttpProcessor Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IHttpProcessor Ptr _
	)As ULONG
	
End Type

Type IHttpProcessor_
	lpVtbl As IHttpProcessorVirtualTable Ptr
End Type

#define IHttpProcessor_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IHttpProcessor_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IHttpProcessor_Release(this) (this)->lpVtbl->Release(this)

#endif
