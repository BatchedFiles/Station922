#ifndef ISENDABLE_BI
#define ISENDABLE_BI

#include once "INetworkStream.bi"

Type ISendable As ISendable_

Type LPISENDABLE As ISendable Ptr

Extern IID_ISendable Alias "IID_ISendable" As Const IID

Type ISendableVirtualTable
	
	QueryInterface As Function( _
		ByVal this As ISendable Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As ISendable Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As ISendable Ptr _
	)As ULONG
	
	Send As Function( _
		ByVal this As ISendable Ptr, _
		ByVal pIStream As INetworkStream Ptr, _
		ByVal pHeader As ZString Ptr, _
		ByVal HeaderLength As DWORD _
	)As HRESULT
	
	BeginSend As Function( _
		ByVal this As ISendable Ptr, _
		ByVal pIStream As INetworkStream Ptr, _
		ByVal pHeader As ZString Ptr, _
		ByVal HeaderLength As DWORD, _
		ByVal callback As AsyncCallback, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndSend As Function( _
		ByVal this As ISendable Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	
End Type

Type ISendable_
	lpVtbl As ISendableVirtualTable Ptr
End Type

#define ISendable_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define ISendable_AddRef(this) (this)->lpVtbl->AddRef(this)
#define ISendable_Release(this) (this)->lpVtbl->Release(this)
#define ISendable_Send(this, pIStream, pHeader, HeaderLength) (this)->lpVtbl->Send(this, pIStream, pHeader, HeaderLength)
#define ISendable_BeginSend(this, pIStream, pHeader, HeaderLength, callback, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginSend(this, pIStream, pHeader, HeaderLength, callback, StateObject, ppIAsyncResult)
#define ISendable_EndSend(this, pIAsyncResult) (this)->lpVtbl->EndSend(this, pIAsyncResult)

#endif
